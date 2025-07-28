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
import '../widgets/scholarship_filter_tags.dart';
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

class _OxfordUniversityPageState extends State<OxfordUniversityPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Scholarship filter state
  String _selectedType = 'All Types';
  String _selectedFunding = 'All Funding';
  String _selectedDegreeLevel = 'All Levels';
  String _selectedDeadline = 'All Deadlines';

  // Oxford scholarship data with comprehensive details
  final List<Map<String, dynamic>> _oxfordScholarships = [
    {
      'title': 'Rhodes Scholarship',
      'offeredBy': 'Rhodes Trust',
      'description': 'The world\'s oldest international scholarship programme, enabling outstanding young people from around the world to study at the University of Oxford.',
      'type': 'International',
      'funding': 'Full',
      'degreeLevel': 'Masters',
      'deadline': 'Ongoing',
      'amount': '£18,180/year + stipend',
      'fieldsOfStudy': ['All Disciplines', 'Liberal Arts', 'Sciences', 'Social Sciences'],
      'eligibility': [
        'Outstanding academic achievement',
        'Leadership potential and commitment to service',
        'Age between 18-24 years',
        'Citizens of eligible countries',
        'English language proficiency'
      ],
      'applicationProcess': 'Submit online application through Rhodes Trust portal. Requires academic transcripts, personal statement, letters of recommendation, and interview.',
      'deadlineStatus': 'Ongoing',
      'url': 'https://www.rhodeshouse.ox.ac.uk/scholarships/the-rhodes-scholarship/',
    },
    {
      'title': 'Clarendon Fund',
      'offeredBy': 'University of Oxford',
      'description': 'Oxford University\'s premier graduate scholarship scheme, offering around 140 new scholarships every year.',
      'type': 'International',
      'funding': 'Full',
      'degreeLevel': 'Masters',
      'deadline': 'Upcoming',
      'amount': 'Full tuition + £17,668 stipend',
      'fieldsOfStudy': ['All Graduate Programs', 'Research', 'Taught Masters'],
      'eligibility': [
        'Outstanding academic merit',
        'Potential for leadership and public service',
        'Strong academic references',
        'Clear research proposal (for research degrees)',
        'Meet Oxford admission requirements'
      ],
      'applicationProcess': 'Automatic consideration when applying to Oxford graduate programs. No separate application required. Submit university application by January deadline.',
      'deadlineStatus': 'Upcoming',
      'url': 'https://www.ox.ac.uk/clarendon',
    },
    {
      'title': 'Reach Oxford Scholarship',
      'offeredBy': 'University of Oxford',
      'description': 'For students from low-income countries who, for political or financial reasons, or because suitable educational facilities do not exist, cannot study for a degree in their own countries.',
      'type': 'International',
      'funding': 'Full',
      'degreeLevel': 'Bachelors',
      'deadline': 'Upcoming',
      'amount': 'Full tuition + living costs',
      'fieldsOfStudy': ['Undergraduate Programs', 'Liberal Arts', 'Sciences'],
      'eligibility': [
        'From low-income developing countries',
        'Cannot study in home country due to circumstances',
        'Demonstrate financial need',
        'Outstanding academic potential',
        'Strong motivation and commitment'
      ],
      'applicationProcess': 'Submit UCAS application for Oxford by October deadline. Complete additional Reach Oxford application form with supporting documents.',
      'deadlineStatus': 'Upcoming',
      'url': 'https://www.ox.ac.uk/admissions/undergraduate/fees-and-funding/oxford-support/reach-oxford-scholarship',
    },
    {
      'title': 'Weidenfeld-Hoffmann Scholarships',
      'offeredBy': 'Weidenfeld-Hoffmann Trust',
      'description': 'Full scholarships for graduate students who have the potential to become leaders in government, business, or civil society in their home countries.',
      'type': 'International',
      'funding': 'Full',
      'degreeLevel': 'Masters',
      'deadline': 'Ongoing',
      'amount': 'Full tuition + £17,668 stipend',
      'fieldsOfStudy': ['Public Policy', 'Economics', 'International Relations', 'Development Studies'],
      'eligibility': [
        'From developing countries',
        'Leadership potential in public service',
        'Commitment to returning home after studies',
        'Strong academic background',
        'Clear career goals in public sector'
      ],
      'applicationProcess': 'Apply through Oxford\'s graduate application system. Complete leadership programme application including essays on leadership experience and future goals.',
      'deadlineStatus': 'Ongoing',
      'url': 'https://www.ox.ac.uk/admissions/graduate/fees-and-funding/fees-funding-and-scholarship-search/weidenfeld-hoffmann-scholarships-and-leadership-programme',
    },
    {
      'title': 'Simon & June Li Scholarship',
      'offeredBy': 'Li Ka Shing Foundation',
      'description': 'Supporting students from developing countries who would not otherwise be able to afford to study at Oxford.',
      'type': 'International',
      'funding': 'Partial',
      'degreeLevel': 'Masters',
      'deadline': 'Ongoing',
      'amount': '£10,000 - £15,000',
      'fieldsOfStudy': ['All Graduate Programs', 'Preferably STEM Fields'],
      'eligibility': [
        'From developing countries in Asia',
        'Demonstrate financial need',
        'Academic excellence',
        'Commitment to development in home country',
        'Previous work experience preferred'
      ],
      'applicationProcess': 'Submit graduate application to Oxford. Complete separate funding application through Oxford funding portal with financial documentation.',
      'deadlineStatus': 'Ongoing',
      'url': 'https://governance.admin.ox.ac.uk/legislation/simon-and-june-li-scholarship-fund',
    },
    {
      'title': 'Hulme Undergraduate Scholarship',
      'offeredBy': 'University of Oxford',
      'description': 'Financial assistance for UK students from backgrounds with little or no tradition of university education.',
      'type': 'Domestic',
      'funding': 'Partial',
      'degreeLevel': 'Bachelors',
      'deadline': 'Upcoming',
      'amount': '£4,000/year',
      'fieldsOfStudy': ['All Undergraduate Programs'],
      'eligibility': [
        'UK residents',
        'First-generation university students',
        'From low-income families',
        'Academic potential',
        'Meet Oxford admission requirements'
      ],
      'applicationProcess': 'Apply through UCAS for Oxford admission. Complete Oxford Bursary application with household income documentation.',
      'deadlineStatus': 'Upcoming',
      'url': 'https://www.ox.ac.uk/admissions/undergraduate/fees-and-funding/oxford-support',
    },
    {
      'title': 'Moritz-Heyman Scholarship',
      'offeredBy': 'Moritz-Heyman Foundation',
      'description': 'For outstanding students pursuing graduate studies who are committed to using their education to improve the lives of others.',
      'type': 'International',
      'funding': 'Full',
      'degreeLevel': 'PhD',
      'deadline': 'Upcoming',
      'amount': 'Full tuition + stipend',
      'fieldsOfStudy': ['Social Impact Research', 'Public Health', 'Development Studies', 'Education'],
      'eligibility': [
        'Commitment to social impact',
        'Outstanding academic record',
        'Demonstrated leadership in community service',
        'Clear research proposal with social benefit',
        'Previous work in relevant field'
      ],
      'applicationProcess': 'Apply for Oxford DPhil program. Submit separate Moritz-Heyman application including essays on social impact goals and research proposal.',
      'deadlineStatus': 'Upcoming',
      'url': 'https://www.ox.ac.uk/admissions/graduate/fees-and-funding',
    },
    {
      'title': 'Hill Foundation Scholarship',
      'offeredBy': 'Hill Foundation',
      'description': 'Enabling intellectually outstanding students from Russia and other countries of the former Soviet Union to pursue graduate studies at leading universities.',
      'type': 'International',
      'funding': 'Full',
      'degreeLevel': 'Masters',
      'deadline': 'Closed',
      'amount': 'Full tuition + living allowance',
      'fieldsOfStudy': ['All Graduate Programs', 'Preferably Academic Research'],
      'eligibility': [
        'Citizens of former Soviet Union countries',
        'Exceptional academic achievement',
        'Commitment to returning home',
        'Leadership potential',
        'Financial need'
      ],
      'applicationProcess': 'Apply through Hill Foundation portal. Requires Oxford admission offer, academic transcripts, essays, and interviews.',
      'deadlineStatus': 'Closed',
      'url': 'https://www.ox.ac.uk/admissions/graduate/fees-and-funding',
    },
  ];

  // Course data
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

  // Scholarship filtering methods
  List<Map<String, dynamic>> get _filteredScholarships {
    List<Map<String, dynamic>> scholarships = _oxfordScholarships;
    
    if (_selectedType != 'All Types') {
      scholarships = scholarships.where((s) => 
        s['type']?.toString().toLowerCase() == _selectedType.toLowerCase()
      ).toList();
    }
    
    if (_selectedFunding != 'All Funding') {
      scholarships = scholarships.where((s) => 
        s['funding']?.toString().toLowerCase() == _selectedFunding.toLowerCase()
      ).toList();
    }
    
    if (_selectedDegreeLevel != 'All Levels') {
      scholarships = scholarships.where((s) => 
        s['degreeLevel']?.toString().toLowerCase() == _selectedDegreeLevel.toLowerCase()
      ).toList();
    }
    
    if (_selectedDeadline != 'All Deadlines') {
      scholarships = scholarships.where((s) => 
        s['deadline']?.toString().toLowerCase() == _selectedDeadline.toLowerCase()
      ).toList();
    }
    
    return scholarships;
  }

  void _onTypeChanged(String value) {
    setState(() {
      _selectedType = value;
    });
  }

  void _onFundingChanged(String value) {
    setState(() {
      _selectedFunding = value;
    });
  }

  void _onDegreeLevelChanged(String value) {
    setState(() {
      _selectedDegreeLevel = value;
    });
  }

  void _onDeadlineChanged(String value) {
    setState(() {
      _selectedDeadline = value;
    });
  }

  void _clearScholarshipFilters() {
    setState(() {
      _selectedType = 'All Types';
      _selectedFunding = 'All Funding';
      _selectedDegreeLevel = 'All Levels';
      _selectedDeadline = 'All Deadlines';
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      
                      // Scholarship Filter Tags
                      ScholarshipFilterTags(
                        selectedType: _selectedType,
                        selectedFunding: _selectedFunding,
                        selectedDegreeLevel: _selectedDegreeLevel,
                        selectedDeadline: _selectedDeadline,
                        onTypeChanged: _onTypeChanged,
                        onFundingChanged: _onFundingChanged,
                        onDegreeLevelChanged: _onDegreeLevelChanged,
                        onDeadlineChanged: _onDeadlineChanged,
                        onClearFilters: _clearScholarshipFilters,
                      ),
                      
                      const SizedBox(height: AppConstants.spaceM),
                      
                      // Filtered Scholarships List
                      SizedBox(
                        height: 200,
                        child: _filteredScholarships.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.card_giftcard_outlined,
                                      size: 48,
                                      color: AppColors.textTertiary,
                                    ),
                                    const SizedBox(height: AppConstants.spaceS),
                                    Text(
                                      'No scholarships match your filters',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                    const SizedBox(height: AppConstants.spaceS),
                                    TextButton(
                                      onPressed: _clearScholarshipFilters,
                                      child: Text(
                                        'Clear Filters',
                                        style: AppTextStyles.labelMedium.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceS),
                                itemCount: _filteredScholarships.length,
                                separatorBuilder: (context, index) => const SizedBox(
                                  width: AppConstants.spaceM,
                                ),
                                itemBuilder: (context, index) {
                                  final scholarship = _filteredScholarships[index];
                                  return ScholarshipCard(
                                    title: scholarship['title']!,
                                    onTap: () => _viewScholarship(scholarship),
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

void _viewScholarship(Map<String, dynamic> scholarship) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 700,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          scholarship['title'] ?? '',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Offered by
                  Text(
                    'Offered by ${scholarship['offeredBy'] ?? 'University of Oxford'}',
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
                          scholarship['degreeLevel'] ?? '',
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
                          '${scholarship['funding']} Funding',
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
                          scholarship['type'] ?? '',
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
                  Text(
                    scholarship['description'] ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
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
                                    children: (scholarship['fieldsOfStudy'] as List<String>? ?? [])
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
                                    scholarship['amount'] ?? 'Amount varies',
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
                                color: scholarship['deadlineStatus'] == 'Upcoming' 
                                    ? AppColors.success.withOpacity(0.1)
                                    : scholarship['deadlineStatus'] == 'Ongoing'
                                        ? AppColors.warning.withOpacity(0.1)
                                        : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                scholarship['deadlineStatus'] ?? 'Check Website',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: scholarship['deadlineStatus'] == 'Upcoming' 
                                      ? AppColors.success
                                      : scholarship['deadlineStatus'] == 'Ongoing'
                                          ? AppColors.warning
                                          : AppColors.error,
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
                  
                  // Eligibility
                  Text(
                    'Eligibility Requirements',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(scholarship['eligibility'] as List<String>? ?? [])
                      .map((requirement) => Padding(
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
                          ))
                      .toList(),
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
                    scholarship['applicationProcess'] ?? 'Please visit the official website for application details.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Official link button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final url = scholarship['url'];
                        if (url != null && url.isNotEmpty) {
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(
                              Uri.parse(url),
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.open_in_new, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Visit Official Page',
                            style: AppTextStyles.labelLarge.copyWith(
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
          ),
        ),
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
}