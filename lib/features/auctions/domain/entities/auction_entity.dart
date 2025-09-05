/// Auction Status Enum
///
/// حالات المزاد المختلفة وفقاً لقاعدة البيانات
enum AuctionStatus { upcoming, live, ended, cancelled }

/// Auction Entity - Domain Layer
///
/// يمثل المزاد في طبقة الدومين
/// يحتوي على منطق العمل والقواعد الأساسية
class AuctionEntity {
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
  final AuctionStatus status;
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

  const AuctionEntity({
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

  // Equality and Hash Code
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuctionEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Business Logic Methods

  /// التحقق من حالة المزاد
  bool get isLive => status == AuctionStatus.live;
  bool get isUpcoming => status == AuctionStatus.upcoming;
  bool get isEnded => status == AuctionStatus.ended;
  bool get isCancelled => status == AuctionStatus.cancelled;

  /// حساب الوقت المتبقي
  Duration get timeRemaining {
    final now = DateTime.now();

    if (isUpcoming) {
      return startTime.difference(now);
    }

    if (isLive) {
      return endTime.difference(now);
    }

    return Duration.zero;
  }

  /// التحقق من انتهاء المزاد
  bool get hasExpired {
    return DateTime.now().isAfter(endTime);
  }

  /// التحقق من بدء المزاد
  bool get hasStarted {
    return DateTime.now().isAfter(startTime);
  }

  /// الصورة الرئيسية
  String get mainImage {
    if (images.isNotEmpty) {
      return images.first;
    }
    return 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400';
  }

  /// اسم البائع
  String get sellerName {
    return seller?['full_name'] as String? ?? 'Unknown Seller';
  }

  /// اسم الفئة
  String get categoryName {
    return category?['name'] as String? ?? 'Uncategorized';
  }

  /// الحد الأدنى للمزايدة التالية
  int get nextMinimumBid {
    return currentHighestBid > 0
        ? currentHighestBid + bidIncrement
        : startingPrice;
  }

  /// السعر الحالي
  int get currentPrice {
    return currentHighestBid > 0 ? currentHighestBid : startingPrice;
  }

  /// القيمة المقدرة (reserve price)
  double? get estimatedValue => reservePrice?.toDouble();

  /// تاريخ المزايدات
  List<Map<String, dynamic>> get bidHistory => bids ?? [];

  /// عدد المزايدات
  int get totalBids => bidCount ?? bidHistory.length;

  /// التحقق من وجود مزايدات
  bool get hasBids => totalBids > 0;

  /// التحقق من تجاوز السعر المحجوز
  bool get hasReachedReservePrice {
    if (reservePrice == null) return true;
    return currentHighestBid >= reservePrice!;
  }

  /// حساب نسبة التقدم في الوقت
  double get timeProgressPercentage {
    if (isUpcoming) return 0.0;
    if (isEnded || isCancelled) return 1.0;

    final totalDuration = endTime.difference(startTime);
    final elapsed = DateTime.now().difference(startTime);

    if (totalDuration.inMilliseconds <= 0) return 1.0;

    final progress = elapsed.inMilliseconds / totalDuration.inMilliseconds;
    return progress.clamp(0.0, 1.0);
  }

  /// حساب نسبة التقدم في السعر
  double get priceProgressPercentage {
    if (reservePrice == null || reservePrice! <= startingPrice) {
      return hasBids ? 1.0 : 0.0;
    }

    final progress =
        (currentPrice - startingPrice) / (reservePrice! - startingPrice);
    return progress.clamp(0.0, 1.0);
  }

  /// التحقق من قرب انتهاء المزاد (آخر ساعة)
  bool get isEndingSoon {
    if (!isLive) return false;
    return timeRemaining.inMinutes <= 60;
  }

  /// التحقق من قرب انتهاء المزاد (آخر 5 دقائق)
  bool get isEndingVerySoon {
    if (!isLive) return false;
    return timeRemaining.inMinutes <= 5;
  }

  /// التحقق من إمكانية المزايدة
  bool get canBid {
    return isLive && !hasExpired;
  }

  /// التحقق من صحة مبلغ المزايدة
  bool isValidBidAmount(int bidAmount) {
    return bidAmount >= nextMinimumBid;
  }

  /// حساب المبلغ المطلوب للمزايدة التالية
  int getRequiredBidAmount(int desiredAmount) {
    if (desiredAmount >= nextMinimumBid) {
      return desiredAmount;
    }
    return nextMinimumBid;
  }

  /// التحقق من كون المستخدم هو البائع
  bool isOwnedBy(String userId) {
    return sellerId == userId;
  }

  /// التحقق من كون المستخدم هو الفائز
  bool isWonBy(String userId) {
    return winnerId == userId;
  }

  /// التحقق من وجود مزايدة للمستخدم
  bool hasUserBid(String userId) {
    return bidHistory.any((bid) => bid['bidder_id'] == userId);
  }

  /// الحصول على أعلى مزايدة للمستخدم
  int? getUserHighestBid(String userId) {
    final userBids = bidHistory
        .where((bid) => bid['bidder_id'] == userId)
        .map((bid) => bid['bid_amount'] as int)
        .toList();

    if (userBids.isEmpty) return null;

    userBids.sort((a, b) => b.compareTo(a));
    return userBids.first;
  }

  /// التحقق من كون المستخدم هو أعلى مزايد حالياً
  bool isUserHighestBidder(String userId) {
    if (!hasBids) return false;

    final highestBid = bidHistory
        .where((bid) => bid['bid_amount'] == currentHighestBid)
        .firstOrNull;

    return highestBid?['bidder_id'] == userId;
  }

  @override
  String toString() {
    return 'AuctionEntity(id: $id, title: $title, status: $status, currentPrice: $currentPrice)';
  }
}
