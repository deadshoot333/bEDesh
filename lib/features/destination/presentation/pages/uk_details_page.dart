import 'package:bedesh/features/university/presentation/pages/university_list_page.dart';
import 'package:bedesh/features/university/presentation/pages/dynamic_university_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/cards/circular_university_card.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../widgets/destination_stat_card.dart';
import 'package:share_plus/share_plus.dart';


class UKDetailsPage extends StatefulWidget {
  const UKDetailsPage({super.key});

  @override
  State<UKDetailsPage> createState() => _UKDetailsPageState();
}

class _UKDetailsPageState extends State<UKDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, String>> universities = [
    {'name': 'Oxford University', 'image': AssetPaths.oxford},
    {'name': 'Cambridge University', 'image': AssetPaths.cambridge},
    {'name': 'Imperial College', 'image': AssetPaths.imperial},
    {'name': 'UCL', 'image': AssetPaths.ucl},
  ];

  
  Widget _buildDocumentItem(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntakePeriod(String title, String dates, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dates,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

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
                expandedHeight: 300,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'United Kingdom',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        AssetPaths.uk,
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
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: _shareDestination,
                    icon: const Icon(
                      Icons.share_outlined,
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
                      // Country Info Header
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
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              child: Image.asset(
                                AssetPaths.britishFlag,
                                width: 80,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundSecondary,
                                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                    ),
                                    child: Icon(
                                      Icons.flag_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: AppConstants.spaceM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'United Kingdom',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.spaceXS),
                                  GestureDetector(
                                    onTap: _navigateToUniversities,
                                    child: Text(
                                      '108 Universities',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceL),

                      // Statistics Section
                      Row(
                        children: [
                          Expanded(
                            child: DestinationStatCard(
                              icon: Icons.person_outline,
                              value: '758K',
                              label: 'International Students',
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          Expanded(
                            child: DestinationStatCard(
                              icon: Icons.emoji_emotions_outlined,
                              value: '20',
                              label: 'Happiness Rank',
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          Expanded(
                            child: DestinationStatCard(
                              icon: Icons.work_outline,
                              value: '75%',
                              label: 'Employment Rate',
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      // Why Study Section
                      const SectionHeader(
                        title: 'Why Study in the UK?',
                        icon: Icons.school_outlined,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'The United Kingdom stands as a beacon of academic excellence, offering a world-class education system that has shaped global leaders for centuries. Home to some of the world\'s most prestigious institutions, including Oxford, Cambridge, and Imperial College, the UK provides an unparalleled blend of traditional academic rigor and cutting-edge research opportunities. The British education system emphasizes critical thinking, creativity, and independent research, preparing students for successful careers in an increasingly competitive global marketplace.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spaceM),
                            Text(
                              'Beyond academics, studying in the UK offers invaluable practical benefits. International students can work part-time during their studies and take advantage of the Graduate Route visa, allowing them to work for two years post-graduation (three years for PhD graduates). With a diverse multicultural environment, strong industry connections, and shorter program durations compared to many other countries, the UK provides an efficient path to achieving your academic and career goals while immersing yourself in a rich cultural heritage.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      // Intake Periods Section
                      const SectionHeader(
                        title: 'Intake Periods',
                        icon: Icons.calendar_today_outlined,
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
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: _buildIntakePeriod(
                                    'Spring Intake',
                                    'January - March',
                                    Icons.sunny,
                                    Colors.orange,
                                  ),
                                ),
                                Expanded(
                                  child: _buildIntakePeriod(
                                    'Fall Intake',
                                    'September - October',
                                    Icons.eco,
                                    Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Application deadlines are typically 3-6 months before the intake period.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      // Best Universities Section
                      const SectionHeader(
                        title: 'Best Universities',
                        icon: Icons.account_balance_outlined,
                      ),
                      const SizedBox(height: AppConstants.spaceM),
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceS),
                          itemCount: universities.length,
                          separatorBuilder: (context, index) => const SizedBox(
                            width: AppConstants.spaceM,
                          ),
                          itemBuilder: (context, index) {
                            final university = universities[index];
                            return CircularUniversityCard(
                              imageUrl: university['image']!,
                              title: university['name']!,
                              location: 'United Kingdom',
                              onTap: () => _navigateToUniversity(university['name']!),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      // Popular Programs Section
                     

                      // Required Documents Section
                      
                      

                      const SizedBox(height: AppConstants.spaceXL),

                      // FAQ Section
                      const SectionHeader(
                        title: 'Frequently Asked Questions',
                        icon: Icons.question_answer_outlined,
                      ),
                      const SizedBox(height: AppConstants.spaceM),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildFAQItem(
                              'What is the process to study in UK?',
                              'The process involves choosing a university and program, submitting required documents, getting an acceptance letter, applying for a student visa, and arranging accommodation.',
                            ),
                            _buildFAQItem(
                              'How much money is required to study in UK?',
                              'Tuition fees range from £12,000 to £35,000 per year depending on the course and university. Living costs average £12,000-£15,000 per year.',
                            ),
                            _buildFAQItem(
                              'Can I get a permanent residency in UK after my studies?',
                              'After completing your studies, you can apply for a Graduate Route visa for 2 years (3 years for PhD). After working in the UK, you may be eligible for permanent residency.',
                            ),
                            _buildFAQItem(
                              'What are the English language requirements?',
                              'Most universities require IELTS scores of 6.0-7.0 overall, with no component below 5.5-6.0. Some universities also accept TOEFL, PTE, or other equivalent tests.',
                            ),
                            _buildFAQItem(
                              'Can I work while studying in the UK?',
                              'Yes, international students can work up to 20 hours per week during term time and full-time during holidays.',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: PrimaryButton(
                              text: 'Explore Universities',
                              icon: Icons.explore_outlined,
                              onPressed: _navigateToUniversities,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          Expanded(
                            flex: 1,
                            child: SecondaryButton(
                              text: 'Share',
                              icon: Icons.share_outlined,
                              onPressed: _shareDestination,
                            ),
                          ),
                        ],
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

  void _navigateToUniversities() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const UniversityListPage(country: '', title: '',),
    ),
  );
}


  void _navigateToUniversity(String universityName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicUniversityPage(
          universityName: universityName,
        ),
      ),
    );
  }


  void _searchProgram(String program) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Searching for $program programs...',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareDestination() async {
  const message = 'Explore study opportunities in the UK 🇬🇧:\nhttps://yourdomain.com/study-in-uk';

  await Share.share(
    message,
    subject: 'Study in the UK',
  );
}

}
