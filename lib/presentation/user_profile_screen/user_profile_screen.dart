import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_tabs_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/statistics_cards_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;

  // Mock user data
  final Map<String, dynamic> userData = {
    "id": 1,
    "username": "BidMaster2024",
    "email": "bidmaster@example.com",
    "avatar":
        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face",
    "memberSince": "January 2024",
    "credits": 250,
  };

  final Map<String, dynamic> statistics = {
    "totalBids": 127,
    "auctionsWon": 8,
    "successRate": 6.3,
    "totalSavings": 1247,
  };

  final List<Map<String, dynamic>> activeBids = [
    {
      "id": 1,
      "title": "iPhone 15 Pro Max 256GB",
      "image":
          "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&h=400&fit=crop",
      "currentPrice": "\$12.47",
      "timeLeft": "2h 15m",
      "myBid": "\$12.47",
      "status": "active",
    },
    {
      "id": 2,
      "title": "Sony WH-1000XM5 Headphones",
      "image":
          "https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400&h=400&fit=crop",
      "currentPrice": "\$8.23",
      "timeLeft": "45m",
      "myBid": "\$8.15",
      "status": "outbid",
    },
    {
      "id": 3,
      "title": "MacBook Air M2 13-inch",
      "image":
          "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=400&h=400&fit=crop",
      "currentPrice": "\$15.89",
      "timeLeft": "1h 32m",
      "myBid": "\$15.89",
      "status": "active",
    },
  ];

  final List<Map<String, dynamic>> wonAuctions = [
    {
      "id": 1,
      "title": "iPad Pro 11-inch 128GB",
      "image":
          "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400&h=400&fit=crop",
      "winPrice": "\$23.45",
      "retailPrice": "\$799.00",
      "savings": "\$775.55",
      "wonDate": "2024-08-20",
      "deliveryStatus": "Shipped",
      "trackingNumber": "1Z999AA1234567890",
    },
    {
      "id": 2,
      "title": "AirPods Pro 2nd Generation",
      "image":
          "https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=400&h=400&fit=crop",
      "winPrice": "\$7.89",
      "retailPrice": "\$249.00",
      "savings": "\$241.11",
      "wonDate": "2024-08-15",
      "deliveryStatus": "Delivered",
      "trackingNumber": "1Z999AA1234567891",
    },
  ];

  final List<Map<String, dynamic>> bidHistory = [
    {
      "id": 1,
      "title": "Samsung Galaxy S24 Ultra",
      "image":
          "https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400&h=400&fit=crop",
      "bidAmount": "\$18.45",
      "status": "lost",
      "timestamp": "2 hours ago",
      "finalPrice": "\$18.67",
    },
    {
      "id": 2,
      "title": "Nintendo Switch OLED",
      "image":
          "https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=400&h=400&fit=crop",
      "bidAmount": "\$12.34",
      "status": "won",
      "timestamp": "1 day ago",
      "finalPrice": "\$12.34",
    },
    {
      "id": 3,
      "title": "Apple Watch Series 9",
      "image":
          "https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=400&h=400&fit=crop",
      "bidAmount": "\$9.87",
      "status": "lost",
      "timestamp": "3 days ago",
      "finalPrice": "\$10.23",
    },
    {
      "id": 4,
      "title": "Dyson V15 Detect Vacuum",
      "image":
          "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop",
      "bidAmount": "\$25.67",
      "status": "active",
      "timestamp": "5 days ago",
      "finalPrice": null,
    },
    {
      "id": 5,
      "title": "KitchenAid Stand Mixer",
      "image":
          "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=400&fit=crop",
      "bidAmount": "\$14.56",
      "status": "lost",
      "timestamp": "1 week ago",
      "finalPrice": "\$15.89",
    },
  ];

  Map<String, bool> settings = {
    "pushNotifications": true,
    "soundEffects": true,
    "hapticFeedback": true,
    "darkTheme": false,
  };

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  void _onSettingChanged(String key, bool value) {
    setState(() {
      settings[key] = value;
    });

    // Handle specific setting changes
    switch (key) {
      case 'hapticFeedback':
        if (value) {
          HapticFeedback.lightImpact();
        }
        break;
      case 'darkTheme':
        // Theme switching would be handled here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? "Dark theme enabled" : "Light theme enabled"),
            duration: const Duration(seconds: 2),
          ),
        );
        break;
    }
  }

  void _onAvatarTap() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  "Update Profile Photo",
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PhotoOption(
                      icon: 'camera_alt',
                      label: "Camera",
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Camera feature would open here"),
                          ),
                        );
                      },
                    ),
                    _PhotoOption(
                      icon: 'photo_library',
                      label: "Gallery",
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Gallery feature would open here"),
                          ),
                        );
                      },
                    ),
                    _PhotoOption(
                      icon: 'delete',
                      label: "Remove",
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Profile photo removed")),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: "Profile",
        showBackButton: false,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _mainTabController.animateTo(1);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.2,
                ),
              ),
            ),
            child: TabBar(
              controller: _mainTabController,
              labelColor: AppTheme.lightTheme.colorScheme.primary,
              unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              indicator: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [Tab(text: "Profile"), Tab(text: "Settings")],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                // Profile Tab
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      ProfileHeaderWidget(
                        userData: userData,
                        onAvatarTap: _onAvatarTap,
                      ),
                      SizedBox(height: 3.h),

                      // Statistics Cards
                      StatisticsCardsWidget(statistics: statistics),
                      SizedBox(height: 3.h),

                      // Profile Tabs (Activity)
                      ProfileTabsWidget(
                        activeBids: activeBids,
                        wonAuctions: wonAuctions,
                        bidHistory: bidHistory,
                      ),
                      SizedBox(height: 10.h), // Bottom padding for navigation
                    ],
                  ),
                ),

                // Settings Tab
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Column(
                    children: [
                      SettingsSectionWidget(
                        settings: settings,
                        onSettingChanged: _onSettingChanged,
                      ),
                      SizedBox(height: 10.h), // Bottom padding for navigation
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 3, // Profile tab index
        onTap: (index) {
          HapticFeedback.lightImpact();
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.auctionBrowse,
                (route) => false,
              );
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.watchlist,
                (route) => false,
              );
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.creditManagement,
                (route) => false,
              );
              break;
            case 3:
              // Already on profile screen
              break;
          }
        },
      ),
    );
  }
}

class _PhotoOption extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
