import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Modern accommodation card component
class AccommodationCard extends StatelessWidget {
  final String title;
  final String location;
  final String propertyType;
  final double rent;
  final String rentPeriod;
  final int bedrooms;
  final int bathrooms;
  final List<String> amenities;
  final String? imageUrl;
  final bool isRoommateRequest;
  final VoidCallback? onTap;
  final List<String> nearbyUniversities;
  final String availableFrom;
  final String? country;
  final String? genderPreference;
  final List<String>? facilities;

  const AccommodationCard({
    super.key,
    required this.title,
    required this.location,
    required this.propertyType,
    required this.rent,
    required this.rentPeriod,
    required this.bedrooms,
    required this.bathrooms,
    required this.amenities,
    this.imageUrl,
    required this.isRoommateRequest,
    this.onTap,
    required this.nearbyUniversities,
    required this.availableFrom,
    this.country,
    this.genderPreference,
    this.facilities,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceM),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusL),
                    topRight: Radius.circular(AppConstants.radiusL),
                  ),
                  color: AppColors.accent,
                ),
                child: Stack(
                  children: [
                    // Placeholder image
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppConstants.radiusL),
                          topRight: Radius.circular(AppConstants.radiusL),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.8),
                            AppColors.secondary.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Icon(
                        isRoommateRequest ? Icons.people : Icons.home,
                        size: 60,
                        color: AppColors.textOnPrimary.withOpacity(0.7),
                      ),
                    ),
                    
                    // Badges
                    Positioned(
                      top: AppConstants.spaceS,
                      left: AppConstants.spaceS,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (isRoommateRequest) 
                                _buildBadge(
                                  'Roommate',
                                  AppColors.secondary,
                                  Icons.people,
                                ),
                              if (country != null) ...[
                                const SizedBox(width: AppConstants.spaceXS),
                                _buildBadge(
                                  country!,
                                  AppColors.info,
                                  Icons.public,
                                ),
                              ],
                            ],
                          ),
                          if (genderPreference != null && genderPreference != 'All') ...[
                            const SizedBox(height: AppConstants.spaceXS),
                            _buildBadge(
                              '$genderPreference Only',
                              AppColors.warning,
                              Icons.person,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Price
                    Positioned(
                      top: AppConstants.spaceS,
                      right: AppConstants.spaceS,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceS,
                          vertical: AppConstants.spaceXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textOnPrimary,
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowMedium,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          '\$${rent.toStringAsFixed(0)}/$rentPeriod',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content section
              Padding(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: AppConstants.spaceXS),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppConstants.spaceXS),
                        Expanded(
                          child: Text(
                            location,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.spaceS),
                    
                    // Property details
                    Row(
                      children: [
                        _buildDetailChip(
                          Icons.single_bed,
                          '$bedrooms bed${bedrooms > 1 ? 's' : ''}',
                        ),
                        const SizedBox(width: AppConstants.spaceS),
                        _buildDetailChip(
                          Icons.bathroom,
                          '$bathrooms bath${bathrooms > 1 ? 's' : ''}',
                        ),
                        const SizedBox(width: AppConstants.spaceS),
                        _buildDetailChip(
                          Icons.home_work,
                          propertyType,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.spaceS),
                    
                    // Nearby universities
                    if (nearbyUniversities.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: AppConstants.spaceXS),
                          Expanded(
                            child: Text(
                              'Near ${nearbyUniversities.take(2).join(', ')}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spaceS),
                    ],
                    
                    // Amenities/Facilities
                    if ((facilities?.isNotEmpty ?? false) || amenities.isNotEmpty) ...[
                      Wrap(
                        spacing: AppConstants.spaceXS,
                        runSpacing: AppConstants.spaceXS,
                        children: (facilities?.isNotEmpty ?? false ? facilities! : amenities)
                            .take(3).map((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spaceS,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                            ),
                            child: Text(
                              item,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppConstants.spaceS),
                    ],
                    
                    // Available from
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: AppConstants.spaceXS),
                        Text(
                          'Available from $availableFrom',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.textOnPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
