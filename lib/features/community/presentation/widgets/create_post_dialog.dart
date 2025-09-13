import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../domain/models/post.dart';

class CreatePostDialog extends StatefulWidget {
  final Function(Post)? onPostCreated;
  final String userName;
  final String userId;
  final String userLocation;

  const CreatePostDialog({
    super.key, 
    this.onPostCreated,
    required this.userName,
    required this.userId,
    required this.userLocation,
  });

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog>
    with TickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  PostType _selectedType = PostType.text;
  late AnimationController _animationController;
  List<String> _selectedTags = [];
  String? _selectedLocation;
  List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

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
    _tagsController.dispose();
    _locationController.dispose();
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
                      onPressed: (_contentController.text.trim().isNotEmpty || _selectedImages.isNotEmpty)
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
                      child: Text(
                        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
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

            // Selected Images Preview
            if (_selectedImages.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceM,
                  vertical: AppConstants.spaceS,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Photos (${_selectedImages.length}/5)',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceS),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: AppConstants.spaceS),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                  child: Image.file(
                                    File(_selectedImages[index].path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImages.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: AppColors.textOnPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
                    _selectedImages.isNotEmpty ? 'Photos (${_selectedImages.length})' : 'Photo',
                    () => _showImagePicker(context),
                    isSelected: _selectedImages.isNotEmpty,
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  _buildActionButton(
                    Icons.tag_outlined,
                    _selectedTags.isNotEmpty ? 'Tags (${_selectedTags.length})' : 'Tags',
                    () => _showTagsDialog(context),
                    isSelected: _selectedTags.isNotEmpty,
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  _buildActionButton(
                    Icons.location_on_outlined,
                    _selectedLocation != null ? 'Location ✓' : 'Location',
                    () => _showLocationDialog(context),
                    isSelected: _selectedLocation != null,
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

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, {bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceM,
          vertical: AppConstants.spaceS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: AppConstants.spaceXS),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
    // Allow posts with either text content or images
    if (_contentController.text.trim().isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add some content or photos to your post',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Auto-add tags based on post type
    List<String> finalTags = List.from(_selectedTags);
    switch (_selectedType) {
      case PostType.question:
        if (!finalTags.contains('Questions')) {
          finalTags.add('Questions');
        }
        break;
      case PostType.tips:
        if (!finalTags.contains('Tips')) {
          finalTags.add('Tips');
        }
        break;
      case PostType.text:
        if (!finalTags.contains('Experiences')) {
          finalTags.add('Experiences');
        }
        break;
    }

    // Create new post
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.userId,
      userImage: '',
      userName: widget.userName,
      userLocation: _selectedLocation ?? widget.userLocation,
      timeAgo: 'Just now',
      content: _contentController.text.trim(),
      likes: 0,
      comments: 0,
      isLiked: false,
      tags: finalTags,
      postType: _selectedType,
      images: _selectedImages.map((image) => image.path).toList(),
    );

    // Call the callback to add post to feed
    if (widget.onPostCreated != null) {
      widget.onPostCreated!(newPost);
    }

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

  void _showTagsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Add Tags',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tagsController,
                decoration: InputDecoration(
                  hintText: 'Enter tags separated by commas...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(AppConstants.spaceM),
                ),
              ),
              const SizedBox(height: AppConstants.spaceM),
              if (_selectedTags.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selected Tags:',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceS),
                Wrap(
                  spacing: AppConstants.spaceS,
                  children: _selectedTags
                      .map((tag) => Chip(
                            label: Text(tag),
                            onDeleted: () {
                              setState(() {
                                _selectedTags.remove(tag);
                              });
                              Navigator.pop(context);
                              _showTagsDialog(context);
                            },
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          PrimaryButton(
            text: 'Add Tags',
            size: ButtonSize.small,
            onPressed: () {
              final tags = _tagsController.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();
              setState(() {
                _selectedTags = tags;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Add Location',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: TextField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Enter your location...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(AppConstants.spaceM),
              prefixIcon: Icon(
                Icons.location_on,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          PrimaryButton(
            text: 'Add Location',
            size: ButtonSize.small,
            onPressed: () {
              setState(() {
                _selectedLocation = _locationController.text.trim();
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusL),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Photos',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceM),
            
            // Selected Images Preview
            if (_selectedImages.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: AppConstants.spaceS),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            child: Image.file(
                              File(_selectedImages[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppConstants.spaceM),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Camera',
                    size: ButtonSize.medium,
                    icon: Icons.camera_alt,
                    onPressed: () async {
                      await _pickImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: SecondaryButton(
                    text: 'Gallery',
                    size: ButtonSize.medium,
                    icon: Icons.photo_library,
                    onPressed: () async {
                      await _pickImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            
            // Multiple Selection
            if (_selectedImages.length < 5) ...[
              const SizedBox(height: AppConstants.spaceM),
              TextButton.icon(
                onPressed: () async {
                  await _pickMultipleImages();
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.add_photo_alternate,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Select Multiple Photos',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: AppConstants.spaceS),
            Text(
              'Maximum 5 photos allowed',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null && _selectedImages.length < 5) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error picking image: $e',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          // Add images up to the limit of 5
          int remainingSlots = 5 - _selectedImages.length;
          for (int i = 0; i < images.length && i < remainingSlots; i++) {
            _selectedImages.add(images[i]);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error picking images: $e',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
