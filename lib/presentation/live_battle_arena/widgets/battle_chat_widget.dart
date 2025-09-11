import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BattleChatWidget extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  final TextEditingController controller;
  final VoidCallback onSendMessage;
  final bool showChat;
  final VoidCallback onToggleChat;

  const BattleChatWidget({
    super.key,
    required this.messages,
    required this.controller,
    required this.onSendMessage,
    required this.showChat,
    required this.onToggleChat,
  });

  @override
  State<BattleChatWidget> createState() => _BattleChatWidgetState();
}

class _BattleChatWidgetState extends State<BattleChatWidget>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    if (widget.showChat) {
      _slideController.forward();
    }
  }

  @override
  void didUpdateWidget(BattleChatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showChat != oldWidget.showChat) {
      if (widget.showChat) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    }

    // Auto-scroll to bottom when new messages arrive
    if (widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String _formatMessageTime(String timestamp) {
    final messageTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inHours}h';
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final sender = message['sender'];
    final isSystemMessage = message['message_type'] == 'system';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: isSystemMessage
          ? _buildSystemMessage(message)
          : _buildUserMessage(message, sender),
    );
  }

  Widget _buildSystemMessage(Map<String, dynamic> message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withAlpha(77),
          width: 1,
        ),
      ),
      child: Text(
        message['content'],
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUserMessage(
      Map<String, dynamic> message, Map<String, dynamic> sender) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User avatar
        CircleAvatar(
          radius: 12,
          backgroundColor: Colors.grey[700],
          backgroundImage: sender['profile_picture_url'] != null
              ? CachedNetworkImageProvider(sender['profile_picture_url'])
              : null,
          child: sender['profile_picture_url'] == null
              ? Text(
                  (sender['full_name'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),

        const SizedBox(width: 8),

        // Message content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender name and time
              Row(
                children: [
                  Text(
                    sender['full_name'] ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatMessageTime(message['created_at']),
                    style: TextStyle(
                      color: Colors.white.withAlpha(153),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              // Message text
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message['content'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat header with toggle button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(128),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Battle Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (widget.messages.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.messages.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onToggleChat,
                    child: Icon(
                      widget.showChat
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Chat content with slide animation
        AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return SizedBox(
              height: 150 * _slideAnimation.value,
              child: Opacity(
                opacity: _slideAnimation.value,
                child: child,
              ),
            );
          },
          child: widget.showChat
              ? Column(
                  children: [
                    // Messages list
                    Expanded(
                      child: Container(
                        color: Colors.black.withAlpha(77),
                        child: widget.messages.isEmpty
                            ? const Center(
                                child: Text(
                                  'Be the first to chat!',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                itemCount: widget.messages.length,
                                itemBuilder: (context, index) {
                                  return _buildMessageBubble(
                                      widget.messages[index]);
                                },
                              ),
                      ),
                    ),

                    // Message input
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(204),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withAlpha(26),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: widget.controller,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withAlpha(128),
                                ),
                                filled: true,
                                fillColor: Colors.white.withAlpha(26),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              maxLines: 1,
                              onSubmitted: (_) => widget.onSendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: widget.onSendMessage,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}
