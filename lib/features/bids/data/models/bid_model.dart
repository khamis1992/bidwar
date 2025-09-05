import '../../domain/entities/bid_entity.dart';

/// Bid Model for Data Layer
///
/// يحول البيانات من/إلى قاعدة البيانات
/// يطبق نمط DTO/Entity mapping وفقاً لقواعد BidWar
class BidModel extends BidEntity {
  const BidModel({
    required super.id,
    required super.auctionItemId,
    required super.bidderId,
    required super.bidAmount,
    required super.status,
    required super.isAutoBid,
    super.maxAutoBid,
    required super.placedAt,
    super.bidder,
    super.auctionItem,
  });

  /// إنشاء BidModel من Map (من قاعدة البيانات)
  factory BidModel.fromMap(Map<String, dynamic> map) {
    return BidModel(
      id: map['id'] as String,
      auctionItemId: map['auction_item_id'] as String,
      bidderId: map['bidder_id'] as String,
      bidAmount: map['bid_amount'] as int,
      status: _mapStatus(map['status'] as String?),
      isAutoBid: map['is_auto_bid'] as bool? ?? false,
      maxAutoBid: map['max_auto_bid'] as int?,
      placedAt: DateTime.parse(map['placed_at'] as String),
      bidder: map['bidder'] as Map<String, dynamic>?,
      auctionItem: map['auction_item'] as Map<String, dynamic>?,
    );
  }

  /// تحويل BidModel إلى Map (لقاعدة البيانات)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auction_item_id': auctionItemId,
      'bidder_id': bidderId,
      'bid_amount': bidAmount,
      'status': status.name,
      'is_auto_bid': isAutoBid,
      'max_auto_bid': maxAutoBid,
      'placed_at': placedAt.toIso8601String(),
    };
  }

  /// تحويل إلى Map للإنشاء (بدون ID وtimestamp)
  Map<String, dynamic> toCreateMap() {
    return {
      'auction_item_id': auctionItemId,
      'bidder_id': bidderId,
      'bid_amount': bidAmount,
      'is_auto_bid': isAutoBid,
      'max_auto_bid': maxAutoBid,
    };
  }

  /// تحويل BidEntity إلى BidModel
  factory BidModel.fromEntity(BidEntity entity) {
    return BidModel(
      id: entity.id,
      auctionItemId: entity.auctionItemId,
      bidderId: entity.bidderId,
      bidAmount: entity.bidAmount,
      status: entity.status,
      isAutoBid: entity.isAutoBid,
      maxAutoBid: entity.maxAutoBid,
      placedAt: entity.placedAt,
      bidder: entity.bidder,
      auctionItem: entity.auctionItem,
    );
  }

  /// نسخ مع تحديث بعض الحقول
  BidModel copyWith({
    String? id,
    String? auctionItemId,
    String? bidderId,
    int? bidAmount,
    BidStatus? status,
    bool? isAutoBid,
    int? maxAutoBid,
    DateTime? placedAt,
    Map<String, dynamic>? bidder,
    Map<String, dynamic>? auctionItem,
  }) {
    return BidModel(
      id: id ?? this.id,
      auctionItemId: auctionItemId ?? this.auctionItemId,
      bidderId: bidderId ?? this.bidderId,
      bidAmount: bidAmount ?? this.bidAmount,
      status: status ?? this.status,
      isAutoBid: isAutoBid ?? this.isAutoBid,
      maxAutoBid: maxAutoBid ?? this.maxAutoBid,
      placedAt: placedAt ?? this.placedAt,
      bidder: bidder ?? this.bidder,
      auctionItem: auctionItem ?? this.auctionItem,
    );
  }

  /// تحويل حالة المزايدة من String إلى Enum
  static BidStatus _mapStatus(String? status) {
    switch (status) {
      case 'active':
        return BidStatus.active;
      case 'outbid':
        return BidStatus.outbid;
      case 'winning':
        return BidStatus.winning;
      default:
        return BidStatus.active;
    }
  }

  @override
  String toString() =>
      'BidModel(id: $id, bidAmount: $bidAmount, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BidModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
