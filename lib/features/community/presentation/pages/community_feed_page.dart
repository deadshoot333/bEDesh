import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/models/user.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/chips/modern_chip.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_dialog.dart';
import '../widgets/comments_dialog.dart';
import '../../domain/models/post.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({super.key});

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  static const String _baseUrl = ApiConstants.baseUrl;

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

  User? currentUser;
  String _userName = 'User';
  String _userLocation = 'Unknown Location';
  String _userId = '';

  String? _authToken;

  List<Post> posts = [];
  bool isLoading = false;

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
    _loadUserData();
    fetchPosts();
  }

  void _loadUserData() {
    final user = StorageService.getUserData();
    final token = StorageService.getAccessToken(); // Ensure this returns a JWT
    setState(() {
      currentUser = user;
      _authToken = token;
      if (user != null) {
        _userName = user.name;
        _userLocation = '${user.city}, ${user.university}';
        _userId = user.id;
      }
    });
  }

  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (_authToken == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Not authenticated')));
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/community/get-posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> postsJson = data['posts'] ?? [];
        setState(() {
          posts = postsJson.map((json) => Post.fromJson(json)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load posts (${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading posts: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> addPost(Post post) async {
    try {
      if (_authToken == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Not authenticated')));
        return;
      }

      final url = Uri.parse('$_baseUrl/api/community/post');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode(post.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final newPost = Post.fromJson(data['post']);
        setState(() {
          posts.insert(0, newPost);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Post added!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add post (${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding post: $e')));
    }
  }
// #TODO:Fix Post connection
  // Filters
  List<Post> get filteredPosts {
    if (_selectedFilter == 'All') return posts;
    return posts.where((post) {
      if (_selectedFilter == 'Questions' && post.postType == PostType.question)
        return true;
      if (_selectedFilter == 'Tips' && post.postType == PostType.tips)
        return true;
      if (_selectedFilter == 'Experiences' && post.postType == PostType.text)
        return true;
      return post.tags.any(
        (tag) => tag.toLowerCase() == _selectedFilter.toLowerCase(),
      );
    }).toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildModernHeader(),
            _buildActionsBar(context),
            _buildFilterRow(),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (filteredPosts.isEmpty
                          ? _buildEmptyState()
                          : _buildFeedList()),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 8,
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }

  Widget _buildActionsBar(BuildContext context) {
    return Container(
      color: AppColors.backgroundCard,
      padding: const EdgeInsets.all(AppConstants.spaceM),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => NavigationService.navigateToProfile(),
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
                child: Text(
                  _userName.isNotEmpty ? _userName.toUpperCase() : 'U',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
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
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  border: Border.all(color: AppColors.borderLight, width: 1),
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
    );
  }

  Widget _buildFilterRow() {
    return Container(
      color: AppColors.backgroundCard,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceM,
          vertical: AppConstants.spaceS,
        ),
        child: Row(
          children: _filters.map((filter) => _buildFilterChip(filter)).toList(),
        ),
      ),
    );
  }

  Widget _buildFeedList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceS),
      itemCount: filteredPosts.length,
      separatorBuilder:
          (context, index) => const SizedBox(height: AppConstants.spaceS),
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        final originalIndex = posts.indexOf(post);
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          child: PostCard(
            post: post,
            onLike: () => _toggleLike(originalIndex),
            onComment: () => _showCommentsDialog(context, post),
            onShare: () => _sharePost(post),
            onTagTap: _filterByTag,
          ),
        );
      },
    );
  }

  Widget _buildModernHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.textOnPrimary,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Feed',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceXS),
                    Text(
                      _selectedFilter == 'All'
                          ? 'Connect with students worldwide'
                          : 'Showing posts filtered by "$_selectedFilter"',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              ModernIconButton(
                icon: Icons.person_outline,
                backgroundColor: AppColors.textOnPrimary.withOpacity(0.2),
                iconColor: AppColors.textOnPrimary,
                onPressed: () {
                  NavigationService.navigateToProfile();
                },
                tooltip: 'Profile',
              ),
            ],
          ),
        ),
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
        onTap: () => setState(() => _selectedFilter = filter),
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
      posts[index].likes += posts[index].isLiked ? 1 : -1;
    });
  }

  void _filterByTag(String tag) => setState(() => _selectedFilter = tag);

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppConstants.spaceL),
            Text(
              'No posts found',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spaceM),
            Text(
              'No posts match the filter "$_selectedFilter".\nTry selecting a different filter or check back later.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spaceXL),
            PrimaryButton(
              text: 'Clear Filter',
              size: ButtonSize.medium,
              onPressed: () => setState(() => _selectedFilter = 'All'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CreatePostDialog(
            onPostCreated: _addNewPostAndSend,
            userName: _userName,
            userId: _userId,
            userLocation: _userLocation,
          ),
    );
  }

  void _addNewPostAndSend(Post newPost) async {
    await addPost(newPost);
  }

  void _showCommentsDialog(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsDialog(post: post),
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
}
