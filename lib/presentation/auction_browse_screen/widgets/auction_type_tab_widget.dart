import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class AuctionTypeTabWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? accentColor;
  final String? badgeText;

  const AuctionTypeTabWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.accentColor,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (accentColor ?? AppTheme.lightTheme.colorScheme.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? (accentColor ?? AppTheme.lightTheme.colorScheme.primary)
                : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        (accentColor ?? AppTheme.lightTheme.colorScheme.primary)
                            .withAlpha(76),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18.sp,
                color: isSelected
                    ? Colors.white
                    : (accentColor ?? AppTheme.lightTheme.colorScheme.primary),
              ),
              SizedBox(width: 2.w),
            ],
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (accentColor ?? AppTheme.lightTheme.colorScheme.primary),
              ),
            ),
            if (badgeText != null && badgeText!.isNotEmpty) ...[
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withAlpha(204)
                      : (accentColor ?? AppTheme.lightTheme.colorScheme.primary)
                          .withAlpha(204),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText!,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? (accentColor ??
                            AppTheme.lightTheme.colorScheme.primary)
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
