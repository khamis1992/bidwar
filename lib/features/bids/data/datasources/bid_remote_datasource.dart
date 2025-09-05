import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../models/bid_model.dart';

/// Remote Data Source للمزايدات
///
/// يتعامل مع قاعدة البيانات عبر Supabase
/// يطبق نمط DataSource وفقاً لقواعد BidWar
abstract class BidRemoteDataSource {
  /// وضع مزايدة جديدة
  Future<Map<String, dynamic>> placeBid({
    required String auctionId,
    required String bidderId,
    required int amount,
    bool isAutoBid = false,
    int? maxAutoBid,
  });

  /// الحصول على مزايدات مزاد معين
  Future<List<BidModel>> getBidsForAuction(String auctionId, {int limit = 20});

  /// الحصول على مزايدات المستخدم
  Future<List<BidModel>> getUserBids(String userId, {int limit = 20});

  /// الحصول على مزايدة واحدة
  Future<BidModel?> getBid(String bidId);

  /// تحديث حالة المزايدة
  Future<void> updateBidStatus(String bidId, String status);

  /// حذف مزايدة (إذا كان مسموحاً)
  Future<void> deleteBid(String bidId);

  /// الحصول على أعلى مزايدة للمزاد
  Future<BidModel?> getHighestBidForAuction(String auctionId);

  /// الحصول على مزايدات المستخدم في مزاد معين
  Future<List<BidModel>> getUserBidsForAuction(String userId, String auctionId);

  /// الاشتراك في تحديثات المزايدات
  dynamic subscribeToBidUpdates(
    String auctionId,
    Function(BidModel) onNewBid,
  );
}

/// تنفيذ Remote Data Source للمزايدات
class BidRemoteDataSourceImpl implements BidRemoteDataSource {
  final SupabaseClient _client;

  BidRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseClientService.client;

  @override
  Future<Map<String, dynamic>> placeBid({
    required String auctionId,
    required String bidderId,
    required int amount,
    bool isAutoBid = false,
    int? maxAutoBid,
  }) async {
    try {
      // استخدام stored procedure للمزايدة (process_bid)
      final response = await _client.rpc(
        'process_bid',
        params: {
          'p_auction_item_id': auctionId,
          'p_bidder_id': bidderId,
          'p_bid_amount': amount,
        },
      );

      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      throw Exception('Failed to place bid: $e');
    }
  }

  @override
  Future<List<BidModel>> getBidsForAuction(
    String auctionId, {
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('bids')
          .select('''
            *,
            bidder:user_profiles!bidder_id(
              id, full_name, profile_picture_url
            ),
            auction_item:auction_items!auction_item_id(
              id, title, images, current_highest_bid, status, end_time
            )
          ''')
          .eq('auction_item_id', auctionId)
          .order('placed_at', ascending: false)
          .limit(limit);

      return response.map((data) => BidModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get bids for auction: $e');
    }
  }

  @override
  Future<List<BidModel>> getUserBids(String userId, {int limit = 20}) async {
    try {
      final response = await _client
          .from('bids')
          .select('''
            *,
            bidder:user_profiles!bidder_id(
              id, full_name, profile_picture_url
            ),
            auction_item:auction_items!auction_item_id(
              id, title, images, current_highest_bid, status, end_time
            )
          ''')
          .eq('bidder_id', userId)
          .order('placed_at', ascending: false)
          .limit(limit);

      return response.map((data) => BidModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get user bids: $e');
    }
  }

  @override
  Future<BidModel?> getBid(String bidId) async {
    try {
      final response = await _client.from('bids').select('''
            *,
            bidder:user_profiles!bidder_id(
              id, full_name, profile_picture_url
            ),
            auction_item:auction_items!auction_item_id(
              id, title, images, current_highest_bid, status, end_time
            )
          ''').eq('id', bidId).maybeSingle();

      if (response == null) return null;

      return BidModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to get bid: $e');
    }
  }

  @override
  Future<void> updateBidStatus(String bidId, String status) async {
    try {
      await _client.from('bids').update({'status': status}).eq('id', bidId);
    } catch (e) {
      throw Exception('Failed to update bid status: $e');
    }
  }

  @override
  Future<void> deleteBid(String bidId) async {
    try {
      await _client.from('bids').delete().eq('id', bidId);
    } catch (e) {
      throw Exception('Failed to delete bid: $e');
    }
  }

  @override
  Future<BidModel?> getHighestBidForAuction(String auctionId) async {
    try {
      final response = await _client
          .from('bids')
          .select('''
            *,
            bidder:user_profiles!bidder_id(
              id, full_name, profile_picture_url
            ),
            auction_item:auction_items!auction_item_id(
              id, title, images, current_highest_bid, status, end_time
            )
          ''')
          .eq('auction_item_id', auctionId)
          .order('bid_amount', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return BidModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to get highest bid: $e');
    }
  }

  @override
  Future<List<BidModel>> getUserBidsForAuction(
    String userId,
    String auctionId,
  ) async {
    try {
      final response = await _client
          .from('bids')
          .select('''
            *,
            bidder:user_profiles!bidder_id(
              id, full_name, profile_picture_url
            ),
            auction_item:auction_items!auction_item_id(
              id, title, images, current_highest_bid, status, end_time
            )
          ''')
          .eq('bidder_id', userId)
          .eq('auction_item_id', auctionId)
          .order('placed_at', ascending: false);

      return response.map((data) => BidModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get user bids for auction: $e');
    }
  }

  @override
  dynamic subscribeToBidUpdates(
    String auctionId,
    Function(BidModel) onNewBid,
  ) {
    return _client
        .channel('bid_updates_$auctionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'bids',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'auction_item_id',
            value: auctionId,
          ),
          callback: (payload) async {
            try {
              // الحصول على بيانات المزايدة الكاملة مع العلاقات
              final bidData = await getBid(
                payload.newRecord['id'] as String,
              );
              if (bidData != null) {
                onNewBid(bidData);
              }
            } catch (e) {
              print('Error processing new bid update: $e');
            }
          },
        )
        .subscribe();
  }
}
