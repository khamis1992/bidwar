import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();
  NotificationService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get user notifications
  Future<List<Map<String, dynamic>>> getNotifications({
    bool? isRead,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return [];

      var query = _client.from('notifications').select('''
            *,
            related_auction:auction_items(title, images)
          ''').eq('user_id', user.id);

      if (isRead != null) {
        query = query.eq('is_read', isRead);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get notifications: $error');
    }
  }

  // Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return 0;

      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .eq('is_read', false)
          .count();

      return response.count ?? 0;
    } catch (error) {
      return 0;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } catch (error) {
      throw Exception('Failed to mark notification as read: $error');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return;

      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
    } catch (error) {
      throw Exception('Failed to mark all notifications as read: $error');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _client.from('notifications').delete().eq('id', notificationId);
    } catch (error) {
      throw Exception('Failed to delete notification: $error');
    }
  }

  // Create notification (used internally)
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedAuctionId,
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'related_auction_id': relatedAuctionId,
      });
    } catch (error) {
      throw Exception('Failed to create notification: $error');
    }
  }

  // Subscribe to real-time notifications
  RealtimeChannel subscribeToNotifications(
      Function(Map<String, dynamic>) callback) {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    return _client
        .channel('user_notifications_${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) => callback(payload.newRecord ?? {}),
        )
        .subscribe();
  }

  // Get notification types for filtering
  List<Map<String, String>> getNotificationTypes() {
    return [
      {'value': 'bid_outbid', 'label': 'Bid Outbid'},
      {'value': 'auction_ending', 'label': 'Auction Ending'},
      {'value': 'auction_won', 'label': 'Auction Won'},
      {'value': 'new_bid', 'label': 'New Bid'},
      {'value': 'auction_started', 'label': 'Auction Started'},
      {'value': 'payment_completed', 'label': 'Payment Completed'},
      {'value': 'credit_low', 'label': 'Low Credits'},
    ];
  }
}
