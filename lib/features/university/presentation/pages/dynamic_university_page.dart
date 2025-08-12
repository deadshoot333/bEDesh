import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/cards/dynamic_course_card.dart';
import '../../../../shared/widgets/cards/scholarship_card.dart';
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

  // Filter states
  String? _selectedCourseLevel;
  String? _selectedCourseField;
  String? _selectedScholarshipType;
  String? _selectedFunding;

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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
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
      );
    }

    if (university == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: const Center(
          child: Text('University not found'),
        ),
      );
    }

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              _buildUniversityHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
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
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {
            // Implement favorite functionality
          },
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
                      // Navigate to scholarship details
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
                    // Navigate to course details
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
            onPressed: () {
              // Open university application URL
              if (university!.websiteUrl.isNotEmpty) {
                // Launch URL
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
          _selectedScholarshipType == null,
          () => setState(() => _selectedScholarshipType = null),
        ),
        _buildFilterChip(
          'International',
          _selectedScholarshipType == 'International',
          () => setState(() => _selectedScholarshipType = 'International'),
        ),
        _buildFilterChip(
          'Merit-based',
          _selectedScholarshipType == 'Merit',
          () => setState(() => _selectedScholarshipType = 'Merit'),
        ),
        _buildFilterChip(
          'Full Funding',
          _selectedFunding == 'Full Funding',
          () => setState(() => _selectedFunding = 'Full Funding'),
        ),
        _buildFilterChip(
          'Partial Funding',
          _selectedFunding == 'Partial Funding',
          () => setState(() => _selectedFunding = 'Partial Funding'),
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
          'All Levels',
          _selectedCourseLevel == null,
          () => setState(() => _selectedCourseLevel = null),
        ),
        _buildFilterChip(
          'Undergraduate',
          _selectedCourseLevel == 'Undergraduate',
          () => setState(() => _selectedCourseLevel = 'Undergraduate'),
        ),
        _buildFilterChip(
          'Masters',
          _selectedCourseLevel == 'Masters',
          () => setState(() => _selectedCourseLevel = 'Masters'),
        ),
        _buildFilterChip(
          'Computer Science',
          _selectedCourseField == 'Computer Science',
          () => setState(() => _selectedCourseField = 'Computer Science'),
        ),
        _buildFilterChip(
          'Engineering',
          _selectedCourseField == 'Engineering',
          () => setState(() => _selectedCourseField = 'Engineering'),
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
    
    if (_selectedScholarshipType != null) {
      filtered = filtered.where((s) => 
        s.type.toLowerCase().contains(_selectedScholarshipType!.toLowerCase())
      ).toList();
    }
    
    if (_selectedFunding != null) {
      filtered = filtered.where((s) => 
        s.weightage.toLowerCase().contains(_selectedFunding!.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  List<Course> _getFilteredCourses() {
    List<Course> filtered = courses;
    
    if (_selectedCourseLevel != null) {
      filtered = filtered.where((c) => 
        c.level.toLowerCase().contains(_selectedCourseLevel!.toLowerCase())
      ).toList();
    }
    
    if (_selectedCourseField != null) {
      filtered = filtered.where((c) => 
        c.fieldOfStudy.toLowerCase().contains(_selectedCourseField!.toLowerCase())
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
}
