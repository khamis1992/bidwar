import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../auth_screen.dart';

/// Auth Header Widget
///
/// يعرض Logo وعنوان الصفحة
/// يتبع قواعد BidWar للتصميم
class AuthHeaderWidget extends StatelessWidget {
  final AuthMode authMode;

  const AuthHeaderWidget({super.key, required this.authMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo Container
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(Icons.gavel, size: 12.w, color: Colors.white),
        ),

        SizedBox(height: 3.h),

        // App Title
        Text(
          'BidWar',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryLight,
            letterSpacing: 1.2,
          ),
        ),

        SizedBox(height: 1.h),

        // Subtitle
        Text(
          authMode == AuthMode.login
              ? 'Welcome back to the auction'
              : 'Join the bidding community',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
