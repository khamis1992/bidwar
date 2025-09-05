import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/auth_service.dart';
import '../auth_screen.dart';

/// Auth Form Widget
///
/// نموذج البيانات للتسجيل والدخول
/// يتبع قواعد BidWar للتصميم والتحقق
class AuthFormWidget extends StatefulWidget {
  final AuthMode authMode;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function({
    required String email,
    required String password,
    String? fullName,
    bool useMagicLink,
  }) onSubmit;

  const AuthFormWidget({
    super.key,
    required this.authMode,
    required this.isLoading,
    this.errorMessage,
    required this.onSubmit,
  });

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _useMagicLink = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: widget.authMode == AuthMode.register
          ? _fullNameController.text.trim()
          : null,
      useMagicLink: _useMagicLink,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Error Message
          if (widget.errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              margin: EdgeInsets.only(bottom: 3.h),
              decoration: BoxDecoration(
                color: AppTheme.errorLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.errorLight.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.errorLight,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      widget.errorMessage!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.errorLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Full Name Field (للتسجيل فقط)
          if (widget.authMode == AuthMode.register) ...[
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
                hintText: 'Enter your full name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 3.h),
          ],

          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
              hintText: 'Enter your email',
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),

          SizedBox(height: 3.h),

          // Password Field (إذا لم يكن Magic Link)
          if (!_useMagicLink) ...[
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                hintText: widget.authMode == AuthMode.register
                    ? 'Create a strong password'
                    : 'Enter your password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (widget.authMode == AuthMode.register && value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitForm(),
            ),
            SizedBox(height: 3.h),
          ],

          // Magic Link Toggle
          Row(
            children: [
              Checkbox(
                value: _useMagicLink,
                onChanged: (value) {
                  setState(() {
                    _useMagicLink = value ?? false;
                  });
                },
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  widget.authMode == AuthMode.login
                      ? 'Use Magic Link (passwordless)'
                      : 'Send verification via Magic Link',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondaryLight,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Submit Button
          SizedBox(
            height: 7.h,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      _getButtonText(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          // Forgot Password (للدخول فقط)
          if (widget.authMode == AuthMode.login && !_useMagicLink) ...[
            SizedBox(height: 2.h),
            Center(
              child: TextButton(
                onPressed: widget.isLoading ? null : _showForgotPasswordDialog,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getButtonText() {
    if (_useMagicLink) {
      return widget.authMode == AuthMode.login
          ? 'Send Magic Link'
          : 'Register with Magic Link';
    }

    return widget.authMode == AuthMode.login ? 'Sign In' : 'Create Account';
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you a password reset link.',
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(height: 3.h),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.trim().isEmpty) return;

              try {
                await AuthService.instance.resetPassword(
                  emailController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password reset link sent to your email'),
                    backgroundColor: AppTheme.successLight,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to send reset link: $e'),
                    backgroundColor: AppTheme.errorLight,
                  ),
                );
              }
            },
            child: Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}
