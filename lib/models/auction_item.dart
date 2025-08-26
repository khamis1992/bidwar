class AuctionItem {
  final String id;
  final String sellerId;
  final String? categoryId;
  final String title;
  final String description;
  final int startingPrice;
  final int? reservePrice;
  final int currentHighestBid;
  final int bidIncrement;
  final String? condition;
  final String? brand;
  final String? model;
  final Map<String, dynamic>? specifications;
  final List<String> images;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final bool featured;
  final int viewCount;
  final String? winnerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final Map<String, dynamic>? seller;
  final Map<String, dynamic>? category;
  final List<Map<String, dynamic>>? bids;
  final int? bidCount;

  AuctionItem({
    required this.id,
    required this.sellerId,
    this.categoryId,
    required this.title,
    required this.description,
    required this.startingPrice,
    this.reservePrice,
    required this.currentHighestBid,
    required this.bidIncrement,
    this.condition,
    this.brand,
    this.model,
    this.specifications,
    required this.images,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.featured,
    required this.viewCount,
    this.winnerId,
    required this.createdAt,
    required this.updatedAt,
    this.seller,
    this.category,
    this.bids,
    this.bidCount,
  });

  factory AuctionItem.fromMap(Map<String, dynamic> map) {
    return AuctionItem(
      id: map['id'] ?? '',
      sellerId: map['seller_id'] ?? '',
      categoryId: map['category_id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startingPrice: map['starting_price'] ?? 0,
      reservePrice: map['reserve_price'],
      currentHighestBid: map['current_highest_bid'] ?? 0,
      bidIncrement: map['bid_increment'] ?? 1,
      condition: map['condition'],
      brand: map['brand'],
      model: map['model'],
      specifications: map['specifications'],
      images: map['images'] != null ? List<String>.from(map['images']) : [],
      status: map['status'] ?? 'upcoming',
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      featured: map['featured'] ?? false,
      viewCount: map['view_count'] ?? 0,
      winnerId: map['winner_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      seller: map['seller'],
      category: map['category'],
      bids: map['bids'] != null
          ? List<Map<String, dynamic>>.from(map['bids'])
          : null,
      bidCount: map['bid_count'] is List
          ? (map['bid_count'] as List).length
          : map['bid_count'],
    );
  }

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
      'status': status,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'featured': featured,
      'view_count': viewCount,
      'winner_id': winnerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Utility methods
  bool get isLive => status == 'live';
  bool get isUpcoming => status == 'upcoming';
  bool get isEnded => status == 'ended';
  bool get isCancelled => status == 'cancelled';

  Duration get timeRemaining {
    if (isUpcoming) return startTime.difference(DateTime.now());
    if (isLive) return endTime.difference(DateTime.now());
    return Duration.zero;
  }

  String get mainImage => images.isNotEmpty
      ? images.first
      : 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400';

  String get sellerName => seller?['full_name'] ?? 'Unknown Seller';
  String get categoryName => category?['name'] ?? 'Uncategorized';

  int get nextMinimumBid =>
      currentHighestBid > 0 ? currentHighestBid + bidIncrement : startingPrice;

  int get currentPrice =>
      currentHighestBid > 0 ? currentHighestBid : startingPrice;

  double? get estimatedValue => reservePrice?.toDouble();

  List<Map<String, dynamic>> get bidHistory => bids ?? [];
}
