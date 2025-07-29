import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class CourseFilterTags extends StatelessWidget {
  final String? selectedField;
  final String? selectedLevel;
  final String? selectedIntake;
  final String? selectedFeeRange;
  final ValueChanged<String> onFieldChanged;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<String> onIntakeChanged;
  final ValueChanged<String> onFeeRangeChanged;
  final VoidCallback? onClearFilters;

  const CourseFilterTags({
    super.key,
    this.selectedField,
    this.selectedLevel,
    this.selectedIntake,
    this.selectedFeeRange,
    required this.onFieldChanged,
    required this.onLevelChanged,
    required this.onIntakeChanged,
    required this.onFeeRangeChanged,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = (selectedField != null && selectedField != 'All Fields') ||
        (selectedLevel != null && selectedLevel != 'All Levels') ||
        (selectedIntake != null && selectedIntake != 'All Intakes') ||
        (selectedFeeRange != null && selectedFeeRange != 'All Fees');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Header
        Row(
          children: [
            Icon(
              Icons.filter_list_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppConstants.spaceXS),
            Text(
              'Filter Courses',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (hasActiveFilters && onClearFilters != null)
              TextButton(
                onPressed: onClearFilters,
                child: Text(
                  'Clear All',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: AppConstants.spaceS),
        
        // Scrollable Filter Dropdowns
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXS),
          child: Row(
            children: [
              _buildFilterDropdown(
                'Field',
                selectedField ?? 'All Fields',
                const [
                  'All Fields',
                  'Computer Science',
                  'Engineering',
                  'Law',
                  'Business & Management',
                  'Medicine',
                  'Social Sciences',
                  'Mathematics',
                  'Arts & Humanities',
                  'Natural Sciences',
                  'Psychology',
                  'Economics',
                ],
                Icons.category_outlined,
                onFieldChanged,
              ),
              const SizedBox(width: AppConstants.spaceM),
              _buildFilterDropdown(
                'Level',
                selectedLevel ?? 'All Levels',
                const [
                  'All Levels',
                  'Undergraduate',
                  'Postgraduate',
                  'Masters',
                  'PhD',
                  'MBA',
                  'Certificate',
                ],
                Icons.school_outlined,
                onLevelChanged,
              ),
              const SizedBox(width: AppConstants.spaceM),
              _buildFilterDropdown(
                'Intake',
                selectedIntake ?? 'All Intakes',
                const [
                  'All Intakes',
                  'Fall',
                  'Spring',
                  'Summer',
                  'Winter',
                  'Year Round',
                ],
                Icons.calendar_month_outlined,
                onIntakeChanged,
              ),
              const SizedBox(width: AppConstants.spaceM),
              _buildFilterDropdown(
                'Fee Range',
                selectedFeeRange ?? 'All Fees',
                const [
                  'All Fees',
                  'Under £15K',
                  '£15K - £25K',
                  '£25K - £35K',
                  '£35K - £45K',
                  'Above £45K',
                ],
                Icons.monetization_on_outlined,
                onFeeRangeChanged,
              ),
              const SizedBox(width: AppConstants.spaceS),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String selectedValue,
    List<String> options,
    IconData icon,
    ValueChanged<String> onChanged,
  ) {
    final isDefault = selectedValue.startsWith('All');
    
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      child: PopupMenuButton<String>(
        onSelected: onChanged,
        offset: const Offset(0, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        color: AppColors.backgroundCard,
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceM,
            vertical: AppConstants.spaceS,
          ),
          decoration: BoxDecoration(
            color: isDefault ? AppColors.backgroundSecondary : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(
              color: isDefault ? AppColors.borderLight : AppColors.primary,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isDefault ? AppColors.textSecondary : AppColors.primary,
              ),
              const SizedBox(width: AppConstants.spaceXS),
              Flexible(
                child: Text(
                  isDefault ? label : selectedValue,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDefault ? AppColors.textSecondary : AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppConstants.spaceXS),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: isDefault ? AppColors.textSecondary : AppColors.primary,
              ),
            ],
          ),
        ),
        itemBuilder: (context) => options.map((option) {
          final isSelected = option == selectedValue;
          return PopupMenuItem<String>(
            value: option,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceXS),
              child: Row(
                children: [
                  if (isSelected)
                    Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.primary,
                    )
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: AppConstants.spaceS),
                  Expanded(
                    child: Text(
                      option.startsWith('All') ? 'All' : option,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
