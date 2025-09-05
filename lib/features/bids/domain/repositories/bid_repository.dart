import '../entities/bid_entity.dart';

/// Repository Interface للمزايدات - Domain Layer
///
/// يحدد العمليات المطلوبة للمزايدات في طبقة الدومين
/// يطبق نمط Repository وفقاً لقواعد BidWar
abstract class BidRepository {
  /// وضع مزايدة جديدة
  ///
  /// [auctionId] - معرف المزاد
  /// [bidderId] - معرف المزايد
  /// [amount] - مبلغ المزايدة
  /// [isAutoBid] - هل هي مزايدة تلقائية
  /// [maxAutoBid] - الحد الأقصى للمزايدة التلقائية
  /// إرجاع نتيجة المزايدة (success, message, bid_id)
  Future<Map<String, dynamic>> placeBid({
    required String auctionId,
    required String bidderId,
    required int amount,
    bool isAutoBid = false,
    int? maxAutoBid,
  });

  /// الحصول على مزايدات مزاد معين
  ///
  /// [auctionId] - معرف المزاد
  /// [limit] - عدد النتائج (افتراضي 20)
  Future<List<BidEntity>> getBidsForAuction(String auctionId, {int limit = 20});

  /// الحصول على مزايدات المستخدم
  ///
  /// [userId] - معرف المستخدم
  /// [limit] - عدد النتائج (افتراضي 20)
  Future<List<BidEntity>> getUserBids(String userId, {int limit = 20});

  /// الحصول على مزايدة واحدة
  ///
  /// [bidId] - معرف المزايدة
  /// إرجاع null إذا لم توجد المزايدة
  Future<BidEntity?> getBid(String bidId);

  /// تحديث حالة المزايدة
  ///
  /// [bidId] - معرف المزايدة
  /// [status] - الحالة الجديدة
  Future<void> updateBidStatus(String bidId, String status);

  /// حذف مزايدة (إذا كان مسموحاً)
  ///
  /// [bidId] - معرف المزايدة
  Future<void> deleteBid(String bidId);

  /// الحصول على أعلى مزايدة للمزاد
  ///
  /// [auctionId] - معرف المزاد
  /// إرجاع null إذا لم توجد مزايدات
  Future<BidEntity?> getHighestBidForAuction(String auctionId);

  /// الحصول على مزايدات المستخدم في مزاد معين
  ///
  /// [userId] - معرف المستخدم
  /// [auctionId] - معرف المزاد
  Future<List<BidEntity>> getUserBidsForAuction(
    String userId,
    String auctionId,
  );

  /// الاشتراك في تحديثات المزايدات المباشرة
  ///
  /// [auctionId] - معرف المزاد
  /// [onNewBid] - دالة callback عند مزايدة جديدة
  /// إرجاع dynamic للتحكم في الاشتراك (RealtimeChannel)
  dynamic subscribeToBidUpdates(
    String auctionId,
    Function(BidEntity) onNewBid,
  );
}
