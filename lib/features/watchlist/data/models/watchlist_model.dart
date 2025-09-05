import '../../domain/entities/watchlist_entity.dart';

/// Watchlist Model for Data Layer
///
/// يحول البيانات من/إلى قاعدة البيانات
/// يطبق نمط DTO/Entity mapping وفقاً لقواعد BidWar
class WatchlistModel extends WatchlistEntity {
  const WatchlistModel({
    required super.id,
    required super.userId,
    required super.auctionItemId,
    required super.createdAt,
    super.auctionItem,
    super.user,
  });

  /// إنشاء WatchlistModel من Map (من قاعدة البيانات)
  factory WatchlistModel.fromMap(Map<String, dynamic> map) {
    return WatchlistModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      auctionItemId: map['auction_item_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      auctionItem: map['auction_item'] as Map<String, dynamic>?,
      user: map['user'] as Map<String, dynamic>?,
    );
  }

  /// تحويل WatchlistModel إلى Map (لقاعدة البيانات)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'auction_item_id': auctionItemId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// تحويل إلى Map للإنشاء (بدون ID وtimestamp)
  Map<String, dynamic> toCreateMap() {
    return {'user_id': userId, 'auction_item_id': auctionItemId};
  }

  /// تحويل WatchlistEntity إلى WatchlistModel
  factory WatchlistModel.fromEntity(WatchlistEntity entity) {
    return WatchlistModel(
      id: entity.id,
      userId: entity.userId,
      auctionItemId: entity.auctionItemId,
      createdAt: entity.createdAt,
      auctionItem: entity.auctionItem,
      user: entity.user,
    );
  }

  /// نسخ مع تحديث بعض الحقول
  WatchlistModel copyWith({
    String? id,
    String? userId,
    String? auctionItemId,
    DateTime? createdAt,
    Map<String, dynamic>? auctionItem,
    Map<String, dynamic>? user,
  }) {
    return WatchlistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      auctionItemId: auctionItemId ?? this.auctionItemId,
      createdAt: createdAt ?? this.createdAt,
      auctionItem: auctionItem ?? this.auctionItem,
      user: user ?? this.user,
    );
  }

  @override
  String toString() => 'WatchlistModel(id: $id, auctionTitle: $auctionTitle)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WatchlistModel &&
        other.id == id &&
        other.userId == userId &&
        other.auctionItemId == auctionItemId;
  }

  @override
  int get hashCode => Object.hash(id, userId, auctionItemId);
}
