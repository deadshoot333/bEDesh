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
  {
    'name': 'BSc Computer Science',
    'level': 'Undergraduate',
    'duration': '3 years',
    'availability': 'September',
    'popularity': 'High',
    'url': 'https://www.swansea.ac.uk/course/computer-science/',
  },
  {
    'name': 'MSc Data Science',
    'level': 'Postgraduate',
    'duration': '1 year',
    'availability': 'September',
    'popularity': 'High',
    'url': 'https://www.swansea.ac.uk/course/data-science-msc/',
  },
  {
    'name': 'MBA Business Administration',
    'level': 'Postgraduate',
    'duration': '1 year',
    'availability': 'January',
    'popularity': 'Medium',
    'url': 'https://www.swansea.ac.uk/course/mba/',
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

  Widget _buildCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Popular Courses',
          icon: Icons.menu_book_outlined,
        ),
        const SizedBox(height: AppConstants.spaceM),
      ListView.separated(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: courses.length,
  separatorBuilder: (context, index) => const SizedBox(height: AppConstants.spaceM),
  itemBuilder: (context, index) {
    final course = courses[index];
    return CourseCard(
      name: course['name']!,
      level: course['level']!,
      duration: course['duration']!,
      onTap: () => _viewCourse(course), courseName: '', fee: '', course: {},
    );
  },
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
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open the scholarship link.')),
                    );
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


 void _viewCourse(Map<String, String> course) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        title: Text(
          course['name']!,
          style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoText('Level', course['level']),
            _infoText('Duration', course['duration']),
            _infoText('Availability', course['availability']),
            _infoText('Popularity', course['popularity']),
            const SizedBox(height: 12),
            if (course['url'] != null)
              InkWell(
                onTap: () async {
                  final uri = Uri.parse(course['url']!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open the course link.')),
                    );
                  }
                },
                child: Text(
                  'Visit Course Page →',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      );
    },
  );
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

  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not open the application link.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnPrimary),
        ),
        backgroundColor: AppColors.error,
      ),
    );
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
