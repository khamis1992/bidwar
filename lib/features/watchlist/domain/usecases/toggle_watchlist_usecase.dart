import '../entities/watchlist_entity.dart';
import '../repositories/watchlist_repository.dart';

/// Use Case لتبديل حالة المزاد في قائمة المتابعة
///
/// يطبق قواعد العمل لإضافة/إزالة المزادات من قائمة المتابعة
/// وفقاً لقواعد BidWar Clean Architecture
class ToggleWatchlistUseCase {
  final WatchlistRepository _repository;

  ToggleWatchlistUseCase(this._repository);

  /// تنفيذ Use Case
  ///
  /// [params] - معاملات التبديل
  /// إرجاع true إذا تم الإضافة، false إذا تم الحذف
  Future<WatchlistToggleResult> call(ToggleWatchlistParams params) async {
    try {
      // التحقق من صحة المعاملات
      _validateParams(params);

      // تبديل الحالة
      final wasAdded = await _repository.toggleWatchlist(
        userId: params.userId,
        auctionId: params.auctionId,
      );

      return WatchlistToggleResult(
        success: true,
        wasAdded: wasAdded,
        message:
            wasAdded
                ? 'Added to watchlist successfully'
                : 'Removed from watchlist successfully',
      );
    } catch (e) {
      return WatchlistToggleResult(
        success: false,
        wasAdded: false,
        message: 'Failed to toggle watchlist: $e',
      );
    }
  }

  /// التحقق من صحة المعاملات
  void _validateParams(ToggleWatchlistParams params) {
    if (params.userId.isEmpty) {
      throw Exception('User ID is required');
    }

    if (params.auctionId.isEmpty) {
      throw Exception('Auction ID is required');
    }
  }
}

/// Use Case للحصول على قائمة المتابعة
///
/// يطبق قواعد العمل للحصول على قائمة متابعة المستخدم
class GetWatchlistUseCase {
  final WatchlistRepository _repository;

  GetWatchlistUseCase(this._repository);

  /// تنفيذ Use Case
  ///
  /// [params] - معاملات الطلب
  Future<List<WatchlistEntity>> call(GetWatchlistParams params) async {
    try {
      // التحقق من صحة المعاملات
      if (params.userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      if (params.limit <= 0) {
        throw Exception('Limit must be greater than 0');
      }

      if (params.activeOnly) {
        return await _repository.getActiveWatchlistItems(
          params.userId,
          limit: params.limit,
        );
      } else {
        return await _repository.getUserWatchlist(
          params.userId,
          limit: params.limit,
        );
      }
    } catch (e) {
      throw Exception('UseCase: Failed to get watchlist - $e');
    }
  }
}

/// Use Case للتحقق من وجود مزاد في قائمة المتابعة
///
/// يطبق قواعد العمل للتحقق من حالة المتابعة
class CheckWatchlistStatusUseCase {
  final WatchlistRepository _repository;

  CheckWatchlistStatusUseCase(this._repository);

  /// تنفيذ Use Case
  ///
  /// [params] - معاملات التحقق
  Future<bool> call(CheckWatchlistParams params) async {
    try {
      // التحقق من صحة المعاملات
      if (params.userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      if (params.auctionId.isEmpty) {
        throw Exception('Auction ID cannot be empty');
      }

      return await _repository.isInWatchlist(
        userId: params.userId,
        auctionId: params.auctionId,
      );
    } catch (e) {
      throw Exception('UseCase: Failed to check watchlist status - $e');
    }
  }
}

/// معاملات ToggleWatchlistUseCase
class ToggleWatchlistParams {
  final String userId;
  final String auctionId;

  const ToggleWatchlistParams({required this.userId, required this.auctionId});

  @override
  String toString() {
    return 'ToggleWatchlistParams(userId: $userId, auctionId: $auctionId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ToggleWatchlistParams &&
        other.userId == userId &&
        other.auctionId == auctionId;
  }

  @override
  int get hashCode => Object.hash(userId, auctionId);
}

/// معاملات GetWatchlistUseCase
class GetWatchlistParams {
  final String userId;
  final int limit;
  final bool activeOnly;

  const GetWatchlistParams({
    required this.userId,
    this.limit = 20,
    this.activeOnly = false,
  });

  /// إنشاء معاملات للمزادات النشطة فقط
  factory GetWatchlistParams.activeOnly({
    required String userId,
    int limit = 20,
  }) {
    return GetWatchlistParams(userId: userId, limit: limit, activeOnly: true);
  }

  @override
  String toString() {
    return 'GetWatchlistParams(userId: $userId, limit: $limit, activeOnly: $activeOnly)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetWatchlistParams &&
        other.userId == userId &&
        other.limit == limit &&
        other.activeOnly == activeOnly;
  }

  @override
  int get hashCode => Object.hash(userId, limit, activeOnly);
}

/// معاملات CheckWatchlistStatusUseCase
class CheckWatchlistParams {
  final String userId;
  final String auctionId;

  const CheckWatchlistParams({required this.userId, required this.auctionId});

  @override
  String toString() {
    return 'CheckWatchlistParams(userId: $userId, auctionId: $auctionId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckWatchlistParams &&
        other.userId == userId &&
        other.auctionId == auctionId;
  }

  @override
  int get hashCode => Object.hash(userId, auctionId);
}

/// نتيجة تبديل قائمة المتابعة
class WatchlistToggleResult {
  final bool success;
  final bool wasAdded;
  final String message;

  const WatchlistToggleResult({
    required this.success,
    required this.wasAdded,
    required this.message,
  });

  /// إنشاء نتيجة نجاح الإضافة
  factory WatchlistToggleResult.added() {
    return const WatchlistToggleResult(
      success: true,
      wasAdded: true,
      message: 'Added to watchlist successfully',
    );
  }

  /// إنشاء نتيجة نجاح الحذف
  factory WatchlistToggleResult.removed() {
    return const WatchlistToggleResult(
      success: true,
      wasAdded: false,
      message: 'Removed from watchlist successfully',
    );
  }

  /// إنشاء نتيجة فشل
  factory WatchlistToggleResult.failure(String message) {
    return WatchlistToggleResult(
      success: false,
      wasAdded: false,
      message: message,
    );
  }

  @override
  String toString() {
    return 'WatchlistToggleResult(success: $success, wasAdded: $wasAdded, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WatchlistToggleResult &&
        other.success == success &&
        other.wasAdded == wasAdded &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(success, wasAdded, message);
}
