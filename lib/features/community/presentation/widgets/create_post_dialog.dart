import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../domain/models/post.dart';

class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({super.key});

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog>
    with TickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  PostType _selectedType = PostType.text;
  late AnimationController _animationController;

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
    _contentController.dispose();
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
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXL),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                      'Create Post',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: PrimaryButton(
                      text: 'Post',
                      size: ButtonSize.small,
                      onPressed: _contentController.text.trim().isNotEmpty
                          ? () => _publishPost()
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              color: AppColors.borderLight,
              height: 1,
            ),

            // User Info
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
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Name',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Share with community',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Post Type Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
              child: Row(
                children: [
                  _buildPostTypeChip('Share', PostType.text, Icons.article_outlined),
                  const SizedBox(width: AppConstants.spaceS),
                  _buildPostTypeChip('Ask', PostType.question, Icons.help_outline),
                  const SizedBox(width: AppConstants.spaceS),
                  _buildPostTypeChip('Tips', PostType.tips, Icons.lightbulb_outline),
                ],
              ),
            ),

            // Content Input
            Padding(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: 6,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: _getHintText(),
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(AppConstants.spaceM),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // Trigger rebuild to update Post button state
                    });
                  },
                ),
              ),
            ),

            // Additional Options
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceM,
                vertical: AppConstants.spaceS,
              ),
              child: Row(
                children: [
                  _buildActionButton(
                    Icons.photo_camera_outlined,
                    'Photo',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Photo upload feature coming soon!',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  _buildActionButton(
                    Icons.tag_outlined,
                    'Tags',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tags feature coming soon!',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  _buildActionButton(
                    Icons.location_on_outlined,
                    'Location',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Location feature coming soon!',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spaceL),
          ],
        ),
      ),
    );
  }

  Widget _buildPostTypeChip(String label, PostType type, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spaceS,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: AppConstants.spaceXS),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceM,
          vertical: AppConstants.spaceS,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
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
              color: AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: AppConstants.spaceXS),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHintText() {
    switch (_selectedType) {
      case PostType.question:
        return 'Ask your question about studying abroad...';
      case PostType.tips:
        return 'Share your tips and advice...';
      case PostType.text:
        return 'Share your experience or thoughts...';
    }
  }

  void _publishPost() {
    if (_contentController.text.trim().isEmpty) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Post published successfully!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View',
          textColor: AppColors.textOnPrimary,
          onPressed: () {},
        ),
      ),
    );
  }
}
