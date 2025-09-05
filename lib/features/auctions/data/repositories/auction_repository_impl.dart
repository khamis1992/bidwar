import '../../domain/entities/auction_entity.dart';
import '../../domain/repositories/auction_repository.dart';
import '../datasources/auction_remote_datasource.dart';
import '../models/auction_model.dart';

/// تنفيذ Repository للمزادات
///
/// يربط بين طبقة الدومين وطبقة البيانات
/// يطبق نمط Repository وفقاً لقواعد BidWar
class AuctionRepositoryImpl implements AuctionRepository {
  final AuctionRemoteDataSource _remoteDataSource;

  AuctionRepositoryImpl({required AuctionRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<AuctionEntity>> getAuctions({
    bool? activeOnly,
    String? query,
    String? categoryId,
    String? status,
    bool? featured,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final auctionModels = await _remoteDataSource.getAuctions(
        activeOnly: activeOnly,
        query: query,
        categoryId: categoryId,
        status: status,
        featured: featured,
        limit: limit,
        offset: offset,
      );

      return auctionModels.map((model) => model as AuctionEntity).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get auctions - $e');
    }
  }

  @override
  Future<AuctionEntity?> getAuction(String id) async {
    try {
      final auctionModel = await _remoteDataSource.getAuction(id);
      return auctionModel; // AuctionModel extends AuctionEntity
    } catch (e) {
      throw Exception('Repository: Failed to get auction - $e');
    }
  }

  @override
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
  }) async {
    try {
      // إنشاء AuctionModel للبيانات الجديدة
      final auction = AuctionModel(
        id: '', // سيتم توليده بواسطة قاعدة البيانات
        sellerId: sellerId,
        categoryId: categoryId,
        title: title,
        description: description,
        startingPrice: startingPrice,
        reservePrice: reservePrice,
        currentHighestBid: 0,
        bidIncrement: bidIncrement,
        condition: condition,
        brand: brand,
        model: model,
        specifications: specifications,
        images: images ?? [],
        status: AuctionStatus.upcoming,
        startTime: startTime,
        endTime: endTime,
        featured: featured,
        viewCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await _remoteDataSource.createAuction(auction);
    } catch (e) {
      throw Exception('Repository: Failed to create auction - $e');
    }
  }

  @override
  Future<void> updateAuction(String id, Map<String, dynamic> updates) async {
    try {
      await _remoteDataSource.updateAuction(id, updates);
    } catch (e) {
      throw Exception('Repository: Failed to update auction - $e');
    }
  }

  @override
  Future<void> deleteAuction(String id) async {
    try {
      await _remoteDataSource.deleteAuction(id);
    } catch (e) {
      throw Exception('Repository: Failed to delete auction - $e');
    }
  }

  @override
  Future<List<AuctionEntity>> getUserAuctions(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final auctionModels = await _remoteDataSource.getUserAuctions(
        userId,
        limit: limit,
      );

      return auctionModels.map((model) => model as AuctionEntity).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get user auctions - $e');
    }
  }

  @override
  Future<List<AuctionEntity>> searchAuctions(
    String query, {
    int limit = 20,
  }) async {
    try {
      final auctionModels = await _remoteDataSource.searchAuctions(
        query,
        limit: limit,
      );

      return auctionModels.map((model) => model as AuctionEntity).toList();
    } catch (e) {
      throw Exception('Repository: Failed to search auctions - $e');
    }
  }

  @override
  Future<List<AuctionEntity>> getFeaturedAuctions({int limit = 10}) async {
    try {
      final auctionModels = await _remoteDataSource.getFeaturedAuctions(
        limit: limit,
      );

      return auctionModels.map((model) => model as AuctionEntity).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get featured auctions - $e');
    }
  }

  @override
  Future<List<AuctionEntity>> getLiveAuctions({int limit = 20}) async {
    try {
      final auctionModels = await _remoteDataSource.getLiveAuctions(
        limit: limit,
      );

      return auctionModels.map((model) => model as AuctionEntity).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get live auctions - $e');
    }
  }

  @override
  dynamic subscribeToAuctionUpdates(
    String auctionId,
    Function(AuctionEntity) onUpdate,
  ) {
    try {
      return _remoteDataSource.subscribeToAuctionUpdates(
        auctionId,
        (auctionModel) => onUpdate(auctionModel),
      );
    } catch (e) {
      throw Exception(
        'Repository: Failed to subscribe to auction updates - $e',
      );
    }
  }
}
