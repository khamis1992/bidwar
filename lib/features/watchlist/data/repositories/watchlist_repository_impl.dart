import '../../domain/entities/watchlist_entity.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_remote_datasource.dart';

/// تنفيذ Repository لقائمة المتابعة
///
/// يربط بين طبقة الدومين وطبقة البيانات
/// يطبق نمط Repository وفقاً لقواعد BidWar
class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistRemoteDataSource _remoteDataSource;

  WatchlistRepositoryImpl({required WatchlistRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<void> addToWatchlist({
    required String userId,
    required String auctionId,
  }) async {
    try {
      await _remoteDataSource.addToWatchlist(
        userId: userId,
        auctionId: auctionId,
      );
    } catch (e) {
      throw Exception('Repository: Failed to add to watchlist - $e');
    }
  }

  @override
  Future<void> removeFromWatchlist({
    required String userId,
    required String auctionId,
  }) async {
    try {
      await _remoteDataSource.removeFromWatchlist(
        userId: userId,
        auctionId: auctionId,
      );
    } catch (e) {
      throw Exception('Repository: Failed to remove from watchlist - $e');
    }
  }

  @override
  Future<bool> toggleWatchlist({
    required String userId,
    required String auctionId,
  }) async {
    try {
      return await _remoteDataSource.toggleWatchlist(
        userId: userId,
        auctionId: auctionId,
      );
    } catch (e) {
      throw Exception('Repository: Failed to toggle watchlist - $e');
    }
  }

  @override
  Future<List<WatchlistEntity>> getUserWatchlist(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final watchlistModels = await _remoteDataSource.getUserWatchlist(
        userId,
        limit: limit,
      );

      return watchlistModels.map((model) => model as WatchlistEntity).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get user watchlist - $e');
    }
  }

  @override
  Future<bool> isInWatchlist({
    required String userId,
    required String auctionId,
  }) async {
    try {
      return await _remoteDataSource.isInWatchlist(
        userId: userId,
        auctionId: auctionId,
      );
    } catch (e) {
      throw Exception('Repository: Failed to check watchlist status - $e');
    }
  }

  @override
  Future<int> getWatchlistCount(String userId) async {
    try {
      return await _remoteDataSource.getWatchlistCount(userId);
    } catch (e) {
      throw Exception('Repository: Failed to get watchlist count - $e');
    }
  }

  @override
  Future<List<WatchlistEntity>> getActiveWatchlistItems(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final watchlistModels = await _remoteDataSource.getActiveWatchlistItems(
        userId,
        limit: limit,
      );

      return watchlistModels.map((model) => model as WatchlistEntity).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get active watchlist items - $e');
    }
  }

  @override
  Future<void> clearWatchlist(String userId) async {
    try {
      await _remoteDataSource.clearWatchlist(userId);
    } catch (e) {
      throw Exception('Repository: Failed to clear watchlist - $e');
    }
  }
}
