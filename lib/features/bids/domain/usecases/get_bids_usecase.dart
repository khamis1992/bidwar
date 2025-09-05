import '../entities/bid_entity.dart';
import '../repositories/bid_repository.dart';

/// Use Case للحصول على مزايدات مزاد معين
///
/// يطبق قواعد العمل للحصول على المزايدات
/// وفقاً لقواعد BidWar Clean Architecture
class GetBidsForAuctionUseCase {
  final BidRepository _repository;

  GetBidsForAuctionUseCase(this._repository);

  /// تنفيذ Use Case
  ///
  /// [params] - معاملات الطلب
  Future<List<BidEntity>> call(GetBidsForAuctionParams params) async {
    try {
      // التحقق من صحة المعاملات
      if (params.auctionId.isEmpty) {
        throw Exception('Auction ID cannot be empty');
      }

      if (params.limit <= 0) {
        throw Exception('Limit must be greater than 0');
      }

      return await _repository.getBidsForAuction(
        params.auctionId,
        limit: params.limit,
      );
    } catch (e) {
      throw Exception('UseCase: Failed to get bids for auction - $e');
    }
  }
}

/// Use Case للحصول على مزايدات المستخدم
///
/// يطبق قواعد العمل للحصول على مزايدات المستخدم
class GetUserBidsUseCase {
  final BidRepository _repository;

  GetUserBidsUseCase(this._repository);

  /// تنفيذ Use Case
  ///
  /// [params] - معاملات الطلب
  Future<List<BidEntity>> call(GetUserBidsParams params) async {
    try {
      // التحقق من صحة المعاملات
      if (params.userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      if (params.limit <= 0) {
        throw Exception('Limit must be greater than 0');
      }

      return await _repository.getUserBids(params.userId, limit: params.limit);
    } catch (e) {
      throw Exception('UseCase: Failed to get user bids - $e');
    }
  }
}

/// Use Case للحصول على أعلى مزايدة في مزاد
///
/// يطبق قواعد العمل للحصول على أعلى مزايدة
class GetHighestBidUseCase {
  final BidRepository _repository;

  GetHighestBidUseCase(this._repository);

  /// تنفيذ Use Case
  ///
  /// [auctionId] - معرف المزاد
  /// إرجاع null إذا لم توجد مزايدات
  Future<BidEntity?> call(String auctionId) async {
    try {
      // التحقق من صحة معرف المزاد
      if (auctionId.isEmpty) {
        throw Exception('Auction ID cannot be empty');
      }

      return await _repository.getHighestBidForAuction(auctionId);
    } catch (e) {
      throw Exception('UseCase: Failed to get highest bid - $e');
    }
  }
}

/// Use Case للحصول على مزايدات المستخدم في مزاد معين
///
/// يطبق قواعد العمل للحصول على مزايدات المستخدم في مزاد محدد
class GetUserBidsForAuctionUseCase {
  final BidRepository _repository;

  GetUserBidsForAuctionUseCase(this._repository);

  /// تنفيذ Use Case
  ///
  /// [params] - معاملات الطلب
  Future<List<BidEntity>> call(GetUserBidsForAuctionParams params) async {
    try {
      // التحقق من صحة المعاملات
      if (params.userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      if (params.auctionId.isEmpty) {
        throw Exception('Auction ID cannot be empty');
      }

      return await _repository.getUserBidsForAuction(
        params.userId,
        params.auctionId,
      );
    } catch (e) {
      throw Exception('UseCase: Failed to get user bids for auction - $e');
    }
  }
}

/// معاملات GetBidsForAuctionUseCase
class GetBidsForAuctionParams {
  final String auctionId;
  final int limit;

  const GetBidsForAuctionParams({required this.auctionId, this.limit = 20});

  @override
  String toString() {
    return 'GetBidsForAuctionParams(auctionId: $auctionId, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetBidsForAuctionParams &&
        other.auctionId == auctionId &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(auctionId, limit);
}

/// معاملات GetUserBidsUseCase
class GetUserBidsParams {
  final String userId;
  final int limit;

  const GetUserBidsParams({required this.userId, this.limit = 20});

  @override
  String toString() {
    return 'GetUserBidsParams(userId: $userId, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetUserBidsParams &&
        other.userId == userId &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(userId, limit);
}

/// معاملات GetUserBidsForAuctionUseCase
class GetUserBidsForAuctionParams {
  final String userId;
  final String auctionId;

  const GetUserBidsForAuctionParams({
    required this.userId,
    required this.auctionId,
  });

  @override
  String toString() {
    return 'GetUserBidsForAuctionParams(userId: $userId, auctionId: $auctionId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetUserBidsForAuctionParams &&
        other.userId == userId &&
        other.auctionId == auctionId;
  }

  @override
  int get hashCode => Object.hash(userId, auctionId);
}
