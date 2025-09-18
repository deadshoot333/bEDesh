import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/cards/dynamic_course_card.dart';
import '../../../../shared/widgets/cards/scholarship_card.dart';
import '../../../../shared/widgets/navigation/navigation_wrapper.dart';
import '../../data/services/university_api_service.dart';
import '../../domain/models/university.dart';
import '../../domain/models/course.dart';
import '../../domain/models/scholarship.dart';

class DynamicUniversityPage extends StatefulWidget {
  final String universityName;
  final String? universityId;

  const DynamicUniversityPage({
    super.key, 
    required this.universityName,
    this.universityId,
  });

  @override
  State<DynamicUniversityPage> createState() => _DynamicUniversityPageState();
}

class _DynamicUniversityPageState extends State<DynamicUniversityPage>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  University? university;
  List<Course> courses = [];
  List<Scholarship> scholarships = [];
  
  bool isLoading = true;
  String? errorMessage;
  bool _isFavorite = false;

  // Filter states
  String? _selectedCourseFilter; // Combined level and field filter
  String? _selectedScholarshipFilter; // Combined type and funding filter

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUniversityData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadUniversityData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('🔍 Loading university data for: ${widget.universityName}');
      
      // Load university details
      final universityData = await UniversityApiService.getUniversityByName(widget.universityName);
      print('🏫 University data loaded: ${universityData.name}');
      print('🖼️ Image URL: ${universityData.imageUrl}');
      
      // Load courses and scholarships in parallel
      final results = await Future.wait([
        UniversityApiService.getCoursesByUniversity(widget.universityName),
        UniversityApiService.getScholarshipsByUniversity(widget.universityName),
      ]);

      print('📚 Courses loaded: ${(results[0] as List<Course>).length}');
      print('🎓 Scholarships loaded: ${(results[1] as List<Scholarship>).length}');

      setState(() {
        university = universityData;
        courses = results[0] as List<Course>;
        scholarships = results[1] as List<Scholarship>;
        _isFavorite = FavoritesService.isFavorite(universityData.id);
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading university data: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (university == null) return;

    try {
      final isFavorite = await FavoritesService.toggleFavorite(
        universityId: university!.id,
        name: university!.name,
        location: university!.location,
        imageUrl: university!.imageUrl,
        ranking: university!.worldRanking,
        description: university!.description,
      );

      setState(() {
        _isFavorite = isFavorite;
      });

      // Show feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorite 
                ? '${university!.name} added to favorites' 
                : '${university!.name} removed from favorites',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
            backgroundColor: isFavorite ? AppColors.success : AppColors.info,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppConstants.spaceM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorites'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return NavigationWrapper(
        selectedIndex: 0, // Home tab context
        child: Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          body: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return NavigationWrapper(
        selectedIndex: 0, // Home tab context
        child: Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppConstants.spaceM),
                Text(
                  'Error Loading University',
                  style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppConstants.spaceS),
                Text(
                  errorMessage!,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spaceL),
                PrimaryButton(
                  text: 'Retry',
                  onPressed: _loadUniversityData,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (university == null) {
      return NavigationWrapper(
        selectedIndex: 0, // Home tab context
        child: Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          body: const Center(
            child: Text('University not found'),
          ),
        ),
      );
    }

    return NavigationWrapper(
      selectedIndex: 0, // Home tab context since users navigate here from country pages
      child: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                _buildUniversityHeader(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, // Further reduced to prevent any overflow
                      vertical: AppConstants.spaceM,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUniversityDescription(),
                        const SizedBox(height: AppConstants.spaceL),
                        _buildUniversityStats(),
                        const SizedBox(height: AppConstants.spaceXL),
                        _buildScholarshipsSection(),
                        const SizedBox(height: AppConstants.spaceXL),
                        _buildCoursesSection(),
                        const SizedBox(height: AppConstants.spaceXL),
                        _buildApplySection(),
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

  Widget _buildUniversityHeader() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                image: university!.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(university!.imageUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Fallback to default image
                          print('Failed to load university image: $exception');
                        },
                      )
                    : null,
                gradient: university!.imageUrl.isEmpty
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      )
                    : null,
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceM,
                      vertical: AppConstants.spaceS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: AppConstants.spaceXS),
                        Text(
                          'Top University',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceM),
                  Text(
                    university!.name,
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            // Implement share functionality
          },
        ),
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? AppColors.cta : Colors.white,
          ),
          onPressed: _toggleFavorite,
        ),
      ],
    );
  }

  Widget _buildUniversityDescription() {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceS),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  Icons.school_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About ${university!.name}',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${university!.establishedYear.isNotEmpty ? "Founded ${university!.establishedYear}" : ""} • ${university!.location}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceM),
          Text(
            university!.description.isNotEmpty 
                ? university!.description 
                : 'One of the world\'s leading universities, renowned for academic excellence and research innovation.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversityStats() {
    return Row(
      children: [
        if (university!.worldRanking > 0) ...[
          Expanded(
            child: _buildStatCard(
              icon: Icons.emoji_events,
              value: '#${university!.worldRanking}',
              label: 'World Ranking',
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: AppConstants.spaceM),
        ],
        if (university!.totalStudents > 0) ...[
          Expanded(
            child: _buildStatCard(
              icon: Icons.people,
              value: _formatNumber(university!.totalStudents),
              label: 'Students',
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: AppConstants.spaceM),
        ],
        if (university!.internationalPercentage > 0) ...[
          Expanded(
            child: _buildStatCard(
              icon: Icons.public,
              value: '${university!.internationalPercentage.toInt()}%',
              label: 'International',
              color: AppColors.success,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScholarshipsSection() {
    final filteredScholarships = _getFilteredScholarships();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Available Scholarships',
          icon: Icons.card_giftcard_outlined,
        ),
        const SizedBox(height: AppConstants.spaceM),
        
        // Filter Tags
        _buildScholarshipFilters(),
        const SizedBox(height: AppConstants.spaceM),
        
        // Scholarships List
        if (filteredScholarships.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Center(
              child: Text(
                'No scholarships available',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredScholarships.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 300,
                  margin: EdgeInsets.only(
                    right: index < filteredScholarships.length - 1 ? AppConstants.spaceM : 0,
                  ),
                  child: ScholarshipCard(
                    scholarship: filteredScholarships[index],
                    onTap: () {
                      _showScholarshipDetails(filteredScholarships[index]);
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCoursesSection() {
    final filteredCourses = _getFilteredCourses();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Popular Courses',
          icon: Icons.menu_book_outlined,
        ),
        const SizedBox(height: AppConstants.spaceM),
        
        // Filter Tags
        _buildCourseFilters(),
        const SizedBox(height: AppConstants.spaceM),
        
        // Courses List
        if (filteredCourses.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Center(
              child: Text(
                'No courses available',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          Column(
            children: filteredCourses.take(10).map((course) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.spaceM),
                child: DynamicCourseCard(
                  course: course,
                  onTap: () {
                    _showCourseDetailsDialog(course);
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildApplySection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Apply?',
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            'Start your application process today',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppConstants.spaceL),
          PrimaryButton(
            text: 'Apply Now',
            onPressed: () async {
              if (university?.websiteUrl != null && university!.websiteUrl.isNotEmpty) {
                final url = university!.websiteUrl;
                try {
                  final uri = Uri.parse(url);
                  bool launched = false;
                  
                  // Try different launch modes for better mobile compatibility
                  if (await canLaunchUrl(uri)) {
                    // First try: External application (opens in browser app)
                    try {
                      launched = await launchUrl(
                        uri, 
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      print('External application launch failed: $e');
                    }
                    
                    // Fallback: Platform default
                    if (!launched) {
                      try {
                        launched = await launchUrl(
                          uri, 
                          mode: LaunchMode.platformDefault,
                        );
                      } catch (e) {
                        print('Platform default launch failed: $e');
                      }
                    }
                  }
                  
                  if (!launched) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not open university website'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  print('Error launching URL: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error opening university website'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('University website URL not available'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            backgroundColor: Colors.white,
            textColor: AppColors.primary,
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  Widget _buildScholarshipFilters() {
    return Wrap(
      spacing: AppConstants.spaceS,
      runSpacing: AppConstants.spaceS,
      children: [
        _buildFilterChip(
          'All Types',
          _selectedScholarshipFilter == null,
          () => setState(() => _selectedScholarshipFilter = null),
        ),
        _buildFilterChip(
          'International',
          _selectedScholarshipFilter == 'International',
          () => setState(() => _selectedScholarshipFilter = 'International'),
        ),
        _buildFilterChip(
          'Merit-based',
          _selectedScholarshipFilter == 'Merit',
          () => setState(() => _selectedScholarshipFilter = 'Merit'),
        ),
        _buildFilterChip(
          'Full Funding',
          _selectedScholarshipFilter == 'Full Funding',
          () => setState(() => _selectedScholarshipFilter = 'Full Funding'),
        ),
        _buildFilterChip(
          'Partial Funding',
          _selectedScholarshipFilter == 'Partial Funding',
          () => setState(() => _selectedScholarshipFilter = 'Partial Funding'),
        ),
      ],
    );
  }

  Widget _buildCourseFilters() {
    return Wrap(
      spacing: AppConstants.spaceS,
      runSpacing: AppConstants.spaceS,
      children: [
        _buildFilterChip(
          'All Courses',
          _selectedCourseFilter == null,
          () => setState(() => _selectedCourseFilter = null),
        ),
        _buildFilterChip(
          'Undergraduate',
          _selectedCourseFilter == 'Undergraduate',
          () => setState(() => _selectedCourseFilter = 'Undergraduate'),
        ),
        _buildFilterChip(
          'Masters',
          _selectedCourseFilter == 'Masters',
          () => setState(() => _selectedCourseFilter = 'Masters'),
        ),
        _buildFilterChip(
          'Computer Science',
          _selectedCourseFilter == 'Computer Science',
          () => setState(() => _selectedCourseFilter = 'Computer Science'),
        ),
        _buildFilterChip(
          'Engineering',
          _selectedCourseFilter == 'Engineering',
          () => setState(() => _selectedCourseFilter = 'Engineering'),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceM,
          vertical: AppConstants.spaceS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  List<Scholarship> _getFilteredScholarships() {
    List<Scholarship> filtered = scholarships;
    
    if (_selectedScholarshipFilter != null) {
      filtered = filtered.where((s) => 
        s.type.toLowerCase().contains(_selectedScholarshipFilter!.toLowerCase()) ||
        s.weightage.toLowerCase().contains(_selectedScholarshipFilter!.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  List<Course> _getFilteredCourses() {
    List<Course> filtered = courses;
    
    if (_selectedCourseFilter != null) {
      filtered = filtered.where((c) => 
        c.level.toLowerCase().contains(_selectedCourseFilter!.toLowerCase()) ||
        c.fieldOfStudy.toLowerCase().contains(_selectedCourseFilter!.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
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
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceS),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXS),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCourseDetailsDialog(Course course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.name,
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                
                // Course details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildCourseDetailRow('Level:', course.level),
                      _buildCourseDetailRow('Duration:', course.duration),
                      _buildCourseDetailRow('Field of Study:', course.fieldOfStudy),
                      _buildCourseDetailRow('Intake:', course.intake),
                      _buildCourseDetailRow('Annual Fee:', course.annualFee),
                      _buildCourseDetailRow('Popularity:', 'High'), // You can make this dynamic
                    ],
                  ),
                ),
                
                // Visit Course Page button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close dialog first
                        
                        // Open course URL if available
                        await _launchCourseUrl(course.url);
                      },
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                      label: const Text(
                        'Visit Course Page',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
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

  Widget _buildCourseDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchCourseUrl(String url) async {
    try {
      // Check if URL is empty or null
      if (url.isEmpty) {
        _showErrorSnackBar('Course page URL not available');
        return;
      }

      // Clean and validate URL
      String cleanUrl = url.trim();
      
      // Add protocol if missing
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }

      // Parse URL to validate format
      final uri = Uri.tryParse(cleanUrl);
      if (uri == null) {
        _showErrorSnackBar('Invalid course page URL format');
        return;
      }

      // Launch URL directly (skip canLaunchUrl as it can be unreliable)
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      _showErrorSnackBar('Error opening course page');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showScholarshipDetails(Scholarship scholarship) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16 : 24),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width < 600 
                  ? MediaQuery.of(context).size.width - 32 
                  : 600,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            scholarship.name,
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close, color: AppColors.textSecondary),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Offered by
                          Text(
                            'Offered by ${scholarship.universityName}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Tags section
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // Degree level chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                ),
                                child: Text(
                                  scholarship.degreeType.isNotEmpty ? scholarship.degreeType : 'Masters',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              
                              // Funding type chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                                ),
                                child: Text(
                                  scholarship.weightage.isNotEmpty ? scholarship.weightage : 'Full Funding',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              
                              // Type chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                                ),
                                child: Text(
                                  scholarship.type.isNotEmpty ? scholarship.type : 'International',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Description
                          if (scholarship.description.isNotEmpty) ...[
                            Text(
                              scholarship.description,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          // Information grid
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundCard,
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              children: [
                                // Fields of study
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.school, size: 20, color: AppColors.textSecondary),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Fields of Study',
                                            style: AppTextStyles.labelMedium.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: ['All Disciplines', 'Liberal Arts', 'Sciences', 'Social Sciences']
                                                .map((field) => Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.backgroundTertiary,
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: AppColors.borderLight),
                                                      ),
                                                      child: Text(
                                                        field,
                                                        style: AppTextStyles.labelSmall.copyWith(
                                                          color: AppColors.textSecondary,
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Amount and deadline
                                Row(
                                  children: [
                                    Icon(Icons.monetization_on, size: 20, color: AppColors.textSecondary),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Amount',
                                            style: AppTextStyles.labelMedium.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '£18,180/year + stipend',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        scholarship.deadline.isNotEmpty ? scholarship.deadline : 'Ongoing',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Eligibility Requirements
                          Text(
                            'Eligibility Requirements',
                            style: AppTextStyles.h5.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (scholarship.eligibility.isNotEmpty)
                            ...scholarship.eligibility.split(',').map((requirement) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('• ', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                                      Expanded(
                                        child: Text(
                                          requirement.trim(),
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                          else
                            ...[
                              'Outstanding academic achievement',
                              'Leadership potential and commitment to service',
                              'Age between 18-24 years',
                              'Citizens of eligible countries',
                              'English language proficiency'
                            ].map((requirement) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('• ', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                                      Expanded(
                                        child: Text(
                                          requirement,
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          const SizedBox(height: 20),
                          
                          // Application process
                          Text(
                            'Application Process',
                            style: AppTextStyles.h5.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Submit online application through scholarship portal. Requires academic transcripts, personal statement, letters of recommendation, and interview.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom button section
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'Visit Official Page',
                        icon: Icons.open_in_new,
                        isExpanded: true,
                        onPressed: scholarship.applicationUrl.isNotEmpty ? () async {
                          final url = scholarship.applicationUrl;
                          try {
                            final uri = Uri.parse(url);
                            bool launched = await launchUrl(
                              uri,
                              mode: LaunchMode.platformDefault,
                            );
                            if (!launched) {
                              // Try alternative launch mode
                              launched = await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                            if (!launched) {
                              throw 'Could not launch URL';
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not open the scholarship link: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        } : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
