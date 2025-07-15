import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// Modern circular university card with enhanced animations and aesthetics
class CircularUniversityCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String? subtitle;
  final int? ranking;
  final double? rating;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  const CircularUniversityCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    this.subtitle,
    this.ranking,
    this.rating,
    this.onTap,
    this.showFavoriteButton = false,
    this.isFavorite = false,
    this.onFavoritePressed,
  });

  @override
  State<CircularUniversityCard> createState() => _CircularUniversityCardState();
}

class _CircularUniversityCardState extends State<CircularUniversityCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _fadeController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    // Scale animation for press effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Shimmer animation for loading effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _fadeController.forward();
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: Container(
                width: 160,
                margin: const EdgeInsets.only(right: AppConstants.spaceM),
                child: Column(
                  children: [
                    // Circular Image Container
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _isPressed 
                                ? AppColors.shadowMedium.withOpacity(0.3)
                                : AppColors.primary.withOpacity(0.2),
                            offset: _isPressed ? const Offset(0, 2) : const Offset(0, 8),
                            blurRadius: _isPressed ? 8 : 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Main Image
                          ClipOval(
                            child: Image.asset(
                              widget.imageUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary.withOpacity(0.7),
                                        AppColors.primaryLight.withOpacity(0.9),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.school_rounded,
                                    size: 40,
                                    color: AppColors.textOnPrimary,
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Gradient Overlay
                          ClipOval(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Shimmer Effect
                          AnimatedBuilder(
                            animation: _shimmerAnimation,
                            builder: (context, child) {
                              return ClipOval(
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(_shimmerAnimation.value - 1, 0),
                                      end: Alignment(_shimmerAnimation.value, 0),
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.2),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Ranking Badge
                          if (widget.ranking != null)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cta,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cta.withOpacity(0.4),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '#${widget.ranking}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          
                          // Favorite Button
                          if (widget.showFavoriteButton)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.onFavoritePressed,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundCard.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      widget.isFavorite 
                                          ? Icons.favorite_rounded 
                                          : Icons.favorite_border_rounded,
                                      color: widget.isFavorite 
                                          ? AppColors.cta 
                                          : AppColors.textSecondary,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spaceS),
                    
                    // Title
                    Text(
                      widget.title,
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppConstants.spaceXS),
                    
                    // Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            widget.location,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    
                    // Rating
                    if (widget.rating != null) ...[
                      const SizedBox(height: AppConstants.spaceXS),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...List.generate(5, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1),
                              child: Icon(
                                index < widget.rating!.floor()
                                    ? Icons.star_rounded
                                    : index < widget.rating!
                                        ? Icons.star_half_rounded
                                        : Icons.star_border_rounded,
                                size: 12,
                                color: AppColors.secondary,
                              ),
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            widget.rating!.toStringAsFixed(1),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
