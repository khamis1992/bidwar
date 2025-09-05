import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local Notification Service for BidWar
///
/// يدير الإشعارات المحلية للمزايدات وانتهاء المزادات
/// يتبع قواعد BidWar للخدمات
class LocalNotificationService {
  static LocalNotificationService? _instance;
  static LocalNotificationService get instance =>
      _instance ??= LocalNotificationService._();

  LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// تهيئة خدمة الإشعارات المحلية
  Future<bool> initialize() async {
    try {
      print('🔔 Initializing Local Notification Service...');

      // إعدادات Android
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // إعدادات iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // إعدادات التهيئة
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // تهيئة الخدمة
      final result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = result ?? false;

      if (_isInitialized) {
        print('✅ Local Notification Service initialized successfully');

        // طلب الأذونات للـ Android 13+
        await _requestPermissions();
      } else {
        print('❌ Failed to initialize Local Notification Service');
      }

      return _isInitialized;
    } catch (e) {
      print('❌ Error initializing Local Notification Service: $e');
      return false;
    }
  }

  /// طلب أذونات الإشعارات
  Future<void> _requestPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          await androidPlugin.requestNotificationsPermission();
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

        if (iosPlugin != null) {
          await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      }
    } catch (e) {
      print('Warning: Failed to request notification permissions: $e');
    }
  }

  /// معالجة النقر على الإشعار
  void _onNotificationTapped(NotificationResponse response) {
    try {
      print('🔔 Notification tapped: ${response.payload}');

      // TODO: معالجة التنقل حسب نوع الإشعار
      // يمكن إضافة navigation logic هنا لاحقاً
    } catch (e) {
      print('Error handling notification tap: $e');
    }
  }

  /// إشعار نجاح المزايدة
  Future<void> showBidSuccessNotification({
    required String auctionTitle,
    required int bidAmount,
    String? auctionId,
  }) async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'bid_success',
        'Bid Success',
        channelDescription: 'Notifications for successful bids',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF27AE60), // AppTheme.successLight
        ledColor: Color(0xFF27AE60),
        ledOnMs: 1000,
        ledOffMs: 500,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'bid_success',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'Bid Placed Successfully! 🎯',
        'Your bid of \$${bidAmount} on "${auctionTitle}" has been placed.',
        notificationDetails,
        payload: auctionId != null ? 'auction_detail:$auctionId' : null,
      );

      print('✅ Bid success notification sent');
    } catch (e) {
      print('❌ Error showing bid success notification: $e');
    }
  }

  /// إشعار اقتراب انتهاء مزاد متابع
  Future<void> showAuctionEndingNotification({
    required String auctionTitle,
    required int currentPrice,
    required int minutesRemaining,
    String? auctionId,
  }) async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'auction_ending',
        'Auction Ending',
        channelDescription: 'Notifications for auctions ending soon',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFF39C12), // AppTheme.warningLight
        ledColor: Color(0xFFF39C12),
        ledOnMs: 1000,
        ledOffMs: 500,
        enableVibration: true,
        playSound: true,
        ticker: 'Auction ending soon!',
      );

      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'auction_ending',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        '⏰ Auction Ending Soon!',
        '"${auctionTitle}" ends in ${minutesRemaining} minutes. Current bid: \$${currentPrice}',
        notificationDetails,
        payload: auctionId != null ? 'auction_detail:$auctionId' : null,
      );

      print('✅ Auction ending notification sent');
    } catch (e) {
      print('❌ Error showing auction ending notification: $e');
    }
  }

  /// إشعار مزايدة جديدة على مزاد المستخدم
  Future<void> showNewBidNotification({
    required String auctionTitle,
    required int newBidAmount,
    required String bidderName,
    String? auctionId,
  }) async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'new_bid',
        'New Bid',
        channelDescription: 'Notifications for new bids on your auctions',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF1B365D), // AppTheme.primaryLight
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'new_bid',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'New Bid Received! 💰',
        '${bidderName} bid \$${newBidAmount} on "${auctionTitle}"',
        notificationDetails,
        payload: auctionId != null ? 'auction_detail:$auctionId' : null,
      );

      print('✅ New bid notification sent');
    } catch (e) {
      print('❌ Error showing new bid notification: $e');
    }
  }

  /// إشعار تم تجاوز مزايدة المستخدم
  Future<void> showBidOutbidNotification({
    required String auctionTitle,
    required int newHighestBid,
    String? auctionId,
  }) async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'bid_outbid',
        'Bid Outbid',
        channelDescription: 'Notifications when your bid is outbid',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFFF6B35), // AppTheme.secondaryLight
        ledColor: Color(0xFFFF6B35),
        ledOnMs: 1000,
        ledOffMs: 500,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'bid_outbid',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'Your Bid Was Outbid! 📈',
        'Someone bid \$${newHighestBid} on "${auctionTitle}". Place a new bid?',
        notificationDetails,
        payload: auctionId != null ? 'auction_detail:$auctionId' : null,
      );

      print('✅ Bid outbid notification sent');
    } catch (e) {
      print('❌ Error showing bid outbid notification: $e');
    }
  }

  /// إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling notifications: $e');
    }
  }

  /// إلغاء إشعار محدد
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      print('✅ Notification $id cancelled');
    } catch (e) {
      print('❌ Error cancelling notification $id: $e');
    }
  }

  /// التحقق من حالة التهيئة
  bool get isInitialized => _isInitialized;

  /// الحصول على معلومات الحالة
  Map<String, dynamic> getStatus() {
    return {
      'initialized': _isInitialized,
      'platform': defaultTargetPlatform.name,
    };
  }

  /// طباعة حالة الخدمة
  void printStatus() {
    final status = getStatus();
    print('🔔 Local Notification Service Status:');
    print('   - Initialized: ${status['initialized'] ? "✅" : "❌"}');
    print('   - Platform: ${status['platform']}');
  }
}
