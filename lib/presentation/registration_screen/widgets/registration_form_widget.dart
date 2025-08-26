import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationFormWidget extends StatefulWidget {
  final Function(String fullName, String email, String password) onRegister;
  final bool isLoading;

  const RegistrationFormWidget({
    super.key,
    required this.onRegister,
    required this.isLoading,
  });

  @override
  State<RegistrationFormWidget> createState() => _RegistrationFormWidgetState();
}

class _RegistrationFormWidgetState extends State<RegistrationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isFullNameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _agreeToTerms = false;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_validateFullName);
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _validateFullName() {
    setState(() {
      _isFullNameValid = _fullNameController.text.trim().length >= 2 &&
          _fullNameController.text.trim().contains(' ');
    });
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    setState(() {
      if (email.isEmpty) {
        _isEmailValid = false;
        _emailError = null;
      } else if (!emailRegex.hasMatch(email)) {
        _isEmailValid = false;
        _emailError = 'Please enter a valid email address';
      } else {
        _isEmailValid = true;
        _emailError = null;
        // Simulate email availability check
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted && _emailController.text.trim() == email) {
            // Mock email availability check
            if (email.toLowerCase().contains('taken')) {
              setState(() {
                _isEmailValid = false;
                _emailError = 'This email is already registered';
              });
            }
          }
        });
      }
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    setState(() {
      _isPasswordValid = hasMinLength && hasUppercase && hasNumber;
      if (password.isEmpty) {
        _passwordError = null;
      } else if (!hasMinLength) {
        _passwordError = 'Password must be at least 8 characters';
      } else if (!hasUppercase) {
        _passwordError = 'Password must contain at least one uppercase letter';
      } else if (!hasNumber) {
        _passwordError = 'Password must contain at least one number';
      } else {
        _passwordError = null;
      }
    });

    // Re-validate confirm password when password changes
    if (_confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword();
    }
  }

  void _validateConfirmPassword() {
    setState(() {
      if (_confirmPasswordController.text.isEmpty) {
        _isConfirmPasswordValid = false;
        _confirmPasswordError = null;
      } else if (_confirmPasswordController.text != _passwordController.text) {
        _isConfirmPasswordValid = false;
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _isConfirmPasswordValid = true;
        _confirmPasswordError = null;
      }
    });
  }

  bool get _isFormValid {
    return _isFullNameValid &&
        _isEmailValid &&
        _isPasswordValid &&
        _isConfirmPasswordValid &&
        _agreeToTerms;
  }

  void _handleSubmit() {
    if (_isFormValid && !widget.isLoading) {
      HapticFeedback.mediumImpact();
      widget.onRegister(
        _fullNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name Field
          _buildInputField(
            controller: _fullNameController,
            focusNode: _fullNameFocusNode,
            nextFocusNode: _emailFocusNode,
            label: 'Full Name',
            hint: 'Enter your full name',
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            isValid: _isFullNameValid,
            prefixIcon: 'person_outline',
          ),
          SizedBox(height: 3.h),

          // Email Field
          _buildInputField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            nextFocusNode: _passwordFocusNode,
            label: 'Email Address',
            hint: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            isValid: _isEmailValid,
            errorText: _emailError,
            prefixIcon: 'email_outlined',
          ),
          SizedBox(height: 3.h),

          // Password Field
          _buildPasswordField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            nextFocusNode: _confirmPasswordFocusNode,
            label: 'Password',
            hint: 'Create a strong password',
            obscureText: _obscurePassword,
            onToggleVisibility: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            isValid: _isPasswordValid,
            errorText: _passwordError,
          ),

          // Password Requirements
          if (_passwordController.text.isNotEmpty) ...[
            SizedBox(height: 1.h),
            _buildPasswordRequirements(),
          ],

          SizedBox(height: 3.h),

          // Confirm Password Field
          _buildPasswordField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            obscureText: _obscureConfirmPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            isValid: _isConfirmPasswordValid,
            errorText: _confirmPasswordError,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSubmit(),
          ),
          SizedBox(height: 4.h),

          // Terms and Conditions
          _buildTermsCheckbox(),
          SizedBox(height: 4.h),

          // Welcome Bonus Message
          _buildWelcomeBonusMessage(),
          SizedBox(height: 4.h),

          // Register Button
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
    required bool isValid,
    String? errorText,
    required String prefixIcon,
    Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted ??
              (nextFocusNode != null
                  ? (_) => FocusScope.of(context).requestFocus(nextFocusNode)
                  : null),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: prefixIcon,
                size: 5.w,
                color: focusNode.hasFocus
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
              ),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: isValid ? 'check_circle' : 'error',
                      size: 5.w,
                      color: isValid
                          ? AppTheme.lightTheme.colorScheme.tertiary
                          : AppTheme.lightTheme.colorScheme.error,
                    ),
                  )
                : null,
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required bool isValid,
    String? errorText,
    TextInputAction textInputAction = TextInputAction.next,
    Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted ??
              (nextFocusNode != null
                  ? (_) => FocusScope.of(context).requestFocus(nextFocusNode)
                  : null),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock_outline',
                size: 5.w,
                color: focusNode.hasFocus
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
              ),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.text.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: CustomIconWidget(
                      iconName: isValid ? 'check_circle' : 'error',
                      size: 5.w,
                      color: isValid
                          ? AppTheme.lightTheme.colorScheme.tertiary
                          : AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                GestureDetector(
                  onTap: onToggleVisibility,
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: obscureText ? 'visibility' : 'visibility_off',
                      size: 5.w,
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          _buildRequirementItem('At least 8 characters', hasMinLength),
          _buildRequirementItem('One uppercase letter', hasUppercase),
          _buildRequirementItem('One number', hasNumber),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isMet ? 'check_circle' : 'radio_button_unchecked',
            size: 4.w,
            color: isMet
                ? AppTheme.lightTheme.colorScheme.tertiary
                : AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.4),
          ),
          SizedBox(width: 2.w),
          Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: isMet
                  ? AppTheme.lightTheme.colorScheme.onSurface
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _agreeToTerms = !_agreeToTerms;
            });
            HapticFeedback.lightImpact();
          },
          child: Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: _agreeToTerms
                  ? AppTheme.lightTheme.colorScheme.primary
                  : Colors.transparent,
              border: Border.all(
                color: _agreeToTerms
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(1.w),
            ),
            child: _agreeToTerms
                ? CustomIconWidget(
                    iconName: 'check',
                    size: 4.w,
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                  )
                : null,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              children: [
                TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeBonusMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: CustomIconWidget(
              iconName: 'card_giftcard',
              size: 6.w,
              color: AppTheme.lightTheme.colorScheme.onSecondary,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Bonus!',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Get 10 free credits to start bidding!',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton(
        onPressed: _isFormValid && !widget.isLoading ? _handleSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid
              ? AppTheme.lightTheme.colorScheme.secondary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          foregroundColor: _isFormValid
              ? AppTheme.lightTheme.colorScheme.onSecondary
              : AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
          elevation: _isFormValid ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
          ),
        ),
        child: widget.isLoading
            ? SizedBox(
                width: 6.w,
                height: 6.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.onSecondary,
                  ),
                ),
              )
            : Text(
                'Create Account',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
      ),
    );
  }
}
