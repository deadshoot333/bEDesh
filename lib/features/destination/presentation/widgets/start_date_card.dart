import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common/section_header.dart';

class StartDateCard extends StatelessWidget {
  const StartDateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final startDates = [
      {
        'title': 'Spring Intake',
        'date': 'January - March',
        'icon': Icons.wb_sunny_outlined,
        'color': AppColors.warning,
      },
      {
        'title': 'Fall Intake',
        'date': 'September - October',
        'icon': Icons.eco_outlined,
        'color': AppColors.success,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Intake Periods',
          icon: Icons.calendar_month_outlined,
        ),
        const SizedBox(height: AppConstants.spaceM),
        Container(
          padding: const EdgeInsets.all(AppConstants.spaceL),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
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
            children: [
              Row(
                children: startDates.map((intake) {
                  final index = startDates.indexOf(intake);
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index < startDates.length - 1 ? AppConstants.spaceM : 0,
                      ),
                      padding: const EdgeInsets.all(AppConstants.spaceM),
                      decoration: BoxDecoration(
                        color: (intake['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: (intake['color'] as Color).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            intake['icon'] as IconData,
                            color: intake['color'] as Color,
                            size: 32,
                          ),
                          const SizedBox(height: AppConstants.spaceS),
                          Text(
                            intake['title'] as String,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppConstants.spaceXS),
                          Text(
                            intake['date'] as String,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spaceM),
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: AppConstants.spaceS),
                    Expanded(
                      child: Text(
                        'Application deadlines are typically 3-6 months before the intake period.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
