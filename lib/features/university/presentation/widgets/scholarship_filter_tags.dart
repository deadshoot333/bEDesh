import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class ScholarshipFilterTags extends StatelessWidget {
  final String? selectedType;
  final String? selectedFunding;
  final String? selectedDegreeLevel;
  final String? selectedDeadline;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onFundingChanged;
  final ValueChanged<String> onDegreeLevelChanged;
  final ValueChanged<String> onDeadlineChanged;
  final VoidCallback? onClearFilters;

  const ScholarshipFilterTags({
    super.key,
    this.selectedType,
    this.selectedFunding,
    this.selectedDegreeLevel,
    this.selectedDeadline,
    required this.onTypeChanged,
    required this.onFundingChanged,
    required this.onDegreeLevelChanged,
    required this.onDeadlineChanged,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = (selectedType != null && selectedType != 'All Types') ||
        (selectedFunding != null && selectedFunding != 'All Funding') ||
        (selectedDegreeLevel != null && selectedDegreeLevel != 'All Levels') ||
        (selectedDeadline != null && selectedDeadline != 'All Deadlines');

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
              'Filter Scholarships',
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
                'Type',
                selectedType ?? 'All Types',
                const ['All Types', 'International', 'Domestic'],
                Icons.public_outlined,
                onTypeChanged,
              ),
              const SizedBox(width: AppConstants.spaceM),
              _buildFilterDropdown(
                'Funding',
                selectedFunding ?? 'All Funding',
                const ['All Funding', 'Full', 'Partial', 'Stipend'],
                Icons.attach_money_outlined,
                onFundingChanged,
              ),
              const SizedBox(width: AppConstants.spaceM),
              _buildFilterDropdown(
                'Level',
                selectedDegreeLevel ?? 'All Levels',
                const ['All Levels', 'Bachelors', 'Masters', 'PhD', 'Post Grad'],
                Icons.school_outlined,
                onDegreeLevelChanged,
              ),
              const SizedBox(width: AppConstants.spaceM),
              _buildFilterDropdown(
                'Deadline',
                selectedDeadline ?? 'All Deadlines',
                const ['All Deadlines', 'Upcoming', 'Ongoing', 'Closed'],
                Icons.access_time_outlined,
                onDeadlineChanged,
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
                  isDefault ? 'Any' : selectedValue,
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
