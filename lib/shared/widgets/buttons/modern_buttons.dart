import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// Modern primary button with enhanced styling and animations
class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final ButtonSize size;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.size = ButtonSize.medium,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
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
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceM,
          vertical: AppConstants.spaceS,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceL,
          vertical: AppConstants.spaceM,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceXL,
          vertical: AppConstants.spaceL,
        );
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTextStyles.buttonSmall;
      case ButtonSize.medium:
        return AppTextStyles.buttonMedium;
      case ButtonSize.large:
        return AppTextStyles.buttonLarge;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? AppColors.primary;
    final textColor = widget.textColor ?? AppColors.textOnPrimary;
    final isDisabled = widget.onPressed == null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.isExpanded ? double.infinity : null,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading || isDisabled
                    ? null
                    : () {
                        _animationController.forward().then((_) {
                          if (mounted) {
                            _animationController.reverse();
                          }
                        });
                        widget.onPressed?.call();
                      },
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Container(
                  padding: _padding,
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? AppColors.textTertiary
                        : backgroundColor,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    boxShadow: isDisabled
                        ? null
                        : [
                            BoxShadow(
                              color: backgroundColor.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading) ...[
                        SizedBox(
                          width: _iconSize,
                          height: _iconSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(textColor),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceS),
                      ] else if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: _iconSize,
                          color: isDisabled ? AppColors.textSecondary : textColor,
                        ),
                        const SizedBox(width: AppConstants.spaceS),
                      ],
                      Text(
                        widget.text,
                        style: _textStyle.copyWith(
                          color: isDisabled ? AppColors.textSecondary : textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Secondary button with outline style
class SecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final ButtonSize size;
  final Color? borderColor;
  final Color? textColor;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.size = ButtonSize.medium,
    this.borderColor,
    this.textColor,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
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
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceM,
          vertical: AppConstants.spaceS,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceL,
          vertical: AppConstants.spaceM,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceXL,
          vertical: AppConstants.spaceL,
        );
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTextStyles.buttonSmall;
      case ButtonSize.medium:
        return AppTextStyles.buttonMedium;
      case ButtonSize.large:
        return AppTextStyles.buttonLarge;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.borderColor ?? AppColors.primary;
    final textColor = widget.textColor ?? AppColors.primary;
    final isDisabled = widget.onPressed == null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.isExpanded ? double.infinity : null,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading || isDisabled
                    ? null
                    : () {
                        _animationController.forward().then((_) {
                          if (mounted) {
                            _animationController.reverse();
                          }
                        });
                        widget.onPressed?.call();
                      },
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Container(
                  padding: _padding,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                      color: isDisabled ? AppColors.borderLight : borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading) ...[
                        SizedBox(
                          width: _iconSize,
                          height: _iconSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(textColor),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceS),
                      ] else if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: _iconSize,
                          color: isDisabled ? AppColors.textTertiary : textColor,
                        ),
                        const SizedBox(width: AppConstants.spaceS),
                      ],
                      Flexible(
                        child: Text(
                          widget.text,
                          style: _textStyle.copyWith(
                            color: isDisabled ? AppColors.textTertiary : textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Icon button with modern styling
class ModernIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;

  const ModernIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.tooltip,
  });

  @override
  State<ModernIconButton> createState() => _ModernIconButtonState();
}

class _ModernIconButtonState extends State<ModernIconButton>
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
      end: 0.9,
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
    final size = widget.size ?? 48.0;
    final backgroundColor = widget.backgroundColor ?? AppColors.backgroundCard;
    final iconColor = widget.iconColor ?? AppColors.textSecondary;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: Tooltip(
              message: widget.tooltip ?? '',
              child: InkWell(
                onTap: widget.onPressed == null
                    ? null
                    : () {
                        _animationController.forward().then((_) {
                          _animationController.reverse();
                        });
                        widget.onPressed?.call();
                      },
                borderRadius: BorderRadius.circular(size / 2),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: iconColor,
                    size: size * 0.4,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Button size enumeration
enum ButtonSize { small, medium, large }
