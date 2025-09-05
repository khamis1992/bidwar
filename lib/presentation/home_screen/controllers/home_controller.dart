import 'package:flutter/foundation.dart';

import '../../../features/auctions/data/datasources/auction_remote_datasource.dart';
import '../../../features/auctions/data/repositories/auction_repository_impl.dart';
import '../../../features/auctions/domain/entities/auction_entity.dart';
import '../../../features/auctions/domain/usecases/get_auctions_usecase.dart';
import '../../../features/watchlist/data/datasources/watchlist_remote_datasource.dart';
import '../../../features/watchlist/data/repositories/watchlist_repository_impl.dart';
import '../../../features/watchlist/domain/usecases/toggle_watchlist_usecase.dart';
import '../../../services/auth_service.dart';

/// Home Controller - إدارة حالة الصفحة الرئيسية
///
/// يدير قائمة المزادات والفلاتر والبحث
/// يتبع قواعد BidWar لإدارة الحالة
class HomeController extends ChangeNotifier {
  // Dependencies
  late final GetAuctionsUseCase _getAuctionsUseCase;
  late final ToggleWatchlistUseCase _toggleWatchlistUseCase;

  // State
  List<AuctionEntity> _liveAuctions = [];
  List<AuctionEntity> _upcomingAuctions = [];
  List<AuctionEntity> _endedAuctions = [];
  List<Map<String, dynamic>> _categories = [];
  Set<String> _watchlistAuctionIds = {};

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategoryId;

  // Realtime subscriptions
  final List<dynamic> _subscriptions = [];

  // Getters
  List<AuctionEntity> get liveAuctions => _liveAuctions;
  List<AuctionEntity> get upcomingAuctions => _upcomingAuctions;
  List<AuctionEntity> get endedAuctions => _endedAuctions;
  List<Map<String, dynamic>> get categories => _categories;
  Set<String> get watchlistAuctionIds => _watchlistAuctionIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  HomeController() {
    _initializeDependencies();
  }

  void _initializeDependencies() {
    // إنشاء DataSources والRepositories
    final auctionDataSource = AuctionRemoteDataSourceImpl();
    final auctionRepository = AuctionRepositoryImpl(
      remoteDataSource: auctionDataSource,
    );
    _getAuctionsUseCase = GetAuctionsUseCase(auctionRepository);

    final watchlistDataSource = WatchlistRemoteDataSourceImpl();
    final watchlistRepository = WatchlistRepositoryImpl(
      remoteDataSource: watchlistDataSource,
    );
    _toggleWatchlistUseCase = ToggleWatchlistUseCase(watchlistRepository);
  }

  /// تهيئة الصفحة الرئيسية
  Future<void> initialize() async {
    try {
      _setLoading(true);

      // تحميل البيانات الأولية
      await Future.wait([
        _loadCategories(),
        _loadWatchlistIds(),
        loadLiveAuctions(),
        loadUpcomingAuctions(),
      ]);

      // إعداد Realtime subscriptions
      _setupRealtimeSubscriptions();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// تحميل المزادات المباشرة
  Future<void> loadLiveAuctions() async {
    try {
      final params = GetAuctionsParams.byStatus(
        status: 'live',
        categoryId: _selectedCategoryId,
      );

      if (_searchQuery.isNotEmpty) {
        final searchParams = GetAuctionsParams.search(
          query: _searchQuery,
          activeOnly: true,
          categoryId: _selectedCategoryId,
        );
        _liveAuctions = await _getAuctionsUseCase(searchParams);
        _liveAuctions =
            _liveAuctions.where((auction) => auction.isLive).toList();
      } else {
        _liveAuctions = await _getAuctionsUseCase(params);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load live auctions: $e');
    }
  }

  /// تحميل المزادات القادمة
  Future<void> loadUpcomingAuctions() async {
    try {
      final params = GetAuctionsParams.byStatus(
        status: 'upcoming',
        categoryId: _selectedCategoryId,
      );

      if (_searchQuery.isNotEmpty) {
        final searchParams = GetAuctionsParams.search(
          query: _searchQuery,
          activeOnly: true,
          categoryId: _selectedCategoryId,
        );
        _upcomingAuctions = await _getAuctionsUseCase(searchParams);
        _upcomingAuctions =
            _upcomingAuctions.where((auction) => auction.isUpcoming).toList();
      } else {
        _upcomingAuctions = await _getAuctionsUseCase(params);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load upcoming auctions: $e');
    }
  }

  /// تحميل المزادات المنتهية
  Future<void> loadEndedAuctions() async {
    try {
      final params = GetAuctionsParams.byStatus(
        status: 'ended',
        categoryId: _selectedCategoryId,
      );

      if (_searchQuery.isNotEmpty) {
        final searchParams = GetAuctionsParams.search(
          query: _searchQuery,
          categoryId: _selectedCategoryId,
        );
        _endedAuctions = await _getAuctionsUseCase(searchParams);
        _endedAuctions =
            _endedAuctions.where((auction) => auction.isEnded).toList();
      } else {
        _endedAuctions = await _getAuctionsUseCase(params);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load ended auctions: $e');
    }
  }

  /// تحميل الفئات
  Future<void> _loadCategories() async {
    try {
      // TODO: إنشاء Use Case للفئات أو استخدام DataSource مباشرة
      // _categories = await _getCategoriesUseCase();
      _categories = []; // مؤقت
      notifyListeners();
    } catch (e) {
      print('Warning: Failed to load categories: $e');
    }
  }

  /// البحث في المزادات
  Future<void> searchAuctions(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      // إعادة تحميل البيانات الأصلية
      await Future.wait([
        loadLiveAuctions(),
        loadUpcomingAuctions(),
        loadEndedAuctions(),
      ]);
    } else {
      // البحث في جميع الفئات
      try {
        _setLoading(true);

        final searchParams = GetAuctionsParams.search(
          query: query,
          activeOnly: true,
          categoryId: _selectedCategoryId,
        );

        final searchResults = await _getAuctionsUseCase(searchParams);

        // تصنيف النتائج حسب الحالة
        _liveAuctions =
            searchResults.where((auction) => auction.isLive).toList();
        _upcomingAuctions =
            searchResults.where((auction) => auction.isUpcoming).toList();
        _endedAuctions =
            searchResults.where((auction) => auction.isEnded).toList();

        notifyListeners();
      } catch (e) {
        _setError('Search failed: $e');
      } finally {
        _setLoading(false);
      }
    }
  }

  /// تطبيق الفلاتر
  Future<void> applyFilters({String? categoryId, bool? featured}) async {
    _selectedCategoryId = categoryId;

    // إعادة تحميل البيانات مع الفلاتر الجديدة
    await Future.wait([
      loadLiveAuctions(),
      loadUpcomingAuctions(),
      loadEndedAuctions(),
    ]);
  }

  /// تحميل معرفات المزادات في قائمة المتابعة
  Future<void> _loadWatchlistIds() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) {
        _watchlistAuctionIds.clear();
        return;
      }

      // TODO: إنشاء Use Case للحصول على معرفات المتابعة فقط
      // مؤقت - سنستخدم مجموعة فارغة
      _watchlistAuctionIds.clear();
      notifyListeners();
    } catch (e) {
      print('Warning: Failed to load watchlist IDs: $e');
    }
  }

  /// تبديل قائمة المتابعة
  Future<void> toggleWatchlist(String auctionId) async {
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
        // تحديث الحالة المحلية
        if (result.wasAdded) {
          _watchlistAuctionIds.add(auctionId);
        } else {
          _watchlistAuctionIds.remove(auctionId);
        }
        notifyListeners();

        // إشعار نجاح
        print(
            '✅ Watchlist ${result.wasAdded ? 'added' : 'removed'}: $auctionId');
      }
    } catch (e) {
      _setError('Failed to toggle watchlist: $e');
    }
  }

  /// تحديث المزادات
  Future<void> refreshAuctions() async {
    await Future.wait([
      loadLiveAuctions(),
      loadUpcomingAuctions(),
      loadEndedAuctions(),
    ]);
  }

  /// إعداد Realtime subscriptions
  void _setupRealtimeSubscriptions() {
    try {
      // الاشتراك في تحديثات المزادات المباشرة
      // TODO: تنفيذ Realtime subscriptions للمزادات المباشرة
    } catch (e) {
      print('Warning: Failed to setup realtime subscriptions: $e');
    }
  }

  /// تعيين حالة التحميل
  void _setLoading(bool loading) {
    _isLoading = loading;
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
    for (final subscription in _subscriptions) {
      subscription.unsubscribe();
    }
    _subscriptions.clear();

    super.dispose();
  }
}
