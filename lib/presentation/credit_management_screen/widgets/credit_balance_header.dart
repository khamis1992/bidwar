import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CreditBalanceHeader extends StatelessWidget {
  final int currentCredits;
  final String lastTransactionDate;
  final String lastTransactionType;

  const CreditBalanceHeader({
    super.key,
    required this.currentCredits,
    required this.lastTransactionDate,
    required this.lastTransactionType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Balance',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              CustomIconWidget(
                iconName: 'account_balance_wallet',
                color: colorScheme.onPrimary,
                size: 28,
              ),
            ],
          ),
          SizedBox(height: 1.h),

          // Credit amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentCredits.toString(),
                style: theme.textTheme.displayMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              SizedBox(width: 2.w),
              Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Text(
                  'Credits',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Last transaction info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: lastTransactionType == 'Purchase'
                      ? 'add_circle'
                      : 'remove_circle',
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Last $lastTransactionType: $lastTransactionDate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
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
