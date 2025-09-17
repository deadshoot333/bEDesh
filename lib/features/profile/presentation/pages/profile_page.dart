import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/services/connections_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/profile_option_card.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/models/user.dart';
import '../../services/profile_service.dart';
import '../pages/favorites_page.dart';
import '../pages/connections_page.dart';
import '../../../auth/presentation/pages/login_page.dart';

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

      // Check if user is authenticated first
      final AuthService authService = AuthService();
      if (!authService.isAuthenticated()) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'login_required'; // Special flag for login required
        });
        return;
      }

      // First try to get user from local storage
      User? localUser = StorageService.getUserData();
      
      if (localUser != null) {
        setState(() {
          _currentUser = localUser;
        });
      }

      // Then try to fetch fresh profile data from server
      try {
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
      final connectionsCount = await ConnectionsService.getConnectionsCount();
      
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
    // Show login required screen if not authenticated
    if (_errorMessage == 'login_required') {
      return _buildLoginRequiredScreen();
    }

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
                    onPressed: _handleLogout,
                    icon: const Icon(
                      Icons.logout,
                      color: AppColors.textOnPrimary,
                    ),
                    tooltip: 'Logout',
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
                          ],
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

  void _navigateToCommunityFeed() {
    // Switch to community tab instead of pushing new page
    NavigationService.navigateToCommunity();
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
        builder: (context) => const ConnectionsPage(),
      ),
    ).then((_) {
      // Refresh stats when returning from connections page
      _refreshStats();
    });
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

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: AppColors.error,
              size: 24,
            ),
            SizedBox(width: AppConstants.spaceS),
            Text(
              'Logout',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
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
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            child: Text(
              'Logout',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(AppConstants.spaceL),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                ),
                SizedBox(height: AppConstants.spaceM),
                Text(
                  'Logging out...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Perform logout
      final AuthService authService = AuthService();
      await authService.logout();

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to login screen (replace with your login route)
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/', // Replace with your login route
          (route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logout failed. Please try again.',
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

  Widget _buildLoginRequiredScreen() {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundPrimary,
              AppColors.primaryLight,
            ],
            stops: [0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceL,
              vertical: AppConstants.spaceM,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 32,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppConstants.spaceL),
                    
                    // Animated Icon Container
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            offset: const Offset(0, 6),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                          const BoxShadow(
                            color: AppColors.shadowLight,
                            offset: Offset(0, 3),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_circle_outlined,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceXL),
                    
                    // Title
                    Text(
                      'Profile Access Required',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceM),
                    
                    // Main Description
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceM,
                        vertical: AppConstants.spaceS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'To view Profile one needs to login first',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceM),
                    
                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceS),
                      child: Text(
                        'Access your personal profile, stats, and connect with students worldwide',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceXL),
                    
                    // Login Button with enhanced styling
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceS),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            offset: const Offset(0, 3),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: PrimaryButton(
                        text: 'Login Now',
                        icon: Icons.login_rounded,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceL),
                    
                    // Feature highlights - Made more compact
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceS),
                      padding: const EdgeInsets.all(AppConstants.spaceM),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFeatureRow(Icons.people_outline, 'Connect with students'),
                          const SizedBox(height: AppConstants.spaceXS),
                          _buildFeatureRow(Icons.favorite_outline, 'Save favorite accommodations'),
                          const SizedBox(height: AppConstants.spaceXS),
                          _buildFeatureRow(Icons.article_outlined, 'Share your experiences'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceL),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
