import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../chips/modern_chip.dart';

/// Modern course card with enhanced styling and information
class CourseCard extends StatefulWidget {
  final String courseName;
  final String universityName;
  final String price;
  final String? duration;
  final String? level;
  final String? imageUrl;
  final double? rating;
  final List<String>? tags;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final bool isBookmarked;
  final bool showPrice;

  const CourseCard({
    super.key,
    required this.courseName,
    required this.universityName,
    required this.price,
    this.duration,
    this.level,
    this.imageUrl,
    this.rating,
    this.tags,
    this.onTap,
    this.onBookmark,
    this.isBookmarked = false,
    this.showPrice = true,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationFast,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: AppConstants.elevationS,
      end: AppConstants.elevationM,
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: AppConstants.spaceM),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    offset: Offset(0, _elevationAnimation.value),
                    blurRadius: _elevationAnimation.value * 2,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with university info and bookmark
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spaceM),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.accent.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppConstants.radiusL),
                        topRight: Radius.circular(AppConstants.radiusL),
                      ),
                    ),
                    child: Row(
                      children: [
                        // University image or icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                            image: widget.imageUrl != null
                                ? DecorationImage(
                                    image: AssetImage(widget.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: widget.imageUrl == null
                              ? Icon(
                                  Icons.school,
                                  color: AppColors.primary,
                                  size: 20,
                                )
                              : null,
                        ),
                        
                        const SizedBox(width: AppConstants.spaceS),
                        
                        // University name
                        Expanded(
                          child: Text(
                            widget.universityName,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Bookmark button
                        if (widget.onBookmark != null)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.onBookmark,
                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                              child: Padding(
                                padding: const EdgeInsets.all(AppConstants.spaceXS),
                                child: Icon(
                                  widget.isBookmarked 
                                      ? Icons.bookmark 
                                      : Icons.bookmark_border,
                                  color: widget.isBookmarked 
                                      ? AppColors.cta 
                                      : AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Course content
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spaceM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course name
                        Text(
                          widget.courseName,
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: AppConstants.spaceS),
                        
                        // Course details row
                        Row(
                          children: [
                            if (widget.level != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spaceS,
                                  vertical: AppConstants.spaceXS,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                ),
                                child: Text(
                                  widget.level!,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppConstants.spaceS),
                            ],
                            
                            if (widget.duration != null) ...[
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: AppConstants.spaceXS),
                              Text(
                                widget.duration!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        const SizedBox(height: AppConstants.spaceS),
                        
                        // Rating (if available)
                        if (widget.rating != null) ...[
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < widget.rating!.floor()
                                      ? Icons.star
                                      : index < widget.rating!
                                          ? Icons.star_half
                                          : Icons.star_border,
                                  size: 16,
                                  color: AppColors.warning,
                                );
                              }),
                              const SizedBox(width: AppConstants.spaceS),
                              Text(
                                widget.rating!.toStringAsFixed(1),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spaceS),
                        ],
                        
                        // Tags (if available)
                        if (widget.tags != null && widget.tags!.isNotEmpty) ...[
                          Wrap(
                            spacing: AppConstants.spaceXS,
                            runSpacing: AppConstants.spaceXS,
                            children: widget.tags!.take(3).map((tag) {
                              return TagChip(
                                label: tag,
                                color: AppColors.primary,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppConstants.spaceS),
                        ],
                        
                        // Price section
                        if (widget.showPrice)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spaceM,
                              vertical: AppConstants.spaceS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                              border: Border.all(
                                color: AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tuition Fee',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  widget.price,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
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