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
  final String? imageUrl;
  final List<String>? imageUrls; // New field for multiple images
  final VoidCallback? onTap;
  final String availableFrom;
  final String? country;
  final String? genderPreference;
  final List<String>? facilities;
  final String? status; // New field for accommodation status

  const AccommodationCard({
    super.key,
    required this.title,
    required this.location,
    required this.propertyType,
    required this.rent,
    this.imageUrl,
    this.imageUrls, // New parameter
    this.onTap,
    required this.availableFrom,
    this.country,
    this.genderPreference,
    this.facilities,
    this.status, // New parameter
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
                    // Image display logic - show actual image if available, otherwise placeholder
                    _buildImageDisplay(),
                    
                    // Badges
                    Positioned(
                      top: AppConstants.spaceS,
                      left: AppConstants.spaceS,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Remove roommate badge since we don't track this anymore
                              if (country != null) 
                                _buildBadge(
                                  country!,
                                  AppColors.info,
                                  Icons.public,
                                ),
                            ],
                          ),
                          if (genderPreference != null && genderPreference != 'Any') ...[
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
                          '\$${rent.toStringAsFixed(0)}/month',
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
                          Icons.home_work,
                          propertyType,
                        ),
                        const SizedBox(width: AppConstants.spaceS),
                        _buildDetailChip(
                          status?.toLowerCase() == 'booked' 
                            ? Icons.event_busy 
                            : Icons.calendar_today,
                          status ?? 'Available',
                          color: status?.toLowerCase() == 'booked' 
                            ? AppColors.error 
                            : AppColors.success,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.spaceS),
                    
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

  Widget _buildDetailChip(IconData icon, String text, {Color? color}) {
    final chipColor = color ?? AppColors.accent;
    final textColor = color != null ? AppColors.textOnPrimary : AppColors.textSecondary;
    final iconColor = color != null ? AppColors.textOnPrimary : AppColors.textSecondary;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: color == null ? Border.all(
          color: AppColors.borderLight,
          width: 1,
        ) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build image display - shows actual uploaded image or placeholder
  Widget _buildImageDisplay() {
    // Get the first available image URL
    String? displayImageUrl;
    
    // Prefer imageUrls array (new format) over single imageUrl (legacy)
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      displayImageUrl = imageUrls!.first;
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      displayImageUrl = imageUrl;
    }

    if (displayImageUrl != null && displayImageUrl.isNotEmpty) {
      // Display the actual uploaded image
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.radiusL),
            topRight: Radius.circular(AppConstants.radiusL),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.radiusL),
            topRight: Radius.circular(AppConstants.radiusL),
          ),
          child: Image.network(
            displayImageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildPlaceholder(); // Show placeholder while loading
            },
            errorBuilder: (context, error, stackTrace) {
              print('❌ Error loading image: $displayImageUrl - $error');
              return _buildPlaceholder(); // Show placeholder on error
            },
          ),
        ),
      );
    } else {
      // No image available, show placeholder
      return _buildPlaceholder();
    }
  }

  /// Build gradient placeholder
  Widget _buildPlaceholder() {
    return Container(
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
        Icons.home, // Default to home icon
        size: 60,
        color: AppColors.textOnPrimary.withOpacity(0.7),
      ),
    );
  }
}
