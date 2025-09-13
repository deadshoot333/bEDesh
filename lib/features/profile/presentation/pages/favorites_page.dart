import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../shared/widgets/cards/university_card.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../university/presentation/pages/dynamic_university_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<Map<String, dynamic>> _favoriteUniversities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _loadFavorites();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    
    try {
      final favorites = FavoritesService.getFavoriteUniversities();
      setState(() {
        _favoriteUniversities = favorites;
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load favorites: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _removeFromFavorites(String universityId, String universityName) async {
    try {
      await FavoritesService.removeFromFavorites(universityId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$universityName removed from favorites',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppConstants.spaceM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
          ),
        );
        
        // Reload favorites list
        _loadFavorites();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove from favorites'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _navigateToUniversity(Map<String, dynamic> university) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicUniversityPage(
          universityName: university['name'],
          universityId: university['id'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Favorite Universities',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_favoriteUniversities.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
              onPressed: _showClearAllDialog,
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _favoriteUniversities.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesList(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppConstants.spaceL),
                Text(
                  'No Favorite Universities Yet',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceS),
                Text(
                  'Start exploring universities and tap the heart icon to add them to your favorites',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXL),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.explore_outlined),
                  label: const Text('Explore Universities'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceL,
                      vertical: AppConstants.spaceM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesList() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Your Favorite Universities',
                  subtitle: '${_favoriteUniversities.length} ${_favoriteUniversities.length == 1 ? 'university' : 'universities'} saved',
                  icon: Icons.favorite,
                ),
                const SizedBox(height: AppConstants.spaceL),
                
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _favoriteUniversities.length,
                  separatorBuilder: (context, index) => const SizedBox(
                    height: AppConstants.spaceM,
                  ),
                  itemBuilder: (context, index) {
                    final university = _favoriteUniversities[index];
                    return UniversityCard(
                      title: university['name'] ?? 'Unknown University',
                      location: university['location'] ?? 'Unknown Location',
                      imageUrl: university['imageUrl'] ?? '',
                      ranking: university['ranking'],
                      rating: 4.5, // Default rating
                      subtitle: university['description'],
                      showFavoriteButton: true,
                      isFavorite: true, // Always true in favorites page
                      onFavoritePressed: () => _removeFromFavorites(
                        university['id'],
                        university['name'] ?? 'University',
                      ),
                      onTap: () => _navigateToUniversity(university),
                    );
                  },
                ),
                
                const SizedBox(height: AppConstants.spaceXL),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Clear All Favorites',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all universities from your favorites? This action cannot be undone.',
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
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FavoritesService.clearAllFavorites();
              _loadFavorites();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'All favorites cleared',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    backgroundColor: AppColors.info,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(AppConstants.spaceM),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}