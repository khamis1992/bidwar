import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SocialLoginWidget extends StatelessWidget {
  final VoidCallback? onGoogleLogin;
  final VoidCallback? onAppleLogin;
  final VoidCallback? onFacebookLogin;
  final bool isLoading;

  const SocialLoginWidget({
    super.key,
    this.onGoogleLogin,
    this.onAppleLogin,
    this.onFacebookLogin,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: colorScheme.outline,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: colorScheme.outline,
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 4.h),

        // Social Login Buttons
        Column(
          children: [
            // Google Login
            _SocialLoginButton(
              icon: 'g_translate',
              label: 'Continue with Google',
              backgroundColor: colorScheme.surface,
              textColor: colorScheme.onSurface,
              borderColor: colorScheme.outline,
              onPressed: isLoading
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      if (onGoogleLogin != null) {
                        onGoogleLogin!();
                      } else {
                        _showComingSoonDialog(context, 'Google Login');
                      }
                    },
            ),

            SizedBox(height: 2.h),

            // Apple Login (iOS only)
            if (Theme.of(context).platform == TargetPlatform.iOS) ...[
              _SocialLoginButton(
                icon: 'apple',
                label: 'Continue with Apple',
                backgroundColor: colorScheme.onSurface,
                textColor: colorScheme.surface,
                borderColor: colorScheme.onSurface,
                onPressed: isLoading
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        if (onAppleLogin != null) {
                          onAppleLogin!();
                        } else {
                          _showComingSoonDialog(context, 'Apple Login');
                        }
                      },
              ),
              SizedBox(height: 2.h),
            ],

            // Facebook Login
            _SocialLoginButton(
              icon: 'facebook',
              label: 'Continue with Facebook',
              backgroundColor: const Color(0xFF1877F2),
              textColor: Colors.white,
              borderColor: const Color(0xFF1877F2),
              onPressed: isLoading
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      if (onFacebookLogin != null) {
                        onFacebookLogin!();
                      } else {
                        _showComingSoonDialog(context, 'Facebook Login');
                      }
                    },
            ),
          ],
        ),
      ],
    );
  }

  void _showComingSoonDialog(BuildContext context, String provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Coming Soon'),
        content:
            Text('$provider integration will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback? onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 6.h,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: textColor,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
