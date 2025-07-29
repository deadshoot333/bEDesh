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

void showCourseDetailsPopup(BuildContext context, Map<String, String> course) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/en/thumb/b/b0/Oxford_University_Coat_Of_Arms.svg/1200px-Oxford_University_Coat_Of_Arms.svg.png',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course['name'] ?? '',
                      style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Level: ${course['level']}', style: AppTextStyles.bodySmall),
                  Text('Duration: ${course['duration']}', style: AppTextStyles.bodySmall),
                  Text('Intake: ${course['availability']}', style: AppTextStyles.bodySmall),
                  Text('Category: ${course['category']}', style: AppTextStyles.bodySmall),
                  Text('Popularity: ${course['popularity']}', style: AppTextStyles.bodySmall),
                  const Divider(height: 24),
                  Text(
                    course['description'] ?? '',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20),
                  if (course['url'] != null)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: const Text("Visit Course Page"),
                      onPressed: () async {
                        final url = Uri.parse(course['url']!);
                        if (await canLaunchUrl(url)) {
                          launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
class HarvardUniversityDetailsPage extends StatefulWidget {
 
  @override
  
  State<HarvardUniversityDetailsPage> createState() =>  _HarvardUniversityDetailsPageState(
    
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

class  _HarvardUniversityDetailsPageState extends State<HarvardUniversityDetailsPage>
    with TickerProviderStateMixin {

 String? selectedLevel;
String? selectedCategory;
String? selectedSession;

List<Map<String, String>> get filteredCourses {
  return courses.where((course) {
    final matchesLevel = selectedLevel == null || course['level'] == selectedLevel;
    final matchesCategory = selectedCategory == null || course['category'] == selectedCategory;
    final matchesSession = selectedSession == null || course['availability'] == selectedSession;
    return matchesLevel && matchesCategory && matchesSession;
  }).toList();
}



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
  'Harvard Financial Aid Initiative': {
    'description':
        'Provides need-based financial aid to undergraduate students. Families earning less than 85,000 may pay nothing.',
    'url': 'https://college.harvard.edu/financial-aid',
  },
  'Harvard International Office Scholarships': {
    'description':
        'Offers a limited number of scholarships and fellowships for international students from select countries.',
    'url': 'https://www.hio.harvard.edu/scholarships-international-students',
  },
  'Kennedy Memorial Trust Scholarship': {
    'description':
        'Funds postgraduate study at Harvard for UK citizens, covering full tuition and living expenses.',
    'url': 'https://www.kennedytrust.org.uk/',
  },
  'GSAS Merit Fellowship': {
    'description':
        'Graduate School of Arts and Sciences offers merit-based fellowships for top graduate students.',
    'url': 'https://gsas.harvard.edu/financial-support/fellowships',
  },
  'Harvard Presidential Scholars Program': {
    'description':
        'Provides full funding to PhD students based on academic excellence and leadership potential.',
    'url': 'https://gsas.harvard.edu/financial-support/presidential-scholars',
  },
  'Fulbright Foreign Student Program': {
    'description':
        'Supports international students applying for graduate study in the U.S., including tuition and living costs.',
    'url': 'https://foreign.fulbrightonline.org/',
  },
};


  

final List<Map<String, String>> courses = [
    {
      'name': 'BSc Computer Science',
      'level': 'Bachelor',
      'category': 'Engineering',
      'duration': '3 years',
      'availability': 'Spring',
      'popularity': 'High',
      'url': 'https://college.harvard.edu/academics/concentrations/computer-science',
      'description':
          'The BSc in Computer Science at Oxford covers algorithms, machine learning, databases, systems architecture, and more. Students gain theoretical understanding and practical experience in software design, preparing for high-demand roles in tech and academia.',
    },
    {
      'name': 'MSc Data Science',
      'level': 'Masters',
      'category': 'Engineering',
      'duration': '1 year',
      'availability': 'Fall',
      'popularity': 'Very High',
      'url': 'https://seas.harvard.edu/academics/graduate-programs/master-science-data-science',
      'description':
          'This program offers hands-on training in statistics, machine learning, and programming, alongside critical social science thinking. Graduates are equipped to lead in data-driven research, business intelligence, and public policy innovation.',
    },
    {
      'name': 'PhD in Artificial Intelligence',
      'level': 'PhD',
      'category': 'Engineering',
      'duration': '3-4 years',
      'availability': 'Winter',
      'popularity': 'Elite',
      'url': 'https://gsas.harvard.edu/programs-of-study/all/artificial-intelligence',
      'description':
          'Oxford\'s AI doctoral program leads cutting-edge research in deep learning, reinforcement learning, ethical AI, and neural-symbolic systems. It fosters innovation in collaboration with global research centers and AI institutes.',
    },
    {
      'name': 'BA in Law (Jurisprudence)',
      'level': 'Bachelor',
      'category': 'Law',
      'duration': '3 years',
      'availability': 'Fall',
      'popularity': 'High',
      'url': 'https://hls.harvard.edu/jd-program/',
      'description':
          'The BA in Law is a rigorous program focusing on legal reasoning, constitutional law, and international human rights. It prepares students for global legal practice and offers opportunities for mooting, debates, and internships.',
    },
    {
      'name': 'DPhil in Public Policy',
      'level': 'PhD',
      'category': 'Law',
      'duration': '3-4 years',
      'availability': 'Fall',
      'popularity': 'Medium',
      'url': 'https://www.hks.harvard.edu/educational-programs/doctoral-programs/phd-public-policy',
      'description':
          'The DPhil in Public Policy equips students with cross-disciplinary skills in governance, economics, law, and political theory. It supports high-impact research that informs public service leadership and policymaking worldwide.',
    },
    {
      'name': 'BA in Fine Arts',
      'level': 'Bachelor',
      'category': 'Arts',
      'duration': '3 years',
      'availability': 'Spring',
      'popularity': 'Moderate',
      'url': 'https://afvs.fas.harvard.edu/undergraduate-program',
      'description':
          'This studio-based course develops students’ creative voice through painting, sculpture, new media, and theory. Offered by the Ruskin School, it combines historical awareness with experimental practice.',
    },
    {
      'name': 'MSt in English Literature',
      'level': 'Masters',
      'category': 'Arts',
      'duration': '1 year',
      'availability': 'Fall',
      'popularity': 'High',
      'url': 'https://gsas.harvard.edu/programs-study/english',
      'description':
          'A deeply immersive literature program spanning medieval to contemporary periods. Students engage in textual analysis, literary criticism, and prepare for careers in academia, publishing, and education.',
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
                    'Harvard University',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        AssetPaths.harvard,
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
                              onTap: () => _viewScholarship(scholarships[index]), name: '', eligibility: '',
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text('Filter Courses:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
  value: selectedLevel,
  hint: const Text('Level'),
  items: [
    const DropdownMenuItem(value: null, child: Text('Levels')),
    ...['Bachelor', 'Masters', 'PhD'].map((level) {
      return DropdownMenuItem(value: level, child: Text(level));
    }),
  ],
  onChanged: (value) => setState(() => selectedLevel = value),
),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
  value: selectedCategory,
  hint: const Text('Category'),
  items: [
    const DropdownMenuItem(value: null, child: Text('Cateogory')),
    ...['Engineering', 'Arts', 'Law'].map((cat) {
      return DropdownMenuItem(value: cat, child: Text(cat));
    }),
  ],
  onChanged: (value) => setState(() => selectedCategory = value),
),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
  value: selectedSession,
  hint: const Text('Session'),
  items: [
    const DropdownMenuItem(value: null, child: Text('Sessions')),
    ...['Spring', 'Fall', 'Winter'].map((session) {
      return DropdownMenuItem(value: session, child: Text(session));
    }),
  ],
  onChanged: (value) => setState(() => selectedSession = value),
),
        ),
      ],
    ),
    const SizedBox(height: 16),
  ],
),


                      // Popular Courses
                      const SectionHeader(
                        title: 'Popular Courses',
                        icon: Icons.menu_book_outlined,
                      ),
                      const SizedBox(height: AppConstants.spaceM),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredCourses.length,
                        separatorBuilder: (context, index) => const SizedBox(
                          height: AppConstants.spaceM,
                        ),
                        itemBuilder: (context, index) {
                          final course = filteredCourses[index];
                          return CourseCard(
                            name: course['name']!,
                            level: course['level']!,
                            duration: course['duration']!,
                            onTap: () => _viewCourse(course['name']!), courseName: '', fee: '', course: {}, tuitionFee: null, description: null, universityName: '', price: null, rating: null, tags: [], imageUrl: '',
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
  onPressed: () {
    setState(() {
      selectedLevel = null;
      selectedCategory = null;
      selectedSession = null;
    });
  },
  child: Text('Clear Filters'),
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
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spaceM),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with logo
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(course['logo'] ??
                          'https://upload.wikimedia.org/wikipedia/en/e/ea/Oxford_University_Circlet.svg'),
                      radius: 24,
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: Text(
                        course['name'] ?? 'Course Name',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceM),

                // Course Banner or Image (optional)
                if (course['image'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    child: Image.network(
                      course['image']!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                  ),

                const SizedBox(height: AppConstants.spaceM),

                // Description
                Text(
                  course['description'] ??
                      'This course provides students with foundational and advanced knowledge in the subject. Students will learn through lectures, lab sessions, and project-based work.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: AppConstants.spaceM),

                // Info Text
                _infoText('Level', course['level']),
                _infoText('Duration', course['duration']),
                _infoText('Availability', course['availability']),
                _infoText('Popularity', course['popularity']),

                const SizedBox(height: AppConstants.spaceM),

                // Visit Website
                if (course['url'] != null && course['url']!.isNotEmpty)
                  Center(
                    child: PrimaryButton(
                      text: 'Visit Course Page',
                      icon: Icons.open_in_new_outlined,
                      onPressed: () async {
                        final uri = Uri.parse(course['url']!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open the course link.')),
                          );
                        }
                      },
                    ),
                  ),

                const SizedBox(height: AppConstants.spaceM),

                // Close Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Close',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
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


