import '../repositories/bid_repository.dart';

/// Use Case لوضع مزايدة جديدة
///
/// يطبق قواعد العمل للمزايدة
/// وفقاً لقواعد BidWar Clean Architecture
class PlaceBidUseCase {
  final BidRepository _repository;

  PlaceBidUseCase(this._repository);

  /// تنفيذ Use Case
  ///
  /// [params] - معاملات المزايدة
  /// إرجاع نتيجة المزايدة
  Future<BidResult> call(PlaceBidParams params) async {
    try {
      // التحقق من صحة المعاملات
      _validateParams(params);

      // وضع المزايدة
      final result = await _repository.placeBid(
        auctionId: params.auctionId,
        bidderId: params.bidderId,
        amount: params.amount,
        isAutoBid: params.isAutoBid,
        maxAutoBid: params.maxAutoBid,
      );

      // تحليل النتيجة
      final success = result['success'] as bool? ?? false;
      final message = result['message'] as String? ?? '';
      final bidId = result['bid_id'] as String?;

      return BidResult(success: success, message: message, bidId: bidId);
    } catch (e) {
      return BidResult(
        success: false,
        message: 'Failed to place bid: $e',
        bidId: null,
      );
    }
  }

  /// التحقق من صحة معاملات المزايدة
  void _validateParams(PlaceBidParams params) {
    // التحقق من الحقول المطلوبة
    if (params.auctionId.isEmpty) {
      throw Exception('Auction ID is required');
    }

    if (params.bidderId.isEmpty) {
      throw Exception('Bidder ID is required');
    }

    // التحقق من المبلغ
    if (params.amount <= 0) {
      throw Exception('Bid amount must be greater than 0');
    }

    if (params.amount > 10000000) {
      throw Exception('Bid amount cannot exceed 10,000,000');
    }

    // التحقق من المزايدة التلقائية
    if (params.isAutoBid) {
      if (params.maxAutoBid == null) {
        throw Exception('Max auto bid is required for auto bidding');
      }

      if (params.maxAutoBid! < params.amount) {
        throw Exception('Max auto bid cannot be less than current bid amount');
      }

      if (params.maxAutoBid! > 10000000) {
        throw Exception('Max auto bid cannot exceed 10,000,000');
      }
    }
  }
}

/// معاملات PlaceBidUseCase
class PlaceBidParams {
  final String auctionId;
  final String bidderId;
  final int amount;
  final bool isAutoBid;
  final int? maxAutoBid;

  const PlaceBidParams({
    required this.auctionId,
    required this.bidderId,
    required this.amount,
    this.isAutoBid = false,
    this.maxAutoBid,
  });

  /// إنشاء معاملات مزايدة عادية
  factory PlaceBidParams.regular({
    required String auctionId,
    required String bidderId,
    required int amount,
  }) {
    return PlaceBidParams(
      auctionId: auctionId,
      bidderId: bidderId,
      amount: amount,
      isAutoBid: false,
    );
  }

  /// إنشاء معاملات مزايدة تلقائية
  factory PlaceBidParams.autoBid({
    required String auctionId,
    required String bidderId,
    required int amount,
    required int maxAutoBid,
  }) {
    return PlaceBidParams(
      auctionId: auctionId,
      bidderId: bidderId,
      amount: amount,
      isAutoBid: true,
      maxAutoBid: maxAutoBid,
    );
  }

  /// نسخ مع تحديث بعض المعاملات
  PlaceBidParams copyWith({
    String? auctionId,
    String? bidderId,
    int? amount,
    bool? isAutoBid,
    int? maxAutoBid,
  }) {
    return PlaceBidParams(
      auctionId: auctionId ?? this.auctionId,
      bidderId: bidderId ?? this.bidderId,
      amount: amount ?? this.amount,
      isAutoBid: isAutoBid ?? this.isAutoBid,
      maxAutoBid: maxAutoBid ?? this.maxAutoBid,
    );
  }

  /// التحقق من صحة المعاملات
  bool get isValid {
    if (auctionId.isEmpty || bidderId.isEmpty) return false;
    if (amount <= 0) return false;
    if (isAutoBid && (maxAutoBid == null || maxAutoBid! < amount)) return false;
    return true;
  }

  @override
  String toString() {
    return 'PlaceBidParams(auctionId: $auctionId, amount: $amount, isAutoBid: $isAutoBid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaceBidParams &&
        other.auctionId == auctionId &&
        other.bidderId == bidderId &&
        other.amount == amount &&
        other.isAutoBid == isAutoBid &&
        other.maxAutoBid == maxAutoBid;
  }

  @override
  int get hashCode {
    return Object.hash(auctionId, bidderId, amount, isAutoBid, maxAutoBid);
  }
}

/// نتيجة المزايدة
class BidResult {
  final bool success;
  final String message;
  final String? bidId;

  const BidResult({required this.success, required this.message, this.bidId});

  /// إنشاء نتيجة نجاح
  factory BidResult.success({
    required String bidId,
    String message = 'Bid placed successfully',
  }) {
    return BidResult(success: true, message: message, bidId: bidId);
  }

  /// إنشاء نتيجة فشل
  factory BidResult.failure({required String message}) {
    return BidResult(success: false, message: message, bidId: null);
  }

  @override
  String toString() {
    return 'BidResult(success: $success, message: $message, bidId: $bidId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BidResult &&
        other.success == success &&
        other.message == message &&
        other.bidId == bidId;
  }

  @override
  int get hashCode => Object.hash(success, message, bidId);
}
