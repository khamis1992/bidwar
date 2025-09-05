/// Watchlist Entity - Domain Layer
///
/// يمثل عنصر قائمة المتابعة في طبقة الدومين
/// يحتوي على منطق العمل والقواعد الأساسية
class WatchlistEntity {
  final String id;
  final String userId;
  final String auctionItemId;
  final DateTime createdAt;

  // Related data
  final Map<String, dynamic>? auctionItem;
  final Map<String, dynamic>? user;

  const WatchlistEntity({
    required this.id,
    required this.userId,
    required this.auctionItemId,
    required this.createdAt,
    this.auctionItem,
    this.user,
  });

  // Equality and Hash Code
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WatchlistEntity &&
        other.id == id &&
        other.userId == userId &&
        other.auctionItemId == auctionItemId;
  }

  @override
  int get hashCode => Object.hash(id, userId, auctionItemId);

  /// Business Logic Methods

  /// عنوان المزاد
  String get auctionTitle {
    return auctionItem?['title'] as String? ?? 'Unknown Auction';
  }

  /// وصف المزاد
  String get auctionDescription {
    return auctionItem?['description'] as String? ?? '';
  }

  /// صور المزاد
  List<String> get auctionImages {
    final images = auctionItem?['images'];
    if (images is List) {
      return List<String>.from(images);
    }
    return [];
  }

  /// السعر الابتدائي
  int get startingPrice {
    return auctionItem?['starting_price'] as int? ?? 0;
  }

  /// السعر الحالي
  int get currentPrice {
    final currentBid = auctionItem?['current_highest_bid'] as int? ?? 0;
    return currentBid > 0 ? currentBid : startingPrice;
  }

  /// حالة المزاد
  String get auctionStatus {
    return auctionItem?['status'] as String? ?? 'unknown';
  }

  /// وقت بداية المزاد
  DateTime? get auctionStartTime {
    final startTime = auctionItem?['start_time'];
    if (startTime is String) {
      return DateTime.tryParse(startTime);
    }
    return null;
  }

  /// وقت انتهاء المزاد
  DateTime? get auctionEndTime {
    final endTime = auctionItem?['end_time'];
    if (endTime is String) {
      return DateTime.tryParse(endTime);
    }
    return null;
  }

  /// اسم البائع
  String get sellerName {
    final seller = auctionItem?['seller'];
    if (seller is Map) {
      return seller['full_name'] as String? ?? 'Unknown Seller';
    }
    return 'Unknown Seller';
  }

  /// اسم الفئة
  String get categoryName {
    final category = auctionItem?['category'];
    if (category is Map) {
      return category['name'] as String? ?? 'Uncategorized';
    }
    return 'Uncategorized';
  }

  /// الصورة الرئيسية
  String get mainImage {
    if (auctionImages.isNotEmpty) {
      return auctionImages.first;
    }
    return 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400';
  }

  /// التحقق من حالة المزاد
  bool get isLive => auctionStatus == 'live';
  bool get isUpcoming => auctionStatus == 'upcoming';
  bool get isEnded => auctionStatus == 'ended';
  bool get isCancelled => auctionStatus == 'cancelled';

  /// حساب الوقت المتبقي
  Duration get timeRemaining {
    final now = DateTime.now();

    if (isUpcoming && auctionStartTime != null) {
      return auctionStartTime!.difference(now);
    }

    if (isLive && auctionEndTime != null) {
      return auctionEndTime!.difference(now);
    }

    return Duration.zero;
  }

  /// التحقق من انتهاء المزاد
  bool get hasExpired {
    if (auctionEndTime == null) return false;
    return DateTime.now().isAfter(auctionEndTime!);
  }

  /// التحقق من بدء المزاد
  bool get hasStarted {
    if (auctionStartTime == null) return true;
    return DateTime.now().isAfter(auctionStartTime!);
  }

  /// التحقق من إمكانية المزايدة
  bool get canBid {
    return isLive && !hasExpired;
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

  /// حساب نسبة التقدم في الوقت
  double get timeProgressPercentage {
    if (auctionStartTime == null || auctionEndTime == null) return 0.0;

    if (isUpcoming) return 0.0;
    if (isEnded || isCancelled) return 1.0;

    final totalDuration = auctionEndTime!.difference(auctionStartTime!);
    final elapsed = DateTime.now().difference(auctionStartTime!);

    if (totalDuration.inMilliseconds <= 0) return 1.0;

    final progress = elapsed.inMilliseconds / totalDuration.inMilliseconds;
    return progress.clamp(0.0, 1.0);
  }

  /// التحقق من وجود مزايدات
  bool get hasBids {
    final bidCount = auctionItem?['bid_count'];
    if (bidCount is int) return bidCount > 0;
    if (bidCount is List) return bidCount.isNotEmpty;
    return currentPrice > startingPrice;
  }

  /// عدد المزايدات
  int get bidCount {
    final bidCount = auctionItem?['bid_count'];
    if (bidCount is int) return bidCount;
    if (bidCount is List) return bidCount.length;
    return 0;
  }

  /// التحقق من كون المزاد مميز
  bool get isFeatured {
    return auctionItem?['featured'] as bool? ?? false;
  }

  /// حساب الوقت المنقضي منذ إضافة العنصر لقائمة المتابعة
  Duration get timeSinceAdded {
    return DateTime.now().difference(createdAt);
  }

  /// التحقق من كون العنصر مضاف حديثاً لقائمة المتابعة
  bool get isRecentlyAdded {
    return timeSinceAdded.inDays < 1;
  }

  /// الحصول على نص حالة المزاد
  String get statusText {
    switch (auctionStatus) {
      case 'upcoming':
        return 'Upcoming';
      case 'live':
        return 'Live';
      case 'ended':
        return 'Ended';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  /// الحصول على نص حالة المزاد بالعربية
  String get statusTextArabic {
    switch (auctionStatus) {
      case 'upcoming':
        return 'قادم';
      case 'live':
        return 'مباشر';
      case 'ended':
        return 'انتهى';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'غير معروف';
    }
  }

  /// الحصول على لون حالة المزاد
  String get statusColor {
    switch (auctionStatus) {
      case 'upcoming':
        return '#f59e0b'; // yellow
      case 'live':
        return '#16a34a'; // green
      case 'ended':
        return '#6b7280'; // gray
      case 'cancelled':
        return '#dc2626'; // red
      default:
        return '#6b7280'; // gray
    }
  }

  /// التحقق من إمكانية إزالة العنصر من قائمة المتابعة
  bool get canBeRemoved => true;

  /// التحقق من وجود تحديثات مهمة (مزايدة جديدة، قرب الانتهاء، إلخ)
  bool get hasImportantUpdates {
    return isEndingSoon || (isLive && hasBids);
  }

  @override
  String toString() {
    return 'WatchlistEntity(id: $id, auctionTitle: $auctionTitle, status: $auctionStatus)';
  }
}
