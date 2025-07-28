import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/cards/circular_university_card.dart';
import '../../../../shared/widgets/chips/modern_chip.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../widgets/destination_stat_card.dart';

class AustraliaDetailsPage extends StatefulWidget {
  const AustraliaDetailsPage({super.key});

  @override
  State<AustraliaDetailsPage> createState() => _AustraliaDetailsPageState();
}
// Edits
class _AustraliaDetailsPageState extends State<AustraliaDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, String>> universities = [
    {'name': 'University of Melbourne', 'image': AssetPaths.australiaUni},
    {'name': 'Australian National University', 'image': AssetPaths.australiaUni},
    {'name': 'University of Sydney', 'image': AssetPaths.australiaUni},
    {'name': 'University of New South Wales', 'image': AssetPaths.australiaUni},
    {'name': 'Monash University', 'image': AssetPaths.australiaUni},
    {'name': 'University of Queensland', 'image': AssetPaths.australiaUni},
  ];

  final List<String> popularPrograms = [
    'Engineering',
    'Business & Management',
    'Information Technology',
    'Health Sciences',
    'Environmental Studies',
    'Tourism & Hospitality',
    'Mining Engineering',
    'Agriculture',
  ];

  final List<String> requiredDocuments = [
    'Academic Transcripts',
    'IELTS/TOEFL Scores',
    'Statement of Purpose',
    'Letters of Recommendation',
    'Passport Copy',
    'Financial Statements',
    'Health Insurance',
    'Genuine Temporary Entrant Statement',
  ];

  final List<String> scholarshipTypes = [
    'Australia Awards Scholarships',
    'Destination Australia Scholarships',
    'Research Training Program',
    'University-specific Scholarships',
    'Industry Sponsorship Programs',
    'Commonwealth Scholarships',
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
                      _buildCountryStats(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildScholarshipSection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildStartDatesSection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildUniversitiesSection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildPopularProgramsSection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildRequiredDocumentsSection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildFAQSection(),
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
          'Study in Australia',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AssetPaths.australiaFlag,
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
                      Icons.verified_outlined,
                      color: AppColors.textOnPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: AppConstants.spaceXS),
                    Text(
                      'High Quality Education',
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

  Widget _buildCountryStats() {
    return Row(
      children: [
        Expanded(
          child: DestinationStatCard(
            icon: Icons.school_outlined,
            value: '40+',
            label: 'Universities',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: DestinationStatCard(
            icon: Icons.people_outline,
            value: '800K+',
            label: 'Int\'l Students',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: DestinationStatCard(
            icon: Icons.emoji_events_outlined,
            value: '7',
            label: 'Top 100 Unis',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildScholarshipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Scholarship Opportunities',
          icon: Icons.card_giftcard_outlined,
        ),
        const SizedBox(height: AppConstants.spaceM),
        Container(
          padding: const EdgeInsets.all(AppConstants.spaceL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withOpacity(0.1),
                AppColors.info.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(
              color: AppColors.success.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.monetization_on_outlined,
                    color: AppColors.success,
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Text(
                    'Up to AUD 15,000 per year',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceM),
              Text(
                'Australia offers various scholarship programs for international students, including government-funded and university-specific scholarships.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),
              Wrap(
                spacing: AppConstants.spaceS,
                runSpacing: AppConstants.spaceS,
                children: scholarshipTypes
                    .map((scholarship) => ModernChip(
                          label: scholarship,
                          backgroundColor: AppColors.success.withOpacity(0.1),
                          textColor: AppColors.success,
                          onTap: () => _searchScholarship(scholarship),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartDatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Academic Calendar',
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: AppConstants.spaceM),
        Row(
          children: [
            Expanded(
              child: _buildStartDateCard(
                'Semester 1',
                'February - June',
                'Main intake with most programs available',
                Icons.wb_sunny_outlined,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: _buildStartDateCard(
                'Semester 2',
                'July - November',
                'Secondary intake for selected programs',
                Icons.eco_outlined,
                AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartDateCard(String title, String period, String description, IconData icon, Color color) {
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.spaceM),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceM),
          Text(
            period,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Top Universities',
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
                location: 'Australia',
                onTap: () => _navigateToUniversity(university['name']!),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularProgramsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Popular Programs',
          icon: Icons.gavel_outlined,
        ),
        const SizedBox(height: AppConstants.spaceM),
        Wrap(
          spacing: AppConstants.spaceS,
          runSpacing: AppConstants.spaceS,
          children: popularPrograms
              .map((program) => ModernChip(
                    label: program,
                    onTap: () => _searchProgram(program),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRequiredDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Required Documents',
          icon: Icons.description_outlined,
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
            children: requiredDocuments.map((document) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceS),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: Text(
                        document,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                      size: 16,
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

  Widget _buildFAQSection() {
    final faqs = [
      {
        'question': 'What is the cost of studying in Australia?',
        'answer': 'Tuition fees range from AUD 20,000 to AUD 45,000 per year for international students, depending on the program and university.'
      },
      {
        'question': 'Can I work while studying in Australia?',
        'answer': 'Yes, international students can work up to 40 hours per fortnight during study periods and unlimited hours during breaks.'
      },
      {
        'question': 'What is the visa processing time?',
        'answer': 'Student visa processing typically takes 4-6 weeks, but can vary based on your country and application completeness.'
      },
      {
        'question': 'Is health insurance mandatory?',
        'answer': 'Yes, Overseas Student Health Cover (OSHC) is mandatory for all international students in Australia.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Frequently Asked Questions',
          icon: Icons.help_outline,
        ),
        const SizedBox(height: AppConstants.spaceM),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: faqs.length,
          separatorBuilder: (context, index) => const SizedBox(
            height: AppConstants.spaceM,
          ),
          itemBuilder: (context, index) {
            final faq = faqs[index];
            return Container(
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
              child: ExpansionTile(
                title: Text(
                  faq['question']!,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                iconColor: AppColors.primary,
                collapsedIconColor: AppColors.textSecondary,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spaceL),
                    child: Text(
                      faq['answer']!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            text: 'Find Universities',
            onPressed: _findUniversities,
            icon: Icons.search_outlined,
          ),
        ),
        const SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: OutlinedButton(
            onPressed: _downloadGuide,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppConstants.spaceS),
                Text(
                  'Download Guide',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _searchScholarship(String scholarship) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'More details about $scholarship coming soon!',
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
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppConstants.spaceM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
    );
  }

  void _navigateToUniversity(String universityName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$universityName details coming soon!',
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

  void _findUniversities() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'University search feature coming soon!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppConstants.spaceM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
    );
  }

  void _downloadGuide() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Download feature coming soon!',
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
}
