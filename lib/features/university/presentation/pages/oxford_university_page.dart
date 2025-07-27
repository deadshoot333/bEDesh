import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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


class OxfordUniversityPage extends StatefulWidget {
 
  @override
  
  State<OxfordUniversityPage> createState() => _OxfordUniversityPageState(
    
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


final Map<String, Map<String, String>> scholarshipDetails = {
  'Rhodes Scholarship': {
    'description': 'Covers all university and living expenses for international students. Extremely competitive and prestigious.',
    'url': 'https://www.rhodeshouse.ox.ac.uk/scholarships/the-rhodes-scholarship/',
  },
  'Clarendon Fund': {
    'description': 'Provides full tuition and generous living stipends for academically excellent graduate students.',
    'url': 'https://www.ox.ac.uk/clarendon',
  },
  'Reach Oxford Scholarship': {
    'description': 'For students from low-income countries, covers tuition, living, and return airfare.',
    'url': 'https://www.ox.ac.uk/admissions/undergraduate/fees-and-funding/oxford-support/reach-oxford-scholarship',
  },
  'Weidenfeld-Hoffmann': {
    'description': 'Targets emerging leaders and covers full tuition and living costs for graduate programs.',
    'url': 'https://www.ox.ac.uk/admissions/graduate/fees-and-funding/fees-funding-and-scholarship-search/weidenfeld-hoffmann-scholarships-and-leadership-programme',
  },
  'Simon & June Li Scholarship': {
    'description': 'Supports students from developing countries based on financial need and academic merit.',
    'url': 'https://governance.admin.ox.ac.uk/legislation/simon-and-june-li-scholarship-fund',
  },
};

class _OxfordUniversityPageState extends State<OxfordUniversityPage>
    with TickerProviderStateMixin {

      void _launchURL(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not open the link',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Map<String, Map<String, String>> scholarshipDetails = {
  'Rhodes Scholarship': {
    'description': 'Covers all university and living expenses for international students. Extremely competitive and prestigious.',
    'url': 'https://www.rhodeshouse.ox.ac.uk/scholarships/the-rhodes-scholarship/',
  },
  'Clarendon Fund': {
    'description': 'Provides full tuition and generous living stipends for academically excellent graduate students.',
    'url': 'https://www.ox.ac.uk/clarendon',
  },
  'Reach Oxford Scholarship': {
    'description': 'For students from low-income countries, covers tuition, living, and return airfare.',
    'url': 'https://www.ox.ac.uk/admissions/undergraduate/fees-and-funding/oxford-support/reach-oxford-scholarship',
  },
  'Weidenfeld-Hoffmann': {
    'description': 'Targets emerging leaders and covers full tuition and living costs for graduate programs.',
    'url': 'https://www.ox.ac.uk/admissions/graduate/fees-and-funding/fees-funding-and-scholarship-search/weidenfeld-hoffmann-scholarships-and-leadership-programme',
  },
  'Simon & June Li Scholarship': {
    'description': 'Supports students from developing countries based on financial need and academic merit.',
    'url': 'https://governance.admin.ox.ac.uk/legislation/simon-and-june-li-scholarship-fund',
  },
};

  final List<Map<String, String>> courses = [
  {
    'name': 'BSc Computer Science',
    'level': 'Undergraduate',
    'duration': '3 years',
    'availability': 'Spring',
    'popularity': 'High',
    'url': 'https://www.ox.ac.uk/admissions/undergraduate/courses/course-listing/computer-science',
  },
  {
    'name': 'MBA Business',
    'level': 'Postgraduate',
    'duration': '2 years',
    'availability': 'Fall',
    'popularity': 'Very High',
    'url': 'https://www.sbs.ox.ac.uk/programmes/mbas/oxford-executive-mba?utm_source=google&utm_medium=cpc&utm_campaign=PPC_Conversion_EMBA_EMBA_google_PMax_UK-North-America-Africa-MENA-Asia-Pacific-Europe_Custom_Generic&gad_source=1&gad_campaignid=22586827665&gbraid=0AAAAADBiMDqukZ5snmFcFKePGoss__jCa&gclid=Cj0KCQjw-ZHEBhCxARIsAGGN96JShfYbZ8TZRGgM4IkcRbuPLf_fEP8uV0FA9CO4XjFtmYHYk_u29UoaAlCdEALw_wcB',
  },
  {
    'name': 'Law LLB',
    'level': 'Undergraduate',
    'duration': '3 years',
    'availability': 'Fall',
    'popularity': 'Medium',
    'url': 'https://www.ox.ac.uk/admissions/undergraduate/courses/course-listing/law-jurisprudence',
  },
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
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
    final List<String> scholarships = scholarshipDetails.keys.toList();
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // Hero App Bar
              SliverAppBar(
                expandedHeight: 320,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Oxford University',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        AssetPaths.oxford,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          );
                        },
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
                      // University Logo/Badge
                      Positioned(
                        top: 100,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceM,
                            vertical: AppConstants.spaceS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textOnPrimary.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: AppColors.warning,
                                size: 16,
                              ),
                              const SizedBox(width: AppConstants.spaceXS),
                              Text(
                                'Top University',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textPrimary,
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
                actions: [
                  IconButton(
                    onPressed: _shareUniversity,
                    icon: const Icon(
                      Icons.share_outlined,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleFavorite,
                    icon: const Icon(
                      Icons.favorite_border,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceS),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // University Description
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
                                        'About Oxford',
                                        style: AppTextStyles.h4.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Founded 1096 • Oxford, England',
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
                              'Founded in 1096, the University of Oxford is the oldest university in the English-speaking world. It consistently ranks among the world\'s top universities and offers an unparalleled academic and cultural experience in the historic city of Oxford.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceL),

                      // University Statistics
                      Row(
                        children: [
                          Expanded(
                            child: UniversityStatCard(
                              icon: Icons.emoji_events_outlined,
                              value: '#1',
                              label: 'World Ranking',
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          Expanded(
                            child: UniversityStatCard(
                              icon: Icons.people_outline,
                              value: '24K',
                              label: 'Students',
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          Expanded(
                            child: UniversityStatCard(
                              icon: Icons.public_outlined,
                              value: '40%',
                              label: 'International',
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      // Available Scholarships
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
                          separatorBuilder: (context, index) => const SizedBox(
                            width: AppConstants.spaceM,
                          ),
                          itemBuilder: (context, index) {
                            return ScholarshipCard(
                              title: scholarships[index],
                              onTap: () => _viewScholarship(scholarships[index]),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      // Popular Courses
                      const SectionHeader(
                        title: 'Popular Courses',
                        icon: Icons.menu_book_outlined,
                      ),
                      const SizedBox(height: AppConstants.spaceM),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: courses.length,
                        separatorBuilder: (context, index) => const SizedBox(
                          height: AppConstants.spaceM,
                        ),
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          return CourseCard(
                            name: course['name']!,
                            level: course['level']!,
                            duration: course['duration']!,
                            onTap: () => _viewCourse(course['name']!), courseName: '', fee: '',
                          );
                        },
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      // Action Buttons
                   
// New:
Center(
  child: SizedBox(
    width: 200, // adjust width as needed
    child: PrimaryButton(
      text: 'Apply Now',
      icon: Icons.send_outlined,
      onPressed: _applyToUniversity,
    ),
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
    );
  }

 void _shareUniversity() {
  final String message = 'Check out Oxford University! 🎓 https://www.ox.ac.uk/';
  Share.share(message);
}


  void _toggleFavorite() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added Oxford to favorites ❤️',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
      ),
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



void _viewCourse(String courseName) {
  final course = courses.firstWhere((c) => c['name'] == courseName);

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
           InkWell(
  onTap: () async {
    final courseUrl = course['url']!;
    final uri = Uri.parse(courseUrl);

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


 void _applyToUniversity() async {
  final url = 'https://www.ox.ac.uk/admissions/undergraduate/applying-to-oxford'; // Replace with actual apply URL

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
          'More information feature coming soon!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.info,
      ),
    );
  }
  
  
}


