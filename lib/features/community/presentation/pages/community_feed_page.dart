import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/inputs/modern_search_bar.dart';
import '../../../../shared/widgets/chips/modern_chip.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_dialog.dart';
import '../widgets/comments_dialog.dart';
import '../../domain/models/post.dart';
import './user_profile_page.dart';
class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({super.key});

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Questions',
    'Experiences',
    'Tips',
    'USA',
    'UK',
    'Canada',
    'Australia',
  ];

  final List<Post> posts = [
    Post(
      id: '1',
      userImage: '', // Will use placeholder
      userName: 'Rahul Sharma',
      userLocation: 'Mumbai, India',
      timeAgo: '2h ago',
      content:
          'Just received my acceptance letter from University of Manchester! 🎉 The journey was tough but totally worth it. Happy to share my experience with anyone planning to apply.',
      likes: 24,
      comments: 8,
      isLiked: false,
      tags: ['UK', 'Masters', 'Manchester'],
      postType: PostType.text,
    ),
    Post(
      id: '2',
      userImage: '', // Will use placeholder
      userName: 'Priya Patel',
      userLocation: 'Delhi, India',
      timeAgo: '4h ago',
      content:
          'Can anyone help me with SOP writing for Canadian universities? I\'m struggling with the structure and would love some guidance.',
      likes: 15,
      comments: 12,
      isLiked: true,
      tags: ['Canada', 'SOP', 'Help'],
      postType: PostType.question,
    ),
    Post(
      id: '3',
      userImage: '', // Will use placeholder
      userName: 'Ahmed Khan',
      userLocation: 'Dhaka, Bangladesh',
      timeAgo: '6h ago',
      content:
          'Finally landed in Melbourne! First week at university has been amazing. The campus is beautiful and people are so welcoming. Missing home food though 😅',
      likes: 31,
      comments: 6,
      isLiked: false,
      tags: ['Australia', 'Melbourne', 'Experience'],
      postType: PostType.text,
      images: [], // Removed missing image
    ),
    Post(
      id: '4',
      userImage: '', // Will use placeholder
      userName: 'Sarah Johnson',
      userLocation: 'Toronto, Canada',
      timeAgo: '8h ago',
      content:
          'Top 5 mistakes to avoid while applying to US universities:\n1. Not researching properly\n2. Generic essays\n3. Missing deadlines\n4. Not preparing for interviews\n5. Ignoring financial planning',
      likes: 67,
      comments: 23,
      isLiked: true,
      tags: ['USA', 'Tips', 'Application'],
      postType: PostType.tips,
    ),
    Post(
      id: '5',
      userImage: '', // Will use placeholder
      userName: 'Michael Chen',
      userLocation: 'London, UK',
      timeAgo: '12h ago',
      content:
          'Anyone else struggling with accommodation costs in London? Looking for shared apartments near Imperial College. Budget is £800-1000/month.',
      likes: 18,
      comments: 15,
      isLiked: false,
      tags: ['UK', 'London', 'Accommodation'],
      postType: PostType.question,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        title: Text(
          'Community',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Notifications feature coming soon!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
          const SizedBox(width: AppConstants.spaceS),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Quick Actions Bar
            Container(
              color: AppColors.backgroundCard,
              padding: const EdgeInsets.all(AppConstants.spaceM),
              child: Row(
                children: [
                  GestureDetector(
                    onTap:
                        () => _navigateToUserProfile(
                          context,
                          'current_user_id', // Replace with actual current user ID
                          'Your Name', // Replace with actual current user name
                          'Your Location', // Replace with actual current user location
                        ),
                    child: Container(
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
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showCreatePostDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceM,
                          vertical: AppConstants.spaceM,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusXL,
                          ),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Share your experience or ask a question...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.edit_outlined,
                              color: AppColors.textTertiary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tabs
            Container(
              color: AppColors.backgroundCard,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceM,
                  vertical: AppConstants.spaceS,
                ),
                child: Row(
                  children:
                      _filters
                          .map((filter) => _buildFilterChip(filter))
                          .toList(),
                ),
              ),
            ),

            // Posts Feed
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spaceS,
                ),
                itemCount: posts.length,
                separatorBuilder:
                    (context, index) =>
                        const SizedBox(height: AppConstants.spaceS),
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeOutBack,
                    child: PostCard(
                      post: posts[index],
                      onLike: () => _toggleLike(index),
                      onComment:
                          () => _showCommentsDialog(context, posts[index]),
                      onShare: () => _sharePost(posts[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        child: const Icon(Icons.add, size: 24),
        elevation: 8,
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return Container(
      margin: const EdgeInsets.only(right: AppConstants.spaceS),
      child: ModernChip(
        label: filter,
        isSelected: isSelected,
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
        },
        backgroundColor:
            isSelected ? AppColors.primary : AppColors.backgroundSecondary,
        textColor:
            isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
      ),
    );
  }

  void _toggleLike(int index) {
    setState(() {
      posts[index].isLiked = !posts[index].isLiked;
      if (posts[index].isLiked) {
        posts[index].likes++;
      } else {
        posts[index].likes--;
      }
    });
  }

  void _showCreatePostDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePostDialog(),
    );
  }

  void _showCommentsDialog(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsDialog(post: post),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
            ),
            title: Text(
              'Search Community',
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
            ),
            content: const ModernSearchBar(
              hintText: 'Search posts, users, or topics...',
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
                text: 'Search',
                size: ButtonSize.small,
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Search feature coming soon!',
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
    );
  }

  void _sharePost(Post post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Post shared successfully!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.textOnPrimary,
          onPressed: () {},
        ),
      ),
    );
  }

  void _navigateToUserProfile(
    BuildContext context,
    String userId,
    String userName,
    String userLocation,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => UserProfilePage(
              userId: userId,
              userName: userName,
              userLocation: userLocation,
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
}
