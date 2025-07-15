import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class ProfileStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final IconData? icon;

  const ProfileStatCard({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceS),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color ?? AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
        ],
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: color ?? AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXS),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
