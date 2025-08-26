import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUserService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get all users with pagination and filters
  static Future<Map<String, dynamic>> getAllUsers({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    String? roleFilter,
    String? statusFilter,
    String? sortBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      var query = _supabase
          .from('user_profiles')
          .select('*, auction_items!seller_id(count), bids!bidder_id(count)');

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .or('full_name.ilike.%$searchQuery%,email.ilike.%$searchQuery%');
      }

      // Apply role filter
      if (roleFilter != null && roleFilter != 'all') {
        query = query.eq('role', roleFilter);
      }

      // Apply status filter (verified status)
      if (statusFilter != null && statusFilter != 'all') {
        bool isVerified = statusFilter == 'verified';
        query = query.eq('is_verified', isVerified);
      }

      // Apply sorting and pagination
      final response = await query
          .order(sortBy!, ascending: ascending)
          .range((page - 1) * limit, page * limit - 1);

      // Get total count for pagination
      final countResponse =
          await _supabase.from('user_profiles').select('id').count();

      return {
        'data': response,
        'total': countResponse.count,
        'page': page,
        'limit': limit,
        'total_pages': ((countResponse.count ?? 0) / limit).ceil(),
      };
    } catch (error) {
      throw Exception('Failed to fetch users: $error');
    }
  }

  // Get user statistics
  static Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      // Get auction statistics
      final auctionStats = await _supabase
          .from('auction_items')
          .select('id, status, current_highest_bid')
          .eq('seller_id', userId);

      // Get bid statistics
      final bidStats = await _supabase
          .from('bids')
          .select('id, bid_amount, status')
          .eq('bidder_id', userId);

      // Get credit transaction statistics
      final creditStats = await _supabase
          .from('credit_transactions')
          .select('id, amount, transaction_type')
          .eq('user_id', userId);

      // Calculate statistics
      int totalAuctions = auctionStats.length;
      int activeAuctions =
          auctionStats.where((a) => a['status'] == 'live').length;
      int totalBids = bidStats.length;
      int totalCredits = creditStats
          .where((t) => t['transaction_type'] == 'credit_purchase')
          .fold(0, (sum, t) => sum + (t['amount'] as int? ?? 0));
      int totalSpent = creditStats
          .where((t) => t['transaction_type'] == 'bid_placed')
          .fold(0, (sum, t) => sum + (t['amount'] as int? ?? 0));

      return {
        'total_auctions': totalAuctions,
        'active_auctions': activeAuctions,
        'total_bids': totalBids,
        'total_credits_purchased': totalCredits,
        'total_credits_spent': totalSpent,
      };
    } catch (error) {
      throw Exception('Failed to fetch user statistics: $error');
    }
  }

  // Update user role
  static Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _supabase
          .from('user_profiles')
          .update({'role': newRole}).eq('id', userId);
    } catch (error) {
      throw Exception('Failed to update user role: $error');
    }
  }

  // Update user verification status
  static Future<void> updateUserVerification(
      String userId, bool isVerified) async {
    try {
      await _supabase
          .from('user_profiles')
          .update({'is_verified': isVerified}).eq('id', userId);
    } catch (error) {
      throw Exception('Failed to update user verification: $error');
    }
  }

  // Adjust user credit balance
  static Future<void> adjustUserCredits(
      String userId, int amount, String description) async {
    try {
      await _supabase.rpc('process_admin_credit_adjustment', params: {
        'user_id': userId,
        'amount': amount,
        'description': description,
      });
    } catch (error) {
      // Fallback if RPC doesn't exist - manual credit adjustment
      final currentUser = await _supabase
          .from('user_profiles')
          .select('credit_balance')
          .eq('id', userId)
          .single();

      final newBalance = (currentUser['credit_balance'] as int? ?? 0) + amount;

      await _supabase.from('user_profiles').update({
        'credit_balance': newBalance,
      }).eq('id', userId);

      // Record transaction
      await _supabase.from('credit_transactions').insert({
        'user_id': userId,
        'amount': amount,
        'transaction_type': amount > 0 ? 'credit_purchase' : 'refund',
        'description': description,
        'payment_status': 'completed',
      });
    }
  }

  // Get user's credit transaction history
  static Future<List<Map<String, dynamic>>> getUserCreditHistory(
      String userId) async {
    try {
      final response = await _supabase
          .from('credit_transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.cast<Map<String, dynamic>>();
    } catch (error) {
      throw Exception('Failed to fetch credit history: $error');
    }
  }

  // Send notification to user
  static Future<void> sendUserNotification(
      String userId, String title, String message) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': 'admin_message',
        'is_read': false,
      });
    } catch (error) {
      throw Exception('Failed to send notification: $error');
    }
  }

  // Get user activity metrics
  static Future<Map<String, dynamic>> getUserActivityMetrics() async {
    try {
      // Total users
      final totalUsers =
          await _supabase.from('user_profiles').select('id').count();

      // Active users (users who placed bids in last 30 days)
      final thirtyDaysAgo =
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
      final activeUsers = await _supabase
          .from('bids')
          .select('bidder_id')
          .gte('placed_at', thirtyDaysAgo)
          .count();

      // New registrations this month
      final startOfMonth =
          DateTime(DateTime.now().year, DateTime.now().month, 1)
              .toIso8601String();
      final newUsers = await _supabase
          .from('user_profiles')
          .select('id')
          .gte('created_at', startOfMonth)
          .count();

      // Verified users
      final verifiedUsers = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('is_verified', true)
          .count();

      return {
        'total_users': totalUsers.count ?? 0,
        'active_users': activeUsers.count ?? 0,
        'new_users_this_month': newUsers.count ?? 0,
        'verified_users': verifiedUsers.count ?? 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch user activity metrics: $error');
    }
  }
}