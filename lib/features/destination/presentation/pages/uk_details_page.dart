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
import '../widgets/start_date_card.dart';
import '../widgets/faq_section.dart';

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

  final List<String> popularPrograms = [
    'Law',
    'Finance', 
    'Education',
    'Business',
    'Computer Sciences',
    'Medicine',
    'Engineering',
  ];

  final List<String> requiredDocuments = [
    'Academic Transcripts',
    'IELTS/TOEFL Scores',
    'Statement of Purpose',
    'Letters of Recommendation',
    'Passport Copy',
    'Financial Statements',
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
                        child: Text(
                          'The UK is a globally renowned study destination with over 758,000 international students. Graduates enjoy strong job prospects, with a 75% employment rate, and can work for two years post-study. PhD students can stay for three years. The UK has a rich history, diverse culture, and is home to some of the world\'s best universities like Oxford and Cambridge.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      // Start Dates Section
                      const StartDateCard(),

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

                      const SizedBox(height: AppConstants.spaceXL),

                      // Required Documents Section
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
                          children: requiredDocuments
                              .map((document) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppConstants.spaceXS,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(AppConstants.spaceXS),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            size: 16,
                                            color: AppColors.primary,
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
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXL),

                      // FAQ Section
                      const FaqSection(),

                      const SizedBox(height: AppConstants.spaceXL),

                      // Action Buttons
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
                            text: 'Share',
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

  void _navigateToUniversities() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Universities listing coming soon!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.info,
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.textOnPrimary,
          onPressed: () {},
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
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.textOnPrimary,
          onPressed: () {},
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

  void _shareDestination() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Shared: Study in UK 🇬🇧',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View',
          textColor: AppColors.textOnPrimary,
          onPressed: () {},
        ),
      ),
    );
  }
}
