import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// Modern university card widget with improved styling and animations
class UniversityCard extends StatefulWidget {
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

  const UniversityCard({
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
  State<UniversityCard> createState() => _UniversityCardState();
}

class _UniversityCardState extends State<UniversityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              width: 280,
              height: 280, // Fixed height to prevent overflow
              margin: const EdgeInsets.only(right: AppConstants.spaceM),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed ? AppColors.shadowMedium : AppColors.shadowLight,
                    offset: _isPressed ? const Offset(0, 2) : const Offset(0, 4),
                    blurRadius: _isPressed ? 4 : 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with overlay
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppConstants.radiusL),
                          topRight: Radius.circular(AppConstants.radiusL),
                        ),
                        child: Image.asset(
                          widget.imageUrl,
                          height: 140, // Reduced from 160 to leave more space for content
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 140, // Updated to match the new image height
                              color: AppColors.backgroundSecondary,
                              child: const Icon(
                                Icons.school,
                                size: 48,
                                color: AppColors.textTertiary,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppConstants.radiusL),
                              topRight: Radius.circular(AppConstants.radiusL),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Favorite button
                      if (widget.showFavoriteButton)
                        Positioned(
                          top: AppConstants.spaceS,
                          right: AppConstants.spaceS,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.onFavoritePressed,
                              borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
                              child: Container(
                                padding: const EdgeInsets.all(AppConstants.spaceS),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundCard.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: widget.isFavorite ? AppColors.cta : AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      // Ranking badge
                      if (widget.ranking != null)
                        Positioned(
                          top: AppConstants.spaceS,
                          left: AppConstants.spaceS,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spaceS,
                              vertical: AppConstants.spaceXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                            ),
                            child: Text(
                              '#${widget.ranking}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spaceS), // Reduced from spaceM
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            widget.title,
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 14, // Slightly smaller for better fit
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: AppConstants.spaceXS),
                        
                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppConstants.spaceXS),
                            Expanded(
                              child: Text(
                                widget.location,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: AppConstants.spaceXS),
                          Text(
                            widget.subtitle!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        if (widget.rating != null) ...[
                          const SizedBox(height: AppConstants.spaceXS), // Reduced from spaceS
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < widget.rating!.floor()
                                      ? Icons.star
                                      : index < widget.rating!
                                          ? Icons.star_half
                                          : Icons.star_border,
                                  size: 14, // Reduced from 16
                                  color: AppColors.secondary,
                                );
                              }),
                              const SizedBox(width: AppConstants.spaceXS),
                              Text(
                                widget.rating!.toStringAsFixed(1),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
