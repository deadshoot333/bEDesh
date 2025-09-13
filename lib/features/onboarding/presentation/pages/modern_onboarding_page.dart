import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';
import '../../../../features/auth/presentation/pages/signup_page.dart';
import '../../../../MainNavigationPage.dart';

/// Modern onboarding page with smooth animations and contemporary design
class ModernOnboardingPage extends StatefulWidget {
  const ModernOnboardingPage({super.key});

  @override
  State<ModernOnboardingPage> createState() => _ModernOnboardingPageState();
}

class _ModernOnboardingPageState extends State<ModernOnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Skip Button Row
              Padding(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainNavigationPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceM,
                          vertical: AppConstants.spaceS,
                        ),
                        backgroundColor: AppColors.primary.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusL,
                          ),
                        ),
                      ),
                      child: Text(
                        'Guest User',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textOnDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Hero Image Section
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppConstants.radiusXL),
                      bottomRight: Radius.circular(AppConstants.radiusXL),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        offset: const Offset(0, 8),
                        blurRadius: 24,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppConstants.radiusXL),
                      bottomRight: Radius.circular(AppConstants.radiusXL),
                    ),
                    child: Stack(
                      children: [
                        // Background Image
                        Image.asset(
                          AssetPaths.onboardingBanner,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryLight,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            );
                          },
                        ),

                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),

                        // Floating Elements Animation
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _fadeController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _fadeAnimation.value * 0.3,
                                child: CustomPaint(
                                  painter: FloatingElementsPainter(
                                    animationValue: _fadeController.value,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content Section
              Expanded(
                flex: 3,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spaceL,
                                vertical: AppConstants.spaceM,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Title and Description
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Column(
                                      children: [
                                        Text(
                                          'Welcome to ${AppConstants.appName}',
                                          style: AppTextStyles.h1.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),

                                        const SizedBox(
                                          height: AppConstants.spaceM,
                                        ),

                                        Text(
                                          'Your gateway to world-class education. Discover universities, connect with peers, and start your study abroad journey.',
                                          style: AppTextStyles.bodyLarge
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                                height: 1.5,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: AppConstants.spaceXL),

                                  // Action Buttons
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Get Started Button
                                        PrimaryButton(
                                          text: 'Sign Up',
                                          isExpanded: true,
                                          size: ButtonSize.large,
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder:
                                                    (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                    ) =>
                                                        const ModernSignupPage(),
                                                transitionsBuilder: (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child,
                                                ) {
                                                  return SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: const Offset(
                                                        1.0,
                                                        0.0,
                                                      ),
                                                      end: Offset.zero,
                                                    ).animate(
                                                      CurvedAnimation(
                                                        parent: animation,
                                                        curve: Curves.easeInOut,
                                                      ),
                                                    ),
                                                    child: child,
                                                  );
                                                },
                                                transitionDuration:
                                                    const Duration(
                                                      milliseconds: 300,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),

                                        const SizedBox(
                                          height: AppConstants.spaceM,
                                        ),

                                        // Login Button
                                        SecondaryButton(
                                          text: 'I already have an account',
                                          isExpanded: true,
                                          size: ButtonSize.large,
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder:
                                                    (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                    ) => const LoginPage(),
                                                transitionsBuilder: (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child,
                                                ) {
                                                  return SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: const Offset(
                                                        -1.0,
                                                        0.0,
                                                      ),
                                                      end: Offset.zero,
                                                    ).animate(
                                                      CurvedAnimation(
                                                        parent: animation,
                                                        curve: Curves.easeInOut,
                                                      ),
                                                    ),
                                                    child: child,
                                                  );
                                                },
                                                transitionDuration:
                                                    const Duration(
                                                      milliseconds: 300,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ], // closing main Column children
          ), // closing main Column
        ), // closing FadeTransition
      ), // closing SafeArea
    ); // closing Scaffold
  }
}

/// Custom painter for floating animated elements
class FloatingElementsPainter extends CustomPainter {
  final double animationValue;

  FloatingElementsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.textOnPrimary.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    // Draw floating circles
    for (int i = 0; i < 8; i++) {
      final double x = (size.width * 0.1) + (i * size.width * 0.15);
      final double y =
          size.height * 0.3 +
          (50 * (animationValue * 2 - 1) * (i % 2 == 0 ? 1 : -1));
      final double radius = 20 + (i * 5);

      canvas.drawCircle(
        Offset(x, y),
        radius * (0.5 + animationValue * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
