import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/battle_service.dart';
import './widgets/battle_chat_widget.dart';
import './widgets/battle_competitor_widget.dart';
import './widgets/battle_effects_overlay_widget.dart';
import './widgets/battle_leaderboard_widget.dart';
import './widgets/battle_support_buttons_widget.dart';
import './widgets/battle_timer_widget.dart';

class LiveBattleArena extends StatefulWidget {
  const LiveBattleArena({super.key});

  @override
  State<LiveBattleArena> createState() => _LiveBattleArenaState();
}

class _LiveBattleArenaState extends State<LiveBattleArena>
    with TickerProviderStateMixin {
  Map<String, dynamic>? currentBattle;
  List<Map<String, dynamic>> chatMessages = [];
  RealtimeChannel? battleChannel;
  RealtimeChannel? supportChannel;
  bool isLoading = true;
  String? error;

  // Animation controllers for battle effects
  late AnimationController _supportEffectController;
  late AnimationController _celebrationController;
  late AnimationController _shakeController;

  // Chat and interaction state
  final TextEditingController _chatController = TextEditingController();
  bool _showChat = true;
  String? _selectedCompetitorId;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadActiveBattle();
  }

  void _initializeAnimations() {
    _supportEffectController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  Future<void> _loadActiveBattle() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final battles = await BattleService.getActiveBattles();
      if (battles.isNotEmpty) {
        final battle = battles.first;
        setState(() {
          currentBattle = battle;
        });

        await _setupRealtimeSubscriptions(battle['id']);
        await _loadBattleChat();
        await BattleService.joinBattle(battle['id']);
      } else {
        // No active battles, show upcoming or create new battle option
        setState(() {
          error = 'No active battles right now. Check back soon!';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load battle: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _setupRealtimeSubscriptions(String battleId) async {
    battleChannel = BattleService.subscribeToBattle(battleId, (battleData) {
      setState(() {
        currentBattle = {...?currentBattle, ...battleData};
      });
    });

    supportChannel =
        BattleService.subscribeToBattleSupport(battleId, (supportData) {
      _triggerSupportEffect(supportData);
    });
  }

  void _triggerSupportEffect(Map<String, dynamic> supportData) {
    _supportEffectController.forward().then((_) {
      _supportEffectController.reset();
    });

    // Shake effect for big support actions
    if ((supportData['amount'] as int? ?? 0) >= 10) {
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });
    }
  }

  Future<void> _loadBattleChat() async {
    if (currentBattle?['stream']?['id'] != null) {
      try {
        final messages =
            await BattleService.getBattleChat(currentBattle!['stream']['id']);
        setState(() {
          chatMessages = messages;
        });
      } catch (e) {
        // Chat failed to load, continue without it
      }
    }
  }

  Future<void> _sendSupport(
      String competitorId, String supportType, int amount) async {
    if (currentBattle == null) return;

    try {
      await BattleService.sendSupport(
        battleId: currentBattle!['id'],
        competitorId: competitorId,
        supportType: supportType,
        amount: amount,
        costCredits: _getSupportCost(supportType, amount),
      );
    } catch (e) {
      _showSnackBar('Failed to send support: $e');
    }
  }

  int _getSupportCost(String supportType, int amount) {
    switch (supportType) {
      case 'heart':
        return 0; // Free
      case 'coin':
        return amount * 5;
      case 'boost':
        return amount * 100;
      case 'gift':
        return amount * 250;
      default:
        return 0;
    }
  }

  Future<void> _sendChatMessage() async {
    if (_chatController.text.trim().isEmpty ||
        currentBattle?['stream']?['id'] == null) {
      return;
    }

    try {
      await BattleService.sendChatMessage(
        streamId: currentBattle!['stream']['id'],
        content: _chatController.text.trim(),
      );
      _chatController.clear();
    } catch (e) {
      _showSnackBar('Failed to send message: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _selectCompetitor(String competitorId) {
    setState(() {
      _selectedCompetitorId = competitorId;
    });
  }

  @override
  void dispose() {
    battleChannel?.unsubscribe();
    supportChannel?.unsubscribe();
    _supportEffectController.dispose();
    _celebrationController.dispose();
    _shakeController.dispose();
    _chatController.dispose();

    // Leave battle when exiting
    if (currentBattle != null) {
      BattleService.leaveBattle(currentBattle!['id']);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else if (error != null)
            _buildErrorState()
          else if (currentBattle != null)
            _buildBattleArena()
          else
            _buildNoBattleState(),

          // Battle effects overlay
          if (currentBattle != null)
            BattleEffectsOverlayWidget(
              supportEffectController: _supportEffectController,
              celebrationController: _celebrationController,
              shakeController: _shakeController,
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          Text(
            error!,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadActiveBattle,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBattleState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_mma, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          const Text(
            'No Active Battles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back soon for epic TikTok-style battles!',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _loadActiveBattle,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Refresh', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleArena() {
    final competitor1 = currentBattle!['competitor1'];
    final competitor2 = currentBattle!['competitor2'];
    final product1 = currentBattle!['product1'];
    final product2 = currentBattle!['product2'];

    return Column(
      children: [
        // Battle timer at the top
        SafeArea(
          child: BattleTimerWidget(
            startTime: DateTime.parse(currentBattle!['start_time']),
            endTime: DateTime.parse(currentBattle!['end_time']),
            totalViewers: currentBattle!['total_viewers'] ?? 0,
          ),
        ),

        // Main battle area - split screen for two competitors
        Expanded(
          flex: 3,
          child: Row(
            children: [
              // Competitor 1 side
              Expanded(
                child: BattleCompetitorWidget(
                  competitor: competitor1,
                  product: product1,
                  supportCount: currentBattle!['competitor_1_support'] ?? 0,
                  isSelected: _selectedCompetitorId == competitor1['id'],
                  onTap: () => _selectCompetitor(competitor1['id']),
                  isLeft: true,
                ),
              ),

              // Center divider with VS
              Container(
                width: 4,
                color: Colors.white.withAlpha(77),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Competitor 2 side
              Expanded(
                child: BattleCompetitorWidget(
                  competitor: competitor2,
                  product: product2,
                  supportCount: currentBattle!['competitor_2_support'] ?? 0,
                  isSelected: _selectedCompetitorId == competitor2['id'],
                  onTap: () => _selectCompetitor(competitor2['id']),
                  isLeft: false,
                ),
              ),
            ],
          ),
        ),

        // Battle leaderboard showing current standings
        BattleLeaderboardWidget(
          competitor1: competitor1,
          competitor2: competitor2,
          competitor1Support: currentBattle!['competitor_1_support'] ?? 0,
          competitor2Support: currentBattle!['competitor_2_support'] ?? 0,
        ),

        // Bottom section with support buttons and chat
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(204),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Support buttons
              if (_selectedCompetitorId != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: BattleSupportButtonsWidget(
                    onSendSupport: (supportType, amount) {
                      _sendSupport(_selectedCompetitorId!, supportType, amount);
                    },
                  ),
                ),

              // Chat section
              Expanded(
                child: BattleChatWidget(
                  messages: chatMessages,
                  controller: _chatController,
                  onSendMessage: _sendChatMessage,
                  showChat: _showChat,
                  onToggleChat: () => setState(() => _showChat = !_showChat),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
