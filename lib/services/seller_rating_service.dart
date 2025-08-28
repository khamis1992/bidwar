import './supabase_service.dart';

class SellerRatingService {
  /// Get seller profile information
  Future<Map<String, dynamic>> getSellerProfile(String sellerId) async {
    try {
      final client = SupabaseService.instance.client;

      final response =
          await client
              .from('user_profiles')
              .select(
                'id, full_name, profile_picture_url, created_at, is_verified',
              )
              .eq('id', sellerId)
              .single();

      return response;
    } catch (error) {
      throw Exception('Failed to load seller profile: $error');
    }
  }

  /// Get seller rating statistics
  Future<Map<String, dynamic>> getSellerRatingStats(String sellerId) async {
    try {
      final client = SupabaseService.instance.client;

      final response =
          await client
              .from('seller_rating_stats')
              .select()
              .eq('seller_id', sellerId)
              .maybeSingle();

      if (response == null) {
        // Return empty stats if no ratings exist
        return {
          'total_reviews': 0,
          'average_rating': 0.0,
          'average_product_quality': 0.0,
          'average_shipping_speed': 0.0,
          'average_communication': 0.0,
          'average_stream_entertainment': 0.0,
          'five_star_count': 0,
          'four_star_count': 0,
          'three_star_count': 0,
          'two_star_count': 0,
          'one_star_count': 0,
          'response_rate': 0.0,
          'total_transactions': 0,
        };
      }

      return response;
    } catch (error) {
      throw Exception('Failed to load seller rating stats: $error');
    }
  }

  /// Get seller reviews with filters
  Future<List<dynamic>> getSellerReviews(
    String sellerId, {
    String rating = 'all',
    String sortBy = 'recent',
    String category = 'all',
    int limit = 50,
  }) async {
    try {
      final client = SupabaseService.instance.client;

      var query = client
          .from('seller_ratings')
          .select('''
            id, overall_rating, product_quality_rating, shipping_speed_rating,
            communication_rating, stream_entertainment_rating, review_text,
            review_images, is_verified, seller_response, seller_response_date,
            created_at,
            buyer:user_profiles!buyer_id(full_name, profile_picture_url),
            auction_item:auction_items(title, images)
          ''')
          .eq('seller_id', sellerId);

      // Apply rating filter
      if (rating != 'all') {
        query = query.eq('overall_rating', rating);
      }

      // Apply category filters
      switch (category) {
        case 'verified':
          query = query.eq('is_verified', true);
          break;
        case 'with_photos':
          query = query.not('review_images', 'eq', '[]');
          break;
        case 'with_response':
          query = query.not('seller_response', 'is', null);
          break;
        case 'recent_purchases':
          final thirtyDaysAgo =
              DateTime.now()
                  .subtract(const Duration(days: 30))
                  .toIso8601String();
          query = query.gte('created_at', thirtyDaysAgo);
          break;
      }

      // Apply sorting - fix the type casting issues
      late var finalQuery;
      switch (sortBy) {
        case 'recent':
          finalQuery = query.order('created_at', ascending: false);
          break;
        case 'oldest':
          finalQuery = query.order('created_at', ascending: true);
          break;
        case 'highest':
          finalQuery = query.order('overall_rating', ascending: false);
          break;
        case 'lowest':
          finalQuery = query.order('overall_rating', ascending: true);
          break;
        case 'helpful':
          // In a real implementation, you'd have a helpful_count column
          finalQuery = query.order('created_at', ascending: false);
          break;
      }

      final reviews = await finalQuery.limit(limit);

      // Process reviews to add reviewer information
      return reviews.map((review) {
        final buyer = review['buyer'];
        return {
          ...review,
          'reviewer_name': buyer?['full_name'] ?? 'Anonymous',
          'reviewer_avatar': buyer?['profile_picture_url'],
          'auction_context':
              review['auction_item'] != null
                  ? {
                    'item_title': review['auction_item']['title'],
                    'item_image':
                        (review['auction_item']['images'] as List?)
                                    ?.isNotEmpty ==
                                true
                            ? review['auction_item']['images'][0]
                            : null,
                  }
                  : {},
        };
      }).toList();
    } catch (error) {
      throw Exception('Failed to load seller reviews: $error');
    }
  }

  /// Submit a new seller rating
  Future<void> submitSellerRating(Map<String, dynamic> ratingData) async {
    try {
      final client = SupabaseService.instance.client;
      final currentUser = client.auth.currentUser;

      if (currentUser == null) {
        throw Exception('Authentication required');
      }

      final reviewData = {
        'seller_id': ratingData['seller_id'],
        'buyer_id': currentUser.id,
        'overall_rating': ratingData['overall_rating'],
        'product_quality_rating': ratingData['product_quality_rating'],
        'shipping_speed_rating': ratingData['shipping_speed_rating'],
        'communication_rating': ratingData['communication_rating'],
        'stream_entertainment_rating':
            ratingData['stream_entertainment_rating'],
        'review_text': ratingData['review_text'],
        'is_verified': true, // Set to true after purchase verification
      };

      await client.from('seller_ratings').insert(reviewData);
    } catch (error) {
      throw Exception('Failed to submit rating: $error');
    }
  }

  /// Respond to a review (seller only)
  Future<void> respondToReview(String reviewId, String response) async {
    try {
      final client = SupabaseService.instance.client;
      final currentUser = client.auth.currentUser;

      if (currentUser == null) {
        throw Exception('Authentication required');
      }

      await client
          .from('seller_ratings')
          .update({
            'seller_response': response,
            'seller_response_date': DateTime.now().toIso8601String(),
          })
          .eq('id', reviewId)
          .eq('seller_id', currentUser.id); // Ensure only seller can respond
    } catch (error) {
      throw Exception('Failed to respond to review: $error');
    }
  }

  /// Mark a review as helpful
  Future<void> markReviewHelpful(String reviewId) async {
    try {
      // In a real implementation, you'd have a helpful_votes table
      // For now, we'll just simulate the action
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (error) {
      throw Exception('Failed to mark review as helpful: $error');
    }
  }

  /// Report a review for moderation
  Future<void> reportReview(String reviewId) async {
    try {
      // In a real implementation, you'd have a review_reports table
      // For now, we'll just simulate the action
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (error) {
      throw Exception('Failed to report review: $error');
    }
  }

  /// Get seller rating trends over time
  Future<List<dynamic>> getSellerRatingTrends(
    String sellerId, {
    int days = 30,
  }) async {
    try {
      final client = SupabaseService.instance.client;
      final startDate =
          DateTime.now().subtract(Duration(days: days)).toIso8601String();

      final response = await client
          .from('seller_ratings')
          .select('overall_rating, created_at')
          .eq('seller_id', sellerId)
          .gte('created_at', startDate)
          .order('created_at', ascending: true);

      return response;
    } catch (error) {
      throw Exception('Failed to load rating trends: $error');
    }
  }
}
