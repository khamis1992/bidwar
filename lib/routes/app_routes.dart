import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/user_profile_screen/user_profile_screen.dart';
import '../presentation/auction_browse_screen/auction_browse_screen.dart';
import '../presentation/auction_detail_screen/auction_detail_screen.dart';
import '../presentation/watchlist_screen/watchlist_screen.dart';
import '../presentation/credit_management_screen/credit_management_screen.dart';
import '../presentation/live_auction_stream_screen/live_auction_stream_screen.dart';
import '../presentation/live_stream_creation_screen/live_stream_creation_screen.dart';
import '../presentation/enhanced_live_stream_creation_screen/enhanced_live_stream_creation_screen.dart';
import '../presentation/product_selection_screen/product_selection_screen.dart';
import '../presentation/live_stream_analytics_dashboard/live_stream_analytics_dashboard.dart';
import '../presentation/creator_commission_dashboard/creator_commission_dashboard.dart';
import '../presentation/seller_rating_review_system/seller_rating_review_system.dart';
import '../presentation/tik_tok_style_auction_browse_screen/tik_tok_style_auction_browse_screen.dart';
import '../presentation/admin_dashboard_overview/admin_dashboard_overview.dart';
import '../presentation/user_management_console/user_management_console.dart';
import '../presentation/auction_management_panel/auction_management_panel.dart';
import '../presentation/advanced_live_stream_admin_panel/advanced_live_stream_admin_panel.dart';
import '../presentation/battle_rooms_hub/battle_rooms_hub.dart';
import '../presentation/battle_creation_competitor_invitation/battle_creation_competitor_invitation.dart';
import '../presentation/live_battle_arena/live_battle_arena.dart';

class AppRoutes {
  static const String initialRoute = '/splash';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String userProfile = '/user-profile';
  static const String auctionBrowse = '/auction-browse';
  static const String auctionDetail = '/auction-detail';
  static const String watchlist = '/watchlist';
  static const String creditManagement = '/credit-management';
  static const String liveAuctionStream = '/live-auction-stream';
  static const String liveStreamCreation = '/live-stream-creation';
  static const String enhancedLiveStreamCreation =
      '/enhanced-live-stream-creation';
  static const String productSelection = '/product-selection';
  static const String aiPoweredStreamRecommendations =
      '/ai-powered-stream-recommendations';
  static const String liveStreamAnalyticsDashboard =
      '/live-stream-analytics-dashboard';
  static const String creatorCommissionDashboard =
      '/creator-commission-dashboard';
  static const String sellerRatingReviewSystem = '/seller-rating-review-system';
  static const String tikTokStyleAuctionBrowse =
      '/tik-tok-style-auction-browse';
  static const String adminDashboard = '/admin-dashboard';
  static const String userManagement = '/user-management';
  static const String auctionManagement = '/auction-management';
  static const String advancedLiveStreamAdminPanel =
      '/advanced-live-stream-admin-panel';
  static const String liveBattleArena = '/live-battle-arena';

  // New Battle Routes
  static const String battleRoomsHub = '/battle-rooms-hub';
  static const String battleCreationCompetitorInvitation =
      '/battle-creation-competitor-invitation';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingFlow(),
        login: (context) => const LoginScreen(),
        registration: (context) => const RegistrationScreen(),
        userProfile: (context) => const UserProfileScreen(),
        auctionBrowse: (context) => const AuctionBrowseScreen(),
        auctionDetail: (context) => const AuctionDetailScreen(),
        watchlist: (context) => const WatchlistScreen(),
        creditManagement: (context) => const CreditManagementScreen(),
        liveAuctionStream: (context) =>
            const LiveAuctionStreamScreen(streamId: ''),
        liveStreamCreation: (context) => const LiveStreamCreationScreen(),
        enhancedLiveStreamCreation: (context) =>
            const EnhancedLiveStreamCreationScreen(),
        productSelection: (context) =>
            const ProductSelectionScreen(userTier: 'bronze', creditBalance: 0),
        liveStreamAnalyticsDashboard: (context) =>
            const LiveStreamAnalyticsDashboard(),
        creatorCommissionDashboard: (context) =>
            const CreatorCommissionDashboard(),
        sellerRatingReviewSystem: (context) => const SellerRatingReviewSystem(),
        tikTokStyleAuctionBrowse: (context) =>
            const TikTokStyleAuctionBrowseScreen(),
        adminDashboard: (context) => const AdminDashboardOverview(),
        userManagement: (context) => const UserManagementConsole(),
        auctionManagement: (context) => const AuctionManagementPanel(),
        advancedLiveStreamAdminPanel: (context) =>
            const AdvancedLiveStreamAdminPanel(),
        liveBattleArena: (context) => const LiveBattleArena(),

        // New Battle Routes
        battleRoomsHub: (context) => const BattleRoomsHub(),
        battleCreationCompetitorInvitation: (context) =>
            const BattleCreationCompetitorInvitation(),
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
