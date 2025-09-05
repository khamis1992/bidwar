import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../auth_screen.dart';

/// Auth Mode Toggle Widget
///
/// تبديل بين وضع تسجيل الدخول والتسجيل
/// يتبع قواعد BidWar للتصميم
class AuthModeToggleWidget extends StatelessWidget {
  final AuthMode authMode;
  final VoidCallback onToggle;

  const AuthModeToggleWidget({
    super.key,
    required this.authMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88.w,
      height: 7.h,
      decoration: BoxDecoration(
        color: AppTheme.borderLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              text: 'Sign In',
              isActive: authMode == AuthMode.login,
              onTap: authMode == AuthMode.register ? onToggle : null,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              text: 'Sign Up',
              isActive: authMode == AuthMode.register,
              onTap: authMode == AuthMode.login ? onToggle : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String text,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.all(0.5.h),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: AppTheme.primaryLight.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? Colors.white : AppTheme.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }
}
