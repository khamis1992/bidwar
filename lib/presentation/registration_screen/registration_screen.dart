import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/registration_footer_widget.dart';
import './widgets/registration_form_widget.dart';
import './widgets/registration_header_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Mock user data for demonstration
  final List<Map<String, dynamic>> _existingUsers = [
    {
      'email': 'john.doe@example.com',
      'fullName': 'John Doe',
      'registeredAt': DateTime.now().subtract(Duration(days: 30)),
    },
    {
      'email': 'sarah.wilson@example.com',
      'fullName': 'Sarah Wilson',
      'registeredAt': DateTime.now().subtract(Duration(days: 15)),
    },
    {
      'email': 'taken@example.com',
      'fullName': 'Test User',
      'registeredAt': DateTime.now().subtract(Duration(days: 5)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setSystemUIOverlay();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration(
      String fullName, String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Check if email already exists (mock validation)
      final emailExists = _existingUsers.any(
        (user) =>
            (user['email'] as String).toLowerCase() == email.toLowerCase(),
      );

      if (emailExists) {
        _showErrorToast(
            'This email is already registered. Please use a different email.');
        return;
      }

      // Simulate successful registration
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'fullName': fullName,
        'email': email,
        'registeredAt': DateTime.now(),
        'credits': 10, // Welcome bonus
        'isVerified': false,
      };

      // Add to mock database
      _existingUsers.add(newUser);

      // Show success message
      _showSuccessToast('Account created successfully! Welcome to BidWar!');

      // Simulate auto-login and navigation
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        // Navigate to onboarding flow
        Navigator.pushReplacementNamed(context, '/onboarding-flow');
      }
    } catch (error) {
      _showErrorToast(
          'Registration failed. Please check your connection and try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 3,
      backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      textColor: AppTheme.lightTheme.colorScheme.onTertiary,
      fontSize: 14.sp,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 3,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
      textColor: AppTheme.lightTheme.colorScheme.onError,
      fontSize: 14.sp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),

                // Header Section
                const RegistrationHeaderWidget(),
                SizedBox(height: 4.h),

                // Registration Form
                RegistrationFormWidget(
                  onRegister: _handleRegistration,
                  isLoading: _isLoading,
                ),
                SizedBox(height: 4.h),

                // Footer Section
                const RegistrationFooterWidget(),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(2.w),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow
                    .withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CustomIconWidget(
            iconName: 'arrow_back_ios',
            size: 5.w,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pushReplacementNamed(context, '/login-screen');
        },
      ),
      actions: [
        // Help/Support Button
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(2.w),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomIconWidget(
              iconName: 'help_outline',
              size: 5.w,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            _showHelpDialog();
          },
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.w),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'support_agent',
                size: 6.w,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(width: 3.w),
              Text(
                'Need Help?',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Having trouble creating your account? Here are some tips:',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              _buildHelpItem('• Use a valid email address'),
              _buildHelpItem('• Password must be at least 8 characters'),
              _buildHelpItem('• Include uppercase letter and number'),
              _buildHelpItem('• Accept terms and conditions'),
              SizedBox(height: 2.h),
              Text(
                'Still need help? Contact our support team at support@bidwar.com',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Got it!',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        text,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color:
              AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
