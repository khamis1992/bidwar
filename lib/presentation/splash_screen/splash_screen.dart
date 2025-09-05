import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/network/supabase_client_provider.dart';
import '../../services/auth_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/environment_service.dart';
import '../../services/supabase_service.dart';

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
  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool _canProceedWithoutSupabase = false;

  // Enhanced status tracking
  ConnectionStatus _connectionStatus = ConnectionStatus.checking;
  Map<String, dynamic>? _connectionDetails;
  Map<String, dynamic>? _environmentStatus;

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

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoPulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Loading indicator animation
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _loadingOpacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Particle animation for floating effect
    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleAnimationController,
        curve: Curves.linear,
      ),
    );

    // Auction icons floating animation
    _auctionIconsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _auctionIconsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _auctionIconsController, curve: Curves.easeInOut),
    );

    // Background color transition
    _backgroundColorAnimation = ColorTween(
      begin: AppTheme.lightTheme.colorScheme.primary,
      end: AppTheme.lightTheme.colorScheme.secondary,
    ).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations with staggered timing
    _logoAnimationController.forward();
    _loadingAnimationController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _particleAnimationController.repeat();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _auctionIconsController.repeat(reverse: true);
    });
  }

  Future<void> _startInitialization() async {
    try {
      // Initialize environment service first
      setState(() {
        _loadingText = 'Loading environment configuration...';
      });

      final envInitialized = await EnvironmentService.initialize();
      _environmentStatus = EnvironmentService.getStatus();

      await Future.delayed(const Duration(milliseconds: 800));

      // Initialize connectivity service
      setState(() {
        _loadingText = 'Initializing connectivity service...';
      });

      await ConnectivityService.instance.initialize();

      // Listen to connection status changes
      ConnectivityService.instance.connectionStatusStream.listen((status) {
        if (mounted) {
          setState(() {
            _connectionStatus = status;
          });
        }
      });

      await _performInitializationTasks();

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        _handleInitializationError('Initialization failed: ${e.toString()}');
      }
    }
  }

  Future<void> _performInitializationTasks() async {
    try {
      // Task 1: Check network connectivity with enhanced validation
      setState(() {
        _loadingText = 'Checking network connection...';
        _connectionStatus = ConnectionStatus.checking;
      });

      await Future.delayed(const Duration(milliseconds: 600));

      final hasNetwork =
          await ConnectivityService.instance.hasNetworkConnection();
      if (!hasNetwork) {
        throw Exception('No network connection available');
      }

      // Task 2: Validate environment configuration
      setState(() {
        _loadingText = 'Validating server configuration...';
      });

      await Future.delayed(const Duration(milliseconds: 700));

      if (!EnvironmentService.hasValidSupabaseCredentials()) {
        setState(() {
          _loadingText = 'Server not configured - Preparing demo mode...';
          _canProceedWithoutSupabase = true;
        });
        await Future.delayed(const Duration(milliseconds: 1500));
        _proceedToDemoMode();
        return;
      }

      // Task 3: Initialize and connect to Supabase
      setState(() {
        _loadingText = 'Connecting to auction servers...';
      });

      final connectionDetails =
          await ConnectivityService.instance.performFullConnectivityCheck();
      _connectionDetails = connectionDetails;

      if (!connectionDetails['hasSupabase']) {
        final errorMsg =
            connectionDetails['errorMessage'] ?? 'Server connection failed';
        final connectivity = connectionDetails['connectivity'] ?? 'unknown';

        print('🔧 Connection failed - Type: $connectivity, Error: $errorMsg');

        // Provide more specific error handling
        if (connectivity == 'timeout') {
          setState(() {
            _loadingText = 'Server response timeout - Retrying...';
          });
          await Future.delayed(const Duration(milliseconds: 1000));

          // Try one more time with longer timeout
          final retryResult =
              await ConnectivityService.instance.retryConnection(maxRetries: 1);
          if (!retryResult) {
            _proceedToDemoModeWithReason('Server timeout - Using offline mode');
            return;
          } else {
            // Retry successful, continue with normal flow
            _connectionDetails!['hasSupabase'] = true;
          }
        } else if (connectivity == 'no_credentials') {
          _proceedToDemoModeWithReason('Credentials not configured');
          return;
        } else if (connectionDetails['hasNetwork'] &&
            !errorMsg.contains('credentials')) {
          _proceedToDemoModeWithReason('Server temporarily unavailable');
          return;
        } else {
          throw Exception(errorMsg);
        }
      }

      await Future.delayed(const Duration(milliseconds: 600));

      // Task 4: Verify authentication status
      setState(() {
        _loadingText = 'Checking authentication status...';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Task 5: Load initial auction data with proper error handling
      setState(() {
        _loadingText = 'Loading auction data...';
      });

      try {
        await Future.delayed(const Duration(milliseconds: 700));

        // Test a simple query to verify everything works
        if (SupabaseService.isInitialized) {
          await SupabaseService.instance.client
              .from('categories')
              .select('id')
              .limit(1)
              .timeout(const Duration(seconds: 4));
        }
      } catch (e) {
        print('⚠️ Initial data load failed, continuing anyway: $e');
        // Don't fail the entire initialization for this
      }

      // Task 6: Prepare real-time connections
      setState(() {
        _loadingText = 'Establishing real-time connections...';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _loadingText = 'Ready to bid! 🎯';
        _connectionStatus = ConnectionStatus.connected;
      });

      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      throw Exception('Initialization sequence failed: ${e.toString()}');
    }
  }

  void _proceedToDemoModeWithReason(String reason) {
    setState(() {
      _loadingText = '$reason - Using demo mode...';
      _canProceedWithoutSupabase = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _proceedToDemoMode();
      }
    });
  }

  void _proceedToDemoMode() {
    setState(() {
      _connectionStatus = ConnectionStatus.connected;
      _loadingText = 'Ready to explore demo! 🚀';
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    final bool isAuthenticated = _checkAuthenticationStatus();
    final bool isFirstTime = _checkFirstTimeUser();

    String nextRoute;
    if (isAuthenticated) {
      nextRoute = '/home'; // التوجه لصفحة Home الجديدة
    } else if (isFirstTime) {
      nextRoute = AppRoutes.onboarding;
    } else {
      nextRoute = '/auth'; // التوجه لصفحة Auth الجديدة
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  bool _checkAuthenticationStatus() {
    try {
      // التحقق من الحالة باستخدام AuthService
      if (AuthService.instance.isLoggedIn) {
        return true;
      }

      // في وضع Demo أو عند عدم توفر Supabase
      if (_canProceedWithoutSupabase ||
          !SupabaseClientProvider.instance.isInitialized) {
        return false;
      }

      return _connectionDetails?['authStatus'] == 'authenticated';
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  bool _checkFirstTimeUser() {
    // Check SharedPreferences for first time user
    return true; // Default to first time for onboarding
  }

  void _handleInitializationError(String error) {
    setState(() {
      _isInitializing = false;
      _showRetryOption = true;
      _connectionStatus = ConnectionStatus.error;
    });

    // Provide more specific error messages
    if (error.contains('network')) {
      setState(() {
        _loadingText = 'Network connection failed - Check your internet';
      });
    } else if (error.contains('timeout')) {
      setState(() {
        _loadingText = 'Server connection timeout - Try again';
      });
    } else if (error.contains('credentials')) {
      setState(() {
        _loadingText = 'Configuration error - Using demo mode';
        _canProceedWithoutSupabase = true;
      });
      Future.delayed(const Duration(milliseconds: 2000), _proceedToDemoMode);
      return;
    } else {
      setState(() {
        _loadingText = 'Connection failed - Check network';
      });
    }
  }

  Future<void> _retryInitialization() async {
    if (_retryCount >= _maxRetries) {
      _showMaxRetriesDialog();
      return;
    }

    setState(() {
      _isInitializing = true;
      _showRetryOption = false;
      _loadingText = 'Retrying connection...';
      _retryCount++;
      _connectionStatus = ConnectionStatus.checking;
    });

    // Try with exponential backoff and enhanced retry logic
    final success = await ConnectivityService.instance.retryConnection(
      maxRetries: 2,
    );

    if (success) {
      _retryCount = 0; // Reset on success
      _startInitialization();
    } else {
      _handleInitializationError('Connection retry failed');
    }
  }

  void _showMaxRetriesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connection Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unable to connect to BidWar servers after multiple attempts.',
            ),
            const SizedBox(height: 12),
            if (_environmentStatus != null) ...[
              const Text(
                'Debug Information:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '• Environment: ${_environmentStatus!['total_variables']} variables loaded',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '• Supabase URL: ${_environmentStatus!['has_supabase_url'] ? "✅" : "❌"}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '• Supabase Key: ${_environmentStatus!['has_supabase_key'] ? "✅" : "❌"}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _canProceedWithoutSupabase = true;
                _retryCount = 0;
              });
              _proceedToDemoMode();
            },
            child: const Text('Demo Mode'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _retryCount = 0;
              });
              _retryInitialization();
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              SystemNavigator.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    _particleAnimationController.dispose();
    _auctionIconsController.dispose();
    ConnectivityService.instance.dispose();
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
    Color primaryColor = _canProceedWithoutSupabase
        ? Colors.orange.shade400
        : _connectionStatus == ConnectionStatus.connected
            ? AppTheme.lightTheme.colorScheme.primary
            : _connectionStatus == ConnectionStatus.error
                ? Colors.red.shade400
                : _connectionStatus == ConnectionStatus.timeout
                    ? Colors.amber.shade400
                    : AppTheme.lightTheme.colorScheme.primary;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor,
          primaryColor.withValues(alpha: 0.8),
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
            final double opacity = (0.1 + (animationPhase * 0.2)).clamp(
              0.0,
              0.3,
            );

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
                                  color: _canProceedWithoutSupabase
                                      ? Colors.orange
                                      : _connectionStatus ==
                                              ConnectionStatus.connected
                                          ? Colors.green
                                          : _connectionStatus ==
                                                  ConnectionStatus.error
                                              ? Colors.red
                                              : _connectionStatus ==
                                                      ConnectionStatus.timeout
                                                  ? Colors.amber
                                                  : Colors.grey,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_canProceedWithoutSupabase
                                              ? Colors.orange
                                              : _connectionStatus ==
                                                      ConnectionStatus.connected
                                                  ? Colors.green
                                                  : _connectionStatus ==
                                                          ConnectionStatus.error
                                                      ? Colors.red
                                                      : _connectionStatus ==
                                                              ConnectionStatus
                                                                  .timeout
                                                          ? Colors.amber
                                                          : Colors.grey)
                                          .withValues(alpha: 0.5),
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
                          _canProceedWithoutSupabase ? 'DEMO' : 'AUCTIONS',
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _canProceedWithoutSupabase
                              ? Colors.orange
                              : _connectionStatus == ConnectionStatus.connected
                                  ? Colors.green
                                  : _connectionStatus ==
                                          ConnectionStatus.timeout
                                      ? Colors.amber
                                      : Colors.white,
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    Icon(
                      _canProceedWithoutSupabase
                          ? Icons.play_arrow
                          : _connectionStatus == ConnectionStatus.connected
                              ? Icons.check_circle
                              : _connectionStatus == ConnectionStatus.error
                                  ? Icons.error
                                  : _connectionStatus ==
                                          ConnectionStatus.timeout
                                      ? Icons.access_time
                                      : Icons.sync,
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
                        alpha: 0.3 + (animationValue * 0.7),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            ),
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
                  _connectionStatus == ConnectionStatus.timeout
                      ? Icons.access_time
                      : Icons.signal_wifi_connected_no_internet_4,
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
                if (_retryCount > 0) ...[
                  SizedBox(height: 1.h),
                  Text(
                    'Attempt ${_retryCount}/$_maxRetries',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _retryInitialization,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.5.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                      ),
                      icon: Icon(Icons.refresh, size: 4.w),
                      label: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _canProceedWithoutSupabase = true;
                          _showRetryOption = false;
                        });
                        _proceedToDemoMode();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.5.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                      ),
                      icon: Icon(Icons.play_arrow, size: 4.w),
                      label: Text(
                        'Demo',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
                _canProceedWithoutSupabase
                    ? Icons.play_circle
                    : _connectionStatus == ConnectionStatus.connected
                        ? Icons.flash_on
                        : _connectionStatus == ConnectionStatus.error
                            ? Icons.signal_wifi_off
                            : _connectionStatus == ConnectionStatus.timeout
                                ? Icons.access_time
                                : Icons.signal_wifi_4_bar,
                size: 5.w,
                color: _canProceedWithoutSupabase
                    ? Colors.orange
                    : _connectionStatus == ConnectionStatus.connected
                        ? Colors.amber
                        : _connectionStatus == ConnectionStatus.timeout
                            ? Colors.amber
                            : Colors.white.withValues(alpha: 0.8),
              ),
              SizedBox(width: 2.w),
              Text(
                _canProceedWithoutSupabase
                    ? 'Demo Mode - Explore Features'
                    : _connectionStatus == ConnectionStatus.connected
                        ? 'Connected - Real-time Bidding Ready'
                        : _connectionStatus == ConnectionStatus.error
                            ? 'Connection Error - Retrying...'
                            : _connectionStatus == ConnectionStatus.timeout
                                ? 'Server Timeout - Check Connection'
                                : 'Establishing Connection...',
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
                _canProceedWithoutSupabase
                    ? 'Explore Without Registration'
                    : 'Secure & Fair Bidding Platform',
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
