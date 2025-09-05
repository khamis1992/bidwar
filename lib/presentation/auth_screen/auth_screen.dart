import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/auth_form_widget.dart';
import './widgets/auth_header_widget.dart';
import './widgets/auth_mode_toggle_widget.dart';

/// Auth Screen موحدة للتسجيل والدخول
///
/// تدعم email+password و magic link
/// تتبع قواعد BidWar للتصميم والبنية
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  AuthMode _authMode = AuthMode.login;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _authMode =
          _authMode == AuthMode.login ? AuthMode.register : AuthMode.login;
      _errorMessage = null;
    });
  }

  Future<void> _handleAuth({
    required String email,
    required String password,
    String? fullName,
    bool useMagicLink = false,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (useMagicLink) {
        // إرسال Magic Link (سيتم تنفيذه لاحقاً)
        await _sendMagicLink(email);
      } else {
        if (_authMode == AuthMode.login) {
          await _signIn(email, password);
        } else {
          await _signUp(email, password, fullName ?? 'User');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = _extractErrorMessage(e.toString());
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn(String email, String password) async {
    final response = await AuthService.instance.signIn(
      email: email,
      password: password,
    );

    if (response.user != null) {
      _navigateToHome();
    }
  }

  Future<void> _signUp(String email, String password, String fullName) async {
    final response = await AuthService.instance.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );

    if (response.user != null) {
      _showEmailConfirmationMessage();
    }
  }

  Future<void> _sendMagicLink(String email) async {
    // TODO: تنفيذ Magic Link لاحقاً
    throw Exception('Magic Link not implemented yet');
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showEmailConfirmationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _authMode == AuthMode.register
              ? 'Registration successful! Please check your email to verify your account.'
              : 'Magic link sent! Please check your email.',
        ),
        backgroundColor: AppTheme.successLight,
        duration: const Duration(seconds: 5),
      ),
    );

    // التبديل إلى وضع تسجيل الدخول بعد التسجيل
    if (_authMode == AuthMode.register) {
      setState(() {
        _authMode = AuthMode.login;
      });
    }
  }

  String _extractErrorMessage(String error) {
    final message = error.replaceFirst('Exception: ', '');

    // رسائل خطأ مخصصة
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (message.contains('Email already registered')) {
      return 'This email is already registered. Please sign in instead.';
    } else if (message.contains('Password')) {
      return 'Password must be at least 6 characters long.';
    } else if (message.contains('Email')) {
      return 'Please enter a valid email address.';
    } else if (message.contains('network')) {
      return 'Network error. Please check your connection.';
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50.h * _slideAnimation.value),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    children: [
                      SizedBox(height: 8.h),

                      // Header مع Logo
                      AuthHeaderWidget(authMode: _authMode),

                      SizedBox(height: 6.h),

                      // Toggle بين Login/Register
                      AuthModeToggleWidget(
                        authMode: _authMode,
                        onToggle: _toggleAuthMode,
                      ),

                      SizedBox(height: 4.h),

                      // Form للبيانات
                      AuthFormWidget(
                        authMode: _authMode,
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                        onSubmit: _handleAuth,
                      ),

                      SizedBox(height: 6.h),

                      // Footer مع معلومات إضافية
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(
          color: AppTheme.borderLight,
          thickness: 1,
          indent: 10.w,
          endIndent: 10.w,
        ),

        SizedBox(height: 3.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 4.w, color: AppTheme.textSecondaryLight),
            SizedBox(width: 2.w),
            Text(
              'Secure & Fair Bidding Platform',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, size: 4.w, color: AppTheme.successLight),
            SizedBox(width: 2.w),
            Text(
              'Protected by Supabase Auth',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// أنماط المصادقة
enum AuthMode { login, register }
