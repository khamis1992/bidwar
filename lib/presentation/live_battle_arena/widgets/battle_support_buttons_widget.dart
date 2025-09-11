import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BattleSupportButtonsWidget extends StatefulWidget {
  final Function(String supportType, int amount) onSendSupport;

  const BattleSupportButtonsWidget({
    super.key,
    required this.onSendSupport,
  });

  @override
  State<BattleSupportButtonsWidget> createState() =>
      _BattleSupportButtonsWidgetState();
}

class _BattleSupportButtonsWidgetState extends State<BattleSupportButtonsWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _buttonControllers;
  late List<Animation<double>> _buttonAnimations;

  final List<Map<String, dynamic>> _supportOptions = [
    {
      'type': 'heart',
      'icon': Icons.favorite,
      'color': Colors.red,
      'label': 'Heart',
      'cost': 0,
      'amount': 1,
    },
    {
      'type': 'coin',
      'icon': Icons.monetization_on,
      'color': Colors.amber,
      'label': '5 Coins',
      'cost': 25,
      'amount': 5,
    },
    {
      'type': 'boost',
      'icon': Icons.rocket_launch,
      'color': Colors.purple,
      'label': 'Boost',
      'cost': 100,
      'amount': 1,
    },
    {
      'type': 'gift',
      'icon': Icons.card_giftcard,
      'color': Colors.pink,
      'label': 'Gift',
      'cost': 250,
      'amount': 1,
    },
  ];

  @override
  void initState() {
    super.initState();

    _buttonControllers = List.generate(
      _supportOptions.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _buttonAnimations = _buttonControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.9).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _buttonControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleSupportTap(int index) async {
    final option = _supportOptions[index];

    // Animate button press
    await _buttonControllers[index].forward();
    _buttonControllers[index].reverse();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Send support
    widget.onSendSupport(
      option['type'],
      option['amount'],
    );

    // Show floating animation
    _showFloatingIcon(option);
  }

  void _showFloatingIcon(Map<String, dynamic> option) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _FloatingIcon(
        icon: option['icon'],
        color: option['color'],
        onComplete: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          const Text(
            'Send Support to Your Favorite Competitor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_supportOptions.length, (index) {
              final option = _supportOptions[index];
              return AnimatedBuilder(
                animation: _buttonAnimations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonAnimations[index].value,
                    child: _buildSupportButton(option, index),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportButton(Map<String, dynamic> option, int index) {
    return GestureDetector(
      onTap: () => _handleSupportTap(index),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: option['color'].withAlpha(51),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: option['color'],
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: option['color'].withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option['icon'],
              color: option['color'],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              option['label'],
              style: TextStyle(
                color: option['color'],
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (option['cost'] > 0) ...[
              const SizedBox(height: 2),
              Text(
                '${option['cost']}c',
                style: TextStyle(
                  color: option['color'].withAlpha(204),
                  fontSize: 8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FloatingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onComplete;

  const _FloatingIcon({
    required this.icon,
    required this.color,
    required this.onComplete,
  });

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: -200.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0),
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 150,
      left: MediaQuery.of(context).size.width / 2 - 25,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _positionAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.color.withAlpha(204),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withAlpha(128),
                          blurRadius: 12,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
