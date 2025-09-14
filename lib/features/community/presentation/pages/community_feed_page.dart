import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/chips/modern_chip.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_dialog.dart';
import '../widgets/comments_dialog.dart';
import '../../domain/models/post.dart';
import '../../../../core/models/user.dart';
import 'user_profile_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/storage_service.dart';

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
  List<Post> posts = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = StorageService.getUserData();
      if (user != null) {
        setState(() {
          currentUser = user;
        });
      } else {
        // ignore: avoid_print
        print("⚠️ No user data found in StorageService");
      }
    });
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (currentUser == null) {
        // ignore: avoid_print
        print("⚠️ currentUser is null, cannot fetch posts");
        return;
      }
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/api/community/get-posts?user_id=${currentUser!.id}',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> postsJson = data['posts'];
        setState(() {
          posts = postsJson.map((json) => Post.fromJson(json)).toList();
        });
      } else {
        // Handle error
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load posts')));
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> addPost(Post post) async {
    final url = Uri.parse('$_baseUrl/api/community/post');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newPost = Post.fromJson(data['post']);
        setState(() {
          posts.insert(0, newPost);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Post added!')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add post')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _onCreatePost() async {
    final newPost = await showDialog<Post>(
      context: context,
      builder: (context) => CreatePostDialog(),
    );
    if (newPost != null) {
      await addPost(newPost);
    }
  }

  // Get filtered posts based on selected filter
  List<Post> get filteredPosts {
    if (_selectedFilter == 'All') {
      return posts;
    }

    return posts.where((post) {
      // Check if filter matches post type
      if (_selectedFilter == 'Questions' &&
          post.postType == PostType.question) {
        return true;
      }
      if (_selectedFilter == 'Tips' && post.postType == PostType.tips) {
        return true;
      }
      if (_selectedFilter == 'Experiences' && post.postType == PostType.text) {
        return true;
      }

      // Check if filter matches any tag (case-insensitive)
      return post.tags.any(
        (tag) => tag.toLowerCase() == _selectedFilter.toLowerCase(),
      );
    }).toList();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _animationController = AnimationController(
  //     duration: const Duration(milliseconds: 1000),
  //     vsync: this,
  //   );
  //   _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
  //     CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
  //   );
  //   _animationController.forward();
  //   fetchPosts();
  // }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Modern Header (like home page)
            _buildModernHeader(),
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
                          '1fa5ba70-6a6c-473c-97c2-d0d4e33dea1e', // Current logged in user
                          'Arqam Bin Almas', // Current user name
                          'Cambridge, USA', // Current user location
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
              child:
                  filteredPosts.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.spaceS,
                        ),
                        itemCount: filteredPosts.length,
                        separatorBuilder:
                            (context, index) =>
                                const SizedBox(height: AppConstants.spaceS),
                        itemBuilder: (context, index) {
                          final post = filteredPosts[index];
                          final originalIndex = posts.indexOf(post);
                          return AnimatedContainer(
                            duration: Duration(
                              milliseconds: 300 + (index * 100),
                            ),
                            curve: Curves.easeOutBack,
                            child: PostCard(
                              post: post,
                              onLike: () => _toggleLike(originalIndex),
                              onComment:
                                  () => _showCommentsDialog(context, post),
                              onShare: () => _sharePost(post),
                              onTagTap: _filterByTag,
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
        elevation: 8,
        child: const Icon(Icons.add, size: 24),
      ),
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
              // Back button
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              // Community Feed title
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
              // Action buttons
              ModernIconButton(
                icon: Icons.person_outline,
                backgroundColor: AppColors.textOnPrimary.withOpacity(0.2),
                iconColor: AppColors.textOnPrimary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
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

  void _filterByTag(String tag) {
    setState(() {
      _selectedFilter = tag;
    });
  }

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
              onPressed: () {
                setState(() {
                  _selectedFilter = 'All';
                });
              },
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
      builder: (context) => CreatePostDialog(onPostCreated: _addNewPost),
    );
  }

  void _addNewPost(Post newPost) {
    setState(() {
      posts.insert(0, newPost); // Add to beginning of list
    });
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
