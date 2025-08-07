import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/models/api_error.dart';
import 'login_page.dart';

class ModernSignupPage extends StatefulWidget {
  const ModernSignupPage({super.key});

  @override
  State<ModernSignupPage> createState() => _ModernSignupPageState();
}

class _ModernSignupPageState extends State<ModernSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(text: '+880');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          // Background Image
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              AssetPaths.signupBanner,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textOnPrimary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  padding: const EdgeInsets.all(AppConstants.spaceS),
                ),
              ),
            ),
          ),

          // Sign Up Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceL),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.spaceXL),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowDark,
                          offset: Offset(0, 8),
                          blurRadius: 24,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo/Title
                          Text(
                            'Create Account',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceXS),
                          Text(
                            'Join ${AppConstants.appName} today',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceXL),

                          // Full Name Field
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: _modernInputDecoration(
                              'Full Name',
                              Icons.person_outline,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Enter your full name'
                                    : null,
                          ),
                          const SizedBox(height: AppConstants.spaceL),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: _modernInputDecoration(
                              'Email Address',
                              Icons.email_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your email address';
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppConstants.spaceL),

                          // Phone Number Field
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: _modernInputDecoration(
                              'Phone Number',
                              Icons.phone_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your phone number';
                              }
                              if (!value.startsWith('+880') || value.length < 14) {
                                return 'Enter valid +880 phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppConstants.spaceL),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: _modernInputDecoration(
                              'Password',
                              Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppConstants.spaceL),

                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: _modernInputDecoration(
                              'Confirm Password',
                              Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceXL),

                          // Sign Up Button
                          PrimaryButton(
                            text: _isLoading ? 'Creating Account...' : 'Create Account',
                            isExpanded: true,
                            size: ButtonSize.large,
                            onPressed: _isLoading ? null : _handleSignup,
                          ),

                          const SizedBox(height: AppConstants.spaceL),

                          // Terms and Privacy
                          Text(
                            'By creating an account, you agree to our Terms of Service and Privacy Policy',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: AppConstants.spaceL),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.borderLight,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spaceM,
                                ),
                                child: Text(
                                  'or',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.borderLight,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppConstants.spaceL),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Login',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _modernInputDecoration(
    String hint,
    IconData prefixIcon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: AppColors.textSecondary,
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.backgroundSecondary.withOpacity(0.8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceM,
        vertical: AppConstants.spaceM,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(
          color: AppColors.borderLight,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(
          color: AppColors.borderLight,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the signup API
      await _authService.signup(
        email: _emailController.text.trim(),
        mobile: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created successfully! Please login.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        String errorMessage = 'Signup failed. Please try again.';
        if (e is ApiError) {
          errorMessage = e.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
