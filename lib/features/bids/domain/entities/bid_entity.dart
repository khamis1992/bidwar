/// Bid Status Enum
///
/// حالات المزايدة المختلفة وفقاً لقاعدة البيانات
enum BidStatus { active, outbid, winning }

/// Bid Entity - Domain Layer
///
/// يمثل المزايدة في طبقة الدومين
/// يحتوي على منطق العمل والقواعد الأساسية
class BidEntity {
  final String id;
  final String auctionItemId;
  final String bidderId;
  final int bidAmount;
  final BidStatus status;
  final bool isAutoBid;
  final int? maxAutoBid;
  final DateTime placedAt;

  // Related data
  final Map<String, dynamic>? bidder;
  final Map<String, dynamic>? auctionItem;

  const BidEntity({
    required this.id,
    required this.auctionItemId,
    required this.bidderId,
    required this.bidAmount,
    required this.status,
    required this.isAutoBid,
    this.maxAutoBid,
    required this.placedAt,
    this.bidder,
    this.auctionItem,
  });

  // Equality and Hash Code
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BidEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Business Logic Methods

  /// التحقق من حالة المزايدة
  bool get isActive => status == BidStatus.active;
  bool get isOutbid => status == BidStatus.outbid;
  bool get isWinning => status == BidStatus.winning;

  /// اسم المزايد
  String get bidderName {
    return bidder?['full_name'] as String? ?? 'Anonymous Bidder';
  }

  /// صورة المزايد
  String? get bidderProfilePicture {
    return bidder?['profile_picture_url'] as String?;
  }

  /// عنوان المزاد
  String get auctionTitle {
    return auctionItem?['title'] as String? ?? 'Unknown Auction';
  }

  /// صور المزاد
  List<String> get auctionImages {
    final images = auctionItem?['images'];
    if (images is List) {
      return List<String>.from(images);
    }
    return [];
  }

  /// السعر الحالي للمزاد
  int get currentAuctionPrice {
    return auctionItem?['current_highest_bid'] as int? ?? bidAmount;
  }

  /// حالة المزاد
  String get auctionStatus {
    return auctionItem?['status'] as String? ?? 'unknown';
  }

  /// وقت انتهاء المزاد
  DateTime? get auctionEndTime {
    final endTime = auctionItem?['end_time'];
    if (endTime is String) {
      return DateTime.tryParse(endTime);
    }
    return null;
  }

  /// التحقق من كون هذه المزايدة هي الأعلى
  bool get isHighestBid {
    return bidAmount == currentAuctionPrice && isActive;
  }

  /// حساب الفرق بين هذه المزايدة والسعر الحالي
  int get bidDifference {
    return currentAuctionPrice - bidAmount;
  }

  /// التحقق من إمكانية زيادة المزايدة التلقائية
  bool get canIncreasAutoBid {
    if (!isAutoBid || maxAutoBid == null) return false;
    return bidAmount < maxAutoBid!;
  }

  /// حساب المبلغ المتبقي للمزايدة التلقائية
  int get remainingAutoBidAmount {
    if (!isAutoBid || maxAutoBid == null) return 0;
    return maxAutoBid! - bidAmount;
  }

  /// التحقق من انتهاء صلاحية المزايدة
  bool get isExpired {
    if (auctionEndTime == null) return false;
    return DateTime.now().isAfter(auctionEndTime!);
  }

  /// التحقق من كون المزاد ما زال نشطاً
  bool get isAuctionActive {
    return auctionStatus == 'live' || auctionStatus == 'upcoming';
  }

  /// التحقق من إمكانية استرداد المزايدة
  bool get canBeRefunded {
    return isOutbid || (auctionStatus == 'ended' && !isWinning);
  }

  /// التحقق من كون المزايدة فائزة
  bool get hasWon {
    return auctionStatus == 'ended' && isHighestBid;
  }

  /// حساب الوقت المنقضي منذ وضع المزايدة
  Duration get timeSincePlaced {
    return DateTime.now().difference(placedAt);
  }

  /// التحقق من كون المزايدة حديثة (أقل من 5 دقائق)
  bool get isRecent {
    return timeSincePlaced.inMinutes < 5;
  }

  /// التحقق من صحة المزايدة التلقائية
  bool get isValidAutoBid {
    if (!isAutoBid) return true;
    if (maxAutoBid == null) return false;
    return maxAutoBid! >= bidAmount;
  }

  /// الحصول على نص حالة المزايدة
  String get statusText {
    switch (status) {
      case BidStatus.active:
        return 'Active';
      case BidStatus.outbid:
        return 'Outbid';
      case BidStatus.winning:
        return 'Winning';
    }
  }

  /// الحصول على نص حالة المزايدة بالعربية
  String get statusTextArabic {
    switch (status) {
      case BidStatus.active:
        return 'نشطة';
      case BidStatus.outbid:
        return 'تم تجاوزها';
      case BidStatus.winning:
        return 'فائزة';
    }
  }

  /// الحصول على لون حالة المزايدة
  String get statusColor {
    switch (status) {
      case BidStatus.active:
        return '#2563eb'; // blue
      case BidStatus.outbid:
        return '#dc2626'; // red
      case BidStatus.winning:
        return '#16a34a'; // green
    }
  }

  /// التحقق من إمكانية تعديل المزايدة
  bool get canBeModified {
    return isActive && isAuctionActive && !isExpired;
  }

  /// التحقق من إمكانية إلغاء المزايدة
  bool get canBeCancelled {
    return isActive &&
        isAuctionActive &&
        !isExpired &&
        timeSincePlaced.inMinutes < 10; // يمكن الإلغاء خلال 10 دقائق
  }

  @override
  String toString() {
    return 'BidEntity(id: $id, auctionItemId: $auctionItemId, bidAmount: $bidAmount, status: $status)';
  }
}
