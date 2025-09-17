import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/cards/circular_university_card.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/navigation/navigation_wrapper.dart';
import '../widgets/destination_stat_card.dart';
import '../../domain/models/country.dart';
import '../../data/services/country_api_service.dart';
import '../../../university/presentation/pages/university_list_page.dart';
import '../../../university/presentation/pages/dynamic_university_page.dart';
import '../../../university/data/services/university_api_service.dart';
import '../../../university/domain/models/university.dart';

class DynamicCountryDetailsPage extends StatefulWidget {
  final String countryName;

  const DynamicCountryDetailsPage({
    super.key,
    required this.countryName,
  });

  @override
  State<DynamicCountryDetailsPage> createState() => _DynamicCountryDetailsPageState();
}

class _DynamicCountryDetailsPageState extends State<DynamicCountryDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Country? _country;
  List<University> _universities = [];
  bool _isLoading = true;
  String? _error;

  // Helper method to get local assets for countries
  String _getCountryImageAsset(String countryName) {
    switch (countryName.toLowerCase()) {
      case 'united kingdom':
      case 'uk':
        return AssetPaths.uk;
      case 'united states':
      case 'usa':
        return AssetPaths.usaFlag;
      case 'canada':
        return AssetPaths.canadaFlag;
      case 'australia':
        return AssetPaths.australiaFlag;
      default:
        return AssetPaths.placeholder;
    }
  }

  String _getCountryFlagAsset(String countryName) {
    switch (countryName.toLowerCase()) {
      case 'united kingdom':
      case 'uk':
        return AssetPaths.britishFlag;
      case 'united states':
      case 'usa':
        return AssetPaths.usaFlag;
      case 'canada':
        return AssetPaths.canadaFlag;
      case 'australia':
        return AssetPaths.australiaFlag;
      default:
        return AssetPaths.placeholder;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCountryData();
  }

  void _initializeAnimations() {
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

  Future<void> _loadCountryData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load country data
      final country = await CountryApiService.getCountryByName(widget.countryName);
      
      if (country == null) {
        setState(() {
          _error = 'Country not found';
          _isLoading = false;
        });
        return;
      }

      // Load universities for this country
      final allUniversities = await UniversityApiService.getAllUniversities();
      final countryUniversities = allUniversities
          .where((uni) => uni.country.toLowerCase() == widget.countryName.toLowerCase())
          .take(4) // Show only top 4 universities
          .toList();

      setState(() {
        _country = country;
        _universities = countryUniversities;
        _isLoading = false;
      });

      // Debug: Print the image URLs
      print('🖼️ Country: ${country.name}');
      print('🖼️ Image URL: ${country.imgUrl}');
      print('🏳️ Flag URL: ${country.flagUrl}');
      print('📝 Description: ${country.countryDescription}');
    } catch (e) {
      setState(() {
        _error = 'Error loading country data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return NavigationWrapper(
        selectedIndex: 0, // Home tab context
        child: Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          appBar: AppBar(
            title: Text(widget.countryName),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_error != null) {
      return NavigationWrapper(
        selectedIndex: 0, // Home tab context
        child: Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          appBar: AppBar(
            title: Text(widget.countryName),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
          ),
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
                _error!,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spaceL),
              PrimaryButton(
                text: 'Retry',
                onPressed: _loadCountryData,
              ),
            ],
          ),
        ),
      ), // Scaffold closes here
    ); // NavigationWrapper closes here
    }

    return NavigationWrapper(
      selectedIndex: 0, // Home tab context
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCountryInfoHeader(),
                      const SizedBox(height: AppConstants.spaceL),
                      _buildStatisticsSection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildWhyStudySection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildIntakePeriodsSection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildBestUniversitiesSection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildFAQSection(),
                      const SizedBox(height: AppConstants.spaceXL),
                      _buildActionButtons(),
                      const SizedBox(height: AppConstants.spaceXL),
                    ],
                  ),
                ),
              ),
            ],
          ), // CustomScrollView closes here
        ), // SlideTransition closes here
      ), // FadeTransition closes here
    ), // Scaffold closes here
  ); // NavigationWrapper closes here
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
          _country!.name,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            _country!.imgUrl.isNotEmpty
                ? Image.network(
                    _country!.imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // If network image fails, try local asset
                      return Image.asset(
                        _getCountryImageAsset(_country!.name),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error2, stackTrace2) {
                          // If both fail, show gradient background
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.public,
                                size: 64,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : Image.asset(
                    _getCountryImageAsset(_country!.name),
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
                        child: const Center(
                          child: Icon(
                            Icons.public,
                            size: 64,
                            color: AppColors.textOnPrimary,
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
    );
  }

  Widget _buildCountryInfoHeader() {
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            child: _country!.flagUrl.isNotEmpty
                ? Image.network(
                    _country!.flagUrl,
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // If network image fails, try local asset
                      return Image.asset(
                        _getCountryFlagAsset(_country!.name),
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error2, stackTrace2) {
                          // If both fail, show icon
                          return Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                            child: const Icon(
                              Icons.flag_outlined,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      );
                    },
                  )
                : Image.asset(
                    _getCountryFlagAsset(_country!.name),
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
                        child: const Icon(
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
                  _country!.name,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXS),
                GestureDetector(
                  onTap: _navigateToUniversities,
                  child: Text(
                    '${_universities.length}+ Universities',
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
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      children: [
        Expanded(
          child: DestinationStatCard(
            icon: Icons.person_outline,
            value: _country!.internationalStudent,
            label: 'International Students',
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: DestinationStatCard(
            icon: Icons.emoji_emotions_outlined,
            value: _country!.happinessRanking,
            label: 'Happiness Rank',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: DestinationStatCard(
            icon: Icons.work_outline,
            value: _country!.employmentRate,
            label: 'Employment Rate',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildWhyStudySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Why Study in ${_country!.name}?',
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
            _country!.countryDescription.isNotEmpty 
                ? _country!.countryDescription 
                : 'Discover world-class education opportunities in ${_country!.name}. Experience academic excellence, cultural diversity, and career advancement in one of the world\'s premier study destinations.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntakePeriodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  const SizedBox(width: AppConstants.spaceM),
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
      ],
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

  Widget _buildBestUniversitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Best Universities',
          icon: Icons.account_balance_outlined,
        ),
        const SizedBox(height: AppConstants.spaceM),
        if (_universities.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
            ),
            child: Center(
              child: Text(
                'No universities found for ${_country!.name}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceS),
              itemCount: _universities.length,
              separatorBuilder: (context, index) => const SizedBox(
                width: AppConstants.spaceM,
              ),
              itemBuilder: (context, index) {
                final university = _universities[index];
                return CircularUniversityCard(
                  imageUrl: university.imageUrl,
                  title: university.name,
                  location: _country!.name,
                  onTap: () => _navigateToUniversity(university.name),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFAQSection() {
    final faqs = _getCountrySpecificFAQs();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            children: faqs.map((faq) => _buildFAQItem(faq['question']!, faq['answer']!)).toList(),
          ),
        ),
      ],
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

  Widget _buildActionButtons() {
    return Row(
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
    );
  }

  List<Map<String, String>> _getCountrySpecificFAQs() {
    final countryName = _country!.name;
    
    return [
      {
        'question': 'What is the process to study in $countryName?',
        'answer': 'The process involves choosing a university and program, submitting required documents, getting an acceptance letter, applying for a student visa, and arranging accommodation.',
      },
      {
        'question': 'How much money is required to study in $countryName?',
        'answer': 'Tuition fees and living costs vary depending on the university and city. It\'s recommended to research specific institutions and their fee structures.',
      },
      {
        'question': 'Can I get a permanent residency in $countryName after my studies?',
        'answer': 'Many countries offer post-study work opportunities and pathways to permanent residency. Check the specific immigration policies for $countryName.',
      },
      {
        'question': 'What are the English language requirements?',
        'answer': 'Most universities require English proficiency tests like IELTS, TOEFL, or PTE. Requirements vary by institution and program level.',
      },
      {
        'question': 'Can I work while studying in $countryName?',
        'answer': 'International students are typically allowed to work part-time during their studies. Check the specific work permit regulations for $countryName.',
      },
    ];
  }

  void _navigateToUniversities() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UniversityListPage(
          country: _country!.name,
          title: '${_country!.name} Universities',
        ),
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

  void _shareDestination() async {
    final message = 'Explore study opportunities in ${_country!.name} 🌍:\nhttps://yourdomain.com/study-in-${_country!.name.toLowerCase().replaceAll(' ', '-')}';

    await Share.share(
      message,
      subject: 'Study in ${_country!.name}',
    );
  }
}
