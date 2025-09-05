import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Home App Bar Widget
///
/// شريط التطبيق للصفحة الرئيسية
/// يتبع قواعد BidWar للتصميم
class HomeAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onSearch;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;

  const HomeAppBarWidget({
    super.key,
    required this.onSearch,
    required this.onProfileTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: AppTheme.shadowLight,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Logo
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.gavel, size: 5.w, color: Colors.white),
          ),

          SizedBox(width: 3.w),

          // App Title
          Text(
            'BidWar',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryLight,
            ),
          ),

          Spacer(),

          // Search Button
          IconButton(
            onPressed: () => _showSearchDialog(context),
            icon: Icon(Icons.search, color: AppTheme.primaryLight, size: 6.w),
          ),

          // Notifications Button
          Stack(
            children: [
              IconButton(
                onPressed: onNotificationsTap,
                icon: Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.primaryLight,
                  size: 6.w,
                ),
              ),
              // Notification Badge (مؤقت)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 2.w,
                  height: 2.w,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          // Profile Button
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(8),
                image: _buildProfileImage(),
              ),
              child: _buildProfileImage() == null
                  ? Icon(
                      Icons.person,
                      size: 5.w,
                      color: AppTheme.textSecondaryLight,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  DecorationImage? _buildProfileImage() {
    // TODO: الحصول على صورة المستخدم من Profile
    return null;
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Auctions'),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Enter search terms...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (query) {
            Navigator.pop(context);
            onSearch(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onSearch(searchController.text);
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
