import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/profile_option_card.dart';
import '../../../home/presentation/pages/modern_home_page.dart';
import '../../../community/presentation/pages/community_feed_page.dart';
import '../../../community/presentation/pages/peer_connect_page.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/models/user.dart';
import '../../services/profile_service.dart';
import '../pages/favorites_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // User data state
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Profile statistics (can be fetched from API later)
  int _postsCount = 0;
  int _connectionsCount = 0;
  int _savedCount = 0;

  // Profile photo state
  String? _profileImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Load user data when page initializes
    _loadUserProfile();
    _loadProfileImage();
    _animationController.forward();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh stats when app comes back to foreground
    if (state == AppLifecycleState.resumed && _currentUser?.id != null) {
      print('🔄 ProfilePage: App resumed, refreshing stats...');
      _refreshStats();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // First try to get user from local storage
      User? localUser = StorageService.getUserData();
      
      if (localUser != null) {
        setState(() {
          _currentUser = localUser;
        });
      }

      // Then try to fetch fresh profile data from server
      try {
        final AuthService authService = AuthService();
        final User freshUser = await authService.getProfile();
        
        setState(() {
          _currentUser = freshUser;
        });
        
        // Update local storage with fresh data
        await StorageService.saveUserData(freshUser);
        
        // Fetch user statistics
        await _loadUserStatistics(freshUser.id);
        
      } catch (e) {
        // If server call fails but we have local data, use that
        if (localUser != null) {
          setState(() {
            _currentUser = localUser;
          });
          // Try to load stats even if profile fetch failed
          await _loadUserStatistics(localUser.id);
        } else {
          setState(() {
            _errorMessage = 'Failed to load profile data';
          });
        }
      }
      
      setState(() {
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile data';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshStats() async {
    print('🔄 ProfilePage: Refreshing stats...');
    if (_currentUser?.id != null) {
      await _loadUserStatistics(_currentUser!.id);
    }
  }

  Future<void> _refreshFavoritesCount() async {
    print('🔄 ProfilePage: Refreshing favorites count only...');
    final savedCount = FavoritesService.getFavoritesCount();
    setState(() {
      _savedCount = savedCount;
    });
    print('📊 ProfilePage: Favorites count refreshed: $savedCount');
  }

  Future<void> _loadUserStatistics(String userId) async {
    try {
      final ProfileService profileService = ProfileService();
      
      // Load posts count
      final postsCount = await profileService.getUserPostsCount(userId);
      
      // Load connections count  
      final connectionsCount = await profileService.getUserConnectionsCount(userId);
      
      // Load favorites count from FavoritesService with debugging
      print('🔍 ProfilePage: Loading favorites count...');
      final savedCount = FavoritesService.getFavoritesCount();
      print('📊 ProfilePage: Favorites count loaded: $savedCount');
      
      setState(() {
        _postsCount = postsCount;
        _connectionsCount = connectionsCount;
        _savedCount = savedCount;
      });
      
      print('✅ ProfilePage: User statistics updated - Posts: $_postsCount, Connections: $_connectionsCount, Saved: $_savedCount');
      
    } catch (e) {
      // If stats loading fails, just keep default values
      print('❌ Failed to load user statistics: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: RefreshIndicator(
            onRefresh: () async {
              print('🔄 ProfilePage: Pull-to-refresh triggered');
              await _loadUserProfile();
            },
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
              // Modern App Bar with Profile Header
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: AppConstants.spaceXL),
                          // Profile Picture
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.textOnPrimary,
                                    width: 4,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.shadowDark,
                                      offset: Offset(0, 4),
                                      blurRadius: 16,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  backgroundImage: _getProfileImageProvider(),
                                  child: _profileImagePath == null ? Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 50,
                                  ) : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.textOnPrimary,
                                      width: 2,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: _showEditProfileDialog,
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: AppColors.textOnPrimary,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spaceM),
                          // Name and Email - Dynamic Data
                          _isLoading
                              ? Column(
                                  children: [
                                    Container(
                                      width: 150,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppColors.textOnPrimary.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: AppConstants.spaceXS),
                                    Container(
                                      width: 120,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: AppColors.textOnPrimary.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                )
                              : _currentUser != null
                                  ? Column(
                                      children: [
                                        Text(
                                          _currentUser!.name,
                                          style: AppTextStyles.h3.copyWith(
                                            color: AppColors.textOnPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: AppConstants.spaceXS),
                                        Text(
                                          _currentUser!.email,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.textOnPrimary.withOpacity(0.8),
                                          ),
                                        ),
                                        // Show university and city if available
                                        if (_currentUser!.university != null || _currentUser!.city != null) ...[
                                          const SizedBox(height: AppConstants.spaceXS),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              if (_currentUser!.university != null) ...[
                                                Icon(
                                                  Icons.school_outlined,
                                                  size: 16,
                                                  color: AppColors.textOnPrimary.withOpacity(0.7),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _currentUser!.university!,
                                                  style: AppTextStyles.bodySmall.copyWith(
                                                    color: AppColors.textOnPrimary.withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                              if (_currentUser!.university != null && _currentUser!.city != null)
                                                Text(
                                                  ' • ',
                                                  style: AppTextStyles.bodySmall.copyWith(
                                                    color: AppColors.textOnPrimary.withOpacity(0.7),
                                                  ),
                                                ),
                                              if (_currentUser!.city != null) ...[
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  size: 16,
                                                  color: AppColors.textOnPrimary.withOpacity(0.7),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _currentUser!.city!,
                                                  style: AppTextStyles.bodySmall.copyWith(
                                                    color: AppColors.textOnPrimary.withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Text(
                                          'Profile Loading...',
                                          style: AppTextStyles.h3.copyWith(
                                            color: AppColors.textOnPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: AppConstants.spaceXS),
                                        if (_errorMessage != null)
                                          Text(
                                            _errorMessage!,
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: AppColors.error,
                                            ),
                                          ),
                                      ],
                                    ),
                          const SizedBox(height: AppConstants.spaceS),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: _loadUserProfile,
                    icon: const Icon(
                      Icons.refresh,
                      color: AppColors.textOnPrimary,
                    ),
                    tooltip: 'Refresh Profile',
                  ),
                  IconButton(
                    onPressed: _showSettings,
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.textOnPrimary,
                    ),
                    tooltip: 'Settings',
                  ),
                  const SizedBox(width: AppConstants.spaceS),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Column(
                    children: [
                      // Stats Section
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spaceL),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ProfileStatCard(label: "Posts", value: "$_postsCount"),
                            ProfileStatCard(label: "Connections", value: "$_connectionsCount"),
                            ProfileStatCard(label: "Favorites", value: "$_savedCount"),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceL),

                      // Quick Actions
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spaceL),
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
                            Text(
                              'Quick Actions',
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spaceM),
                            Row(
                              children: [
                                Expanded(
                                  child: SecondaryButton(
                                    text: 'Apply Now',
                                    icon: Icons.edit_outlined,
                                    onPressed: () => _navigateToHome(),
                                  ),
                                ),
                                const SizedBox(width: AppConstants.spaceM),
                                Expanded(
                                  child: SecondaryButton(
                                    text: 'View Community',
                                    icon: Icons.people_outline,
                                    onPressed: () => _navigateToCommunityFeed(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceL),

                      // Menu Options
                      Container(
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
                          children: [
                            ProfileOptionCard(
                              icon: Icons.article_outlined,
                              title: "My Posts",
                              subtitle: "View and manage your community posts",
                              onTap: () => _navigateToCommunityFeed(),
                            ),
                            const Divider(color: AppColors.borderLight, height: 1),
                            ProfileOptionCard(
                              icon: Icons.people_outline,
                              title: "My Connections",
                              subtitle: "Connect with other students",
                              onTap: () => _navigateToPeerConnect(),
                            ),
                            const Divider(color: AppColors.borderLight, height: 1),
                            ProfileOptionCard(
                              icon: Icons.favorite_outline,
                              title: "Favorite Universities",
                              subtitle: "View your saved universities (${FavoritesService.getFavoritesCount()})",
                              onTap: () => _navigateToFavorites(),
                            ),
                            const Divider(color: AppColors.borderLight, height: 1),
                            ProfileOptionCard(
                              icon: Icons.notifications_outlined,
                              title: "Notifications",
                              subtitle: "Manage your preferences",
                              onTap: () => _showFeatureComingSoon('Notifications'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceL),

                      // Logout Section
                      Container(
                        width: double.infinity,
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
                        child: ProfileOptionCard(
                          icon: Icons.logout_outlined,
                          title: "Logout",
                          subtitle: "Sign out of your account",
                          isDestructive: true,
                          onTap: _showLogoutDialog,
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXL),
                    ],
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModernHomePage(),
      ),
    );
  }

  void _navigateToCommunityFeed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CommunityFeedPage(),
      ),
    );
  }

  void _navigateToFavorites() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritesPage(),
      ),
    );
    // Refresh stats when returning from favorites page
    _refreshStats();
  }

  void _navigateToPeerConnect() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PeerConnectPage(),
      ),
    );
  }

  // Profile photo methods
  void _loadProfileImage() {
    final savedPath = StorageService.getProfilePhotoPath();
    if (savedPath != null) {
      setState(() {
        _profileImagePath = savedPath;
      });
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        await StorageService.setProfilePhotoPath(pickedFile.path);
        setState(() {
          _profileImagePath = pickedFile.path;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile photo updated successfully!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.backgroundPrimary,
                ),
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick image. Please try again.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.backgroundPrimary,
              ),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusL),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppConstants.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: AppConstants.spaceL),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Select Profile Photo',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppConstants.spaceL),
            Column(
              children: [
                // Camera option - always show, handle platform limitations gracefully
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    'Camera',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.camera);
                  },
                ),
                // Gallery/File picker option
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    'Gallery',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.gallery);
                  },
                ),
              ],
            ),
            SizedBox(height: AppConstants.spaceM),
          ],
        ),
      ),
    );
  }

  ImageProvider _getProfileImageProvider() {
    if (_profileImagePath != null) {
      if (kIsWeb) {
        // For web, use NetworkImage or handle differently
        return AssetImage('assets/img.png'); // Fallback for web
      } else {
        return FileImage(File(_profileImagePath!));
      }
    }
    return const AssetImage('assets/img.png'); // Default image
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile photo section
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: _getProfileImageProvider(),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.backgroundPrimary,
                    size: 30,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppConstants.spaceM),
            Text(
              'Tap to change profile photo',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Done',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    _showFeatureComingSoon('Settings');
  }

  void _showFeatureComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature feature coming soon!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.info,
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.textOnPrimary,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Logout',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
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
            text: 'Logout',
            size: ButtonSize.small,
            backgroundColor: AppColors.error,
            onPressed: () async {
              Navigator.pop(context);
              await _handleLogout();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Clear all authentication data
      await StorageService.clearAuthData();
      
      // Navigate to onboarding page
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      // Show error if logout fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logout failed. Please try again.',
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
