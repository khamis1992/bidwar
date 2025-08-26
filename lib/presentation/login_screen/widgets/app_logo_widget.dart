import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AppLogoWidget extends StatelessWidget {
  final double? size;
  final bool showTagline;

  const AppLogoWidget({
    super.key,
    this.size,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final logoSize = size ?? 20.w;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Container with Gavel Icon
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(logoSize * 0.25),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'gavel',
              color: colorScheme.onPrimary,
              size: logoSize * 0.4,
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // App Name
        Text(
          'BidWar',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),

        if (showTagline) ...[
          SizedBox(height: 1.h),

          // Tagline
          Text(
            'Win Big, Bid Smart',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}
