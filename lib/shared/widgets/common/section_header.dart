import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// Modern section header with enhanced styling
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;
  final VoidCallback? onActionPressed;
  final String? actionText;
  final bool showDivider;
  final EdgeInsets? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.onActionPressed,
    this.actionText,
    this.showDivider = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.fromLTRB(
        AppConstants.spaceM,
        AppConstants.spaceL,
        AppConstants.spaceM,
        AppConstants.spaceM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.spaceS),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceS),
              ],
              
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppConstants.spaceXS),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action button or custom widget
              if (action != null)
                action!
              else if (onActionPressed != null && actionText != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onActionPressed,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceS,
                        vertical: AppConstants.spaceXS,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            actionText!,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceXS),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Divider
          if (showDivider) ...[
            const SizedBox(height: AppConstants.spaceM),
            Divider(
              color: AppColors.borderLight,
              thickness: 1,
              height: 1,
            ),
          ],
        ],
      ),
    );
  }
}

/// Simplified section title for smaller sections
class SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final EdgeInsets? padding;

  const SectionTitle({
    super.key,
    required this.title,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(
        AppConstants.spaceM,
        AppConstants.spaceL,
        AppConstants.spaceM,
        AppConstants.spaceS,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: AppConstants.spaceS),
          ],
          Text(
            title,
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Page header for main pages
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? backgroundImage;
  final List<Widget>? actions;
  final double? height;
  final Color? backgroundColor;
  final Gradient? gradient;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.backgroundImage,
    this.actions,
    this.height,
    this.backgroundColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        gradient: gradient ?? const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background image
          if (backgroundImage != null)
            Positioned.fill(
              child: backgroundImage!,
            ),
          
          // Gradient overlay
          Positioned.fill(
            child: Container(
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
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Actions row
                  if (actions != null && actions!.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!,
                    ),
                  
                  const Spacer(),
                  
                  // Title and subtitle
                  Text(
                    title,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  if (subtitle != null) ...[
                    const SizedBox(height: AppConstants.spaceS),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textOnPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: AppConstants.spaceM),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
