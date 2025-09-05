import 'package:flutter/foundation.dart';

import '../../../features/watchlist/data/datasources/watchlist_remote_datasource.dart';
import '../../../features/watchlist/data/repositories/watchlist_repository_impl.dart';
import '../../../features/watchlist/domain/entities/watchlist_entity.dart';
import '../../../features/watchlist/domain/usecases/toggle_watchlist_usecase.dart';
import '../../../services/auth_service.dart';
import '../../../services/local_notification_service.dart';

/// My Watchlist Controller - إدارة حالة صفحة قائمة المتابعة
///
/// يدير قائمة المتابعة والإشعارات
/// يتبع قواعد BidWar لإدارة الحالة
class MyWatchlistController extends ChangeNotifier {
  // Dependencies
  late final ToggleWatchlistUseCase _toggleWatchlistUseCase;

  // State
  List<WatchlistEntity> _watchlistItems = [];
  List<WatchlistEntity> _activeWatchlistItems = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<WatchlistEntity> get watchlistItems => _watchlistItems;
  List<WatchlistEntity> get activeWatchlistItems => _activeWatchlistItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Stats
  int get endingSoonCount =>
      _activeWatchlistItems.where((item) => item.isEndingSoon).length;

  MyWatchlistController() {
    _initializeDependencies();
  }

  void _initializeDependencies() {
    final watchlistDataSource = WatchlistRemoteDataSourceImpl();
    final watchlistRepository = WatchlistRepositoryImpl(
      remoteDataSource: watchlistDataSource,
    );

    // TODO: إنشاء GetWatchlistUseCase
    // _getWatchlistUseCase = GetWatchlistUseCase(watchlistRepository);
    _toggleWatchlistUseCase = ToggleWatchlistUseCase(watchlistRepository);
  }

  /// تهيئة صفحة قائمة المتابعة
  Future<void> initialize() async {
    try {
      _setLoading(true);

      await Future.wait([
        loadActiveWatchlist(),
        loadAllWatchlist(),
      ]);

      // إعداد مراقبة الإشعارات للمزادات القريبة من الانتهاء
      _setupEndingNotifications();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// تحميل المزادات المتابعة النشطة
  Future<void> loadActiveWatchlist() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) {
        _activeWatchlistItems.clear();
        return;
      }

      // TODO: استخدام GetWatchlistUseCase عند إنشاؤه
      // final params = GetWatchlistParams.activeOnly(userId: user.id);
      // _activeWatchlistItems = await _getWatchlistUseCase(params);

      // مؤقت
      _activeWatchlistItems = [];
      notifyListeners();
    } catch (e) {
      _setError('Failed to load active watchlist: $e');
    }
  }

  /// تحميل جميع المزادات المتابعة
  Future<void> loadAllWatchlist() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) {
        _watchlistItems.clear();
        return;
      }

      // TODO: استخدام GetWatchlistUseCase عند إنشاؤه
      // final params = GetWatchlistParams(userId: user.id);
      // _watchlistItems = await _getWatchlistUseCase(params);

      // مؤقت
      _watchlistItems = [];
      notifyListeners();
    } catch (e) {
      _setError('Failed to load watchlist: $e');
    }
  }

  /// إزالة من قائمة المتابعة
  Future<void> removeFromWatchlist(String auctionId) async {
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
        // إزالة من القوائم المحلية
        _watchlistItems.removeWhere((item) => item.auctionItemId == auctionId);
        _activeWatchlistItems
            .removeWhere((item) => item.auctionItemId == auctionId);
        notifyListeners();

        print('✅ Removed from watchlist: $auctionId');
      }
    } catch (e) {
      _setError('Failed to remove from watchlist: $e');
    }
  }

  /// مسح قائمة المتابعة كاملة
  Future<void> clearWatchlist() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) {
        throw Exception('Please sign in to use watchlist');
      }

      // TODO: إنشاء ClearWatchlistUseCase أو استخدام Repository مباشرة
      // await _clearWatchlistUseCase(user.id);

      // مؤقت - مسح القوائم المحلية
      _watchlistItems.clear();
      _activeWatchlistItems.clear();
      notifyListeners();

      print('✅ Watchlist cleared');
    } catch (e) {
      throw Exception('Failed to clear watchlist: $e');
    }
  }

  /// تحديث قائمة المتابعة
  Future<void> refreshWatchlist() async {
    await Future.wait([
      loadActiveWatchlist(),
      loadAllWatchlist(),
    ]);
  }

  /// إعداد إشعارات اقتراب انتهاء المزادات
  void _setupEndingNotifications() {
    try {
      // مراقبة المزادات القريبة من الانتهاء
      for (final item in _activeWatchlistItems) {
        if (item.isLive && item.isEndingSoon) {
          _scheduleEndingNotification(item);
        }
      }
    } catch (e) {
      print('Warning: Failed to setup ending notifications: $e');
    }
  }

  /// جدولة إشعار اقتراب انتهاء مزاد
  void _scheduleEndingNotification(WatchlistEntity item) {
    try {
      // إرسال إشعار فوري إذا كان المزاد ينتهي خلال 10 دقائق
      if (item.timeRemaining.inMinutes <= 10 &&
          item.timeRemaining.inMinutes > 0) {
        LocalNotificationService.instance.showAuctionEndingNotification(
          auctionTitle: item.auctionTitle,
          currentPrice: item.currentPrice,
          minutesRemaining: item.timeRemaining.inMinutes,
          auctionId: item.auctionItemId,
        );
      }
    } catch (e) {
      print('Warning: Failed to schedule ending notification: $e');
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
}

/// مؤقت - سيتم استبداله بـ GetWatchlistUseCase
class GetWatchlistUseCase {
  GetWatchlistUseCase(repository);

  Future<List<WatchlistEntity>> call(params) async {
    return [];
  }
}
