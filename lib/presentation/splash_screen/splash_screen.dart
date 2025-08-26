import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _auctionIconsController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoPulseAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _loadingOpacityAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _auctionIconsAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  bool _isInitializing = true;
  String _loadingText = 'Initializing BidWar...';
  bool _showRetryOption = false;

  // Auction-themed floating icons
  final List<IconData> _auctionIcons = [
    Icons.gavel,
    Icons.trending_up,
    Icons.timer,
    Icons.star,
    Icons.attach_money,
    Icons.flash_on,
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startInitialization();
  }

  void _setupAnimations() {
    // Main logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _logoPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
    ));

    // Loading indicator animation
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _loadingOpacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeInOut,
    ));

    // Particle animation for floating effect
    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleAnimationController,
      curve: Curves.linear,
    ));

    // Auction icons floating animation
    _auctionIconsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _auctionIconsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _auctionIconsController,
      curve: Curves.easeInOut,
    ));

    // Background color transition
    _backgroundColorAnimation = ColorTween(
      begin: AppTheme.lightTheme.colorScheme.primary,
      end: AppTheme.lightTheme.colorScheme.secondary,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations with staggered timing
    _logoAnimationController.forward();
    _loadingAnimationController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      _particleAnimationController.repeat();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _auctionIconsController.repeat(reverse: true);
    });
  }

  Future<void> _startInitialization() async {
    try {
      await _performInitializationTasks();

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        _handleInitializationError();
      }
    }
  }

  Future<void> _performInitializationTasks() async {
    // Task 1: Check authentication status
    setState(() {
      _loadingText = 'Connecting to auction house...';
    });
    await Future.delayed(const Duration(milliseconds: 800));

    // Task 2: Load user credit balance
    setState(() {
      _loadingText = 'Loading your bidding power...';
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // Task 3: Fetch active auctions
    setState(() {
      _loadingText = 'Finding live auctions...';
    });
    await Future.delayed(const Duration(milliseconds: 700));

    // Task 4: Prepare cached auction data
    setState(() {
      _loadingText = 'Preparing auction catalog...';
    });
    await Future.delayed(const Duration(milliseconds: 500));

    // Task 5: Initialize real-time connections
    setState(() {
      _loadingText = 'Establishing real-time bidding...';
    });
    await Future.delayed(const Duration(milliseconds: 600));
  }

  void _navigateToNextScreen() {
    final bool isAuthenticated = _checkAuthenticationStatus();
    final bool isFirstTime = _checkFirstTimeUser();

    String nextRoute;
    if (isAuthenticated) {
      nextRoute = '/auction-browse-screen';
    } else if (isFirstTime) {
      nextRoute = '/onboarding-flow';
    } else {
      nextRoute = '/login-screen';
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  bool _checkAuthenticationStatus() {
    return false;
  }

  bool _checkFirstTimeUser() {
    return true;
  }

  void _handleInitializationError() {
    setState(() {
      _isInitializing = false;
      _loadingText = 'Connection timeout - Check network';
      _showRetryOption = true;
    });
  }

  void _retryInitialization() {
    setState(() {
      _isInitializing = true;
      _showRetryOption = false;
      _loadingText = 'Reconnecting to auction house...';
    });
    _startInitialization();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    _particleAnimationController.dispose();
    _auctionIconsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: AnimatedBuilder(
          animation: _backgroundColorAnimation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: _buildAnimatedBackgroundGradient(),
              child: Stack(
                children: [
                  _buildFloatingParticles(),
                  _buildFloatingAuctionIcons(),
                  SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildEnhancedAnimatedLogo(),
                                SizedBox(height: 8.h),
                                _buildEnhancedLoadingSection(),
                              ],
                            ),
                          ),
                        ),
                        _buildEnhancedBottomSection(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _buildAnimatedBackgroundGradient() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _backgroundColorAnimation.value ??
              AppTheme.lightTheme.colorScheme.primary,
          AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
          AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.6),
          AppTheme.lightTheme.colorScheme.secondary,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final double animationOffset = (index * 0.2) % 1.0;
            final double adjustedAnimation =
                (_particleAnimation.value + animationOffset) % 1.0;

            return Positioned(
              left: (20 + (index * 15)) % 100.w,
              top: adjustedAnimation * 100.h,
              child: Transform.rotate(
                angle: adjustedAnimation * 6.28,
                child: Container(
                  width: 2.w + (index % 3),
                  height: 2.w + (index % 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3 - (index * 0.02)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildFloatingAuctionIcons() {
    return AnimatedBuilder(
      animation: _auctionIconsAnimation,
      builder: (context, child) {
        return Stack(
          children: _auctionIcons.asMap().entries.map((entry) {
            final int index = entry.key;
            final IconData icon = entry.value;

            final double animationPhase =
                (_auctionIconsAnimation.value + (index * 0.15)) % 1.0;
            final double opacity =
                (0.1 + (animationPhase * 0.2)).clamp(0.0, 0.3);

            return Positioned(
              left: (10 + (index * 25)) % 85.w,
              top: (15 + (index * 12) + (animationPhase * 10)) % 70.h,
              child: Transform.scale(
                scale: 0.5 + (animationPhase * 0.3),
                child: Icon(
                  icon,
                  size: 6.w,
                  color: Colors.white.withValues(alpha: opacity),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEnhancedAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value,
            child: AnimatedBuilder(
              animation: _logoPulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoPulseAnimation.value,
                  child: Container(
                    width: 35.w,
                    height: 35.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.gavel,
                              size: 14.w,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 4.w,
                                height: 4.w,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.amber.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'BidWar',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.lightTheme.colorScheme.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'AUCTIONS',
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.7),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedLoadingSection() {
    return Column(
      children: [
        if (_isInitializing) ...[
          AnimatedBuilder(
            animation: _loadingOpacityAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _loadingOpacityAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 12.w,
                      height: 12.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    Icon(
                      Icons.timer,
                      size: 5.w,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 4.h),
          Text(
            _loadingText,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                3,
                (index) => AnimatedBuilder(
                      animation: _loadingAnimationController,
                      builder: (context, child) {
                        final double delay = index * 0.2;
                        final double animationValue =
                            (_loadingAnimationController.value + delay) % 1.0;
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 1.w),
                          width: 2.w,
                          height: 2.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                                alpha: 0.3 + (animationValue * 0.7)),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    )),
          ),
        ],
        if (_showRetryOption) ...[
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.signal_wifi_connected_no_internet_4,
                  size: 10.w,
                  color: Colors.white,
                ),
                SizedBox(height: 2.h),
                Text(
                  _loadingText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                ElevatedButton.icon(
                  onPressed: _retryInitialization,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                  ),
                  icon: Icon(
                    Icons.refresh,
                    size: 5.w,
                  ),
                  label: Text(
                    'Retry Connection',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEnhancedBottomSection() {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flash_on,
                size: 5.w,
                color: Colors.amber,
              ),
              SizedBox(width: 2.w),
              Text(
                'Real-time Penny Auctions',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user,
                size: 4.w,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              SizedBox(width: 2.w),
              Text(
                'Secure & Fair Bidding Platform',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}