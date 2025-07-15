import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// Modern chip component with enhanced styling
class ModernChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  final ChipSize size;
  final bool showBorder;

  const ModernChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
    this.size = ChipSize.medium,
    this.showBorder = true,
  });

  @override
  State<ModernChip> createState() => _ModernChipState();
}

class _ModernChipState extends State<ModernChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

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

  EdgeInsets get _padding {
    switch (widget.size) {
      case ChipSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceS,
          vertical: AppConstants.spaceXS,
        );
      case ChipSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceM,
          vertical: AppConstants.spaceS,
        );
      case ChipSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceL,
          vertical: AppConstants.spaceM,
        );
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case ChipSize.small:
        return AppTextStyles.labelSmall;
      case ChipSize.medium:
        return AppTextStyles.labelMedium;
      case ChipSize.large:
        return AppTextStyles.labelLarge;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case ChipSize.small:
        return 14;
      case ChipSize.medium:
        return 16;
      case ChipSize.large:
        return 18;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isSelected
        ? (widget.selectedColor ?? AppColors.primary)
        : (widget.backgroundColor ?? AppColors.accent);
    
    final textColor = widget.isSelected
        ? AppColors.textOnPrimary
        : (widget.textColor ?? AppColors.textPrimary);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap == null
                  ? null
                  : () {
                      _animationController.forward().then((_) {
                        _animationController.reverse();
                      });
                      widget.onTap?.call();
                    },
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              child: AnimatedContainer(
                duration: AppConstants.animationNormal,
                padding: _padding,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  border: widget.showBorder
                      ? Border.all(
                          color: widget.isSelected
                              ? (widget.selectedColor ?? AppColors.primary)
                              : AppColors.borderLight,
                          width: 1,
                        )
                      : null,
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: (widget.selectedColor ?? AppColors.primary)
                                .withOpacity(0.2),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: _iconSize,
                        color: textColor,
                      ),
                      const SizedBox(width: AppConstants.spaceXS),
                    ],
                    Text(
                      widget.label,
                      style: _textStyle.copyWith(
                        color: textColor,
                        fontWeight: widget.isSelected 
                            ? FontWeight.w600 
                            : FontWeight.w500,
                      ),
                    ),
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

/// Course chip specifically for course listings
class CourseChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isPopular;

  const CourseChip({
    super.key,
    required this.label,
    this.onTap,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return ModernChip(
      label: label,
      onTap: onTap,
      backgroundColor: isPopular ? AppColors.cta.withOpacity(0.1) : AppColors.accent,
      selectedColor: AppColors.secondary,
      textColor: isPopular ? AppColors.cta : AppColors.textPrimary,
      showBorder: true,
      icon: isPopular ? Icons.trending_up : null,
    );
  }
}

/// Subject chip for subject categories
class SubjectChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;

  const SubjectChip({
    super.key,
    required this.label,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ModernChip(
      label: label,
      onTap: onTap,
      isSelected: isSelected,
      backgroundColor: AppColors.backgroundCard,
      selectedColor: AppColors.primary,
      size: ChipSize.medium,
    );
  }
}

/// Tag chip for posts and content
class TagChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const TagChip({
    super.key,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ModernChip(
      label: label,
      onTap: onTap,
      backgroundColor: (color ?? AppColors.secondary).withOpacity(0.1),
      textColor: color ?? AppColors.secondary,
      size: ChipSize.small,
      showBorder: false,
    );
  }
}

/// Scholarship chip for scholarship types
class ScholarshipChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const ScholarshipChip({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModernChip(
      label: label,
      onTap: onTap,
      backgroundColor: AppColors.secondary.withOpacity(0.1),
      selectedColor: AppColors.secondary,
      textColor: AppColors.secondary,
      icon: Icons.school,
      size: ChipSize.medium,
    );
  }
}

/// Status chip for application status, etc.
class StatusChip extends StatelessWidget {
  final String label;
  final StatusType status;
  final VoidCallback? onTap;

  const StatusChip({
    super.key,
    required this.label,
    required this.status,
    this.onTap,
  });

  Color get _backgroundColor {
    switch (status) {
      case StatusType.success:
        return AppColors.success.withOpacity(0.1);
      case StatusType.warning:
        return AppColors.warning.withOpacity(0.1);
      case StatusType.error:
        return AppColors.error.withOpacity(0.1);
      case StatusType.info:
        return AppColors.info.withOpacity(0.1);
      case StatusType.neutral:
        return AppColors.accent;
    }
  }

  Color get _textColor {
    switch (status) {
      case StatusType.success:
        return AppColors.success;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.error:
        return AppColors.error;
      case StatusType.info:
        return AppColors.info;
      case StatusType.neutral:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (status) {
      case StatusType.success:
        return Icons.check_circle;
      case StatusType.warning:
        return Icons.warning;
      case StatusType.error:
        return Icons.error;
      case StatusType.info:
        return Icons.info;
      case StatusType.neutral:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernChip(
      label: label,
      onTap: onTap,
      backgroundColor: _backgroundColor,
      textColor: _textColor,
      icon: _icon,
      size: ChipSize.small,
      showBorder: false,
    );
  }
}

/// Chip size enumeration
enum ChipSize { small, medium, large }

/// Status type enumeration
enum StatusType { success, warning, error, info, neutral }
