import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PaymentProcessingDialog extends StatefulWidget {
  final int credits;
  final double amount;
  final VoidCallback onSuccess;
  final VoidCallback onError;

  const PaymentProcessingDialog({
    super.key,
    required this.credits,
    required this.amount,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<PaymentProcessingDialog> createState() =>
      _PaymentProcessingDialogState();
}

class _PaymentProcessingDialogState extends State<PaymentProcessingDialog>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _successController;
  late Animation<double> _loadingAnimation;
  late Animation<double> _successAnimation;

  bool _isProcessing = true;
  bool _isSuccess = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _loadingController.repeat();
    _simulatePayment();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _simulatePayment() async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    // Simulate random success/failure (90% success rate)
    final isSuccess = DateTime.now().millisecond % 10 != 0;

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSuccess = isSuccess;
        _isError = !isSuccess;
      });

      _loadingController.stop();

      if (isSuccess) {
        _successController.forward();
        await Future.delayed(const Duration(seconds: 2));
        widget.onSuccess();
      } else {
        await Future.delayed(const Duration(seconds: 2));
        widget.onError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status icon
            SizedBox(
              height: 20.w,
              width: 20.w,
              child: _buildStatusIcon(colorScheme),
            ),
            SizedBox(height: 4.h),

            // Title
            Text(
              _getTitle(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),

            // Description
            Text(
              _getDescription(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),

            // Purchase details
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Credits:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '${widget.credits}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '\$${widget.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),

            // Security badges
            if (_isProcessing) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'security',
                    color: colorScheme.tertiary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Secure Payment',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  CustomIconWidget(
                    iconName: 'verified_user',
                    color: colorScheme.tertiary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'SSL Encrypted',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            // Action button (only show for error state)
            if (_isError) ...[
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isProcessing = true;
                          _isError = false;
                        });
                        _loadingController.repeat();
                        _simulatePayment();
                      },
                      child: Text('Retry'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ColorScheme colorScheme) {
    if (_isProcessing) {
      return AnimatedBuilder(
        animation: _loadingAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _loadingAnimation.value * 2 * 3.14159,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          );
        },
      );
    } else if (_isSuccess) {
      return AnimatedBuilder(
        animation: _successAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _successAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check',
                color: colorScheme.onTertiary,
                size: 40,
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.error,
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(
          iconName: 'close',
          color: colorScheme.onError,
          size: 40,
        ),
      );
    }
  }

  String _getTitle() {
    if (_isProcessing) {
      return 'Processing Payment';
    } else if (_isSuccess) {
      return 'Payment Successful!';
    } else {
      return 'Payment Failed';
    }
  }

  String _getDescription() {
    if (_isProcessing) {
      return 'Please wait while we process your payment securely...';
    } else if (_isSuccess) {
      return 'Your credits have been added to your account successfully.';
    } else {
      return 'There was an issue processing your payment. Please try again.';
    }
  }
}
