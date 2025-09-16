import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/university/domain/models/course.dart';

class DynamicCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const DynamicCourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              offset: Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon and Course Name
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Icon
                Container(
                  padding: const EdgeInsets.all(AppConstants.spaceS),
                  decoration: BoxDecoration(
                    color: course.isUndergraduate 
                        ? AppColors.info.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Icon(
                    course.isUndergraduate ? Icons.school : Icons.book,
                    color: course.isUndergraduate ? AppColors.info : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceS),
                
                // Course Name - Takes remaining space
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: AppTextStyles.h5.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.spaceXS),
                      if (course.fieldOfStudy.isNotEmpty)
                        Text(
                          course.fieldOfStudy,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                
                // Action Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.spaceM),
            
            // Bottom Row: Level, Duration, and Fee (wrapped layout)
            Wrap(
              spacing: AppConstants.spaceS,
              runSpacing: AppConstants.spaceXS,
              children: [
                // Level Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceS,
                    vertical: AppConstants.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: course.isUndergraduate 
                        ? AppColors.info.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    course.level,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: course.isUndergraduate ? AppColors.info : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // Duration
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceS,
                    vertical: AppConstants.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppConstants.spaceXS),
                      Text(
                        course.duration,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Annual Fee (if available)
                if (course.annualFee.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceS,
                      vertical: AppConstants.spaceXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 12,
                          color: AppColors.success,
                        ),
                        Text(
                          course.annualFee.contains(',') ? '£${course.annualFee}' : '£${course.annualFee}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
