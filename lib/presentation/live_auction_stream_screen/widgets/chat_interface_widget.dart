import 'package:flutter/material.dart';

class ChatInterfaceWidget extends StatefulWidget {
  final List<dynamic> messages;
  final TextEditingController chatController;
  final VoidCallback onSendMessage;
  final VoidCallback onToggleChat;

  const ChatInterfaceWidget({
    Key? key,
    required this.messages,
    required this.chatController,
    required this.onSendMessage,
    required this.onToggleChat,
  }) : super(key: key);

  @override
  State<ChatInterfaceWidget> createState() => _ChatInterfaceWidgetState();
}

class _ChatInterfaceWidgetState extends State<ChatInterfaceWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(ChatInterfaceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withAlpha(204),
              Colors.black.withAlpha(230),
            ],
          ),
        ),
        child: Column(
          children: [
            // Chat Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.chat,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Live Chat (${widget.messages.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: widget.onToggleChat,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: widget.messages.isEmpty
                    ? const Center(
                        child: Text(
                          'No messages yet. Start the conversation!',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: widget.messages.length,
                        itemBuilder: (context, index) {
                          final message = widget.messages[index];
                          return _buildMessageItem(message);
                        },
                      ),
              ),
            ),

            // Message Input
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Emoji button
                  GestureDetector(
                    onTap: () {
                      // Add emoji picker functionality
                      _showEmojiOptions();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '😊',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Text input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: widget.chatController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => widget.onSendMessage(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Send button
                  GestureDetector(
                    onTap: widget.onSendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final messageType = message['message_type'] ?? 'text';
    final content = message['content'] ?? '';
    final sender = message['sender'] as Map<String, dynamic>?;
    final senderName = sender?['full_name'] ?? 'Anonymous';
    final isSystemMessage = messageType == 'system';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: isSystemMessage
          ? _buildSystemMessage(content)
          : _buildUserMessage(senderName, content, messageType),
    );
  }

  Widget _buildSystemMessage(String content) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withAlpha(51),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          content,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildUserMessage(
      String senderName, String content, String messageType) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            senderName,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          messageType == 'emoji'
              ? Text(
                  content,
                  style: const TextStyle(fontSize: 24),
                )
              : Text(
                  content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
        ],
      ),
    );
  }

  void _showEmojiOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Reactions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['😍', '🔥', '👏', '😮', '❤️', '😂'].map((emoji) {
                return GestureDetector(
                  onTap: () {
                    widget.chatController.text = emoji;
                    Navigator.pop(context);
                    widget.onSendMessage();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
