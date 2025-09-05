import '../entities/watchlist_entity.dart';

/// Repository Interface لقائمة المتابعة - Domain Layer
///
/// يحدد العمليات المطلوبة لقائمة المتابعة في طبقة الدومين
/// يطبق نمط Repository وفقاً لقواعد BidWar
abstract class WatchlistRepository {
  /// إضافة مزاد لقائمة المتابعة
  ///
  /// [userId] - معرف المستخدم
  /// [auctionId] - معرف المزاد
  Future<void> addToWatchlist({
    required String userId,
    required String auctionId,
  });

  /// إزالة مزاد من قائمة المتابعة
  ///
  /// [userId] - معرف المستخدم
  /// [auctionId] - معرف المزاد
  Future<void> removeFromWatchlist({
    required String userId,
    required String auctionId,
  });

  /// تبديل حالة المزاد في قائمة المتابعة
  ///
  /// [userId] - معرف المستخدم
  /// [auctionId] - معرف المزاد
  /// إرجاع true إذا تم الإضافة، false إذا تم الحذف
  Future<bool> toggleWatchlist({
    required String userId,
    required String auctionId,
  });

  /// الحصول على قائمة متابعة المستخدم
  ///
  /// [userId] - معرف المستخدم
  /// [limit] - عدد النتائج (افتراضي 20)
  Future<List<WatchlistEntity>> getUserWatchlist(
    String userId, {
    int limit = 20,
  });

  /// التحقق من وجود مزاد في قائمة المتابعة
  ///
  /// [userId] - معرف المستخدم
  /// [auctionId] - معرف المزاد
  Future<bool> isInWatchlist({
    required String userId,
    required String auctionId,
  });

  /// الحصول على عدد المزادات في قائمة المتابعة
  ///
  /// [userId] - معرف المستخدم
  Future<int> getWatchlistCount(String userId);

  /// الحصول على المزادات المتابعة النشطة فقط
  ///
  /// [userId] - معرف المستخدم
  /// [limit] - عدد النتائج (افتراضي 20)
  Future<List<WatchlistEntity>> getActiveWatchlistItems(
    String userId, {
    int limit = 20,
  });

  /// مسح قائمة المتابعة
  ///
  /// [userId] - معرف المستخدم
  Future<void> clearWatchlist(String userId);
}
