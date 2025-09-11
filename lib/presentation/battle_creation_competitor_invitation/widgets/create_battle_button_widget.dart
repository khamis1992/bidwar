import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CreateBattleButtButtonWidget extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool canProceed;

  const CreateBattleButtButtonWidget({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.canProceed,
  });

  @override
  State<CreateBattleButtButtonWidget> createState() =>
      _CreateBattleButtButtonWidgetState();
}

class _CreateBattleButtButtonWidgetState
    extends State<CreateBattleButtButtonWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.orange,
      end: Colors.orange.shade700,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.canProceed && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.canProceed && !widget.isLoading ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: 7.h,
              decoration: BoxDecoration(
                gradient: widget.canProceed && !widget.isLoading
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _colorAnimation.value ?? Colors.orange,
                          Colors.red,
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.grey[700]!,
                          Colors.grey[800]!,
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.canProceed && !widget.isLoading
                    ? [
                        BoxShadow(
                          color: Colors.orange.withAlpha(77),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: widget.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rocket_launch,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Create Epic Battle!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

// Fix the class name typo
class CreateBattleButtonWidget extends CreateBattleButtButtonWidget {
  const CreateBattleButtonWidget({
    super.key,
    required super.onPressed,
    required super.isLoading,
    required super.canProceed,
  });
}
