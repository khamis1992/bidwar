import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './controllers/create_auction_controller.dart';
import './widgets/auction_form_widget.dart';
import './widgets/image_upload_widget.dart';
import './widgets/preview_card_widget.dart';

/// Create Auction Screen - صفحة إنشاء مزاد جديد
///
/// تتيح للمستخدمين إنشاء مزادات جديدة
/// تتبع قواعد BidWar للتصميم والبنية
class CreateAuctionScreen extends StatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  State<CreateAuctionScreen> createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends State<CreateAuctionScreen>
    with SingleTickerProviderStateMixin {
  late CreateAuctionController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = CreateAuctionController();
    _tabController = TabController(length: 3, vsync: this);
    _checkAuthentication();
  }

  void _checkAuthentication() {
    if (!AuthService.instance.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginRequiredDialog();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text('You need to sign in to create an auction.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // العودة للصفحة السابقة
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/auth');
            },
            child: Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 2.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.successLight,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleCreateAuction() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) {
        _showLoginRequiredDialog();
        return;
      }

      final result = await _controller.createAuction(sellerId: user.id);

      if (result.success) {
        _showSuccess('Auction created successfully!');

        // التنقل لصفحة تفاصيل المزاد الجديد
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.auctionDetail,
          arguments: {'auctionId': result.auctionId},
        );
      } else {
        _showError(result.message);
      }
    } catch (e) {
      _showError('Failed to create auction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Create Auction',
          style: TextStyle(
            color: AppTheme.primaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Preview Button
          TextButton.icon(
            onPressed: () => _tabController.animateTo(2),
            icon: Icon(Icons.preview, size: 5.w),
            label: Text('Preview'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryLight,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 4.w),
                      SizedBox(width: 1.w),
                      Text('Details'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 4.w),
                      SizedBox(width: 1.w),
                      Text('Images'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.preview, size: 4.w),
                      SizedBox(width: 1.w),
                      Text('Preview'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Details Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: AuctionFormWidget(
                    controller: _controller,
                    onNext: () => _tabController.animateTo(1),
                  ),
                ),

                // Images Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: ImageUploadWidget(
                    controller: _controller,
                    onNext: () => _tabController.animateTo(2),
                    onPrevious: () => _tabController.animateTo(0),
                  ),
                ),

                // Preview Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: PreviewCardWidget(
                    controller: _controller,
                    onEdit: () => _tabController.animateTo(0),
                    onCreate: _handleCreateAuction,
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
