import '../entities/auction_entity.dart';

/// Repository Interface للمزادات - Domain Layer
///
/// يحدد العمليات المطلوبة للمزادات في طبقة الدومين
/// يطبق نمط Repository وفقاً لقواعد BidWar
abstract class AuctionRepository {
  /// الحصول على قائمة المزادات مع فلاتر
  ///
  /// [activeOnly] - عرض المزادات النشطة فقط (upcoming, live)
  /// [query] - البحث في العنوان والوصف والعلامة التجارية
  /// [categoryId] - فلترة حسب الفئة
  /// [status] - فلترة حسب الحالة
  /// [featured] - فلترة المزادات المميزة
  /// [limit] - عدد النتائج (افتراضي 20)
  /// [offset] - رقم البداية للصفحات
  Future<List<AuctionEntity>> getAuctions({
    bool? activeOnly,
    String? query,
    String? categoryId,
    String? status,
    bool? featured,
    int limit = 20,
    int offset = 0,
  });

  /// الحصول على مزاد واحد بالتفاصيل
  ///
  /// [id] - معرف المزاد
  /// إرجاع null إذا لم يوجد المزاد
  Future<AuctionEntity?> getAuction(String id);

  /// إنشاء مزاد جديد
  ///
  /// إرجاع معرف المزاد الجديد
  Future<String> createAuction({
    required String sellerId,
    String? categoryId,
    required String title,
    required String description,
    required int startingPrice,
    int? reservePrice,
    required int bidIncrement,
    required DateTime startTime,
    required DateTime endTime,
    String? condition,
    String? brand,
    String? model,
    Map<String, dynamic>? specifications,
    List<String>? images,
    bool featured = false,
  });

  /// تحديث مزاد موجود
  ///
  /// [id] - معرف المزاد
  /// [updates] - الحقول المراد تحديثها
  Future<void> updateAuction(String id, Map<String, dynamic> updates);

  /// حذف مزاد
  ///
  /// [id] - معرف المزاد
  Future<void> deleteAuction(String id);

  /// الحصول على مزادات المستخدم
  ///
  /// [userId] - معرف المستخدم (البائع)
  /// [limit] - عدد النتائج (افتراضي 20)
  Future<List<AuctionEntity>> getUserAuctions(String userId, {int limit = 20});

  /// البحث في المزادات
  ///
  /// [query] - نص البحث
  /// [limit] - عدد النتائج (افتراضي 20)
  Future<List<AuctionEntity>> searchAuctions(String query, {int limit = 20});

  /// الحصول على المزادات المميزة
  ///
  /// [limit] - عدد النتائج (افتراضي 10)
  Future<List<AuctionEntity>> getFeaturedAuctions({int limit = 10});

  /// الحصول على المزادات المباشرة
  ///
  /// [limit] - عدد النتائج (افتراضي 20)
  Future<List<AuctionEntity>> getLiveAuctions({int limit = 20});

  /// الاشتراك في تحديثات المزاد المباشرة
  ///
  /// [auctionId] - معرف المزاد
  /// [onUpdate] - دالة callback عند التحديث
  /// إرجاع dynamic للتحكم في الاشتراك (RealtimeChannel)
  dynamic subscribeToAuctionUpdates(
    String auctionId,
    Function(AuctionEntity) onUpdate,
  );
}
