import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationHeaderWidget extends StatelessWidget {
  const RegistrationHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and App Name
        Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.lightTheme.colorScheme.primary,
                    AppTheme.lightTheme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(3.w),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CustomIconWidget(
                iconName: 'gavel',
                size: 7.w,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'BidWar',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppTheme.lightTheme.colorScheme.primary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),

        // Welcome Title
        Text(
          'Create Your Account',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        SizedBox(height: 1.h),

        // Subtitle
        Text(
          'Join thousands of bidders and start winning amazing deals today',
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
        SizedBox(height: 4.h),

        // Features Preview
        _buildFeaturesList(),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': 'flash_on',
        'title': 'Real-time Bidding',
        'description': 'Compete in live penny auctions',
      },
      {
        'icon': 'savings',
        'title': 'Huge Savings',
        'description': 'Win items at fraction of retail price',
      },
      {
        'icon': 'security',
        'title': 'Secure & Trusted',
        'description': 'Safe payments and fair auctions',
      },
    ];

    return Column(
      children: features
          .map((feature) => _buildFeatureItem(
                icon: feature['icon']!,
                title: feature['title']!,
                description: feature['description']!,
              ))
          .toList(),
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: CustomIconWidget(
              iconName: icon,
              size: 5.w,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
