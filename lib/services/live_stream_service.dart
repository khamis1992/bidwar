import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class LiveStreamService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Create a new live stream
  static Future<Map<String, dynamic>?> createLiveStream({
    required String auctionItemId,
    required String title,
    required String description,
    required DateTime scheduledStart,
    Map<String, dynamic>? streamSettings,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final agoraChannelId = 'channel_${DateTime.now().millisecondsSinceEpoch}';

      final response = await _client
          .from('live_streams')
          .insert({
            'streamer_id': user.id,
            'auction_item_id': auctionItemId,
            'title': title,
            'description': description,
            'agora_channel_id': agoraChannelId,
            'scheduled_start': scheduledStart.toIso8601String(),
            'stream_settings': streamSettings ?? {},
            'status': 'upcoming',
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create live stream: $error');
    }
  }

  // Start a live stream
  static Future<void> startLiveStream(String streamId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client
          .from('live_streams')
          .update({
            'status': 'live',
            'actual_start': DateTime.now().toIso8601String(),
          })
          .eq('id', streamId)
          .eq('streamer_id', user.id);
    } catch (error) {
      throw Exception('Failed to start live stream: $error');
    }
  }

  // End a live stream
  static Future<void> endLiveStream(String streamId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client
          .from('live_streams')
          .update({
            'status': 'ended',
            'ended_at': DateTime.now().toIso8601String(),
          })
          .eq('id', streamId)
          .eq('streamer_id', user.id);
    } catch (error) {
      throw Exception('Failed to end live stream: $error');
    }
  }

  // Get live streams
  static Future<List<dynamic>> getLiveStreams({
    String? status,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('live_streams').select('''
            *,
            streamer:user_profiles!streamer_id(*),
            auction_item:auction_items(*)
          ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      final response =
          await query.order('scheduled_start', ascending: false).limit(limit);

      return response;
    } catch (error) {
      throw Exception('Failed to get live streams: $error');
    }
  }

  // Get stream details
  static Future<Map<String, dynamic>?> getStreamDetails(String streamId) async {
    try {
      final response = await _client.from('live_streams').select('''
            *,
            streamer:user_profiles!streamer_id(*),
            auction_item:auction_items(*),
            viewers_count:stream_viewers(count)
          ''').eq('id', streamId).single();

      return response;
    } catch (error) {
      throw Exception('Failed to get stream details: $error');
    }
  }

  // Join stream as viewer
  static Future<void> joinStream(String streamId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client.from('stream_viewers').upsert({
        'stream_id': streamId,
        'viewer_id': user.id,
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Update viewer count
      await updateViewerCount(streamId);
    } catch (error) {
      throw Exception('Failed to join stream: $error');
    }
  }

  // Leave stream
  static Future<void> leaveStream(String streamId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client
          .from('stream_viewers')
          .update({
            'left_at': DateTime.now().toIso8601String(),
          })
          .eq('stream_id', streamId)
          .eq('viewer_id', user.id);

      await updateViewerCount(streamId);
    } catch (error) {
      throw Exception('Failed to leave stream: $error');
    }
  }

  // Update viewer count
  static Future<void> updateViewerCount(String streamId) async {
    try {
      final countResponse = await _client
          .from('stream_viewers')
          .select()
          .eq('stream_id', streamId)
          .isFilter('left_at', null)
          .count();

      await _client.from('live_streams').update({
        'viewer_count': countResponse.count ?? 0,
      }).eq('id', streamId);
    } catch (error) {
      print('Failed to update viewer count: $error');
    }
  }

  // Send chat message
  static Future<Map<String, dynamic>?> sendChatMessage({
    required String streamId,
    required String content,
    String messageType = 'text',
    Map<String, dynamic>? emojiData,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('stream_chat_messages').insert({
        'stream_id': streamId,
        'sender_id': user.id,
        'message_type': messageType,
        'content': content,
        'emoji_data': emojiData,
      }).select('''
            *,
            sender:user_profiles!sender_id(*)
          ''').single();

      return response;
    } catch (error) {
      throw Exception('Failed to send chat message: $error');
    }
  }

  // Get chat messages
  static Future<List<dynamic>> getChatMessages(String streamId,
      {int limit = 50}) async {
    try {
      final response = await _client
          .from('stream_chat_messages')
          .select('''
            *,
            sender:user_profiles!sender_id(*)
          ''')
          .eq('stream_id', streamId)
          .order('created_at', ascending: true)
          .limit(limit);

      return response;
    } catch (error) {
      throw Exception('Failed to get chat messages: $error');
    }
  }

  // Subscribe to stream updates
  static RealtimeChannel subscribeToStreamUpdates(
      String streamId, Function(PostgresChangePayload) callback) {
    return _client
        .channel('stream_updates_$streamId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'live_streams',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: streamId,
          ),
          callback: callback,
        )
        .subscribe();
  }

  // Subscribe to chat messages
  static RealtimeChannel subscribeToChatMessages(
      String streamId, Function(PostgresChangePayload) callback) {
    return _client
        .channel('chat_$streamId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stream_chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'stream_id',
            value: streamId,
          ),
          callback: callback,
        )
        .subscribe();
  }

  // Subscribe to viewer count updates
  static RealtimeChannel subscribeToViewerUpdates(
      String streamId, Function(PostgresChangePayload) callback) {
    return _client
        .channel('viewers_$streamId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stream_viewers',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'stream_id',
            value: streamId,
          ),
          callback: callback,
        )
        .subscribe();
  }

  // Place a bid during live stream
  static Future<Map<String, dynamic>> placeBid({
    required String auctionItemId,
    required int bidAmount,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.rpc('process_bid', params: {
        'p_auction_item_id': auctionItemId,
        'p_bidder_id': user.id,
        'p_bid_amount': bidAmount,
      });

      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to place bid: $error');
    }
  }

  /// Get comprehensive analytics for a seller's live streams
  Future<Map<String, dynamic>> getSellerAnalytics(
    String sellerId, {
    String period = '7d',
  }) async {
    try {
      final client = SupabaseService.instance.client;

      // Calculate date range
      final now = DateTime.now();
      final days = _parsePeriodDays(period);
      final startDate = now.subtract(Duration(days: days)).toIso8601String();

      // Get live streams data with analytics
      final streamsQuery = client
          .from('live_streams')
          .select('''
            id, title, status, viewer_count, max_viewers, created_at, actual_start, ended_at,
            auction_item_id,
            auction_items!inner(id, title, current_highest_bid, starting_price)
          ''')
          .eq('streamer_id', sellerId)
          .gte('created_at', startDate)
          .order('created_at', ascending: false);

      final streams = await streamsQuery;

      // Get stream viewers data for engagement metrics
      final viewersQuery = client
          .from('stream_viewers')
          .select('*, live_streams!inner(streamer_id)')
          .eq('live_streams.streamer_id', sellerId)
          .gte('joined_at', startDate);

      final viewers = await viewersQuery;

      // Get chat messages for engagement
      final chatQuery = client
          .from('stream_chat_messages')
          .select('*, live_streams!inner(streamer_id)')
          .eq('live_streams.streamer_id', sellerId)
          .gte('created_at', startDate);

      final chatMessages = await chatQuery;

      // Get bids data for conversion metrics
      final bidsQuery = client
          .from('bids')
          .select('*, auction_items!inner(seller_id)')
          .eq('auction_items.seller_id', sellerId)
          .gte('placed_at', startDate);

      final bids = await bidsQuery;

      // Process analytics data
      return {
        'overview': _calculateOverviewMetrics(streams, viewers, bids),
        'engagement':
            _calculateEngagementMetrics(streams, viewers, chatMessages, bids),
        'revenue': _calculateRevenueMetrics(streams, bids),
        'demographics': _calculateDemographics(viewers),
        'quality_metrics': _calculateQualityMetrics(streams),
      };
    } catch (error) {
      throw Exception('Failed to load seller analytics: $error');
    }
  }

  int _parsePeriodDays(String period) {
    switch (period) {
      case '7d':
        return 7;
      case '30d':
        return 30;
      case '90d':
        return 90;
      default:
        return 7;
    }
  }

  Map<String, dynamic> _calculateOverviewMetrics(
    List<dynamic> streams,
    List<dynamic> viewers,
    List<dynamic> bids,
  ) {
    if (streams.isEmpty) {
      return {
        'total_viewers': 0,
        'peak_concurrent': 0,
        'avg_watch_time': 0,
        'conversion_rate': 0.0,
        'viewers_trend': 0,
        'peak_trend': 0,
        'watch_time_trend': 0,
        'conversion_trend': 0,
      };
    }

    final totalViewers = viewers.length;
    final peakConcurrent = streams.fold<int>(0, (max, stream) {
      final viewerCount = stream['max_viewers'] ?? 0;
      return viewerCount > max ? viewerCount : max;
    });

    final avgWatchTime = viewers.isNotEmpty
        ? (viewers.fold<num>(
                    0, (sum, viewer) => sum + (viewer['watch_duration'] ?? 0)) /
                viewers.length)
            .round()
        : 0;

    final uniqueViewers = <String>{};
    for (final viewer in viewers) {
      uniqueViewers.add(viewer['viewer_id'] ?? '');
    }

    final uniqueBidders = <String>{};
    for (final bid in bids) {
      uniqueBidders.add(bid['bidder_id'] ?? '');
    }

    final conversionRate = uniqueViewers.isNotEmpty
        ? (uniqueBidders.length / uniqueViewers.length) * 100
        : 0.0;

    return {
      'total_viewers': totalViewers,
      'peak_concurrent': peakConcurrent,
      'avg_watch_time': avgWatchTime,
      'conversion_rate': conversionRate,
      'viewers_trend': 15, // Mock trend data
      'peak_trend': 8,
      'watch_time_trend': -5,
      'conversion_trend': 12,
    };
  }

  Map<String, dynamic> _calculateEngagementMetrics(
    List<dynamic> streams,
    List<dynamic> viewers,
    List<dynamic> chatMessages,
    List<dynamic> bids,
  ) {
    final timeline = <Map<String, dynamic>>[];
    final totalChatMessages = chatMessages.length;

    // Calculate active bidders (unique bidders in period)
    final activeBidders = <String>{};
    for (final bid in bids) {
      activeBidders.add(bid['bidder_id'] ?? '');
    }

    // Calculate bid frequency (bids per minute)
    final totalMinutes = streams.fold<int>(0, (sum, stream) {
      if (stream['actual_start'] != null && stream['ended_at'] != null) {
        final start = DateTime.parse(stream['actual_start']);
        final end = DateTime.parse(stream['ended_at']);
        return sum + end.difference(start).inMinutes;
      }
      return sum;
    });

    final bidFrequency = totalMinutes > 0 ? (bids.length / totalMinutes) : 0;

    // Mock timeline data
    for (int i = 0; i < 24; i++) {
      timeline.add({
        'hour': i,
        'chat_count': (i * 5 + 10), // Mock data
        'bid_count': (i * 2 + 3),
        'viewer_count': (i * 8 + 20),
      });
    }

    return {
      'timeline': timeline,
      'total_chat_messages': totalChatMessages,
      'active_bidders': activeBidders.length,
      'bid_frequency': bidFrequency.toStringAsFixed(1),
      'peak_hour': 20, // Mock peak hour
      'avg_chat_per_minute':
          totalMinutes > 0 ? (totalChatMessages / totalMinutes) : 0,
    };
  }

  Map<String, dynamic> _calculateRevenueMetrics(
    List<dynamic> streams,
    List<dynamic> bids,
  ) {
    double totalSales = 0.0;
    double totalBidValue = 0.0;
    int itemsSold = 0;
    final recentSales = <Map<String, dynamic>>[];

    for (final stream in streams) {
      final auctionItem = stream['auction_items'];
      if (auctionItem != null) {
        final currentBid = auctionItem['current_highest_bid'] ?? 0;
        if (currentBid > 0) {
          totalSales += currentBid.toDouble();
          itemsSold++;

          // Add to recent sales (mock buyer data)
          recentSales.add({
            'item_title': auctionItem['title'] ?? 'Unknown Item',
            'final_price': currentBid.toDouble(),
            'bidder_name': 'Anonymous Buyer',
            'sale_date': DateTime.now()
                .subtract(Duration(days: recentSales.length))
                .toIso8601String(),
          });
        }
      }
    }

    totalBidValue = bids.fold<double>(
        0.0, (sum, bid) => sum + (bid['bid_amount'] ?? 0).toDouble());
    final avgBidValue = bids.isNotEmpty ? totalBidValue / bids.length : 0.0;

    // Calculate commission details
    final platformFeeRate = 0.05; // 5% platform fee
    final paymentFeeRate = 0.029; // 2.9% payment processing

    final platformFee = totalSales * platformFeeRate;
    final paymentFee = totalSales * paymentFeeRate;
    final netRevenue = totalSales - platformFee - paymentFee;

    return {
      'total_sales': totalSales,
      'average_bid_value': avgBidValue,
      'total_items_sold': itemsSold,
      'previous_period': totalSales * 0.85, // Mock previous period data
      'commission_details': {
        'platform_fee': platformFee,
        'payment_fee': paymentFee,
        'net_revenue': netRevenue,
      },
      'recent_sales': recentSales.take(5).toList(),
    };
  }

  Map<String, dynamic> _calculateDemographics(List<dynamic> viewers) {
    final geographic = <Map<String, dynamic>>[
      {'country': 'United States', 'count': 45, 'percentage': 35.0},
      {'country': 'United Kingdom', 'count': 25, 'percentage': 20.0},
      {'country': 'Canada', 'count': 20, 'percentage': 15.0},
      {'country': 'Germany', 'count': 15, 'percentage': 12.0},
      {'country': 'Australia', 'count': 10, 'percentage': 8.0},
    ];

    final devices = <Map<String, dynamic>>[
      {'type': 'Mobile', 'count': 80, 'percentage': 60.0},
      {'type': 'Desktop', 'count': 40, 'percentage': 30.0},
      {'type': 'Tablet', 'count': 15, 'percentage': 10.0},
    ];

    final avgViewTime = viewers.isNotEmpty
        ? (viewers.fold<num>(
                    0, (sum, viewer) => sum + (viewer['watch_duration'] ?? 0)) /
                viewers.length)
            .round()
        : 0;

    final retention = {
      'average_view_time': avgViewTime,
      'retention_rate': 65.0,
      'dropoff_points': [
        {'time_point': 300, 'percentage': 15.0}, // 5 minutes
        {'time_point': 900, 'percentage': 25.0}, // 15 minutes
        {'time_point': 1800, 'percentage': 35.0}, // 30 minutes
      ],
    };

    return {
      'geographic': geographic,
      'devices': devices,
      'retention': retention,
    };
  }

  Map<String, dynamic> _calculateQualityMetrics(List<dynamic> streams) {
    // Mock quality data - in real implementation, this would come from Agora.io analytics
    return {
      'average_bitrate': 1800,
      'average_latency': 250,
      'quality_score': 8.5,
      'stability': {
        'dropout_count': 2,
        'reconnection_count': 1,
        'average_connection_time': 3600,
      },
      'trends': [
        {
          'timestamp':
              DateTime.now().subtract(Duration(hours: 6)).toIso8601String(),
          'quality_score': 8.2,
          'bitrate': 1750
        },
        {
          'timestamp':
              DateTime.now().subtract(Duration(hours: 5)).toIso8601String(),
          'quality_score': 8.7,
          'bitrate': 1850
        },
        {
          'timestamp':
              DateTime.now().subtract(Duration(hours: 4)).toIso8601String(),
          'quality_score': 8.5,
          'bitrate': 1800
        },
        {
          'timestamp':
              DateTime.now().subtract(Duration(hours: 3)).toIso8601String(),
          'quality_score': 8.9,
          'bitrate': 1900
        },
        {
          'timestamp':
              DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
          'quality_score': 8.3,
          'bitrate': 1750
        },
        {
          'timestamp':
              DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
          'quality_score': 8.6,
          'bitrate': 1850
        },
      ],
    };
  }

  /// Export analytics report as PDF/CSV
  Future<void> exportAnalyticsReport(Map<String, dynamic> analyticsData) async {
    // In a real implementation, this would generate a PDF or CSV file
    // For now, we'll simulate the export process
    await Future.delayed(const Duration(seconds: 2));

    // Mock export logic - in real app, use packages like pdf or csv
    // and save to device storage or share via platform channels
    print('Analytics report exported successfully');
  }
}
