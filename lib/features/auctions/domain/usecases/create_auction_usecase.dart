import '../repositories/auction_repository.dart';

/// Use Case لإنشاء مزاد جديد
///
/// يطبق قواعد العمل لإنشاء المزادات
/// وفقاً لقواعد BidWar Clean Architecture
class CreateAuctionUseCase {
  final AuctionRepository _repository;

  CreateAuctionUseCase(this._repository);

  /// تنفيذ Use Case
  ///
  /// [params] - معاملات إنشاء المزاد
  /// إرجاع معرف المزاد الجديد
  Future<String> call(CreateAuctionParams params) async {
    try {
      // التحقق من صحة المعاملات
      _validateParams(params);

      return await _repository.createAuction(
        sellerId: params.sellerId,
        categoryId: params.categoryId,
        title: params.title,
        description: params.description,
        startingPrice: params.startingPrice,
        reservePrice: params.reservePrice,
        bidIncrement: params.bidIncrement,
        startTime: params.startTime,
        endTime: params.endTime,
        condition: params.condition,
        brand: params.brand,
        model: params.model,
        specifications: params.specifications,
        images: params.images,
        featured: params.featured,
      );
    } catch (e) {
      throw Exception('UseCase: Failed to create auction - $e');
    }
  }

  /// التحقق من صحة معاملات إنشاء المزاد
  void _validateParams(CreateAuctionParams params) {
    // التحقق من الحقول المطلوبة
    if (params.sellerId.isEmpty) {
      throw Exception('Seller ID is required');
    }

    if (params.title.isEmpty) {
      throw Exception('Title is required');
    }

    if (params.title.length < 3) {
      throw Exception('Title must be at least 3 characters long');
    }

    if (params.title.length > 100) {
      throw Exception('Title cannot exceed 100 characters');
    }

    if (params.description.isEmpty) {
      throw Exception('Description is required');
    }

    if (params.description.length < 10) {
      throw Exception('Description must be at least 10 characters long');
    }

    if (params.description.length > 1000) {
      throw Exception('Description cannot exceed 1000 characters');
    }

    // التحقق من الأسعار
    if (params.startingPrice <= 0) {
      throw Exception('Starting price must be greater than 0');
    }

    if (params.startingPrice > 1000000) {
      throw Exception('Starting price cannot exceed 1,000,000');
    }

    if (params.reservePrice != null &&
        params.reservePrice! < params.startingPrice) {
      throw Exception('Reserve price cannot be less than starting price');
    }

    if (params.bidIncrement <= 0) {
      throw Exception('Bid increment must be greater than 0');
    }

    if (params.bidIncrement > params.startingPrice) {
      throw Exception('Bid increment cannot be greater than starting price');
    }

    // التحقق من الأوقات
    final now = DateTime.now();

    if (params.startTime.isBefore(now)) {
      throw Exception('Start time cannot be in the past');
    }

    if (params.endTime.isBefore(params.startTime)) {
      throw Exception('End time must be after start time');
    }

    final duration = params.endTime.difference(params.startTime);

    if (duration.inMinutes < 30) {
      throw Exception('Auction duration must be at least 30 minutes');
    }

    if (duration.inDays > 30) {
      throw Exception('Auction duration cannot exceed 30 days');
    }

    // التحقق من الصور
    if (params.images != null && params.images!.length > 10) {
      throw Exception('Cannot have more than 10 images');
    }
  }
}

/// معاملات CreateAuctionUseCase
class CreateAuctionParams {
  final String sellerId;
  final String? categoryId;
  final String title;
  final String description;
  final int startingPrice;
  final int? reservePrice;
  final int bidIncrement;
  final DateTime startTime;
  final DateTime endTime;
  final String? condition;
  final String? brand;
  final String? model;
  final Map<String, dynamic>? specifications;
  final List<String>? images;
  final bool featured;

  const CreateAuctionParams({
    required this.sellerId,
    this.categoryId,
    required this.title,
    required this.description,
    required this.startingPrice,
    this.reservePrice,
    required this.bidIncrement,
    required this.startTime,
    required this.endTime,
    this.condition,
    this.brand,
    this.model,
    this.specifications,
    this.images,
    this.featured = false,
  });

  /// إنشاء معاملات أساسية
  factory CreateAuctionParams.basic({
    required String sellerId,
    required String title,
    required String description,
    required int startingPrice,
    required int bidIncrement,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return CreateAuctionParams(
      sellerId: sellerId,
      title: title,
      description: description,
      startingPrice: startingPrice,
      bidIncrement: bidIncrement,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// إنشاء معاملات كاملة
  factory CreateAuctionParams.complete({
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
  }) {
    return CreateAuctionParams(
      sellerId: sellerId,
      categoryId: categoryId,
      title: title,
      description: description,
      startingPrice: startingPrice,
      reservePrice: reservePrice,
      bidIncrement: bidIncrement,
      startTime: startTime,
      endTime: endTime,
      condition: condition,
      brand: brand,
      model: model,
      specifications: specifications,
      images: images,
      featured: featured,
    );
  }

  /// نسخ مع تحديث بعض المعاملات
  CreateAuctionParams copyWith({
    String? sellerId,
    String? categoryId,
    String? title,
    String? description,
    int? startingPrice,
    int? reservePrice,
    int? bidIncrement,
    DateTime? startTime,
    DateTime? endTime,
    String? condition,
    String? brand,
    String? model,
    Map<String, dynamic>? specifications,
    List<String>? images,
    bool? featured,
  }) {
    return CreateAuctionParams(
      sellerId: sellerId ?? this.sellerId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      startingPrice: startingPrice ?? this.startingPrice,
      reservePrice: reservePrice ?? this.reservePrice,
      bidIncrement: bidIncrement ?? this.bidIncrement,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      condition: condition ?? this.condition,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      specifications: specifications ?? this.specifications,
      images: images ?? this.images,
      featured: featured ?? this.featured,
    );
  }

  /// حساب مدة المزاد
  Duration get duration => endTime.difference(startTime);

  /// التحقق من صحة الأوقات
  bool get hasValidTimes =>
      endTime.isAfter(startTime) && startTime.isAfter(DateTime.now());

  /// التحقق من صحة الأسعار
  bool get hasValidPrices {
    if (startingPrice <= 0 || bidIncrement <= 0) return false;
    if (reservePrice != null && reservePrice! < startingPrice) return false;
    return true;
  }

  @override
  String toString() {
    return 'CreateAuctionParams(title: $title, startingPrice: $startingPrice, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreateAuctionParams &&
        other.sellerId == sellerId &&
        other.title == title &&
        other.startingPrice == startingPrice &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode {
    return Object.hash(sellerId, title, startingPrice, startTime, endTime);
  }
}
