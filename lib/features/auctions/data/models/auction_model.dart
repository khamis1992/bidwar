import '../../domain/entities/auction_entity.dart';

/// Auction Model for Data Layer
///
/// يحول البيانات من/إلى قاعدة البيانات
/// يطبق نمط DTO/Entity mapping وفقاً لقواعد BidWar
class AuctionModel extends AuctionEntity {
  const AuctionModel({
    required super.id,
    required super.sellerId,
    super.categoryId,
    required super.title,
    required super.description,
    required super.startingPrice,
    super.reservePrice,
    required super.currentHighestBid,
    required super.bidIncrement,
    super.condition,
    super.brand,
    super.model,
    super.specifications,
    required super.images,
    required super.status,
    required super.startTime,
    required super.endTime,
    required super.featured,
    required super.viewCount,
    super.winnerId,
    required super.createdAt,
    required super.updatedAt,
    super.seller,
    super.category,
    super.bids,
    super.bidCount,
  });

  /// إنشاء AuctionModel من Map (من قاعدة البيانات)
  factory AuctionModel.fromMap(Map<String, dynamic> map) {
    return AuctionModel(
      id: map['id'] as String,
      sellerId: map['seller_id'] as String,
      categoryId: map['category_id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String,
      startingPrice: map['starting_price'] as int,
      reservePrice: map['reserve_price'] as int?,
      currentHighestBid: map['current_highest_bid'] as int? ?? 0,
      bidIncrement: map['bid_increment'] as int? ?? 1,
      condition: map['condition'] as String?,
      brand: map['brand'] as String?,
      model: map['model'] as String?,
      specifications: map['specifications'] as Map<String, dynamic>?,
      images:
          map['images'] != null ? List<String>.from(map['images'] as List) : [],
      status: _mapStatus(map['status'] as String?),
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
      featured: map['featured'] as bool? ?? false,
      viewCount: map['view_count'] as int? ?? 0,
      winnerId: map['winner_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      seller: map['seller'] as Map<String, dynamic>?,
      category: map['category'] as Map<String, dynamic>?,
      bids:
          map['bids'] != null
              ? List<Map<String, dynamic>>.from(map['bids'] as List)
              : null,
      bidCount: _extractBidCount(map['bid_count']),
    );
  }

  /// تحويل AuctionModel إلى Map (لقاعدة البيانات)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seller_id': sellerId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'starting_price': startingPrice,
      'reserve_price': reservePrice,
      'current_highest_bid': currentHighestBid,
      'bid_increment': bidIncrement,
      'condition': condition,
      'brand': brand,
      'model': model,
      'specifications': specifications,
      'images': images,
      'status': status.name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'featured': featured,
      'view_count': viewCount,
      'winner_id': winnerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// تحويل إلى Map للإنشاء (بدون ID وtimestamps)
  Map<String, dynamic> toCreateMap() {
    return {
      'seller_id': sellerId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'starting_price': startingPrice,
      'reserve_price': reservePrice,
      'bid_increment': bidIncrement,
      'condition': condition,
      'brand': brand,
      'model': model,
      'specifications': specifications,
      'images': images,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'featured': featured,
    };
  }

  /// تحويل AuctionEntity إلى AuctionModel
  factory AuctionModel.fromEntity(AuctionEntity entity) {
    return AuctionModel(
      id: entity.id,
      sellerId: entity.sellerId,
      categoryId: entity.categoryId,
      title: entity.title,
      description: entity.description,
      startingPrice: entity.startingPrice,
      reservePrice: entity.reservePrice,
      currentHighestBid: entity.currentHighestBid,
      bidIncrement: entity.bidIncrement,
      condition: entity.condition,
      brand: entity.brand,
      model: entity.model,
      specifications: entity.specifications,
      images: entity.images,
      status: entity.status,
      startTime: entity.startTime,
      endTime: entity.endTime,
      featured: entity.featured,
      viewCount: entity.viewCount,
      winnerId: entity.winnerId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      seller: entity.seller,
      category: entity.category,
      bids: entity.bids,
      bidCount: entity.bidCount,
    );
  }

  /// نسخ مع تحديث بعض الحقول
  AuctionModel copyWith({
    String? id,
    String? sellerId,
    String? categoryId,
    String? title,
    String? description,
    int? startingPrice,
    int? reservePrice,
    int? currentHighestBid,
    int? bidIncrement,
    String? condition,
    String? brand,
    String? model,
    Map<String, dynamic>? specifications,
    List<String>? images,
    AuctionStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    bool? featured,
    int? viewCount,
    String? winnerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? seller,
    Map<String, dynamic>? category,
    List<Map<String, dynamic>>? bids,
    int? bidCount,
  }) {
    return AuctionModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      startingPrice: startingPrice ?? this.startingPrice,
      reservePrice: reservePrice ?? this.reservePrice,
      currentHighestBid: currentHighestBid ?? this.currentHighestBid,
      bidIncrement: bidIncrement ?? this.bidIncrement,
      condition: condition ?? this.condition,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      specifications: specifications ?? this.specifications,
      images: images ?? this.images,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      featured: featured ?? this.featured,
      viewCount: viewCount ?? this.viewCount,
      winnerId: winnerId ?? this.winnerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      seller: seller ?? this.seller,
      category: category ?? this.category,
      bids: bids ?? this.bids,
      bidCount: bidCount ?? this.bidCount,
    );
  }

  /// تحويل حالة المزاد من String إلى Enum
  static AuctionStatus _mapStatus(String? status) {
    switch (status) {
      case 'upcoming':
        return AuctionStatus.upcoming;
      case 'live':
        return AuctionStatus.live;
      case 'ended':
        return AuctionStatus.ended;
      case 'cancelled':
        return AuctionStatus.cancelled;
      default:
        return AuctionStatus.upcoming;
    }
  }

  /// استخراج عدد المزايدات من البيانات
  static int? _extractBidCount(dynamic bidCount) {
    if (bidCount == null) return null;
    if (bidCount is int) return bidCount;
    if (bidCount is List) return bidCount.length;
    if (bidCount is Map && bidCount.containsKey('count')) {
      return bidCount['count'] as int?;
    }
    return null;
  }

  @override
  String toString() => 'AuctionModel(id: $id, title: $title, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuctionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
