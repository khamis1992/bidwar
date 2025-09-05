import '../../domain/entities/bid_entity.dart';
import '../../domain/repositories/bid_repository.dart';
import '../datasources/bid_remote_datasource.dart';

/// تنفيذ Repository للمزايدات
///
/// يربط بين طبقة الدومين وطبقة البيانات
/// يطبق نمط Repository وفقاً لقواعد BidWar
class BidRepositoryImpl implements BidRepository {
  final BidRemoteDataSource _remoteDataSource;

  BidRepositoryImpl({required BidRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Map<String, dynamic>> placeBid({
    required String auctionId,
    required String bidderId,
    required int amount,
    bool isAutoBid = false,
    int? maxAutoBid,
  }) async {
    try {
      return await _remoteDataSource.placeBid(
        auctionId: auctionId,
        bidderId: bidderId,
        amount: amount,
        isAutoBid: isAutoBid,
        maxAutoBid: maxAutoBid,
      );
    } catch (e) {
      throw Exception('Repository: Failed to place bid - $e');
    }
  }

  @override
  Future<List<BidEntity>> getBidsForAuction(
    String auctionId, {
    int limit = 20,
  }) async {
    try {
      final bidModels = await _remoteDataSource.getBidsForAuction(
        auctionId,
        limit: limit,
      );

      return bidModels.map((model) => model as BidEntity).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get bids for auction - $e');
    }
  }

  @override
  Future<List<BidEntity>> getUserBids(String userId, {int limit = 20}) async {
    try {
      final bidModels = await _remoteDataSource.getUserBids(
        userId,
        limit: limit,
      );

      return bidModels.map((model) => model as BidEntity).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get user bids - $e');
    }
  }

  @override
  Future<BidEntity?> getBid(String bidId) async {
    try {
      final bidModel = await _remoteDataSource.getBid(bidId);
      return bidModel; // BidModel extends BidEntity
    } catch (e) {
      throw Exception('Repository: Failed to get bid - $e');
    }
  }

  @override
  Future<void> updateBidStatus(String bidId, String status) async {
    try {
      await _remoteDataSource.updateBidStatus(bidId, status);
    } catch (e) {
      throw Exception('Repository: Failed to update bid status - $e');
    }
  }

  @override
  Future<void> deleteBid(String bidId) async {
    try {
      await _remoteDataSource.deleteBid(bidId);
    } catch (e) {
      throw Exception('Repository: Failed to delete bid - $e');
    }
  }

  @override
  Future<BidEntity?> getHighestBidForAuction(String auctionId) async {
    try {
      final bidModel = await _remoteDataSource.getHighestBidForAuction(
        auctionId,
      );
      return bidModel; // BidModel extends BidEntity
    } catch (e) {
      throw Exception('Repository: Failed to get highest bid - $e');
    }
  }

  @override
  Future<List<BidEntity>> getUserBidsForAuction(
    String userId,
    String auctionId,
  ) async {
    try {
      final bidModels = await _remoteDataSource.getUserBidsForAuction(
        userId,
        auctionId,
      );

      return bidModels.map((model) => model as BidEntity).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get user bids for auction - $e');
    }
  }

  @override
  dynamic subscribeToBidUpdates(
    String auctionId,
    Function(BidEntity) onNewBid,
  ) {
    try {
      return _remoteDataSource.subscribeToBidUpdates(
        auctionId,
        (bidModel) => onNewBid(bidModel),
      );
    } catch (e) {
      throw Exception('Repository: Failed to subscribe to bid updates - $e');
    }
  }
}
