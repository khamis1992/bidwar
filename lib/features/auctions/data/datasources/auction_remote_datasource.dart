import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../models/auction_model.dart';

/// Remote Data Source للمزادات
///
/// يتعامل مع قاعدة البيانات عبر Supabase
/// يطبق نمط DataSource وفقاً لقواعد BidWar
abstract class AuctionRemoteDataSource {
  /// الحصول على قائمة المزادات مع فلاتر
  Future<List<AuctionModel>> getAuctions({
    bool? activeOnly,
    String? query,
    String? categoryId,
    String? status,
    bool? featured,
    int limit = 20,
    int offset = 0,
  });

  /// الحصول على مزاد واحد بالتفاصيل
  Future<AuctionModel?> getAuction(String id);

  /// إنشاء مزاد جديد
  Future<String> createAuction(AuctionModel auction);

  /// تحديث مزاد موجود
  Future<void> updateAuction(String id, Map<String, dynamic> updates);

  /// حذف مزاد
  Future<void> deleteAuction(String id);

  /// الحصول على مزادات المستخدم
  Future<List<AuctionModel>> getUserAuctions(String userId, {int limit = 20});

  /// البحث في المزادات
  Future<List<AuctionModel>> searchAuctions(String query, {int limit = 20});

  /// الحصول على المزادات المميزة
  Future<List<AuctionModel>> getFeaturedAuctions({int limit = 10});

  /// الحصول على المزادات المباشرة
  Future<List<AuctionModel>> getLiveAuctions({int limit = 20});

  /// الاشتراك في تحديثات المزاد
  dynamic subscribeToAuctionUpdates(
    String auctionId,
    Function(AuctionModel) onUpdate,
  );
}

/// تنفيذ Remote Data Source للمزادات
class AuctionRemoteDataSourceImpl implements AuctionRemoteDataSource {
  final SupabaseClient _client;

  AuctionRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseClientService.client;

  @override
  Future<List<AuctionModel>> getAuctions({
    bool? activeOnly,
    String? query,
    String? categoryId,
    String? status,
    bool? featured,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var supabaseQuery = _client.from('auction_items').select('''
            *,
            seller:user_profiles!seller_id(
              id, full_name, profile_picture_url, is_verified
            ),
            category:categories(id, name, image_url),
            bid_count:bids(count)
          ''');

      // تطبيق الفلاتر
      if (activeOnly == true) {
        supabaseQuery = supabaseQuery.in_('status', ['upcoming', 'live']);
      }

      if (categoryId != null) {
        supabaseQuery = supabaseQuery.eq('category_id', categoryId);
      }

      if (status != null) {
        supabaseQuery = supabaseQuery.eq('status', status);
      }

      if (featured != null) {
        supabaseQuery = supabaseQuery.eq('featured', featured);
      }

      if (query != null && query.isNotEmpty) {
        supabaseQuery = supabaseQuery.or(
          'title.ilike.%$query%,description.ilike.%$query%,brand.ilike.%$query%',
        );
      }

      // ترتيب وتحديد العدد
      final response = await supabaseQuery
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((data) => AuctionModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get auctions: $e');
    }
  }

  @override
  Future<AuctionModel?> getAuction(String id) async {
    try {
      final response = await _client.from('auction_items').select('''
            *,
            seller:user_profiles!seller_id(
              id, full_name, profile_picture_url, is_verified, phone
            ),
            category:categories(id, name, description, image_url),
            bids:bids(
              id, bid_amount, placed_at, status,
              bidder:user_profiles!bidder_id(id, full_name, profile_picture_url)
            )
          ''').eq('id', id).maybeSingle();

      if (response == null) return null;

      // زيادة عداد المشاهدات
      await _incrementViewCount(id);

      return AuctionModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to get auction: $e');
    }
  }

  @override
  Future<String> createAuction(AuctionModel auction) async {
    try {
      final response = await _client
          .from('auction_items')
          .insert(auction.toCreateMap())
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create auction: $e');
    }
  }

  @override
  Future<void> updateAuction(String id, Map<String, dynamic> updates) async {
    try {
      await _client.from('auction_items').update({
        ...updates,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update auction: $e');
    }
  }

  @override
  Future<void> deleteAuction(String id) async {
    try {
      await _client.from('auction_items').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete auction: $e');
    }
  }

  @override
  Future<List<AuctionModel>> getUserAuctions(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('auction_items')
          .select('''
            *,
            category:categories(id, name, image_url),
            bid_count:bids(count)
          ''')
          .eq('seller_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((data) => AuctionModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get user auctions: $e');
    }
  }

  @override
  Future<List<AuctionModel>> searchAuctions(
    String query, {
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('auction_items')
          .select('''
            *,
            seller:user_profiles!seller_id(
              id, full_name, profile_picture_url
            ),
            category:categories(id, name, image_url),
            bid_count:bids(count)
          ''')
          .or(
            'title.ilike.%$query%,description.ilike.%$query%,brand.ilike.%$query%,model.ilike.%$query%',
          )
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((data) => AuctionModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to search auctions: $e');
    }
  }

  @override
  Future<List<AuctionModel>> getFeaturedAuctions({int limit = 10}) async {
    try {
      final response = await _client
          .from('auction_items')
          .select('''
            *,
            seller:user_profiles!seller_id(
              id, full_name, profile_picture_url
            ),
            category:categories(id, name, image_url),
            bid_count:bids(count)
          ''')
          .eq('featured', true)
          .in_('status', ['upcoming', 'live'])
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map((data) => AuctionModel.fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get featured auctions: $e');
    }
  }

  @override
  Future<List<AuctionModel>> getLiveAuctions({int limit = 20}) async {
    try {
      final response = await _client
          .from('auction_items')
          .select('''
            *,
            seller:user_profiles!seller_id(
              id, full_name, profile_picture_url
            ),
            category:categories(id, name, image_url),
            bid_count:bids(count)
          ''')
          .eq('status', 'live')
          .order('end_time', ascending: true)
          .limit(limit);

      return response.map((data) => AuctionModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get live auctions: $e');
    }
  }

  @override
  dynamic subscribeToAuctionUpdates(
    String auctionId,
    Function(AuctionModel) onUpdate,
  ) {
    return _client
        .channel('auction_updates_$auctionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'auction_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: auctionId,
          ),
          callback: (payload) {
            final updatedAuction = AuctionModel.fromMap(
              payload.newRecord as Map<String, dynamic>,
            );
            onUpdate(updatedAuction);
          },
        )
        .subscribe();
  }

  /// زيادة عداد المشاهدات
  Future<void> _incrementViewCount(String auctionId) async {
    try {
      await _client.rpc(
        'increment_view_count',
        params: {'auction_id': auctionId},
      );
    } catch (e) {
      // تجاهل الأخطاء في عداد المشاهدات
      print('Warning: Failed to increment view count: $e');
    }
  }
}
