import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CreditPackageCard extends StatelessWidget {
  final int credits;
  final double price;
  final String? badge;
  final bool isPopular;
  final VoidCallback onPurchase;

  const CreditPackageCard({
    super.key,
    required this.credits,
    required this.price,
    this.badge,
    this.isPopular = false,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final costPerCredit = price / credits;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isPopular
            ? Border.all(color: colorScheme.secondary, width: 2)
            : Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Credits amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$credits Credits',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'account_balance_wallet',
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ],
                ),
                SizedBox(height: 1.h),

                // Price
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 0.5.h),

                // Cost per credit
                Text(
                  '\$${costPerCredit.toStringAsFixed(3)} per credit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 2.h),

                // Purchase button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onPurchase();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular
                          ? colorScheme.secondary
                          : colorScheme.primary,
                      foregroundColor: isPopular
                          ? colorScheme.onSecondary
                          : colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Purchase',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Badge
          if (badge != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Text(
                  badge!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
