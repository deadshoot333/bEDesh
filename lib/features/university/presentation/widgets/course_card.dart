import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class CourseCard extends StatelessWidget {
  final String name;
  final String level;
  final String duration;
  final String? department;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.name,
    required this.level,
    required this.duration,
    this.department,
    required this.onTap, required String courseName, required String fee,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              offset: Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Course Icon
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceS),
              decoration: BoxDecoration(
                color: _getLevelColor(level).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Icon(
                _getLevelIcon(level),
                color: _getLevelColor(level),
                size: 20,
              ),
            ),
            
            const SizedBox(width: AppConstants.spaceM),
            
            // Course Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceXS),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceS,
                          vertical: AppConstants.spaceXS,
                        ),
                        decoration: BoxDecoration(
                          color: _getLevelColor(level).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: Text(
                          level,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _getLevelColor(level),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceS),
                      Icon(
                        Icons.schedule,
                        color: AppColors.textTertiary,
                        size: 14,
                      ),
                      const SizedBox(width: AppConstants.spaceXS),
                      Text(
                        duration,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  if (department != null) ...[
                    const SizedBox(height: AppConstants.spaceXS),
                    Text(
                      department!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'undergraduate':
        return AppColors.info;
      case 'postgraduate':
        return AppColors.success;
      case 'phd':
      case 'doctorate':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'undergraduate':
        return Icons.school_outlined;
      case 'postgraduate':
        return Icons.auto_awesome_outlined;
      case 'phd':
      case 'doctorate':
        return Icons.psychology_outlined;
      default:
        return Icons.menu_book_outlined;
    }
  }
}
