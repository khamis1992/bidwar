import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class SignupPromptWidget extends StatelessWidget {
  final VoidCallback? onSignupTap;

  const SignupPromptWidget({
    super.key,
    this.onSignupTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New to BidWar? ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (onSignupTap != null) {
                onSignupTap!();
              } else {
                Navigator.pushNamed(context, '/registration-screen');
              }
            },
            child: Text(
              'Sign Up',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
