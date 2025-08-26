import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AdminService {
  static AdminService? _instance;
  static AdminService get instance => _instance ??= AdminService._();
  AdminService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Dashboard Statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get active auctions count
      final activeAuctionsData = await _client
          .from('auction_items')
          .select('id')
          .eq('status', 'live')
          .count();

      // Get total users count
      final totalUsersData =
          await _client.from('user_profiles').select('id').count();

      // Get daily revenue from today's transactions
      final dailyRevenueData = await _client
          .from('credit_transactions')
          .select('amount')
          .eq('transaction_type', 'credit_purchase')
          .eq('payment_status', 'completed')
          .gte('created_at', today.toIso8601String());

      int dailyRevenue = 0;
      for (var transaction in dailyRevenueData) {
        dailyRevenue += (transaction['amount'] as int?) ?? 0;
      }

      // Get upcoming auctions count
      final upcomingAuctionsData = await _client
          .from('auction_items')
          .select('id')
          .eq('status', 'upcoming')
          .count();

      return {
        'active_auctions': activeAuctionsData.count ?? 0,
        'total_users': totalUsersData.count ?? 0,
        'daily_revenue': dailyRevenue,
        'upcoming_auctions': upcomingAuctionsData.count ?? 0,
      };
    } catch (error) {
      throw Exception('Failed to get dashboard stats: $error');
    }
  }

  // Get auction analytics for charts
  Future<List<Map<String, dynamic>>> getAuctionAnalytics() async {
    try {
      final last7Days = DateTime.now().subtract(const Duration(days: 7));

      final auctionsData = await _client
          .from('auction_items')
          .select('created_at, status')
          .gte('created_at', last7Days.toIso8601String())
          .order('created_at');

      return List<Map<String, dynamic>>.from(auctionsData);
    } catch (error) {
      throw Exception('Failed to get auction analytics: $error');
    }
  }

  // Get user engagement metrics
  Future<List<Map<String, dynamic>>> getUserEngagementMetrics() async {
    try {
      final last30Days = DateTime.now().subtract(const Duration(days: 30));

      final bidsData = await _client
          .from('bids')
          .select('placed_at, bidder_id')
          .gte('placed_at', last30Days.toIso8601String())
          .order('placed_at');

      return List<Map<String, dynamic>>.from(bidsData);
    } catch (error) {
      throw Exception('Failed to get user engagement metrics: $error');
    }
  }

  // Auction Management
  Future<List<Map<String, dynamic>>> getAuctions({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client.from('auction_items').select('''
            *,
            categories(name),
            user_profiles!seller_id(full_name, email)
          ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      final auctionsData = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(auctionsData);
    } catch (error) {
      throw Exception('Failed to get auctions: $error');
    }
  }

  Future<Map<String, dynamic>?> updateAuctionStatus(
      String auctionId, String newStatus) async {
    try {
      final result = await _client
          .from('auction_items')
          .update({'status': newStatus})
          .eq('id', auctionId)
          .select()
          .single();

      return result;
    } catch (error) {
      throw Exception('Failed to update auction status: $error');
    }
  }

  Future<bool> deleteAuction(String auctionId) async {
    try {
      await _client.from('auction_items').delete().eq('id', auctionId);

      return true;
    } catch (error) {
      throw Exception('Failed to delete auction: $error');
    }
  }

  // User Management
  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client.from('user_profiles').select('*');

      if (role != null) {
        query = query.eq('role', role);
      }

      final usersData = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(usersData);
    } catch (error) {
      throw Exception('Failed to get users: $error');
    }
  }

  Future<Map<String, dynamic>?> updateUserCreditBalance(
      String userId, int newBalance) async {
    try {
      final result = await _client
          .from('user_profiles')
          .update({'credit_balance': newBalance})
          .eq('id', userId)
          .select()
          .single();

      return result;
    } catch (error) {
      throw Exception('Failed to update user credit balance: $error');
    }
  }

  Future<Map<String, dynamic>?> updateUserVerificationStatus(
      String userId, bool isVerified) async {
    try {
      final result = await _client
          .from('user_profiles')
          .update({'is_verified': isVerified})
          .eq('id', userId)
          .select()
          .single();

      return result;
    } catch (error) {
      throw Exception('Failed to update user verification status: $error');
    }
  }

  // Financial Management
  Future<List<Map<String, dynamic>>> getCreditTransactions({
    String? userId,
    String? transactionType,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _client.from('credit_transactions').select('''
            *,
            user_profiles(full_name, email)
          ''');

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      if (transactionType != null) {
        query = query.eq('transaction_type', transactionType);
      }

      final transactionsData = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(transactionsData);
    } catch (error) {
      throw Exception('Failed to get credit transactions: $error');
    }
  }

  // Revenue Analytics
  Future<Map<String, dynamic>> getRevenueAnalytics() async {
    try {
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);
      final lastMonth = DateTime(now.year, now.month - 1);

      // This month revenue
      final thisMonthData = await _client
          .from('credit_transactions')
          .select('amount')
          .eq('transaction_type', 'credit_purchase')
          .eq('payment_status', 'completed')
          .gte('created_at', thisMonth.toIso8601String());

      int thisMonthRevenue = 0;
      for (var transaction in thisMonthData) {
        thisMonthRevenue += (transaction['amount'] as int?) ?? 0;
      }

      // Last month revenue
      final lastMonthData = await _client
          .from('credit_transactions')
          .select('amount')
          .eq('transaction_type', 'credit_purchase')
          .eq('payment_status', 'completed')
          .gte('created_at', lastMonth.toIso8601String())
          .lt('created_at', thisMonth.toIso8601String());

      int lastMonthRevenue = 0;
      for (var transaction in lastMonthData) {
        lastMonthRevenue += (transaction['amount'] as int?) ?? 0;
      }

      return {
        'this_month_revenue': thisMonthRevenue,
        'last_month_revenue': lastMonthRevenue,
        'growth_percentage': lastMonthRevenue > 0
            ? ((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue * 100)
                .round()
            : 0,
      };
    } catch (error) {
      throw Exception('Failed to get revenue analytics: $error');
    }
  }

  // Categories Management
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final categoriesData =
          await _client.from('categories').select('*').order('name');

      return List<Map<String, dynamic>>.from(categoriesData);
    } catch (error) {
      throw Exception('Failed to get categories: $error');
    }
  }

  Future<Map<String, dynamic>?> toggleCategoryStatus(
      String categoryId, bool isActive) async {
    try {
      final result = await _client
          .from('categories')
          .update({'is_active': isActive})
          .eq('id', categoryId)
          .select()
          .single();

      return result;
    } catch (error) {
      throw Exception('Failed to toggle category status: $error');
    }
  }

  // Notifications Management
  Future<List<Map<String, dynamic>>> getSystemNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final notificationsData = await _client
          .from('notifications')
          .select('''
            *,
            user_profiles(full_name, email)
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(notificationsData);
    } catch (error) {
      throw Exception('Failed to get system notifications: $error');
    }
  }

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final userProfile = await _client
          .from('user_profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      return userProfile['role'] == 'admin';
    } catch (error) {
      return false;
    }
  }
}
