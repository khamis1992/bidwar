import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../models/watchlist_model.dart';

/// Remote Data Source لقائمة المتابعة
///
/// يتعامل مع قاعدة البيانات عبر Supabase
/// يطبق نمط DataSource وفقاً لقواعد BidWar
abstract class WatchlistRemoteDataSource {
  /// إضافة مزاد لقائمة المتابعة
  Future<void> addToWatchlist({
    required String userId,
    required String auctionId,
  });

  /// إزالة مزاد من قائمة المتابعة
  Future<void> removeFromWatchlist({
    required String userId,
    required String auctionId,
  });

  /// تبديل حالة المزاد في قائمة المتابعة
  Future<bool> toggleWatchlist({
    required String userId,
    required String auctionId,
  });

  /// الحصول على قائمة متابعة المستخدم
  Future<List<WatchlistModel>> getUserWatchlist(
    String userId, {
    int limit = 20,
  });

  /// التحقق من وجود مزاد في قائمة المتابعة
  Future<bool> isInWatchlist({
    required String userId,
    required String auctionId,
  });

  /// الحصول على عدد المزادات في قائمة المتابعة
  Future<int> getWatchlistCount(String userId);

  /// الحصول على المزادات المتابعة النشطة فقط
  Future<List<WatchlistModel>> getActiveWatchlistItems(
    String userId, {
    int limit = 20,
  });

  /// مسح قائمة المتابعة
  Future<void> clearWatchlist(String userId);
}

/// تنفيذ Remote Data Source لقائمة المتابعة
class WatchlistRemoteDataSourceImpl implements WatchlistRemoteDataSource {
  final SupabaseClient _client;

  WatchlistRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseClientService.client;

  @override
  Future<void> addToWatchlist({
    required String userId,
    required String auctionId,
  }) async {
    try {
      await _client.from('watchlist').insert({
        'user_id': userId,
        'auction_item_id': auctionId,
      });
    } catch (e) {
      // التحقق من خطأ التكرار
      if (e.toString().contains('duplicate') ||
          e.toString().contains('unique_violation')) {
        // العنصر موجود بالفعل، لا نحتاج لعمل شيء
        return;
      }
      throw Exception('Failed to add to watchlist: $e');
    }
  }

  @override
  Future<void> removeFromWatchlist({
    required String userId,
    required String auctionId,
  }) async {
    try {
      await _client
          .from('watchlist')
          .delete()
          .eq('user_id', userId)
          .eq('auction_item_id', auctionId);
    } catch (e) {
      throw Exception('Failed to remove from watchlist: $e');
    }
  }

  @override
  Future<bool> toggleWatchlist({
    required String userId,
    required String auctionId,
  }) async {
    try {
      final isInWatchlist = await this.isInWatchlist(
        userId: userId,
        auctionId: auctionId,
      );

      if (isInWatchlist) {
        await removeFromWatchlist(userId: userId, auctionId: auctionId);
        return false; // تم الإزالة
      } else {
        await addToWatchlist(userId: userId, auctionId: auctionId);
        return true; // تم الإضافة
      }
    } catch (e) {
      throw Exception('Failed to toggle watchlist: $e');
    }
  }

  @override
  Future<List<WatchlistModel>> getUserWatchlist(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('watchlist')
          .select('''
            *,
            auction_item:auction_items!auction_item_id(
              *,
              seller:user_profiles!seller_id(
                id, full_name, profile_picture_url
              ),
              category:categories(id, name, image_url),
              bid_count:bids(count)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((data) => WatchlistModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get user watchlist: $e');
    }
  }

  @override
  Future<bool> isInWatchlist({
    required String userId,
    required String auctionId,
  }) async {
    try {
      final response = await _client
          .from('watchlist')
          .select('id')
          .eq('user_id', userId)
          .eq('auction_item_id', auctionId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check watchlist status: $e');
    }
  }

  @override
  Future<int> getWatchlistCount(String userId) async {
    try {
      final response =
          await _client.from('watchlist').select('id').eq('user_id', userId);

      return response.length;
    } catch (e) {
      throw Exception('Failed to get watchlist count: $e');
    }
  }

  @override
  Future<List<WatchlistModel>> getActiveWatchlistItems(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('watchlist')
          .select('''
            *,
            auction_item:auction_items!auction_item_id(
              *,
              seller:user_profiles!seller_id(
                id, full_name, profile_picture_url
              ),
              category:categories(id, name, image_url),
              bid_count:bids(count)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map((data) => WatchlistModel.fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active watchlist items: $e');
    }
  }

  @override
  Future<void> clearWatchlist(String userId) async {
    try {
      await _client.from('watchlist').delete().eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to clear watchlist: $e');
    }
  }
}
