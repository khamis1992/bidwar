import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/onboarding_navigation_widget.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;

  // Mock onboarding data
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "How Penny Auctions Work",
      "description":
          "Each bid increases the price by exactly \$0.01. The last person to bid when the timer expires wins the item at that final price!",
      "useAnimation": true,
      "animationType": "auction_work",
      "showInteractive": false,
    },
    {
      "title": "Credit System & Timer",
      "description":
          "Each bid costs 1 credit and extends the timer by 10-30 seconds. Buy credits to participate and watch the excitement build!",
      "useAnimation": true,
      "animationType": "credit_timer",
      "showInteractive": false,
    },
    {
      "title": "Winning Strategy",
      "description":
          "Be strategic! Time your bids carefully and be the last bidder when the countdown reaches zero to win amazing items at incredible prices.",
      "useAnimation": true,
      "animationType": "winning_strategy",
      "showInteractive": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    HapticFeedback.selectionClick();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/auction-browse-screen',
      (route) => false,
    );
  }

  void _getStarted() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/auction-browse-screen',
      (route) => false,
    );
  }

  void _handleInteraction() {
    HapticFeedback.lightImpact();
    // Show a brief animation or feedback for the interactive element
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Great! You\'re ready to start bidding!',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.inverseSurface,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Skip button in top-right corner
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 2.h, right: 4.w),
                child: Align(
                  alignment: Alignment.topRight,
                  child: _currentPage < _onboardingData.length - 1
                      ? TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _skipOnboarding();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
                          ),
                          child: Text(
                            'Skip',
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final pageData = _onboardingData[index];
                  return OnboardingPageWidget(
                    title: pageData["title"] as String,
                    description: pageData["description"] as String,
                    useAnimation: pageData["useAnimation"] as bool? ?? false,
                    animationType: pageData["animationType"] as String?,
                    showInteractiveElement: pageData["showInteractive"] as bool,
                    onInteraction: _handleInteraction,
                  );
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: PageIndicatorWidget(
                currentPage: _currentPage,
                totalPages: _onboardingData.length,
              ),
            ),

            // Navigation buttons
            OnboardingNavigationWidget(
              currentPage: _currentPage,
              totalPages: _onboardingData.length,
              onNext: _nextPage,
              onSkip: _skipOnboarding,
              onGetStarted: _getStarted,
            ),
          ],
        ),
      ),
    );
  }
}
