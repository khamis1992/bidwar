import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import './widgets/app_logo_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/signup_prompt_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Check if user is admin and navigate accordingly
        final isAdmin = await AuthService.instance.isAdmin();
        if (isAdmin) {
          // Navigate to admin dashboard
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        } else {
          // Navigate to regular user home screen
          Navigator.pushReplacementNamed(context, AppRoutes.auctionBrowse);
        }
      }
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');

      // Handle specific Supabase initialization error
      if (errorMessage.contains('Supabase not initialized')) {
        errorMessage =
            'خدمة قاعدة البيانات غير متاحة حالياً. يرجى المحاولة لاحقاً.';
      } else if (errorMessage.contains('Invalid login credentials')) {
        errorMessage =
            'بيانات تسجيل الدخول غير صحيحة. يرجى التحقق من البريد الإلكتروني وكلمة المرور.';
      } else if (errorMessage.contains('network')) {
        errorMessage = 'مشكلة في الاتصال بالإنترنت. يرجى التحقق من اتصالك.';
      }

      _showError(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email address first');
      return;
    }

    try {
      await AuthService.instance.resetPassword(_emailController.text.trim());
      _showSuccess('Password reset email sent! Check your inbox.');
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 5.h),

                // App logo and branding
                const AppLogoWidget(),

                SizedBox(height: 5.h),

                // Welcome text
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Sign in to continue bidding',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 4.h),

                // Login form
                LoginFormWidget(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  obscurePassword: _obscurePassword,
                  isLoading: _isLoading,
                  onTogglePassword: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onSignIn: _signIn,
                  onForgotPassword: _forgotPassword,
                ),

                SizedBox(height: 3.h),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Text(
                        'OR',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                SizedBox(height: 3.h),

                // Social login options
                const SocialLoginWidget(),

                SizedBox(height: 4.h),

                // Guest mode option
                OutlinedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, AppRoutes.auctionBrowse),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: const Text('المتابعة كضيف'),
                ),

                SizedBox(height: 3.h),

                // Sign up prompt
                const SignupPromptWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
