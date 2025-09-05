import '../entities/auction_entity.dart';
import '../repositories/auction_repository.dart';

/// Use Case للحصول على قائمة المزادات
///
/// يطبق قواعد العمل للحصول على المزادات مع الفلاتر
/// وفقاً لقواعد BidWar Clean Architecture
class GetAuctionsUseCase {
  final AuctionRepository _repository;

  GetAuctionsUseCase(this._repository);

  /// تنفيذ Use Case
  ///
  /// [params] - معاملات البحث والفلترة
  Future<List<AuctionEntity>> call(GetAuctionsParams params) async {
    try {
      return await _repository.getAuctions(
        activeOnly: params.activeOnly,
        query: params.query,
        categoryId: params.categoryId,
        status: params.status,
        featured: params.featured,
        limit: params.limit,
        offset: params.offset,
      );
    } catch (e) {
      throw Exception('UseCase: Failed to get auctions - $e');
    }
  }
}

/// معاملات GetAuctionsUseCase
class GetAuctionsParams {
  final bool? activeOnly;
  final String? query;
  final String? categoryId;
  final String? status;
  final bool? featured;
  final int limit;
  final int offset;

  const GetAuctionsParams({
    this.activeOnly,
    this.query,
    this.categoryId,
    this.status,
    this.featured,
    this.limit = 20,
    this.offset = 0,
  });

  /// إنشاء معاملات افتراضية
  factory GetAuctionsParams.defaultParams() {
    return const GetAuctionsParams();
  }

  /// إنشاء معاملات للمزادات النشطة فقط
  factory GetAuctionsParams.activeOnly({
    String? query,
    String? categoryId,
    int limit = 20,
    int offset = 0,
  }) {
    return GetAuctionsParams(
      activeOnly: true,
      query: query,
      categoryId: categoryId,
      limit: limit,
      offset: offset,
    );
  }

  /// إنشاء معاملات للبحث
  factory GetAuctionsParams.search({
    required String query,
    bool? activeOnly,
    String? categoryId,
    int limit = 20,
    int offset = 0,
  }) {
    return GetAuctionsParams(
      query: query,
      activeOnly: activeOnly,
      categoryId: categoryId,
      limit: limit,
      offset: offset,
    );
  }

  /// إنشاء معاملات للمزادات المميزة
  factory GetAuctionsParams.featured({
    bool? activeOnly = true,
    int limit = 10,
  }) {
    return GetAuctionsParams(
      featured: true,
      activeOnly: activeOnly,
      limit: limit,
    );
  }

  /// إنشاء معاملات لفئة معينة
  factory GetAuctionsParams.byCategory({
    required String categoryId,
    bool? activeOnly,
    int limit = 20,
    int offset = 0,
  }) {
    return GetAuctionsParams(
      categoryId: categoryId,
      activeOnly: activeOnly,
      limit: limit,
      offset: offset,
    );
  }

  /// إنشاء معاملات لحالة معينة
  factory GetAuctionsParams.byStatus({
    required String status,
    String? categoryId,
    int limit = 20,
    int offset = 0,
  }) {
    return GetAuctionsParams(
      status: status,
      categoryId: categoryId,
      limit: limit,
      offset: offset,
    );
  }

  /// نسخ مع تحديث بعض المعاملات
  GetAuctionsParams copyWith({
    bool? activeOnly,
    String? query,
    String? categoryId,
    String? status,
    bool? featured,
    int? limit,
    int? offset,
  }) {
    return GetAuctionsParams(
      activeOnly: activeOnly ?? this.activeOnly,
      query: query ?? this.query,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      featured: featured ?? this.featured,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  /// التحقق من وجود فلاتر
  bool get hasFilters {
    return activeOnly != null ||
        query != null ||
        categoryId != null ||
        status != null ||
        featured != null;
  }

  /// التحقق من كون البحث نشط
  bool get isSearching => query != null && query!.isNotEmpty;

  @override
  String toString() {
    return 'GetAuctionsParams(activeOnly: $activeOnly, query: $query, categoryId: $categoryId, status: $status, featured: $featured, limit: $limit, offset: $offset)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetAuctionsParams &&
        other.activeOnly == activeOnly &&
        other.query == query &&
        other.categoryId == categoryId &&
        other.status == status &&
        other.featured == featured &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode {
    return Object.hash(
      activeOnly,
      query,
      categoryId,
      status,
      featured,
      limit,
      offset,
    );
  }
}
