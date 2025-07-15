import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class ScholarshipCard extends StatelessWidget {
  final String title;
  final String? description;
  final String? amount;
  final VoidCallback onTap;

  const ScholarshipCard({
    super.key,
    required this.title,
    this.description,
    this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(AppConstants.spaceM),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: AppColors.warning.withOpacity(0.3),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spaceXS),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    color: AppColors.warning,
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceS),
                Expanded(
                  child: Text(
                    'Scholarship',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceS),
            Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (description != null) ...[
              const SizedBox(height: AppConstants.spaceXS),
              Text(
                description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (amount != null) ...[
              const SizedBox(height: AppConstants.spaceS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceS,
                  vertical: AppConstants.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  amount!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Learn More',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
