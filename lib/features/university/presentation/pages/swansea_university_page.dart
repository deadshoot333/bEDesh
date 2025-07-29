import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../widgets/university_stat_card.dart';
import '../widgets/scholarship_card.dart';
import '../widgets/course_card.dart';
import '../widgets/course_filter_tags.dart';

class SwanseaUniversityPage extends StatefulWidget {
  const SwanseaUniversityPage({super.key});

  @override
  State<SwanseaUniversityPage> createState() => _SwanseaUniversityPageState();
}

class _SwanseaUniversityPageState extends State<SwanseaUniversityPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Course filter state
  String _selectedField = 'All Fields';
  String _selectedLevel = 'All Levels';
  String _selectedIntake = 'All Intakes';
  String _selectedFeeRange = 'All Fees';

  final Map<String, Map<String, String>> scholarshipDetails = {
  'Swansea International Scholarship': {
    'description': 'Provides financial support for international students demonstrating academic excellence.',
    'url': 'https://www.swansea.ac.uk/international/fees-and-funding/scholarships/',
  },
  'Vice-Chancellor\'s Scholarship': {
    'description': 'Awarded to high-achieving students across various disciplines at Swansea University.',
    'url': 'https://www.swansea.ac.uk/undergraduate/fees-and-funding/scholarships/',
  },
  'Sports Excellence Scholarship': {
    'description': 'Supports talented athletes combining sport and study.',
    'url': 'https://www.swansea.ac.uk/sports-performance/scholarships/',
  },
};
late final List<String> scholarships = scholarshipDetails.keys.toList();



  final List<Map<String, String>> courses = [
    // Computer Science
    {
      'name': 'BSc Computer Science',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Computer Science',
      'intake': 'Fall',
      'fee': '£20,350/year',
      'feeRange': '£15K - £25K',
      'popularity': 'High',
      'description': 'Study programming, algorithms, and software development with industry placement opportunities.',
      'url': 'https://www.swansea.ac.uk/course/computer-science/',
    },
    {
      'name': 'MSc Data Science',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Computer Science',
      'intake': 'Fall',
      'fee': '£22,650/year',
      'feeRange': '£15K - £25K',
      'popularity': 'High',
      'description': 'Advanced data analytics, machine learning, and big data technologies.',
      'url': 'https://www.swansea.ac.uk/course/data-science-msc/',
    },
    {
      'name': 'PhD Computer Science',
      'level': 'PhD',
      'duration': '3-4 years',
      'field': 'Computer Science',
      'intake': 'Fall',
      'fee': '£18,400/year',
      'feeRange': '£15K - £25K',
      'popularity': 'Medium',
      'description': 'Research degree in computer science and technology.',
      'url': 'https://www.swansea.ac.uk/postgraduate/research-degrees/computer-science/',
    },
    // Engineering
    {
      'name': 'BEng Civil Engineering',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Engineering',
      'intake': 'Fall',
      'fee': '£21,200/year',
      'feeRange': '£15K - £25K',
      'popularity': 'High',
      'description': 'Design and construction of infrastructure, roads, and buildings.',
      'url': 'https://www.swansea.ac.uk/course/civil-engineering/',
    },
    {
      'name': 'MEng Aerospace Engineering',
      'level': 'Undergraduate',
      'duration': '4 years',
      'field': 'Engineering',
      'intake': 'Fall',
      'fee': '£21,850/year',
      'feeRange': '£15K - £25K',
      'popularity': 'High',
      'description': 'Design and development of aircraft and spacecraft systems.',
      'url': 'https://www.swansea.ac.uk/course/aerospace-engineering/',
    },
    {
      'name': 'MSc Environmental Engineering',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Engineering',
      'intake': 'Fall',
      'fee': '£22,400/year',
      'feeRange': '£15K - £25K',
      'popularity': 'Medium',
      'description': 'Sustainable engineering solutions for environmental challenges.',
      'url': 'https://www.swansea.ac.uk/course/environmental-engineering/',
    },
    // Business
    {
      'name': 'MBA Business Administration',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Business',
      'intake': 'Spring',
      'fee': '£24,500/year',
      'feeRange': '£15K - £25K',
      'popularity': 'Medium',
      'description': 'Executive leadership and strategic business management.',
      'url': 'https://www.swansea.ac.uk/course/mba/',
    },
    {
      'name': 'BSc Economics',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Business',
      'intake': 'Fall',
      'fee': '£19,650/year',
      'feeRange': '£15K - £25K',
      'popularity': 'Medium',
      'description': 'Economic theory, policy analysis, and financial markets.',
      'url': 'https://www.swansea.ac.uk/course/economics/',
    },
    {
      'name': 'MSc Finance and Investment',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Business',
      'intake': 'Fall',
      'fee': '£23,200/year',
      'feeRange': '£15K - £25K',
      'popularity': 'High',
      'description': 'Corporate finance, investment analysis, and risk management.',
      'url': 'https://www.swansea.ac.uk/course/finance-investment/',
    },
    // Medicine
    {
      'name': 'MBBS Medicine',
      'level': 'Undergraduate',
      'duration': '5 years',
      'field': 'Medicine',
      'intake': 'Fall',
      'fee': '£38,000/year',
      'feeRange': '£35K - £45K',
      'popularity': 'Very High',
      'description': 'Medical degree with clinical training and research opportunities.',
      'url': 'https://www.swansea.ac.uk/course/medicine/',
    },
    {
      'name': 'BSc Health and Social Care',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Medicine',
      'intake': 'Fall',
      'fee': '£20,100/year',
      'feeRange': '£15K - £25K',
      'popularity': 'High',
      'description': 'Comprehensive healthcare and social work training.',
      'url': 'https://www.swansea.ac.uk/course/health-social-care/',
    },
    {
      'name': 'MSc Public Health',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Medicine',
      'intake': 'Fall',
      'fee': '£21,850/year',
      'feeRange': '£15K - £25K',
      'popularity': 'Medium',
      'description': 'Population health, epidemiology, and health policy.',
      'url': 'https://www.swansea.ac.uk/course/public-health/',
    },
    // Law
    {
      'name': 'LLB Law',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Law',
      'intake': 'Fall',
      'fee': '£19,400/year',
      'feeRange': '£15K - £25K',
      'popularity': 'High',
      'description': 'Comprehensive legal education with practical training.',
      'url': 'https://www.swansea.ac.uk/course/law/',
    },
    {
      'name': 'LLM Human Rights Law',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Law',
      'intake': 'Fall',
      'fee': '£21,200/year',
      'feeRange': '£15K - £25K',
      'popularity': 'Medium',
      'description': 'Specialized study in international human rights law.',
      'url': 'https://www.swansea.ac.uk/course/human-rights-law/',
    },
    // Psychology
    {
      'name': 'BSc Psychology',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Psychology',
      'intake': 'Fall',
      'fee': '£19,850/year',
      'feeRange': '£15K - £25K',
      'popularity': 'High',
      'description': 'Scientific study of mind and behavior with research opportunities.',
      'url': 'https://www.swansea.ac.uk/course/psychology/',
    },
    {
      'name': 'MSc Clinical Psychology',
      'level': 'Masters',
      'duration': '2 years',
      'field': 'Psychology',
      'intake': 'Fall',
      'fee': '£22,100/year',
      'feeRange': '£15K - £25K',
      'popularity': 'Medium',
      'description': 'Advanced clinical practice and therapeutic interventions.',
      'url': 'https://www.swansea.ac.uk/course/clinical-psychology/',
    },
    // Fall/Spring alternative intakes
    {
      'name': 'MSc International Management',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Business',
      'intake': 'Spring',
      'fee': '£22,900/year',
      'feeRange': '£15K - £25K',
      'popularity': 'Medium',
      'description': 'Global business management and cross-cultural leadership.',
      'url': 'https://www.swansea.ac.uk/course/international-management/',
    },
    {
      'name': 'BSc Environmental Science',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Science',
      'intake': 'Fall',
      'fee': '£20,750/year',
      'feeRange': '£15K - £25K',
      'popularity': 'Medium',
      'description': 'Environmental sustainability and conservation science.',
      'url': 'https://www.swansea.ac.uk/course/environmental-science/',
    },
    {
      'name': 'MSc Renewable Energy Engineering',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Engineering',
      'intake': 'Spring',
      'fee': '£23,400/year',
      'feeRange': '£15K - £25K',
      'popularity': 'High',
      'description': 'Sustainable energy technologies and green engineering.',
      'url': 'https://www.swansea.ac.uk/course/renewable-energy/',
    },
  ];

  final List<String> highlights = [
    'High student satisfaction with 83% employability rate',
    'Beautiful bay campus with stunning coastal views',
    'Strong industry connections and placement opportunities',
    'Modern facilities including Egypt Centre and Bay Library',
    'Vibrant student life with 200+ societies and clubs',
    'Research excellence with world-class faculty',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Course filtering methods
  List<Map<String, String>> get filteredCourses {
    List<Map<String, String>> coursesList = courses;
    
    if (_selectedField != 'All Fields') {
      coursesList = coursesList.where((c) => 
        c['field']?.toString().toLowerCase() == _selectedField.toLowerCase()
      ).toList();
    }
    
    if (_selectedLevel != 'All Levels') {
      coursesList = coursesList.where((c) => 
        c['level']?.toString().toLowerCase() == _selectedLevel.toLowerCase()
      ).toList();
    }
    
    if (_selectedIntake != 'All Intakes') {
      coursesList = coursesList.where((c) => 
        c['intake']?.toString().toLowerCase() == _selectedIntake.toLowerCase()
      ).toList();
    }
    
    if (_selectedFeeRange != 'All Fees') {
      coursesList = coursesList.where((c) => 
        c['feeRange']?.toString() == _selectedFeeRange
      ).toList();
    }
    
    return coursesList;
  }

  void _onFieldChanged(String value) {
    setState(() {
      _selectedField = value;
    });
  }

  void _onLevelChanged(String value) {
    setState(() {
      _selectedLevel = value;
    });
  }

  void _onIntakeChanged(String value) {
    setState(() {
      _selectedIntake = value;
    });
  }

  void _onFeeRangeChanged(String value) {
    setState(() {
      _selectedFeeRange = value;
    });
  }

  void _clearCourseFilters() {
    setState(() {
      _selectedField = 'All Fields';
      _selectedLevel = 'All Levels';
      _selectedIntake = 'All Intakes';
      _selectedFeeRange = 'All Fees';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUniversityOverview(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildStatsSection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildHighlightsSection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildScholarshipsSection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildCoursesSection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildActionButtons(),
                    ],
                  ),
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
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Swansea University',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AssetPaths.swanseaUni,
              fit: BoxFit.cover,
            ),
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
            Positioned(
              top: 60,
              right: AppConstants.spaceL,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceM,
                  vertical: AppConstants.spaceS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: AppColors.textOnPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: AppConstants.spaceXS),
                    Text(
                      'Top 300 Global',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUniversityOverview() {
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
                padding: const EdgeInsets.all(AppConstants.spaceM),
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
                      'About Swansea University',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Founded 1920 • Swansea, Wales',
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
            'Founded in 1920, Swansea University is a research-led university located on the stunning coastline of South Wales. Known for its world-class research facilities and beautiful bay campus, Swansea offers an exceptional student experience with high employability rates and strong industry connections.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: UniversityStatCard(
            icon: Icons.emoji_events_outlined,
            value: '296',
            label: 'World Ranking',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: UniversityStatCard(
            icon: Icons.people_outline,
            value: '20K',
            label: 'Students',
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: UniversityStatCard(
            icon: Icons.work_outline,
            value: '83%',
            label: 'Employability',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'University Highlights',
          icon: Icons.star_outline,
        ),
        const SizedBox(height: AppConstants.spaceM),
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
            children: highlights.map((highlight) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, right: AppConstants.spaceM),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        highlight,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildScholarshipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Available Scholarships',
          icon: Icons.card_giftcard_outlined,
        ),
        const SizedBox(height: AppConstants.spaceM),
        SizedBox(
  height: 140,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceS),
    itemCount: scholarships.length,
    separatorBuilder: (context, index) => const SizedBox(width: AppConstants.spaceM),
    itemBuilder: (context, index) {
      return ScholarshipCard(
        title: scholarships[index],
        onTap: () => _viewScholarship(scholarships[index]),
      );
    },
  ),
)

      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'Apply Now',
                onPressed: _applyToUniversity,
                icon: Icons.send_outlined,
              ),
            ),
            const SizedBox(width: AppConstants.spaceM),
           
          ],
        ),
       
      ],
    );
  }

  void _viewScholarship(String scholarship) {
  final data = scholarshipDetails[scholarship];
  final detail = data?['description'] ?? 'Details coming soon.';
  final url = data?['url'];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        title: Text(
          scholarship,
          style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            if (url != null && url.isNotEmpty) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
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
                },
                child: Text(
                  'Visit Scholarship Page →',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}


 void _viewCourse(String courseName) {
    final courseDetail = courses.firstWhere(
      (course) => course['name'] == courseName,
      orElse: () => {},
    );
    if (courseDetail.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(courseDetail['name'] ?? courseName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(courseDetail['description'] ?? ''),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _launchURL(courseDetail['url'] ?? ''),
              child: const Text(
                'Visit Course Page',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Popular Courses',
          icon: Icons.menu_book_outlined,
        ),
        const SizedBox(height: AppConstants.spaceM),
        CourseFilterTags(
          selectedField: _selectedField,
          selectedLevel: _selectedLevel,
          selectedIntake: _selectedIntake,
          selectedFeeRange: _selectedFeeRange,
          onFieldChanged: _onFieldChanged,
          onLevelChanged: _onLevelChanged,
          onIntakeChanged: _onIntakeChanged,
          onFeeRangeChanged: _onFeeRangeChanged,
          onClearFilters: _clearCourseFilters,
        ),
        const SizedBox(height: AppConstants.spaceM),
        filteredCourses.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(AppConstants.spaceL),
                child: Center(
                  child: Text(
                    'No courses match your filter criteria.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredCourses.length,
                itemBuilder: (context, index) {
                  final course = filteredCourses[index];
                  return CourseCard(
                    courseName: course['name']!,
                    duration: course['duration']!,
                    fee: course['fee']!,
                    name: course['name']!,
                    level: course['level']!,
                    onTap: () => _viewCourse(course['name']!),
                  );
                },
              ),
      ],
    );
  }

  void _launchURL(String url) async {
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
            content: Text(
              'Could not open the link: $e',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnPrimary),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildCourseDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceXS),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

 void _applyToUniversity() async {
  final url = 'https://www.swansea.ac.uk/apply/'; // Replace with actual apply URL

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
          content: Text(
            'Could not open the application link: $e',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnPrimary),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

  void _learnMore() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'More university information coming soon!',
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

  
  Widget _infoText(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        text: '$label: ',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        children: [
          TextSpan(
            text: value ?? '-',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

}
