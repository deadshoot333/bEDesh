import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/post.dart';

class CommentsDialog extends StatefulWidget {
  final Post post;

  const CommentsDialog({super.key, required this.post});

  @override
  State<CommentsDialog> createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<CommentsDialog>
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  late AnimationController _animationController;
  final List<Comment> _comments = [
    Comment(
      id: '1',
      userImage: '', // Will use placeholder
      userName: 'Alex Johnson',
      timeAgo: '2h ago',
      content: 'This is really helpful! Thanks for sharing your experience.',
    ),
    Comment(
      id: '2',
      userImage: '', // Will use placeholder
      userName: 'Sarah Kim',
      timeAgo: '4h ago',
      content: 'I had a similar experience. Would love to connect and share more details.',
    ),
    Comment(
      id: '3',
      userImage: '', // Will use placeholder
      userName: 'Mike Chen',
      timeAgo: '6h ago',
      content: 'Great advice! This will definitely help students planning their applications.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      )),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXL),
          ),
        ),
        child: Column(
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: AppConstants.spaceS),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Comments (${_comments.length})',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the close button
                ],
              ),
            ),

            const Divider(
              color: AppColors.borderLight,
              height: 1,
            ),

            // Comments List
            Expanded(
              child: _comments.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppConstants.spaceM),
                      itemCount: _comments.length,
                      separatorBuilder: (context, index) => const SizedBox(
                        height: AppConstants.spaceM,
                      ),
                      itemBuilder: (context, index) {
                        return _buildCommentCard(_comments[index]);
                      },
                    ),
            ),

            // Comment Input
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              decoration: const BoxDecoration(
                color: AppColors.backgroundSecondary,
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceS),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _commentController,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spaceM,
                              vertical: AppConstants.spaceS,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // Trigger rebuild to update send button state
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceS),
                    Container(
                      decoration: BoxDecoration(
                        color: _commentController.text.trim().isNotEmpty
                            ? AppColors.primary
                            : AppColors.backgroundSecondary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _commentController.text.trim().isNotEmpty
                            ? _sendComment
                            : null,
                        icon: Icon(
                          Icons.send,
                          color: _commentController.text.trim().isNotEmpty
                              ? AppColors.textOnPrimary
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(Comment comment) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: comment.userImage.isNotEmpty 
                  ? AssetImage(comment.userImage) 
                  : null,
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              onBackgroundImageError: comment.userImage.isNotEmpty 
                  ? (_, __) {} 
                  : null,
              child: comment.userImage.isEmpty
                  ? Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 16,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppConstants.spaceS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceS),
                    Text(
                      comment.timeAgo,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceXS),
                Text(
                  comment.content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceS),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Like comment functionality
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_border,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: AppConstants.spaceXS),
                          Text(
                            'Like',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceM),
                    GestureDetector(
                      onTap: () {
                        // Reply functionality
                        _commentController.text = '@${comment.userName} ';
                      },
                      child: Text(
                        'Reply',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.comment_outlined,
            color: AppColors.textTertiary,
            size: 48,
          ),
          const SizedBox(height: AppConstants.spaceM),
          Text(
            'No comments yet',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            'Be the first to comment on this post',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;

    // Add new comment to the list
    setState(() {
      _comments.insert(
        0,
        Comment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userImage: '', // Will use placeholder
          userName: 'You',
          timeAgo: 'Just now',
          content: _commentController.text.trim(),
        ),
      );
      _commentController.clear();
    });

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Comment posted successfully!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class Comment {
  final String id;
  final String userImage;
  final String userName;
  final String timeAgo;
  final String content;

  Comment({
    required this.id,
    required this.userImage,
    required this.userName,
    required this.timeAgo,
    required this.content,
  });
}
