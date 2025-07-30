import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/chips/modern_chip.dart';
import '../widgets/post_card.dart';
import '../../domain/models/post.dart';
import '../../domain/models/user_profile.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userLocation;

  const UserProfilePage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userLocation,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isFollowing = false;
  String _selectedTab = 'Posts';
  final List<String> _tabs = ['Posts', 'About', 'Activity'];

  // Mock user profile data
  late UserProfile userProfile;
  List<Post> userPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserProfile();
    _loadUserPosts();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Don't start animation immediately - wait for data to load
  }

  void _loadUserProfile() {
    // Create profile with passed parameters
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          userProfile = UserProfile(
            id: widget.userId,
            name: widget.userName,
            location: widget.userLocation,
            bio: 'Computer Science student pursuing Masters in AI/ML. Passionate about technology and helping fellow students navigate their study abroad journey.',
            joinedDate: 'March 2023',
            followersCount: 245,
            followingCount: 189,
            postsCount: 23,
            university: 'University of Manchester',
            course: 'MSc Computer Science',
            interests: ['AI/ML', 'Technology', 'Study Tips', 'Career Advice'],
            achievements: [
              'Dean\'s List - Fall 2023',
              'Outstanding Student Award',
              'Research Assistant - AI Lab'
            ],
            languages: ['English', 'Hindi', 'Bengali'],
            profileImageUrl: '',
            coverImageUrl: '',
          );
          _isLoading = false;
          // Start animations after data is loaded
          _animationController.forward();
        });
      }
    });
  }

  void _loadUserPosts() {
    // Mock user posts - in real app, fetch from API
    userPosts = [
      Post(
        id: '1',
        userId: 'userId_1',
        userImage: '',
        userName: widget.userName,
        userLocation: widget.userLocation,
        timeAgo: '2h ago',
        content: 'Just received my acceptance letter from University of Manchester! 🎉',
        likes: 24,
        comments: 8,
        isLiked: false,
        tags: ['UK', 'Masters', 'Manchester'],
        postType: PostType.text,
      ),
      Post(
        id: '3',
        userId: 'userId_3',
        userImage: '',
        userName: widget.userName,
        userLocation: widget.userLocation,
        timeAgo: '1d ago',
        content: 'Tips for acing your university interviews - preparation is key!',
        likes: 45,
        comments: 12,
        isLiked: true,
        tags: ['Tips', 'Interview', 'University'],
        postType: PostType.tips,
      ),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text(
            widget.userName,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textOnPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_slideAnimation),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    _buildTabBar(),
                    _buildTabContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: userProfile.coverImageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(userProfile.coverImageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.textOnPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.more_vert,
            color: AppColors.textOnPrimary,
          ),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: AppColors.backgroundCard,
      padding: const EdgeInsets.all(AppConstants.spaceL),
      child: Column(
        children: [
          // Profile Picture and Basic Info
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: userProfile.profileImageUrl.isNotEmpty
                      ? NetworkImage(userProfile.profileImageUrl)
                      : null,
                  child: userProfile.profileImageUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 48,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: AppConstants.spaceL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile.name,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceXS),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: AppConstants.spaceXS),
                        Expanded(
                          child: Text(
                            userProfile.location,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceXS),
                    Text(
                      'Joined ${userProfile.joinedDate}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spaceL),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Posts', userProfile.postsCount.toString()),
              _buildStatItem('Followers', userProfile.followersCount.toString()),
              _buildStatItem('Following', userProfile.followingCount.toString()),
            ],
          ),
          
          const SizedBox(height: AppConstants.spaceL),
          
          // Bio
          if (userProfile.bio.isNotEmpty) ...[
            Text(
              userProfile.bio,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spaceL),
          ],
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: _isFollowing ? 'Following' : 'Follow',
                  onPressed: _toggleFollow,
                  backgroundColor: _isFollowing ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppConstants.spaceM),
              SecondaryButton(
                text: 'Message',
                onPressed: _sendMessage,
                size: ButtonSize.medium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXS),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.backgroundCard,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceL,
          vertical: AppConstants.spaceS,
        ),
        child: Row(
          children: _tabs.map((tab) => _buildTabChip(tab)).toList(),
        ),
      ),
    );
  }

  Widget _buildTabChip(String tab) {
    final isSelected = _selectedTab == tab;
    return Container(
      margin: const EdgeInsets.only(right: AppConstants.spaceM),
      child: ModernChip(
        label: tab,
        isSelected: isSelected,
        onTap: () {
          setState(() {
            _selectedTab = tab;
          });
        },
        backgroundColor: isSelected ? AppColors.primary : AppColors.backgroundSecondary,
        textColor: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'Posts':
        return _buildPostsTab();
      case 'About':
        return _buildAboutTab();
      case 'Activity':
        return _buildActivityTab();
      default:
        return _buildPostsTab();
    }
  }

  Widget _buildPostsTab() {
    return Container(
      color: AppColors.backgroundPrimary,
      child: userPosts.isEmpty
          ? _buildEmptyState('No posts yet', 'This user hasn\'t shared any posts.')
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.spaceS),
              itemCount: userPosts.length,
              separatorBuilder: (context, index) => const SizedBox(
                height: AppConstants.spaceS,
              ),
              itemBuilder: (context, index) {
                return PostCard(
                  post: userPosts[index],
                  onLike: () => _togglePostLike(index),
                  onComment: () => _showCommentsDialog(userPosts[index]),
                  onShare: () => _sharePost(userPosts[index]),
                );
              },
            ),
    );
  }

  Widget _buildAboutTab() {
    return Container(
      color: AppColors.backgroundPrimary,
      padding: const EdgeInsets.all(AppConstants.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAboutSection('Education', [
            '${userProfile.course} at ${userProfile.university}',
          ]),
          const SizedBox(height: AppConstants.spaceL),
          _buildAboutSection('Interests', userProfile.interests),
          const SizedBox(height: AppConstants.spaceL),
          _buildAboutSection('Languages', userProfile.languages),
          const SizedBox(height: AppConstants.spaceL),
          _buildAboutSection('Achievements', userProfile.achievements),
        ],
      ),
    );
  }

  Widget _buildAboutSection(String title, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spaceM),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceS),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: AppConstants.spaceS),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return Container(
      color: AppColors.backgroundPrimary,
      child: _buildEmptyState(
        'Activity Coming Soon',
        'User activity and engagement stats will be available here.',
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            color: AppColors.textTertiary,
            size: 64,
          ),
          const SizedBox(height: AppConstants.spaceL),
          Text(
            title,
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
      if (_isFollowing) {
        userProfile.followersCount++;
      } else {
        userProfile.followersCount--;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFollowing
              ? 'You are now following ${userProfile.name}'
              : 'You unfollowed ${userProfile.name}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: _isFollowing ? AppColors.success : AppColors.info,
      ),
    );
  }

  void _sendMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Messaging feature coming soon!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _togglePostLike(int index) {
    setState(() {
      userPosts[index].isLiked = !userPosts[index].isLiked;
      if (userPosts[index].isLiked) {
        userPosts[index].likes++;
      } else {
        userPosts[index].likes--;
      }
    });
  }

  void _showCommentsDialog(Post post) {
    // Implementation for showing comments dialog
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
      ),
    );
  }

  void _showMoreOptions() {
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
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report User'),
              onTap: () {
                Navigator.pop(context);
                // Handle report
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                // Handle block
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Profile'),
              onTap: () {
                Navigator.pop(context);
                // Handle share
              },
            ),
          ],
        ),
      ),
    );
  }
}