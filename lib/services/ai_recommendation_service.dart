
import '../models/auction_item.dart';
import '../models/recommendation.dart';
import './supabase_service.dart';

class AIRecommendationService {
  final _client = SupabaseService.instance.client;

  /// Get personalized recommendations based on discovery mode
  Future<List<Recommendation>> getPersonalizedRecommendations(
      String discoveryMode) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get user preferences first
      final userPrefs = await getUserPreferences();

      List<dynamic> results;

      switch (discoveryMode) {
        case 'similar_to_watched':
          results =
              await _getSimilarToWatchedRecommendations(userId, userPrefs);
          break;
        case 'trending_now':
          results = await _getTrendingRecommendations();
          break;
        case 'ending_soon':
          results = await _getEndingSoonRecommendations(userPrefs);
          break;
        case 'new_sellers':
          results = await _getNewSellerRecommendations(userPrefs);
          break;
        default:
          results = await _getGeneralRecommendations(userId, userPrefs);
      }

      // Generate AI model scores for recommendations
      final recommendations = <Recommendation>[];
      for (final item in results) {
        final auctionItem = AuctionItem.fromMap(item);
        final recommendation = await _generateRecommendation(
          auctionItem,
          discoveryMode,
          userPrefs,
        );
        recommendations.add(recommendation);
      }

      // Sort by confidence score
      recommendations
          .sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));

      // Store recommendation history
      await _storeRecommendationHistory(recommendations);

      return recommendations.take(20).toList(); // Limit to top 20
    } catch (e) {
      throw Exception(
          'Failed to get personalized recommendations: ${e.toString()}');
    }
  }

  /// Get user preferences from database
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // Create default preferences
        final defaultPrefs = {
          'user_id': userId,
          'category_preferences': <String, String>{},
          'price_range_min': 0,
          'price_range_max': 1000000,
          'preferred_times': <String>[],
          'seller_preferences': <String, dynamic>{},
          'notification_settings': <String, bool>{
            'new_recommendations': true,
            'price_drops': true,
            'ending_soon': true,
          },
          'recommendation_frequency': 'medium',
          'discovery_mode_enabled': true,
        };

        await _client.from('user_preferences').insert(defaultPrefs);
        return defaultPrefs;
      }

      return response;
    } catch (e) {
      throw Exception('Failed to get user preferences: ${e.toString()}');
    }
  }

  /// Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      preferences['updated_at'] = DateTime.now().toIso8601String();

      await _client
          .from('user_preferences')
          .update(preferences)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to update user preferences: ${e.toString()}');
    }
  }

  /// Track user interaction with recommendations
  Future<void> trackInteraction(
    String auctionItemId,
    String interactionType,
    Map<String, dynamic> context,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('user_interactions').insert({
        'user_id': userId,
        'auction_item_id': auctionItemId,
        'interaction_type': interactionType,
        'interaction_context': context,
      });

      // Update recommendation history if this was a click
      if (interactionType == 'click' && context['recommendation_id'] != null) {
        await _client.from('recommendation_history').update({
          'is_clicked': true,
          'clicked_at': DateTime.now().toIso8601String(),
        }).eq('id', context['recommendation_id']);
      }
    } catch (e) {
      throw Exception('Failed to track interaction: ${e.toString()}');
    }
  }

  /// Submit feedback on recommendations
  Future<void> submitRecommendationFeedback(
    String recommendationId,
    String feedbackType,
    String? reason,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('recommendation_feedback').insert({
        'user_id': userId,
        'recommendation_id': recommendationId,
        'feedback_type': feedbackType,
        'feedback_reason': reason,
      });
    } catch (e) {
      throw Exception(
          'Failed to submit recommendation feedback: ${e.toString()}');
    }
  }

  /// Get recommendations similar to watched items
  Future<List<dynamic>> _getSimilarToWatchedRecommendations(
    String userId,
    Map<String, dynamic> userPrefs,
  ) async {
    // Get user's interaction history
    final interactions = await _client
        .from('user_interactions')
        .select('auction_item_id')
        .eq('user_id', userId)
        .inFilter('interaction_type', ['view', 'watchlist_add', 'bid'])
        .order('created_at', ascending: false)
        .limit(10);

    if (interactions.isEmpty) {
      return _getGeneralRecommendations(userId, userPrefs);
    }

    final watchedItemIds =
        interactions.map((i) => i['auction_item_id']).toList();

    // Get categories and brands from watched items
    final watchedItems = await _client
        .from('auction_items')
        .select('category_id, brand')
        .inFilter('id', watchedItemIds);

    final categoryIds = watchedItems
        .where((item) => item['category_id'] != null)
        .map((item) => item['category_id'])
        .toSet()
        .toList();

    final brands = watchedItems
        .where((item) => item['brand'] != null)
        .map((item) => item['brand'])
        .toSet()
        .toList();

    // Find similar items
    var query = _client
        .from('auction_items')
        .select('*, categories!inner(*)')
        .eq('status', 'live')
        .not('id', 'in', watchedItemIds);

    if (categoryIds.isNotEmpty) {
      query = query.inFilter('category_id', categoryIds);
    }

    return await query.order('view_count', ascending: false).limit(50);
  }

  /// Get trending recommendations
  Future<List<dynamic>> _getTrendingRecommendations() async {
    return await _client
        .from('auction_items')
        .select('*, categories(*)')
        .eq('status', 'live')
        .gte('created_at',
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
        .order('view_count', ascending: false)
        .order('current_highest_bid', ascending: false)
        .limit(50);
  }

  /// Get ending soon recommendations
  Future<List<dynamic>> _getEndingSoonRecommendations(
      Map<String, dynamic> userPrefs) async {
    final now = DateTime.now();
    final endingSoon = now.add(const Duration(hours: 24));

    var query = _client
        .from('auction_items')
        .select('*, categories(*)')
        .eq('status', 'live')
        .gte('end_time', now.toIso8601String())
        .lte('end_time', endingSoon.toIso8601String());

    // Apply price filter if preferences exist
    if (userPrefs['price_range_min'] != null) {
      query = query.gte('current_highest_bid', userPrefs['price_range_min']);
    }
    if (userPrefs['price_range_max'] != null) {
      query = query.lte('current_highest_bid', userPrefs['price_range_max']);
    }

    return await query.order('end_time', ascending: true).limit(50);
  }

  /// Get new seller recommendations
  Future<List<dynamic>> _getNewSellerRecommendations(
      Map<String, dynamic> userPrefs) async {
    // Get sellers who joined in the last 30 days
    final recentDate = DateTime.now().subtract(const Duration(days: 30));

    return await _client
        .from('auction_items')
        .select('*, categories(*), user_profiles!inner(*)')
        .eq('status', 'live')
        .gte('user_profiles.created_at', recentDate.toIso8601String())
        .order('user_profiles.created_at', ascending: false)
        .limit(50);
  }

  /// Get general recommendations
  Future<List<dynamic>> _getGeneralRecommendations(
    String userId,
    Map<String, dynamic> userPrefs,
  ) async {
    var query = _client
        .from('auction_items')
        .select('*, categories(*)')
        .eq('status', 'live');

    // Apply price filter
    if (userPrefs['price_range_min'] != null) {
      query = query.gte('current_highest_bid', userPrefs['price_range_min']);
    }
    if (userPrefs['price_range_max'] != null) {
      query = query.lte('current_highest_bid', userPrefs['price_range_max']);
    }

    return await query
        .eq('featured', true)
        .order('created_at', ascending: false)
        .limit(50);
  }

  /// Generate recommendation with AI scoring
  Future<Recommendation> _generateRecommendation(
    AuctionItem auctionItem,
    String recommendationType,
    Map<String, dynamic> userPrefs,
  ) async {
    final userId = _client.auth.currentUser?.id;

    // Calculate various scores
    final categoryScore = await _calculateCategoryScore(auctionItem, userPrefs);
    final priceScore = _calculatePriceScore(auctionItem, userPrefs);
    final trendingScore = _calculateTrendingScore(auctionItem);
    final urgencyScore = _calculateUrgencyScore(auctionItem);
    final similarityScore =
        await _calculateSimilarityScore(auctionItem, userId!);

    // Calculate final recommendation score
    final finalScore = (categoryScore * 0.3 +
        priceScore * 0.2 +
        trendingScore * 0.2 +
        urgencyScore * 0.1 +
        similarityScore * 0.2);

    // Store AI model scores
    await _storeAIModelScores(userId, auctionItem, {
      'similarity_score': similarityScore,
      'category_match_score': categoryScore,
      'price_preference_score': priceScore,
      'trending_score': trendingScore,
      'urgency_score': urgencyScore,
      'final_recommendation_score': finalScore,
    });

    // Build reasoning
    final reasoning = _buildReasoning(
      auctionItem,
      categoryScore,
      priceScore,
      similarityScore,
      userPrefs,
    );

    return Recommendation(
      id: '', // Will be set when stored
      auctionItem: auctionItem,
      type: recommendationType,
      confidenceScore: finalScore,
      reasoning: reasoning,
      generatedAt: DateTime.now(),
    );
  }

  /// Calculate category preference score
  Future<double> _calculateCategoryScore(
    AuctionItem auctionItem,
    Map<String, dynamic> userPrefs,
  ) async {
    try {
      if (auctionItem.categoryId == null) return 0.5;

      final category = await _client
          .from('categories')
          .select('name')
          .eq('id', auctionItem.categoryId!)
          .single();

      final categoryPrefs =
          userPrefs['category_preferences'] as Map<String, dynamic>? ?? {};
      final categoryName =
          category['name']?.toString().toLowerCase().replaceAll(' ', '_') ?? '';
      final preference = categoryPrefs[categoryName] ?? 'medium';

      switch (preference) {
        case 'critical':
          return 1.0;
        case 'high':
          return 0.8;
        case 'medium':
          return 0.6;
        case 'low':
          return 0.3;
        default:
          return 0.5;
      }
    } catch (e) {
      return 0.5;
    }
  }

  /// Calculate price preference score
  double _calculatePriceScore(
      AuctionItem auctionItem, Map<String, dynamic> userPrefs) {
    final minPrice = userPrefs['price_range_min'] as int? ?? 0;
    final maxPrice = userPrefs['price_range_max'] as int? ?? 1000000;
    final currentBid = auctionItem.currentHighestBid;

    if (currentBid >= minPrice && currentBid <= maxPrice) {
      // Perfect fit
      return 1.0;
    } else if (currentBid < minPrice) {
      // Below preferred range
      final diff = minPrice - currentBid;
      return (1.0 - (diff / minPrice)).clamp(0.0, 1.0);
    } else {
      // Above preferred range
      final diff = currentBid - maxPrice;
      return (1.0 - (diff / maxPrice)).clamp(0.0, 1.0);
    }
  }

  /// Calculate trending score
  double _calculateTrendingScore(AuctionItem auctionItem) {
    final viewCount = auctionItem.viewCount;
    final maxViews = 1000; // Normalize against expected max views
    return (viewCount / maxViews).clamp(0.0, 1.0);
  }

  /// Calculate urgency score based on time remaining
  double _calculateUrgencyScore(AuctionItem auctionItem) {
    final now = DateTime.now();
    final timeRemaining = auctionItem.endTime.difference(now);

    if (timeRemaining.isNegative) return 0.0;

    final hours = timeRemaining.inHours;
    if (hours <= 1) return 1.0;
    if (hours <= 6) return 0.8;
    if (hours <= 24) return 0.6;
    if (hours <= 72) return 0.4;
    return 0.2;
  }

  /// Calculate similarity score based on user interactions
  Future<double> _calculateSimilarityScore(
      AuctionItem auctionItem, String userId) async {
    try {
      // Get user's interaction patterns
      final interactions = await _client
          .from('user_interactions')
          .select('auction_item_id, interaction_type')
          .eq('user_id', userId)
          .limit(50);

      if (interactions.isEmpty) return 0.5;

      // Get auction items user has interacted with
      final interactedItemIds =
          interactions.map((i) => i['auction_item_id']).toSet().toList();

      final interactedItems = await _client
          .from('auction_items')
          .select('category_id, brand')
          .inFilter('id', interactedItemIds);

      // Calculate similarity based on category and brand matches
      double categoryMatches = 0;
      double brandMatches = 0;

      for (final item in interactedItems) {
        if (item['category_id'] == auctionItem.categoryId) {
          categoryMatches++;
        }
        if (item['brand'] == auctionItem.brand) {
          brandMatches++;
        }
      }

      final totalItems = interactedItems.length;
      if (totalItems == 0) return 0.5;

      final categoryScore = categoryMatches / totalItems;
      final brandScore = brandMatches / totalItems;

      return (categoryScore * 0.7 + brandScore * 0.3).clamp(0.0, 1.0);
    } catch (e) {
      return 0.5;
    }
  }

  /// Store AI model scores in database
  Future<void> _storeAIModelScores(
    String userId,
    AuctionItem auctionItem,
    Map<String, double> scores,
  ) async {
    try {
      await _client.from('ai_model_scores').insert({
        'user_id': userId,
        'auction_item_id': auctionItem.id,
        ...scores,
      });
    } catch (e) {
      // Log error but don't fail the recommendation
      print('Failed to store AI model scores: $e');
    }
  }

  /// Build reasoning explanation
  Map<String, dynamic> _buildReasoning(
    AuctionItem auctionItem,
    double categoryScore,
    double priceScore,
    double similarityScore,
    Map<String, dynamic> userPrefs,
  ) {
    final reasoning = <String, dynamic>{};

    if (categoryScore > 0.7) {
      reasoning['category_match'] = 'Matches your preferred categories';
    }

    if (priceScore > 0.8) {
      reasoning['price_fit'] = 'Within your preferred price range';
    }

    if (similarityScore > 0.6) {
      reasoning['similar_items_viewed'] = 'Similar to items you\'ve viewed';
    }

    if (auctionItem.viewCount > 100) {
      reasoning['popular'] = 'Popular item with high interest';
    }

    final timeRemaining = auctionItem.endTime.difference(DateTime.now());
    if (timeRemaining.inHours <= 24) {
      reasoning['urgency'] = 'Ending soon - last chance to bid';
    }

    return reasoning;
  }

  /// Store recommendation history
  Future<void> _storeRecommendationHistory(
      List<Recommendation> recommendations) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final historyData = recommendations
          .map((rec) => {
                'user_id': userId,
                'auction_item_id': rec.auctionItem.id,
                'recommendation_type': rec.type,
                'confidence_score': rec.confidenceScore,
                'reasoning': rec.reasoning,
              })
          .toList();

      await _client.from('recommendation_history').insert(historyData);
    } catch (e) {
      // Log error but don't fail
      print('Failed to store recommendation history: $e');
    }
  }
}
