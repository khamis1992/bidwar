import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/creator_tier.dart';
import '../models/product_inventory.dart';
import '../models/product_selection.dart';
import './supabase_service.dart';

class ProductService {
  static final SupabaseClient _client = SupabaseService.instance.client;

  /// Get available products for the current creator based on their credit balance and tier
  static Future<List<ProductInventory>> getAvailableProductsForCreator() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response =
          await _client.rpc('get_available_products_for_creator', params: {
        'creator_user_id': userId,
      });

      return (response as List)
          .map((item) => ProductInventory.fromJson(item))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch available products: $error');
    }
  }

  /// Get products filtered by category and accessibility
  static Future<List<ProductInventory>> getProductsByCategory({
    String? categoryId,
    String? tierFilter,
    bool? accessibleOnly,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('product_inventory').select('''
            *,
            categories (
              id,
              name,
              image_url
            )
          ''').eq('is_active', true).eq('availability_status', 'available');

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (tierFilter != null) {
        query = query.eq('required_tier', tierFilter);
      }

      final response = await query
          .order('is_featured', ascending: false)
          .order('retail_value', ascending: false)
          .limit(limit);

      return (response as List)
          .map((item) => ProductInventory.fromJson(item))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch products by category: $error');
    }
  }

  /// Select a product for auction creation
  static Future<ProductSelection> selectProductForAuction(
    String productInventoryId, {
    DateTime? scheduledStartTime,
    String? notes,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get current user's credit balance and tier
      final userProfile = await _client
          .from('user_profiles')
          .select('credit_balance')
          .eq('id', userId)
          .single();

      final creditBalance = userProfile['credit_balance'] as int;

      // Calculate current tier
      final tierResponse = await _client.rpc('calculate_creator_tier', params: {
        'credit_balance': creditBalance,
      });

      final selectionData = {
        'creator_id': userId,
        'product_inventory_id': productInventoryId,
        'scheduled_start_time': scheduledStartTime?.toIso8601String(),
        'estimated_end_time': scheduledStartTime
            ?.add(const Duration(hours: 24))
            .toIso8601String(),
        'selection_notes': notes,
        'creator_tier_at_selection': tierResponse,
        'credit_balance_at_selection': creditBalance,
        'commission_rate': 0.10, // 10% commission rate
      };

      final response = await _client
          .from('product_selections')
          .insert(selectionData)
          .select()
          .single();

      return ProductSelection.fromJson(response);
    } catch (error) {
      throw Exception('Failed to select product: $error');
    }
  }

  /// Get creator's product selections history
  static Future<List<ProductSelection>> getCreatorProductSelections({
    int limit = 50,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('product_selections')
          .select('''
            *,
            product_inventory (
              id,
              title,
              retail_value,
              images,
              brand,
              model
            ),
            auction_items (
              id,
              title,
              status,
              current_highest_bid,
              winner_id
            )
          ''')
          .eq('creator_id', userId)
          .order('selected_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((item) => ProductSelection.fromJson(item))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch product selections: $error');
    }
  }

  /// Get creator tier information
  static Future<CreatorTier> getCreatorTierInfo(int creditBalance) async {
    try {
      final tierName = await _client.rpc('calculate_creator_tier', params: {
        'credit_balance': creditBalance,
      });

      final response = await _client
          .from('creator_tiers')
          .select()
          .eq('tier_name', tierName)
          .single();

      return CreatorTier.fromJson(response);
    } catch (error) {
      throw Exception('Failed to fetch creator tier info: $error');
    }
  }

  /// Get all available creator tiers
  static Future<List<CreatorTier>> getAllCreatorTiers() async {
    try {
      final response = await _client
          .from('creator_tiers')
          .select()
          .eq('is_active', true)
          .order('min_credit_requirement', ascending: true);

      return (response as List)
          .map((item) => CreatorTier.fromJson(item))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch creator tiers: $error');
    }
  }

  /// Create auction from selected product
  static Future<Map<String, dynamic>> createAuctionFromProduct(
      String productSelectionId, Map<String, dynamic> auctionData) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get product selection details
      final selectionResponse =
          await _client.from('product_selections').select('''
            *,
            product_inventory (
              id,
              title,
              description,
              category_id,
              starting_price,
              reserve_price,
              images,
              specifications,
              brand,
              model,
              condition
            )
          ''').eq('id', productSelectionId).eq('creator_id', userId).single();

      final productInventory = selectionResponse['product_inventory'];

      // Create auction item based on product inventory
      final auctionItemData = {
        'title': productInventory['title'],
        'description': productInventory['description'],
        'seller_id': userId,
        'category_id': productInventory['category_id'],
        'starting_price': productInventory['starting_price'],
        'reserve_price': productInventory['reserve_price'],
        'images': productInventory['images'],
        'specifications': productInventory['specifications'],
        'brand': productInventory['brand'],
        'model': productInventory['model'],
        'condition': productInventory['condition'],
        'bid_increment': auctionData['bid_increment'] ?? 100,
        'start_time':
            auctionData['start_time'] ?? DateTime.now().toIso8601String(),
        'end_time': auctionData['end_time'] ??
            DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        'featured': auctionData['featured'] ?? false,
        'status': 'upcoming',
      };

      // Insert auction item
      final auctionResponse = await _client
          .from('auction_items')
          .insert(auctionItemData)
          .select()
          .single();

      // Update product selection with auction_item_id
      await _client.from('product_selections').update({
        'auction_item_id': auctionResponse['id'],
        'status': 'live',
      }).eq('id', productSelectionId);

      // Mark product as reserved
      await _client.from('product_inventory').update({
        'availability_status': 'reserved',
      }).eq('id', productInventory['id']);

      return auctionResponse;
    } catch (error) {
      throw Exception('Failed to create auction from product: $error');
    }
  }

  /// Calculate potential commission for a product
  static int calculatePotentialCommission(int retailValue,
      [double commissionRate = 0.10]) {
    return (retailValue * commissionRate).round();
  }

  /// Get commission earnings for creator
  static Future<List<Map<String, dynamic>>> getCreatorCommissionEarnings({
    String? status,
    int limit = 50,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      var query = _client.from('commission_earnings').select('''
            *,
            auction_items (
              id,
              title,
              images
            ),
            product_selections (
              id,
              product_inventory (
                title,
                brand,
                model
              )
            )
          ''').eq('creator_id', userId);

      if (status != null) {
        query = query.eq('commission_status', status);
      }

      final response =
          await query.order('earned_at', ascending: false).limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch commission earnings: $error');
    }
  }
}
