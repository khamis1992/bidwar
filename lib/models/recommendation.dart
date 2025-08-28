import 'package:equatable/equatable.dart';

import './auction_item.dart';

class Recommendation extends Equatable {
  final String id;
  final AuctionItem auctionItem;
  final String type;
  final double confidenceScore;
  final Map<String, dynamic> reasoning;
  final DateTime generatedAt;
  final bool isClicked;
  final bool isSuccessful;

  const Recommendation({
    required this.id,
    required this.auctionItem,
    required this.type,
    required this.confidenceScore,
    required this.reasoning,
    required this.generatedAt,
    this.isClicked = false,
    this.isSuccessful = false,
  });

  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      id: map['id'] ?? '',
      auctionItem: AuctionItem.fromMap(map['auction_items'] ?? map),
      type: map['recommendation_type'] ?? 'general',
      confidenceScore: (map['confidence_score'] as num?)?.toDouble() ?? 0.0,
      reasoning: Map<String, dynamic>.from(map['reasoning'] ?? {}),
      generatedAt: DateTime.parse(
          map['generated_at'] ?? DateTime.now().toIso8601String()),
      isClicked: map['is_clicked'] ?? false,
      isSuccessful: map['is_successful'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auction_item': auctionItem.toMap(),
      'recommendation_type': type,
      'confidence_score': confidenceScore,
      'reasoning': reasoning,
      'generated_at': generatedAt.toIso8601String(),
      'is_clicked': isClicked,
      'is_successful': isSuccessful,
    };
  }

  Recommendation copyWith({
    String? id,
    AuctionItem? auctionItem,
    String? type,
    double? confidenceScore,
    Map<String, dynamic>? reasoning,
    DateTime? generatedAt,
    bool? isClicked,
    bool? isSuccessful,
  }) {
    return Recommendation(
      id: id ?? this.id,
      auctionItem: auctionItem ?? this.auctionItem,
      type: type ?? this.type,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      reasoning: reasoning ?? this.reasoning,
      generatedAt: generatedAt ?? this.generatedAt,
      isClicked: isClicked ?? this.isClicked,
      isSuccessful: isSuccessful ?? this.isSuccessful,
    );
  }

  @override
  List<Object?> get props => [
        id,
        auctionItem,
        type,
        confidenceScore,
        reasoning,
        generatedAt,
        isClicked,
        isSuccessful,
      ];

  @override
  String toString() {
    return 'Recommendation{id: $id, type: $type, confidenceScore: $confidenceScore, auctionItem: ${auctionItem.title}}';
  }

  /// Get recommendation type display name
  String get typeDisplayName {
    switch (type) {
      case 'similar_to_watched':
        return 'Similar to Watched';
      case 'trending_now':
        return 'Trending Now';
      case 'ending_soon':
        return 'Ending Soon';
      case 'new_sellers':
        return 'New Sellers';
      case 'category_based':
        return 'Category Based';
      case 'price_based':
        return 'Price Based';
      case 'collaborative_filtering':
        return 'Users Like You';
      default:
        return 'Recommended';
    }
  }

  /// Get confidence level description
  String get confidenceLevelDescription {
    if (confidenceScore >= 0.9) {
      return 'Excellent Match';
    } else if (confidenceScore >= 0.8) {
      return 'Very Good Match';
    } else if (confidenceScore >= 0.7) {
      return 'Good Match';
    } else if (confidenceScore >= 0.6) {
      return 'Fair Match';
    } else {
      return 'Potential Interest';
    }
  }

  /// Get primary reasoning text
  String get primaryReason {
    if (reasoning.containsKey('category_match')) {
      return reasoning['category_match'];
    } else if (reasoning.containsKey('similar_items_viewed')) {
      return reasoning['similar_items_viewed'];
    } else if (reasoning.containsKey('price_fit')) {
      return reasoning['price_fit'];
    } else if (reasoning.containsKey('popular')) {
      return reasoning['popular'];
    } else if (reasoning.containsKey('urgency')) {
      return reasoning['urgency'];
    } else {
      return 'Recommended based on your activity';
    }
  }

  /// Check if this is a high-confidence recommendation
  bool get isHighConfidence => confidenceScore >= 0.8;

  /// Check if this is an urgent recommendation (ending soon)
  bool get isUrgent {
    final timeRemaining = auctionItem.endTime.difference(DateTime.now());
    return timeRemaining.inHours <= 24 && timeRemaining.inMinutes > 0;
  }

  /// Get recommendation priority score (for sorting)
  double get priorityScore {
    double priority = confidenceScore;

    // Boost urgent items
    if (isUrgent) priority += 0.1;

    // Boost trending items
    if (type == 'trending_now') priority += 0.05;

    // Boost high-value items within user's range
    if (auctionItem.currentHighestBid >= 10000) priority += 0.02;

    return priority.clamp(0.0, 1.0);
  }
}
