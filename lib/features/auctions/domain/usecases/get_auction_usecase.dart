import '../entities/auction_entity.dart';
import '../repositories/auction_repository.dart';

/// Use Case للحصول على مزاد واحد بالتفاصيل
///
/// يطبق قواعد العمل للحصول على مزاد محدد
/// وفقاً لقواعد BidWar Clean Architecture
class GetAuctionUseCase {
  final AuctionRepository _repository;

  GetAuctionUseCase(this._repository);

  /// تنفيذ Use Case
  ///
  /// [auctionId] - معرف المزاد
  /// إرجاع null إذا لم يوجد المزاد
  Future<AuctionEntity?> call(String auctionId) async {
    try {
      // التحقق من صحة معرف المزاد
      if (auctionId.isEmpty) {
        throw Exception('Auction ID cannot be empty');
      }

      final auction = await _repository.getAuction(auctionId);

      // يمكن إضافة منطق عمل إضافي هنا
      // مثل تسجيل المشاهدة، التحقق من الأذونات، إلخ

      return auction;
    } catch (e) {
      throw Exception('UseCase: Failed to get auction - $e');
    }
  }
}

/// Use Case للحصول على مزاد مع التحقق من الأذونات
///
/// يطبق قواعد العمل مع فحص أذونات المستخدم
class GetAuctionWithPermissionsUseCase {
  final AuctionRepository _repository;

  GetAuctionWithPermissionsUseCase(this._repository);

  /// تنفيذ Use Case مع التحقق من الأذونات
  ///
  /// [params] - معاملات الطلب مع معرف المستخدم
  Future<AuctionWithPermissions> call(
    GetAuctionWithPermissionsParams params,
  ) async {
    try {
      // التحقق من صحة المعاملات
      if (params.auctionId.isEmpty) {
        throw Exception('Auction ID cannot be empty');
      }

      final auction = await _repository.getAuction(params.auctionId);

      if (auction == null) {
        throw Exception('Auction not found');
      }

      // حساب الأذونات
      final permissions = _calculatePermissions(auction, params.userId);

      return AuctionWithPermissions(auction: auction, permissions: permissions);
    } catch (e) {
      throw Exception('UseCase: Failed to get auction with permissions - $e');
    }
  }

  /// حساب أذونات المستخدم للمزاد
  AuctionPermissions _calculatePermissions(
    AuctionEntity auction,
    String? userId,
  ) {
    if (userId == null) {
      return const AuctionPermissions(
        canBid: false,
        canEdit: false,
        canDelete: false,
        canView: true,
      );
    }

    final isOwner = auction.isOwnedBy(userId);
    final canBid = auction.canBid && !isOwner;

    return AuctionPermissions(
      canBid: canBid,
      canEdit: isOwner && (auction.isUpcoming || auction.isLive),
      canDelete: isOwner && auction.isUpcoming,
      canView: true,
    );
  }
}

/// معاملات GetAuctionWithPermissionsUseCase
class GetAuctionWithPermissionsParams {
  final String auctionId;
  final String? userId;

  const GetAuctionWithPermissionsParams({required this.auctionId, this.userId});

  @override
  String toString() {
    return 'GetAuctionWithPermissionsParams(auctionId: $auctionId, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetAuctionWithPermissionsParams &&
        other.auctionId == auctionId &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(auctionId, userId);
}

/// نتيجة GetAuctionWithPermissionsUseCase
class AuctionWithPermissions {
  final AuctionEntity auction;
  final AuctionPermissions permissions;

  const AuctionWithPermissions({
    required this.auction,
    required this.permissions,
  });

  @override
  String toString() {
    return 'AuctionWithPermissions(auction: ${auction.title}, permissions: $permissions)';
  }
}

/// أذونات المزاد للمستخدم
class AuctionPermissions {
  final bool canBid;
  final bool canEdit;
  final bool canDelete;
  final bool canView;

  const AuctionPermissions({
    required this.canBid,
    required this.canEdit,
    required this.canDelete,
    required this.canView,
  });

  @override
  String toString() {
    return 'AuctionPermissions(canBid: $canBid, canEdit: $canEdit, canDelete: $canDelete, canView: $canView)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuctionPermissions &&
        other.canBid == canBid &&
        other.canEdit == canEdit &&
        other.canDelete == canDelete &&
        other.canView == canView;
  }

  @override
  int get hashCode => Object.hash(canBid, canEdit, canDelete, canView);
}
