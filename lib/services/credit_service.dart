import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class CreditService {
  static CreditService? _instance;
  static CreditService get instance => _instance ??= CreditService._();
  CreditService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get user's current credit balance
  Future<int> getCreditBalance() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return 0;

      final response =
          await _client
              .from('user_profiles')
              .select('credit_balance')
              .eq('id', user.id)
              .single();

      return response['credit_balance'] ?? 0;
    } catch (error) {
      throw Exception('Failed to get credit balance: $error');
    }
  }

  // Purchase credits
  Future<void> purchaseCredits({
    required int amount,
    required String paymentReference,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Add credit transaction record
      await _client.from('credit_transactions').insert({
        'user_id': user.id,
        'transaction_type': 'credit_purchase',
        'amount': amount,
        'description': 'Credit purchase - $amount credits',
        'payment_reference': paymentReference,
        'payment_status': 'completed',
      });

      // Update user's credit balance
      final currentBalance = await getCreditBalance();
      await _client
          .from('user_profiles')
          .update({
            'credit_balance': currentBalance + amount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (error) {
      throw Exception('Failed to purchase credits: $error');
    }
  }

  // Get credit transaction history
  Future<List<Map<String, dynamic>>> getCreditTransactions({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('credit_transactions')
          .select('''
            *,
            related_auction:auction_items(title),
            related_bid:bids(bid_amount)
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get credit transactions: $error');
    }
  }

  // Alias method for compatibility
  Future<List<Map<String, dynamic>>> getUserTransactionHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    return getCreditTransactions(limit: limit, offset: offset);
  }

  // Deduct credits (used internally by bid processing)
  Future<void> deductCredits({
    required int amount,
    required String description,
    String? relatedAuctionId,
    String? relatedBidId,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Check if user has sufficient credits
      final currentBalance = await getCreditBalance();
      if (currentBalance < amount) {
        throw Exception('Insufficient credits');
      }

      // Add deduction transaction
      await _client.from('credit_transactions').insert({
        'user_id': user.id,
        'transaction_type': 'bid_placed',
        'amount': -amount,
        'description': description,
        'related_auction_id': relatedAuctionId,
        'related_bid_id': relatedBidId,
        'payment_status': 'completed',
      });

      // Update user's credit balance
      await _client
          .from('user_profiles')
          .update({
            'credit_balance': currentBalance - amount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (error) {
      throw Exception('Failed to deduct credits: $error');
    }
  }

  // Refund credits (used when bid is outbid)
  Future<void> refundCredits({
    required int amount,
    required String description,
    String? relatedAuctionId,
    String? relatedBidId,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Add refund transaction
      await _client.from('credit_transactions').insert({
        'user_id': user.id,
        'transaction_type': 'refund',
        'amount': amount,
        'description': description,
        'related_auction_id': relatedAuctionId,
        'related_bid_id': relatedBidId,
        'payment_status': 'completed',
      });

      // Update user's credit balance
      final currentBalance = await getCreditBalance();
      await _client
          .from('user_profiles')
          .update({
            'credit_balance': currentBalance + amount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (error) {
      throw Exception('Failed to refund credits: $error');
    }
  }

  // Get spending summary
  Future<Map<String, dynamic>> getSpendingSummary() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return {};

      final response = await _client
          .from('credit_transactions')
          .select('transaction_type, amount')
          .eq('user_id', user.id);

      final transactions = List<Map<String, dynamic>>.from(response);

      int totalPurchased = 0;
      int totalSpent = 0;
      int totalRefunded = 0;

      for (final transaction in transactions) {
        final amount = transaction['amount'] as int;
        final type = transaction['transaction_type'] as String;

        switch (type) {
          case 'credit_purchase':
            totalPurchased += amount;
            break;
          case 'bid_placed':
            totalSpent += amount.abs();
            break;
          case 'refund':
            totalRefunded += amount;
            break;
        }
      }

      return {
        'total_purchased': totalPurchased,
        'total_spent': totalSpent,
        'total_refunded': totalRefunded,
        'current_balance': await getCreditBalance(),
      };
    } catch (error) {
      throw Exception('Failed to get spending summary: $error');
    }
  }

  // Get available credit packages
  List<Map<String, dynamic>> getCreditPackages() {
    return [
      {
        'id': 'starter',
        'name': 'Starter Pack',
        'credits': 1000,
        'price': 9.99,
        'bonus_credits': 0,
        'popular': false,
      },
      {
        'id': 'popular',
        'name': 'Popular Pack',
        'credits': 5000,
        'price': 39.99,
        'bonus_credits': 500,
        'popular': true,
      },
      {
        'id': 'premium',
        'name': 'Premium Pack',
        'credits': 10000,
        'price': 69.99,
        'bonus_credits': 1500,
        'popular': false,
      },
      {
        'id': 'ultimate',
        'name': 'Ultimate Pack',
        'credits': 25000,
        'price': 149.99,
        'bonus_credits': 5000,
        'popular': false,
      },
    ];
  }
}
