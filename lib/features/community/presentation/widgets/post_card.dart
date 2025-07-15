import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceM),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: post.userImage.isNotEmpty 
                        ? AssetImage(post.userImage) 
                        : null,
                    radius: 20,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    onBackgroundImageError: post.userImage.isNotEmpty 
                        ? (_, __) {} 
                        : null,
                    child: post.userImage.isEmpty
                        ? Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 20,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${post.userLocation} • ${post.timeAgo}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceS,
                    vertical: AppConstants.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: _getPostTypeColor(post.postType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPostTypeIcon(post.postType),
                        color: _getPostTypeColor(post.postType),
                        size: 14,
                      ),
                      const SizedBox(width: AppConstants.spaceXS),
                      Text(
                        _getPostTypeLabel(post.postType),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _getPostTypeColor(post.postType),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
            child: Text(
              post.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),

          // Images (if any)
          if (post.images != null && post.images!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceM),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: AppConstants.spaceM),
                itemCount: post.images!.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: AppConstants.spaceS),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      color: AppColors.backgroundSecondary,
                      image: DecorationImage(
                        image: AssetImage(post.images![index]),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      ),
                    ),
                    child: post.images![index].isEmpty
                        ? Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: AppColors.textTertiary,
                              size: 32,
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
          ],

          // Tags
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceM),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
              child: Wrap(
                spacing: AppConstants.spaceS,
                runSpacing: AppConstants.spaceXS,
                children: post.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceS,
                      vertical: AppConstants.spaceXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Text(
                      '#$tag',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // Actions
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceM),
            child: Row(
              children: [
                // Like Button
                GestureDetector(
                  onTap: onLike,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceS,
                      vertical: AppConstants.spaceXS,
                    ),
                    decoration: BoxDecoration(
                      color: post.isLiked
                          ? AppColors.error.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            post.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            key: ValueKey(post.isLiked),
                            color: post.isLiked
                                ? AppColors.error
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceXS),
                        Text(
                          '${post.likes}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: post.isLiked
                                ? AppColors.error
                                : AppColors.textSecondary,
                            fontWeight: post.isLiked
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: AppConstants.spaceM),

                // Comment Button
                GestureDetector(
                  onTap: onComment,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceS,
                      vertical: AppConstants.spaceXS,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.spaceXS),
                        Text(
                          '${post.comments}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Share Button
                GestureDetector(
                  onTap: onShare,
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.spaceXS),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Icon(
                      Icons.share_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
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

  IconData _getPostTypeIcon(PostType type) {
    switch (type) {
      case PostType.question:
        return Icons.help_outline;
      case PostType.tips:
        return Icons.lightbulb_outline;
      case PostType.text:
        return Icons.article_outlined;
    }
  }

  Color _getPostTypeColor(PostType type) {
    switch (type) {
      case PostType.question:
        return AppColors.warning;
      case PostType.tips:
        return AppColors.success;
      case PostType.text:
        return AppColors.info;
    }
  }

  String _getPostTypeLabel(PostType type) {
    switch (type) {
      case PostType.question:
        return 'Question';
      case PostType.tips:
        return 'Tips';
      case PostType.text:
        return 'Post';
    }
  }
}
