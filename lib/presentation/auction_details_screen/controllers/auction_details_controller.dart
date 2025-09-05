import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/auctions/data/datasources/auction_remote_datasource.dart';
import '../../../features/auctions/data/repositories/auction_repository_impl.dart';
import '../../../features/auctions/domain/entities/auction_entity.dart';
import '../../../features/auctions/domain/usecases/get_auction_usecase.dart';
import '../../../features/bids/data/datasources/bid_remote_datasource.dart';
import '../../../features/bids/data/repositories/bid_repository_impl.dart';
import '../../../features/bids/domain/entities/bid_entity.dart';
import '../../../features/bids/domain/usecases/get_bids_usecase.dart';
import '../../../features/bids/domain/usecases/place_bid_usecase.dart';
import '../../../features/watchlist/data/datasources/watchlist_remote_datasource.dart';
import '../../../features/watchlist/data/repositories/watchlist_repository_impl.dart';
import '../../../features/watchlist/domain/usecases/toggle_watchlist_usecase.dart';
import '../../../services/auth_service.dart';
import '../../../services/local_notification_service.dart';

/// Auction Details Controller - إدارة حالة صفحة تفاصيل المزاد
///
/// يدير بيانات المزاد مع Realtime updates
/// يتبع قواعد BidWar لإدارة الحالة
class AuctionDetailsController extends ChangeNotifier {
  final String auctionId;

  // Dependencies
  late final GetAuctionUseCase _getAuctionUseCase;
  late final GetBidsForAuctionUseCase _getBidsUseCase;
  late final PlaceBidUseCase _placeBidUseCase;
  late final ToggleWatchlistUseCase _toggleWatchlistUseCase;

  // State
  AuctionEntity? _auction;
  List<BidEntity> _bids = [];

  bool _isLoading = false;
  bool _isLoadingBids = false;
  bool _isBidding = false;
  bool _isInWatchlist = false;
  String? _errorMessage;

  // Realtime subscriptions
  dynamic _auctionSubscription;
  dynamic _bidSubscription;

  // Getters
  AuctionEntity? get auction => _auction;
  List<BidEntity> get bids => _bids;
  bool get isLoading => _isLoading;
  bool get isLoadingBids => _isLoadingBids;
  bool get isBidding => _isBidding;
  bool get isInWatchlist => _isInWatchlist;
  String? get errorMessage => _errorMessage;

  AuctionDetailsController({required this.auctionId}) {
    _initializeDependencies();
  }

  void _initializeDependencies() {
    // إنشاء DataSources والRepositories
    final auctionDataSource = AuctionRemoteDataSourceImpl();
    final auctionRepository = AuctionRepositoryImpl(
      remoteDataSource: auctionDataSource,
    );
    _getAuctionUseCase = GetAuctionUseCase(auctionRepository);

    final bidDataSource = BidRemoteDataSourceImpl();
    final bidRepository = BidRepositoryImpl(remoteDataSource: bidDataSource);
    _getBidsUseCase = GetBidsForAuctionUseCase(bidRepository);
    _placeBidUseCase = PlaceBidUseCase(bidRepository);

    final watchlistDataSource = WatchlistRemoteDataSourceImpl();
    final watchlistRepository = WatchlistRepositoryImpl(
      remoteDataSource: watchlistDataSource,
    );
    _toggleWatchlistUseCase = ToggleWatchlistUseCase(watchlistRepository);
  }

  /// تهيئة صفحة التفاصيل
  Future<void> initialize() async {
    try {
      _setLoading(true);

      // تحميل البيانات الأولية
      await Future.wait([_loadAuction(), _loadBids(), _checkWatchlistStatus()]);

      // إعداد Realtime subscriptions
      await _setupRealtimeSubscriptions();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// تحميل بيانات المزاد
  Future<void> _loadAuction() async {
    try {
      _auction = await _getAuctionUseCase(auctionId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load auction: $e');
    }
  }

  /// تحميل تاريخ المزايدات
  Future<void> _loadBids() async {
    try {
      _setLoadingBids(true);

      final params = GetBidsForAuctionParams(
        auctionId: auctionId,
        limit: 50, // عرض آخر 50 مزايدة
      );

      _bids = await _getBidsUseCase(params);
      notifyListeners();
    } catch (e) {
      print('Warning: Failed to load bids: $e');
    } finally {
      _setLoadingBids(false);
    }
  }

  /// التحقق من حالة قائمة المتابعة
  Future<void> _checkWatchlistStatus() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) {
        _isInWatchlist = false;
        return;
      }

      // TODO: إنشاء CheckWatchlistStatusUseCase واستخدامه
      _isInWatchlist = false; // مؤقت
      notifyListeners();
    } catch (e) {
      print('Warning: Failed to check watchlist status: $e');
    }
  }

  /// إعداد Realtime subscriptions
  Future<void> _setupRealtimeSubscriptions() async {
    try {
      // الاشتراك في تحديثات المزاد
      _auctionSubscription = await _subscribeToAuctionUpdates();

      // الاشتراك في تحديثات المزايدات
      _bidSubscription = await _subscribeToBidUpdates();
    } catch (e) {
      print('Warning: Failed to setup realtime subscriptions: $e');
    }
  }

  /// الاشتراك في تحديثات المزاد
  Future<dynamic> _subscribeToAuctionUpdates() async {
    final auctionDataSource = AuctionRemoteDataSourceImpl();

    return auctionDataSource.subscribeToAuctionUpdates(auctionId, (
      updatedAuction,
    ) {
      _auction = updatedAuction;
      notifyListeners();

      print('🔄 Auction updated: ${updatedAuction.currentPrice}');
    });
  }

  /// الاشتراك في تحديثات المزايدات
  Future<dynamic> _subscribeToBidUpdates() async {
    final bidDataSource = BidRemoteDataSourceImpl();

    return bidDataSource.subscribeToBidUpdates(auctionId, (newBid) {
      // إضافة المزايدة الجديدة لأول القائمة
      _bids.insert(0, newBid);

      // تحديث السعر الحالي في المزاد إذا كانت أعلى مزايدة
      if (_auction != null && newBid.bidAmount > _auction!.currentHighestBid) {
        // تحديث البيانات المحلية فوراً
        final updatedAuction = AuctionEntity(
          id: _auction!.id,
          sellerId: _auction!.sellerId,
          categoryId: _auction!.categoryId,
          title: _auction!.title,
          description: _auction!.description,
          startingPrice: _auction!.startingPrice,
          reservePrice: _auction!.reservePrice,
          currentHighestBid: newBid.bidAmount,
          bidIncrement: _auction!.bidIncrement,
          condition: _auction!.condition,
          brand: _auction!.brand,
          model: _auction!.model,
          specifications: _auction!.specifications,
          images: _auction!.images,
          status: _auction!.status,
          startTime: _auction!.startTime,
          endTime: _auction!.endTime,
          featured: _auction!.featured,
          viewCount: _auction!.viewCount,
          winnerId: _auction!.winnerId,
          createdAt: _auction!.createdAt,
          updatedAt: DateTime.now(),
          seller: _auction!.seller,
          category: _auction!.category,
          bids: _auction!.bids,
          bidCount: (_auction!.bidCount ?? 0) + 1,
        );

        _auction = updatedAuction;
      }

      notifyListeners();

      print(
        '🔄 New bid received: \$${newBid.bidAmount} by ${newBid.bidderName}',
      );
    });
  }

  /// وضع مزايدة جديدة
  Future<BidResult> placeBid({
    required String bidderId,
    required int amount,
    bool isAutoBid = false,
    int? maxAutoBid,
  }) async {
    try {
      _setBidding(true);

      final params = PlaceBidParams(
        auctionId: auctionId,
        bidderId: bidderId,
        amount: amount,
        isAutoBid: isAutoBid,
        maxAutoBid: maxAutoBid,
      );

      final result = await _placeBidUseCase(params);

      if (result.success) {
        // تحديث البيانات المحلية فوراً (قبل Realtime)
        await refreshAuction();

        // إرسال إشعار نجاح المزايدة
        if (_auction != null) {
          await LocalNotificationService.instance.showBidSuccessNotification(
            auctionTitle: _auction!.title,
            bidAmount: amount,
            auctionId: auctionId,
          );
        }
      }

      return result;
    } catch (e) {
      return BidResult.failure(message: 'Failed to place bid: $e');
    } finally {
      _setBidding(false);
    }
  }

  /// تبديل قائمة المتابعة
  Future<void> toggleWatchlist() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) {
        throw Exception('Please sign in to use watchlist');
      }

      final params = ToggleWatchlistParams(
        userId: user.id,
        auctionId: auctionId,
      );

      final result = await _toggleWatchlistUseCase(params);

      if (result.success) {
        _isInWatchlist = result.wasAdded;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to toggle watchlist: $e');
    }
  }

  /// تحديث بيانات المزاد
  Future<void> refreshAuction() async {
    try {
      await _loadAuction();
    } catch (e) {
      _setError('Failed to refresh auction: $e');
    }
  }

  /// تحديث تاريخ المزايدات
  Future<void> refreshBids() async {
    try {
      await _loadBids();
    } catch (e) {
      _setError('Failed to refresh bids: $e');
    }
  }

  /// تعيين حالة التحميل الرئيسية
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// تعيين حالة تحميل المزايدات
  void _setLoadingBids(bool loading) {
    _isLoadingBids = loading;
    notifyListeners();
  }

  /// تعيين حالة المزايدة
  void _setBidding(bool bidding) {
    _isBidding = bidding;
    notifyListeners();
  }

  /// تعيين رسالة الخطأ
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // إلغاء Realtime subscriptions
    _auctionSubscription?.unsubscribe();
    _bidSubscription?.unsubscribe();

    super.dispose();
  }
}
