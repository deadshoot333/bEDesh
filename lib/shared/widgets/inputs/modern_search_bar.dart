import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// Modern search bar with enhanced styling and animations
class ModernSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showFilter;
  final VoidCallback? onFilterPressed;

  const ModernSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.controller,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.showFilter = false,
    this.onFilterPressed,
  });

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late FocusNode _focusNode;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationNormal,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _focusNode = FocusNode();
    _textController = widget.controller ?? TextEditingController();
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    if (widget.controller == null) {
      _textController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: _focusNode.hasFocus 
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.shadowLight,
                  offset: const Offset(0, 2),
                  blurRadius: _focusNode.hasFocus ? 8 : 4,
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: _focusNode.hasFocus 
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.borderLight,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Search input
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    readOnly: widget.readOnly,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    onTap: widget.onTap,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      prefixIcon: widget.prefixIcon ?? 
                          Icon(
                            Icons.search,
                            color: _focusNode.hasFocus 
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            size: 24,
                          ),
                      suffixIcon: widget.suffixIcon,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceM,
                        vertical: AppConstants.spaceM,
                      ),
                    ),
                  ),
                ),
                
                // Filter button (optional)
                if (widget.showFilter) ...[
                  Container(
                    width: 1,
                    height: 24,
                    color: AppColors.borderLight,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceS,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onFilterPressed,
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      child: Container(
                        padding: const EdgeInsets.all(AppConstants.spaceS),
                        margin: const EdgeInsets.only(right: AppConstants.spaceS),
                        child: Icon(
                          Icons.tune,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Search suggestion chip
class SearchSuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isSelected;

  const SearchSuggestionChip({
    super.key,
    required this.text,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceM,
            vertical: AppConstants.spaceS,
          ),
          margin: const EdgeInsets.only(right: AppConstants.spaceS),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.accent,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Filter chip for search results
class FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const FilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: AnimatedContainer(
          duration: AppConstants.animationFast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceM,
            vertical: AppConstants.spaceS,
          ),
          margin: const EdgeInsets.only(right: AppConstants.spaceS),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.borderLight,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.2),
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
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                ),
                const SizedBox(width: AppConstants.spaceXS),
              ],
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
