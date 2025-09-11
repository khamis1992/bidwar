import 'package:flutter/material.dart';
import 'dart:async';

class BattleTimerWidget extends StatefulWidget {
  final DateTime startTime;
  final DateTime endTime;
  final int totalViewers;

  const BattleTimerWidget({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.totalViewers,
  });

  @override
  State<BattleTimerWidget> createState() => _BattleTimerWidgetState();
}

class _BattleTimerWidgetState extends State<BattleTimerWidget>
    with TickerProviderStateMixin {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  late AnimationController _urgencyController;
  late Animation<Color?> _urgencyColorAnimation;
  bool _isUrgent = false;

  @override
  void initState() {
    super.initState();

    _urgencyController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _urgencyColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _urgencyController,
      curve: Curves.easeInOut,
    ));

    _calculateTimeRemaining();
    _startTimer();
  }

  void _calculateTimeRemaining() {
    final now = DateTime.now();
    if (now.isBefore(widget.endTime)) {
      _timeRemaining = widget.endTime.difference(now);

      // Trigger urgency animation when less than 1 minute remaining
      final shouldBeUrgent = _timeRemaining.inSeconds <= 60;
      if (shouldBeUrgent && !_isUrgent) {
        _isUrgent = true;
        _urgencyController.repeat(reverse: true);
      } else if (!shouldBeUrgent && _isUrgent) {
        _isUrgent = false;
        _urgencyController.stop();
        _urgencyController.reset();
      }
    } else {
      _timeRemaining = Duration.zero;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _calculateTimeRemaining();
      });

      if (_timeRemaining == Duration.zero) {
        timer.cancel();
      }
    });
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return "00:00";

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  String _formatViewerCount(int viewers) {
    if (viewers >= 1000000) {
      return "${(viewers / 1000000).toStringAsFixed(1)}M";
    } else if (viewers >= 1000) {
      return "${(viewers / 1000).toStringAsFixed(1)}K";
    } else {
      return viewers.toString();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _urgencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withAlpha(204),
            Colors.black.withAlpha(153),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Live indicator and viewers
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(
                    Icons.visibility,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatViewerCount(widget.totalViewers),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Battle timer in center
          AnimatedBuilder(
            animation: _urgencyColorAnimation,
            builder: (context, child) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: _isUrgent
                      ? Colors.red.withAlpha(51)
                      : Colors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isUrgent ? Colors.red : Colors.white.withAlpha(77),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      color: _isUrgent
                          ? _urgencyColorAnimation.value
                          : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(_timeRemaining),
                      style: TextStyle(
                        color: _isUrgent
                            ? _urgencyColorAnimation.value
                            : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Battle info
          Row(
            children: [
              const Icon(
                Icons.sports_mma,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                'BATTLE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ARENA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
