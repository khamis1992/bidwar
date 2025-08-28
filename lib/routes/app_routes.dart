import 'package:flutter/material.dart';

import '../presentation/admin_dashboard_overview/admin_dashboard_overview.dart';
import '../presentation/advanced_live_stream_admin_panel/advanced_live_stream_admin_panel.dart';
import '../presentation/ai_powered_stream_recommendations_engine/ai_powered_stream_recommendations_engine.dart';
import '../presentation/auction_browse_screen/auction_browse_screen.dart';
import '../presentation/auction_detail_screen/auction_detail_screen.dart';
import '../presentation/auction_management_panel/auction_management_panel.dart';
import '../presentation/creator_commission_dashboard/creator_commission_dashboard.dart';
import '../presentation/credit_management_screen/credit_management_screen.dart';
import '../presentation/enhanced_live_stream_creation_screen/enhanced_live_stream_creation_screen.dart';
import '../presentation/live_auction_stream_screen/live_auction_stream_screen.dart';
import '../presentation/live_stream_analytics_dashboard/live_stream_analytics_dashboard.dart';
import '../presentation/live_stream_creation_screen/live_stream_creation_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/product_selection_screen/product_selection_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/seller_rating_review_system/seller_rating_review_system.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/tik_tok_style_auction_browse_screen/tik_tok_style_auction_browse_screen.dart';
import '../presentation/user_management_console/user_management_console.dart';
import '../presentation/user_profile_screen/user_profile_screen.dart';
import '../presentation/watchlist_screen/watchlist_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String auctionBrowse = '/auction-browse';
  static const String tikTokStyleAuctionBrowse = '/tiktok-auction-browse';
  static const String auctionDetail = '/auction-detail';
  static const String liveAuctionStream = '/live-auction-stream';
  static const String liveStreamCreation = '/live-stream-creation';
  static const String watchlist = '/watchlist';
  static const String userProfile = '/user-profile';
  static const String creditManagement = '/credit-management';
  static const String liveStreamAnalytics = '/live-stream-analytics';
  static const String sellerRatingReview = '/seller-rating-review';
  static const String aiStreamRecommendations = '/ai-stream-recommendations';
  static const String adminDashboard = '/admin-dashboard';
  static const String userManagement = '/user-management';
  static const String auctionManagement = '/auction-management';
  static const String advancedLiveStreamAdmin = '/advanced-live-stream-admin';
  static const String productSelectionScreen = '/product-selection-screen';
  static const String creatorCommissionDashboard = '/creator-commission-dashboard';
  static const String enhancedLiveStreamCreationScreen = '/enhanced-live-stream-creation-screen';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingFlow(),
    login: (context) => const LoginScreen(),
    registration: (context) => const RegistrationScreen(),
    auctionBrowse: (context) => const AuctionBrowseScreen(),
    tikTokStyleAuctionBrowse: (context) => const TikTokStyleAuctionBrowseScreen(),
    auctionDetail: (context) => const AuctionDetailScreen(),
    liveAuctionStream: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      return LiveAuctionStreamScreen(
        streamId: args['streamId'] ?? 'default',
      );
    },
    liveStreamCreation: (context) => LiveStreamCreationScreen(),
    watchlist: (context) => WatchlistScreen(),
    userProfile: (context) => UserProfileScreen(),
    creditManagement: (context) => CreditManagementScreen(),
    liveStreamAnalytics: (context) => LiveStreamAnalyticsDashboard(),
    sellerRatingReview: (context) => SellerRatingReviewSystem(),
    adminDashboard: (context) => AdminDashboardOverview(),
    userManagement: (context) => UserManagementConsole(),
    auctionManagement: (context) => AuctionManagementPanel(),
    advancedLiveStreamAdmin: (context) => AdvancedLiveStreamAdminPanel(),
    productSelectionScreen: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      return ProductSelectionScreen(
        userTier: args['userTier'] ?? 'bronze',
        creditBalance: args['creditBalance'] ?? 0,
      );
    },
    creatorCommissionDashboard: (context) => CreatorCommissionDashboard(),
    enhancedLiveStreamCreationScreen: (context) => EnhancedLiveStreamCreationScreen(),
  };

  Route<dynamic> generateRoute(RouteSettings settings) {
    final routes = AppRoutes.routes;
    final routeBuilder = routes[settings.name];

    if (routeBuilder != null) {
      return MaterialPageRoute(
        builder: routeBuilder,
        settings: settings,
      );
    }

    // Fallback route
    return MaterialPageRoute(
      builder: (context) => const SplashScreen(),
      settings: settings,
    );
  }
}