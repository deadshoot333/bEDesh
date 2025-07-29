import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/chips/modern_chip.dart';
import '../../domain/models/post.dart';
import '../pages/user_profile_page.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final Function(String)? onTagTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceM),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToUserProfile(context),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage:
                          post.userImage.isNotEmpty
                              ? NetworkImage(post.userImage)
                              : null,
                      child:
                          post.userImage.isEmpty
                              ? Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 20,
                              )
                              : null,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToUserProfile(context),
                        child: Text(
                          post.userName,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceXS),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: AppColors.textTertiary,
                            size: 12,
                          ),
                          const SizedBox(width: AppConstants.spaceXS),
                          Text(
                            post.userLocation,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceS),
                          Icon(
                            Icons.access_time,
                            color: AppColors.textTertiary,
                            size: 12,
                          ),
                          const SizedBox(width: AppConstants.spaceXS),
                          Text(
                            post.timeAgo,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textTertiary,
                  ),
                  onPressed: () => _showPostOptions(context),
                ),
              ],
            ),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceM,
            ),
            child: Text(
              post.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),

          // Post images (if any)
          if (post.images != null && post.images!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceM),
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: post.images!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceM,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      child: _buildImage(post.images![index]),
                    ),
                  );
                },
              ),
            ),
          ],

          // Tags
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceM),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceM,
              ),
              child: Wrap(
                spacing: AppConstants.spaceS,
                runSpacing: AppConstants.spaceS,
                children:
                    post.tags
                        .map(
                          (tag) => ModernChip(
                            label: tag,
                            isSelected: false,
                            onTap: () => onTagTap != null 
                                ? onTagTap!(tag) 
                                : _searchByTag(context, tag),
                            backgroundColor: AppColors.backgroundSecondary,
                            textColor: AppColors.textSecondary,
                          ),
                        )
                        .toList(),
              ),
            ),
          ],

          // Actions bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceM),
            child: Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: onLike,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceM,
                      vertical: AppConstants.spaceS,
                    ),
                    decoration: BoxDecoration(
                      color:
                          post.isLiked
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          color:
                              post.isLiked
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: AppConstants.spaceS),
                        Text(
                          post.likes.toString(),
                          style: AppTextStyles.labelMedium.copyWith(
                            color:
                                post.isLiked
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),

                // Comment button
                GestureDetector(
                  onTap: onComment,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceM,
                      vertical: AppConstants.spaceS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: AppConstants.spaceS),
                        Text(
                          post.comments.toString(),
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Share button
                GestureDetector(
                  onTap: onShare,
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.spaceS),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToUserProfile(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => UserProfilePage(
              userId: post.userId, // Fixed: Use actual user ID instead of post ID
              userName: post.userName,
              userLocation: post.userLocation,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _searchByTag(BuildContext context, String tag) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for posts with tag: $tag'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusL),
        ),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.bookmark_outline),
                  title: const Text('Save Post'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post saved successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report_outlined),
                  title: const Text('Report Post'),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle report
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block_outlined),
                  title: const Text('Hide Post'),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle hide
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildImage(String imagePath) {
    // Check if it's a local file path or network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Network image
      return Image.network(
        imagePath,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            color: AppColors.backgroundSecondary,
            child: Center(
              child: Icon(
                Icons.broken_image,
                color: AppColors.textTertiary,
                size: 48,
              ),
            ),
          );
        },
      );
    } else {
      // Local file
      return Image.file(
        File(imagePath),
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            color: AppColors.backgroundSecondary,
            child: Center(
              child: Icon(
                Icons.broken_image,
                color: AppColors.textTertiary,
                size: 48,
              ),
            ),
          );
        },
      );
    }
  }
}
