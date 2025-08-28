import 'package:flutter/material.dart';

class StreamControlsWidget extends StatelessWidget {
  final bool isMuted;
  final bool isVideoEnabled;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleVideo;
  final VoidCallback onEndStream;

  const StreamControlsWidget({
    Key? key,
    required this.isMuted,
    required this.isVideoEnabled,
    required this.onToggleMute,
    required this.onToggleVideo,
    required this.onEndStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      top: 100,
      child: Column(
        children: [
          // Mute/Unmute button
          _buildControlButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            backgroundColor: isMuted ? Colors.red : Colors.black54,
            onTap: onToggleMute,
            tooltip: isMuted ? 'Unmute' : 'Mute',
          ),

          const SizedBox(height: 12),

          // Video on/off button
          _buildControlButton(
            icon: isVideoEnabled ? Icons.videocam : Icons.videocam_off,
            backgroundColor: !isVideoEnabled ? Colors.red : Colors.black54,
            onTap: onToggleVideo,
            tooltip: isVideoEnabled ? 'Turn off video' : 'Turn on video',
          ),

          const SizedBox(height: 12),

          // End stream button
          _buildControlButton(
            icon: Icons.call_end,
            backgroundColor: Colors.red,
            onTap: () => _showEndStreamDialog(context),
            tooltip: 'End stream',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(77),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showEndStreamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Live Stream'),
        content: const Text(
          'Are you sure you want to end this live stream? This action cannot be undone and all viewers will be disconnected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onEndStream();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Stream'),
          ),
        ],
      ),
    );
  }
}
