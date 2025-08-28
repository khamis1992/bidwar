import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class AuctionService {
  static AuctionService? _instance;
  static AuctionService get instance => _instance ??= AuctionService._();
  AuctionService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get all auction items with filters
  Future<List<Map<String, dynamic>>> getAuctionItems({
    String? categoryId,
    String? status,
    String? search,
    bool? featured,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client.from('auction_items').select('''
            *,
            seller:user_profiles!seller_id(full_name, profile_picture_url),
            category:categories(name, image_url),
            bid_count:bids(count)
          ''');

      // Apply filters
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (status != null) {
        query = query.eq('status', status);
      }
      if (featured != null) {
        query = query.eq('featured', featured);
      }
      if (search != null && search.isNotEmpty) {
        query = query.or('title.ilike.%$search%,description.ilike.%$search%');
      }

      // Apply ordering and pagination
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get auction items: $error');
    }
  }

  // Get single auction item with details
  Future<Map<String, dynamic>?> getAuctionItem(String itemId) async {
    try {
      final response = await _client.from('auction_items').select('''
            *,
            seller:user_profiles!seller_id(full_name, profile_picture_url, is_verified),
            category:categories(name),
            bids:bids(
              id, bid_amount, placed_at,
              bidder:user_profiles!bidder_id(full_name)
            )
          ''').eq('id', itemId).single();

      // Increment view count
      await _client.from('auction_items').update(
          {'view_count': (response['view_count'] ?? 0) + 1}).eq('id', itemId);

      return response;
    } catch (error) {
      throw Exception('Failed to get auction item: $error');
    }
  }

  // Create new auction item
  Future<String> createAuctionItem({
    required String title,
    required String description,
    required int startingPrice,
    int? reservePrice,
    required int bidIncrement,
    required String categoryId,
    required DateTime startTime,
    required DateTime endTime,
    String? condition,
    String? brand,
    String? model,
    Map<String, dynamic>? specifications,
    List<String>? images,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await _client
          .from('auction_items')
          .insert({
            'seller_id': user.id,
            'title': title,
            'description': description,
            'starting_price': startingPrice,
            'reserve_price': reservePrice,
            'bid_increment': bidIncrement,
            'category_id': categoryId,
            'start_time': startTime.toIso8601String(),
            'end_time': endTime.toIso8601String(),
            'condition': condition,
            'brand': brand,
            'model': model,
            'specifications': specifications,
            'images': images ?? [],
          })
          .select('id')
          .single();

      return response['id'];
    } catch (error) {
      throw Exception('Failed to create auction: $error');
    }
  }

  // Place a bid
  Future<Map<String, dynamic>> placeBid({
    required String auctionItemId,
    required int bidAmount,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

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

  // Get user's bids
  Future<List<Map<String, dynamic>>> getUserBids({int limit = 20}) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('bids')
          .select('''
            *,
            auction_item:auction_items(
              id, title, images, current_highest_bid, end_time, status
            )
          ''')
          .eq('bidder_id', user.id)
          .order('placed_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get user bids: $error');
    }
  }

  // Get user's auction items
  Future<List<Map<String, dynamic>>> getUserAuctions({int limit = 20}) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('auction_items')
          .select('''
            *,
            category:categories(name),
            bid_count:bids(count)
          ''')
          .eq('seller_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get user auctions: $error');
    }
  }

  // Add to watchlist
  Future<void> addToWatchlist(String auctionItemId) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _client.from('watchlist').insert({
        'user_id': user.id,
        'auction_item_id': auctionItemId,
      });
    } catch (error) {
      throw Exception('Failed to add to watchlist: $error');
    }
  }

  // Remove from watchlist
  Future<void> removeFromWatchlist(String auctionItemId) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _client
          .from('watchlist')
          .delete()
          .eq('user_id', user.id)
          .eq('auction_item_id', auctionItemId);
    } catch (error) {
      throw Exception('Failed to remove from watchlist: $error');
    }
  }

  // Get user's watchlist
  Future<List<Map<String, dynamic>>> getUserWatchlist() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return [];

      final response = await _client.from('watchlist').select('''
            *,
            auction_item:auction_items(
              *, 
              category:categories(name),
              seller:user_profiles!seller_id(full_name)
            )
          ''').eq('user_id', user.id).order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get watchlist: $error');
    }
  }

  // Check if item is in watchlist
  Future<bool> isInWatchlist(String auctionItemId) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return false;

      final response = await _client
          .from('watchlist')
          .select('id')
          .eq('user_id', user.id)
          .eq('auction_item_id', auctionItemId);

      return response.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  // Get categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get categories: $error');
    }
  }

  // Subscribe to auction updates
  RealtimeChannel subscribeToAuctionUpdates(
      String auctionItemId, Function(Map<String, dynamic>) callback) {
    return _client
        .channel('auction_updates_$auctionItemId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'auction_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: auctionItemId,
          ),
          callback: (payload) => callback(payload.newRecord ?? {}),
        )
        .subscribe();
  }

  // Subscribe to bid updates
  RealtimeChannel subscribeToBidUpdates(
      String auctionItemId, Function(Map<String, dynamic>) callback) {
    return _client
        .channel('bid_updates_$auctionItemId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'bids',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'auction_item_id',
            value: auctionItemId,
          ),
          callback: (payload) => callback(payload.newRecord ?? {}),
        )
        .subscribe();
  }

  // Get live auctions with streams
  Future<List<Map<String, dynamic>>> getLiveAuctions({
    String? categoryId,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client.from('auction_items').select('''
            *,
            seller:user_profiles!seller_id(full_name, profile_picture_url),
            category:categories(name, image_url),
            live_stream:live_streams!auction_item_id(
              id, title, status, viewer_count, scheduled_start, actual_start
            ),
            bid_count:bids(count)
          ''').not('live_streams.id', 'iss', null);

      // Apply filters
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (search != null && search.isNotEmpty) {
        query = query.or('title.ilike.%$search%,description.ilike.%$search%');
      }

      // Apply ordering and pagination
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get live auctions: $error');
    }
  }

  // Get regular auctions (non-live)
  Future<List<Map<String, dynamic>>> getRegularAuctions({
    String? categoryId,
    String? status,
    String? search,
    bool? featured,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // First, get all auction IDs that have live streams
      final liveStreamAuctionIds = await _client
          .from('live_streams')
          .select('auction_item_id')
          .not('auction_item_id', 'is', null);

      // Extract the auction item IDs from the response
      final List<String> excludeIds = liveStreamAuctionIds
          .map((item) => item['auction_item_id'] as String)
          .toList();

      var query = _client.from('auction_items').select('''
            *,
            seller:user_profiles!seller_id(full_name, profile_picture_url),
            category:categories(name, image_url),
            bid_count:bids(count)
          ''');

      // Exclude auction items that have live streams
      if (excludeIds.isNotEmpty) {
        query = query.not('id', 'in', excludeIds);
      }

      // Apply filters
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (status != null) {
        query = query.eq('status', status);
      }
      if (featured != null) {
        query = query.eq('featured', featured);
      }
      if (search != null && search.isNotEmpty) {
        query = query.or('title.ilike.%$search%,description.ilike.%$search%');
      }

      // Apply ordering and pagination
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get regular auctions: $error');
    }
  }
}
