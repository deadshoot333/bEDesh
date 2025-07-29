
import 'package:bedesh/features/destination/presentation/widgets/destination_stat_card.dart';

import 'package:bedesh/features/university/presentation/pages/university_list_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/cards/circular_university_card.dart';
import '../../../../shared/widgets/common/section_header.dart';

import 'package:share_plus/share_plus.dart';

class USADetailsPage extends StatefulWidget {
  const USADetailsPage({super.key});

  @override
  State<USADetailsPage> createState() => _USADetailsPageState();
}

class _USADetailsPageState extends State<USADetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, String>> universities = [
    {'name': 'Harvard University', 'image': AssetPaths.harvard},
    {'name': 'MIT', 'image': AssetPaths.mit_uni},
    {'name': 'Stanford University', 'image': AssetPaths.stanford},
    {'name': 'Yale University', 'image': AssetPaths.yale},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToUniversities() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UniversityListPage(country: 'USA', title: 'USA Universities'),
      ),
    );
  }

  void _navigateToUniversity(String universityName) {
    if (universityName == 'Harvard University') {
      //Navigator.push(context, MaterialPageRoute(builder: (_) => const HarvardUniversityDetailsPage()));
    } else if (universityName == 'MIT') {
     // Navigator.push(context, MaterialPageRoute(builder: (_) => const MITUniversityPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$universityName details coming soon!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnPrimary),
          ),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  void _shareDestination() async {
    const message = 'Explore study opportunities in the USA 🇺🇸:\nhttps://yourdomain.com/study-in-usa';
    await Share.share(message, subject: 'Study in the USA');
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
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'United States',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        AssetPaths.liberty,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: _shareDestination,
                    icon: const Icon(Icons.share_outlined, color: AppColors.textOnPrimary),
                  ),
                  const SizedBox(width: AppConstants.spaceS),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spaceL),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                          boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8)],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              child: Image.asset(
                                AssetPaths.USA_f,
                                width: 80,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: AppConstants.spaceM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('United States', style: AppTextStyles.h3),
                                  const SizedBox(height: AppConstants.spaceXS),
                                  GestureDetector(
                                    onTap: _navigateToUniversities,
                                    child: Text(
                                      '200+ Universities',
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

                      // Stats
                      Row(
                        children: [
                          Expanded(
                            child: DestinationStatCard(
                              icon: Icons.person_outline,
                              value: '1.1M',
                              label: 'Intl. Students',
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          Expanded(
                            child: DestinationStatCard(
                              icon: Icons.emoji_emotions_outlined,
                              value: '15',
                              label: 'Happiness Rank',
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          Expanded(
                            child: DestinationStatCard(
                              icon: Icons.work_outline,
                              value: '78%',
                              label: 'Employment Rate',
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spaceXL),

                      // Why Study
                      const SectionHeader(title: 'Why Study in the USA?', icon: Icons.school_outlined),
                      const SizedBox(height: AppConstants.spaceM),
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spaceL),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                          boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'The USA hosts many of the world’s top universities and offers unparalleled academic flexibility across a wide range of disciplines. With institutions like Harvard, MIT, and Stanford, students benefit from advanced research, global networking, and access to leading industries.',
                              style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                            ),
                            const SizedBox(height: AppConstants.spaceM),
                            Text(
                              'Studying in the USA also offers rich cultural exposure, practical internships (CPT/OPT), and post-study work options. The American education system is known for its innovation, entrepreneurship focus, and supportive campus environments.',
                              style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      // Intake Periods
                      const SectionHeader(title: 'Intake Periods', icon: Icons.calendar_today_outlined),
                      const SizedBox(height: AppConstants.spaceM),
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spaceL),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                          boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8)],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildIntakePeriod('Spring Intake', 'January - May', Icons.sunny, Colors.orange),
                                _buildIntakePeriod('Fall Intake', 'August - December', Icons.eco, Colors.green),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Deadlines vary by university, often 6–9 months before semester start.',
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

                      // Best Universities
                      const SectionHeader(title: 'Best Universities', icon: Icons.account_balance_outlined),
                      const SizedBox(height: AppConstants.spaceM),
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceS),
                          itemCount: universities.length,
                          separatorBuilder: (_, __) => const SizedBox(width: AppConstants.spaceM),
                          itemBuilder: (_, index) {
                            final university = universities[index];
                            return CircularUniversityCard(
                              imageUrl: university['image']!,
                              title: university['name']!,
                              location: 'United States',
                              onTap: () => _navigateToUniversity(university['name']!),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      // FAQ
                      const SectionHeader(title: 'Frequently Asked Questions', icon: Icons.question_answer_outlined),
                      const SizedBox(height: AppConstants.spaceM),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                          boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8)],
                        ),
                        child: Column(
                          children: [
                            _buildFAQItem('What exams are required to study in the USA?',
                                'Most universities require TOEFL/IELTS for English proficiency. Some may require SAT/ACT for undergraduate or GRE/GMAT for graduate admissions.'),
                            _buildFAQItem('Can I work while studying?',
                                'Yes, international students can work up to 20 hours per week on-campus. Optional Practical Training (OPT) is available after graduation.'),
                            _buildFAQItem('What is the cost of studying in the USA?',
                                'Tuition ranges from \$20,000 to \$60,000/year. Living costs are around \$10,000–\$20,000/year.'),
                            _buildFAQItem('Is financial aid available for international students?',
                                'Yes, many universities offer scholarships, assistantships, and need-based aid to international students.'),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              text: 'Explore Universities',
                              icon: Icons.explore_outlined,
                              onPressed: _navigateToUniversities,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          SecondaryButton(
                            text: '',
                            icon: Icons.share_outlined,
                            onPressed: _shareDestination,
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
          Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(dates, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
        ),
      ],
    );
  }
}
