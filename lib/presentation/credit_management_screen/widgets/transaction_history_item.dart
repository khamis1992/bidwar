import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TransactionHistoryItem extends StatelessWidget {
  final String type;
  final int credits;
  final double? amount;
  final String date;
  final String? auctionTitle;
  final String status;

  const TransactionHistoryItem({
    super.key,
    required this.type,
    required this.credits,
    this.amount,
    required this.date,
    this.auctionTitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPurchase = type == 'Purchase';
    final isBonus = type == 'Bonus';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(colorScheme),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomIconWidget(
              iconName: _getIconName(),
              color: _getIconColor(colorScheme),
              size: 20,
            ),
          ),
          SizedBox(width: 4.w),

          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      type,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${isPurchase || isBonus ? '+' : '-'}$credits credits',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isPurchase || isBonus
                            ? colorScheme.tertiary
                            : colorScheme.error,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                if (auctionTitle != null) ...[
                  Text(
                    auctionTitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (amount != null)
                      Text(
                        '\$${amount!.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getIconName() {
    switch (type) {
      case 'Purchase':
        return 'add_circle';
      case 'Bid':
        return 'gavel';
      case 'Bonus':
        return 'card_giftcard';
      case 'Refund':
        return 'refresh';
      default:
        return 'account_balance_wallet';
    }
  }

  Color _getIconColor(ColorScheme colorScheme) {
    switch (type) {
      case 'Purchase':
      case 'Bonus':
      case 'Refund':
        return colorScheme.tertiary;
      case 'Bid':
        return colorScheme.error;
      default:
        return colorScheme.primary;
    }
  }

  Color _getIconBackgroundColor(ColorScheme colorScheme) {
    switch (type) {
      case 'Purchase':
      case 'Bonus':
      case 'Refund':
        return colorScheme.tertiary.withValues(alpha: 0.1);
      case 'Bid':
        return colorScheme.error.withValues(alpha: 0.1);
      default:
        return colorScheme.primary.withValues(alpha: 0.1);
    }
  }
}
