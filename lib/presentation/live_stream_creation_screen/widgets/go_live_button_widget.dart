import 'package:flutter/material.dart';

class GoLiveButtonWidget extends StatelessWidget {
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  const GoLiveButtonWidget({
    Key? key,
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          // Pre-flight checks indicator
          if (!isEnabled && !isLoading)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Please complete all required settings to go live',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

          // Go Live Button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: isEnabled && !isLoading ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnabled ? Colors.red : Colors.grey[400],
                foregroundColor: Colors.white,
                elevation: isEnabled ? 8 : 0,
                shadowColor: Colors.red.withAlpha(77),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'GO LIVE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.videocam, size: 20),
                      ],
                    ),
            ),
          ),

          // Helper text
          const SizedBox(height: 12),
          Text(
            isLoading
                ? 'Starting your live stream...'
                : 'Your auction will be broadcast to all viewers',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
