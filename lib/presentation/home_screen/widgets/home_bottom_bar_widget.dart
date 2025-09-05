import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Home Bottom Bar Widget
///
/// شريط التنقل السفلي
/// يتبع قواعد BidWar للتصميم
class HomeBottomBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HomeBottomBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.primaryLight,
      unselectedItemColor: AppTheme.textSecondaryLight,
      elevation: 8,
      selectedFontSize: 12.sp,
      unselectedFontSize: 10.sp,
      iconSize: 6.w,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border),
          activeIcon: Icon(Icons.bookmark),
          label: 'Watchlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Credits',
        ),
      ],
    );
  }
}
