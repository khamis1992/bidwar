import 'package:supabase_flutter/supabase_flutter.dart';

class BattleService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get active live battles
  static Future<List<Map<String, dynamic>>> getActiveBattles() async {
    try {
      final response = await _client.from('battle_rooms').select('''
            id, title, description, status, start_time, end_time,
            competitor_1_support, competitor_2_support, total_viewers,
            competitor_1_id, competitor_2_id,
            competitor1:user_profiles!battle_rooms_competitor_1_id_fkey(id, full_name, profile_picture_url),
            competitor2:user_profiles!battle_rooms_competitor_2_id_fkey(id, full_name, profile_picture_url),
            product1:auction_items!battle_rooms_product_1_id_fkey(id, title, description, images, starting_price),
            product2:auction_items!battle_rooms_product_2_id_fkey(id, title, description, images, starting_price),
            stream:live_streams(id, agora_channel_id, status),
            battle_metrics(*)
          ''').eq('status', 'live').order('start_time', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch active battles: $error');
    }
  }

  // Get upcoming battles
  static Future<List<Map<String, dynamic>>> getUpcomingBattles() async {
    try {
      final response = await _client
          .from('battle_rooms')
          .select('''
            id, title, description, status, start_time, end_time,
            competitor1:user_profiles!battle_rooms_competitor_1_id_fkey(id, full_name, profile_picture_url),
            competitor2:user_profiles!battle_rooms_competitor_2_id_fkey(id, full_name, profile_picture_url),
            product1:auction_items!battle_rooms_product_1_id_fkey(id, title, images, starting_price),
            product2:auction_items!battle_rooms_product_2_id_fkey(id, title, images, starting_price)
          ''')
          .eq('status', 'upcoming')
          .order('start_time', ascending: true)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch upcoming battles: $error');
    }
  }

  // Get battle by ID with full details
  static Future<Map<String, dynamic>?> getBattleById(String battleId) async {
    try {
      final response = await _client.from('battle_rooms').select('''
            id, title, description, status, start_time, end_time, duration_minutes,
            competitor_1_support, competitor_2_support, total_viewers, max_viewers,
            winner_id, created_at, updated_at,
            competitor1:user_profiles!battle_rooms_competitor_1_id_fkey(id, full_name, profile_picture_url),
            competitor2:user_profiles!battle_rooms_competitor_2_id_fkey(id, full_name, profile_picture_url),
            product1:auction_items!battle_rooms_product_1_id_fkey(id, title, description, images, starting_price),
            product2:auction_items!battle_rooms_product_2_id_fkey(id, title, description, images, starting_price),
            stream:live_streams(id, agora_channel_id, status),
            battle_metrics(*)
          ''').eq('id', battleId).single();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch battle details: $error');
    }
  }

  // Send support to competitor
  static Future<void> sendSupport({
    required String battleId,
    required String competitorId,
    required String supportType,
    int amount = 1,
    int costCredits = 0,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Insert support action
      await _client.from('battle_support_actions').insert({
        'battle_room_id': battleId,
        'supporter_id': userId,
        'competitor_id': competitorId,
        'support_type': supportType,
        'amount': amount,
        'cost_credits': costCredits,
      });

      // Update battle room support counts
      await _client.rpc('update_battle_support', params: {
        'battle_uuid': battleId,
        'competitor_uuid': competitorId,
        'support_amount': amount,
      });

      // Update user credits if needed
      if (costCredits > 0) {
        await _client.from('user_profiles').update({
          'credit_balance': _client
              .from('user_profiles')
              .select('credit_balance')
              .eq('id', userId)
              .single()
              .then((user) => (user['credit_balance'] as int) - costCredits)
        }).eq('id', userId);
      }
    } catch (error) {
      throw Exception('Failed to send support: $error');
    }
  }

  // Join battle as spectator
  static Future<void> joinBattle(String battleId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('battle_spectators').upsert({
        'battle_room_id': battleId,
        'spectator_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Update total viewers count
      await _client.rpc('increment', params: {
        'table_name': 'battle_rooms',
        'row_id': battleId,
        'column_name': 'total_viewers',
      });
    } catch (error) {
      throw Exception('Failed to join battle: $error');
    }
  }

  // Leave battle
  static Future<void> leaveBattle(String battleId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      await _client
          .from('battle_spectators')
          .update({'left_at': DateTime.now().toIso8601String()})
          .eq('battle_room_id', battleId)
          .eq('spectator_id', userId);
    } catch (error) {
      throw Exception('Failed to leave battle: $error');
    }
  }

  // Get battle chat messages
  static Future<List<Map<String, dynamic>>> getBattleChat(
      String streamId) async {
    try {
      final response = await _client
          .from('stream_chat_messages')
          .select('''
            id, content, message_type, created_at, is_pinned,
            sender:user_profiles!stream_chat_messages_sender_id_fkey(id, full_name, profile_picture_url)
          ''')
          .eq('stream_id', streamId)
          .order('created_at', ascending: false)
          .limit(100);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch chat messages: $error');
    }
  }

  // Send chat message
  static Future<void> sendChatMessage({
    required String streamId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('stream_chat_messages').insert({
        'stream_id': streamId,
        'sender_id': userId,
        'content': content,
        'message_type': messageType,
      });
    } catch (error) {
      throw Exception('Failed to send message: $error');
    }
  }

  // Subscribe to battle updates
  static RealtimeChannel subscribeToBattle(
      String battleId, Function(Map<String, dynamic>) onUpdate) {
    return _client
        .channel('battle_$battleId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'battle_rooms',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: battleId,
          ),
          callback: (payload) {
            onUpdate(payload.newRecord);
          },
        )
        .subscribe();
  }

  // Subscribe to battle support actions
  static RealtimeChannel subscribeToBattleSupport(
      String battleId, Function(Map<String, dynamic>) onSupportAction) {
    return _client
        .channel('battle_support_$battleId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'battle_support_actions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'battle_room_id',
            value: battleId,
          ),
          callback: (payload) {
            onSupportAction(payload.newRecord);
          },
        )
        .subscribe();
  }

  // Create battle invitation
  static Future<void> createBattleInvitation({
    required String battleId,
    required String inviteeId,
    String? message,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('battle_invitations').insert({
        'battle_room_id': battleId,
        'inviter_id': userId,
        'invitee_id': inviteeId,
        'message': message,
        'status': 'pending',
      });
    } catch (error) {
      throw Exception('Failed to create invitation: $error');
    }
  }

  // Respond to battle invitation
  static Future<void> respondToInvitation({
    required String invitationId,
    required String response, // 'accepted' or 'declined'
  }) async {
    try {
      await _client.from('battle_invitations').update({
        'status': response,
        'responded_at': DateTime.now().toIso8601String(),
      }).eq('id', invitationId);
    } catch (error) {
      throw Exception('Failed to respond to invitation: $error');
    }
  }

  // Get user's battle invitations
  static Future<List<Map<String, dynamic>>> getUserInvitations() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('battle_invitations')
          .select('''
            id, message, status, created_at,
            inviter:user_profiles!battle_invitations_inviter_id_fkey(id, full_name, profile_picture_url),
            battle_room:battle_rooms(id, title, description, start_time, end_time)
          ''')
          .eq('invitee_id', userId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch invitations: $error');
    }
  }
}
