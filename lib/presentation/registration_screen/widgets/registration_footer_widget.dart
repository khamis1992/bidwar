import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationFooterWidget extends StatelessWidget {
  const RegistrationFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Already have an account?',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),

        // Sign In Button
        SizedBox(
          width: double.infinity,
          height: 7.h,
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushReplacementNamed(context, '/login-screen');
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'login',
                  size: 5.w,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Sign In Instead',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 3.h),

        // Trust Indicators
        _buildTrustIndicators(),
        SizedBox(height: 2.h),

        // Copyright
        Text(
          '© 2025 BidWar. All rights reserved.',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTrustIndicators() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'security',
                size: 4.w,
                color: AppTheme.lightTheme.colorScheme.tertiary,
              ),
              SizedBox(width: 2.w),
              Text(
                'Secure & Encrypted',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTrustBadge('verified', 'Verified Platform'),
              _buildTrustBadge('payment', 'Secure Payments'),
              _buildTrustBadge('support', '24/7 Support'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(String icon, String text) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(1.5.w),
          ),
          child: CustomIconWidget(
            iconName: icon,
            size: 4.w,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          text,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontSize: 10.sp,
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
