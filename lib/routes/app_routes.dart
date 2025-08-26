import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/credit_management_screen/credit_management_screen.dart';
import '../presentation/user_profile_screen/user_profile_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/auction_browse_screen/auction_browse_screen.dart';
import '../presentation/auction_detail_screen/auction_detail_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/watchlist_screen/watchlist_screen.dart';
import '../presentation/admin_dashboard_overview/admin_dashboard_overview.dart';
import '../presentation/auction_management_panel/auction_management_panel.dart';
import '../presentation/user_management_console/user_management_console.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String creditManagement = '/credit-management-screen';
  static const String userProfile = '/user-profile-screen';
  static const String login = '/login-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String auctionBrowse = '/auction-browse-screen';
  static const String auctionDetail = '/auction-detail-screen';
  static const String registration = '/registration-screen';
  static const String watchlist = '/watchlist-screen';
  static const String adminDashboardOverview = '/admin-dashboard-overview';
  static const String auctionManagementPanel = '/auction-management-panel';
  static const String userManagementConsole = '/user-management-console';

  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const SplashScreen(),
        splash: (context) => const SplashScreen(),
        creditManagement: (context) => const CreditManagementScreen(),
        userProfile: (context) => const UserProfileScreen(),
        login: (context) => const LoginScreen(),
        onboardingFlow: (context) => const OnboardingFlow(),
        auctionBrowse: (context) => const AuctionBrowseScreen(),
        auctionDetail: (context) => const AuctionDetailScreen(),
        registration: (context) => const RegistrationScreen(),
        watchlist: (context) => const WatchlistScreen(),
        adminDashboardOverview: (context) => const AdminDashboardOverview(),
        auctionManagementPanel: (context) => const AuctionManagementPanel(),
        userManagementConsole: (context) => const UserManagementConsole(),
        // TODO: Add your other routes here
      };
}
