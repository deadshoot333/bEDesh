import 'package:bedesh/features/accommodation/presentation/pages/accommodation_page.dart';
import 'package:bedesh/features/community/presentation/pages/community_feed_page.dart';
import 'package:bedesh/features/destination/presentation/pages/uk_details_page.dart';
import 'package:bedesh/features/university/presentation/pages/Cambridge_University_Page.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/inputs/modern_search_bar.dart';
import '../../../../shared/widgets/cards/circular_destination_card.dart';
import '../../../../shared/widgets/cards/circular_university_card.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';

// Import the existing pages for navigation
import '../../../university/presentation/pages/oxford_university_page.dart';
import '../../../university/presentation/pages/swansea_university_page.dart';
import '../../../destination/presentation/pages/australia_details_page.dart';
import '../../../university/presentation/pages/university_list_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class ModernHomePage extends StatefulWidget {
  const ModernHomePage({super.key});

  @override
  State<ModernHomePage> createState() => _ModernHomePageState();
}

class _ModernHomePageState extends State<ModernHomePage>
    with TickerProviderStateMixin {
  late AnimationController _heroAnimationController;
  late AnimationController _sectionsAnimationController;
  
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  final PageController _bannerController = PageController(viewportFraction: 0.85);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Hero section animation
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _heroFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    _heroSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
    ));

    // Sections staggered animation
    _sectionsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    _heroAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _sectionsAnimationController.forward();
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _sectionsAnimationController.dispose();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToOnboarding();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: AnimatedBuilder(
        animation: Listenable.merge([
          _heroAnimationController,
          _sectionsAnimationController,
        ]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _heroFadeAnimation,
            child: SlideTransition(
              position: _heroSlideAnimation,
              child: Column(
                children: [
                  // Modern Header (extends to top)
                  _buildModernHeader(),
                  
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppConstants.spaceL),

                          // Featured Banner Section
                          _buildFeaturedBanners(),

                      // Popular Destinations
                      SectionHeader(
                        title: 'Popular Destinations',
                        subtitle: 'Explore top study abroad destinations',
                        icon: Icons.public,
                        actionText: 'View All',
                        onActionPressed: () {
                          // Navigate to all destinations
                        },
                      ),
                      _buildDestinationsSection(),

                      // In-demand Courses
                      SectionHeader(
                        title: 'In-demand Courses',
                        subtitle: 'Most popular courses this year',
                        icon: Icons.trending_up,
                      ),
                      _buildCoursesSection(),

                      // Top Universities
                      SectionHeader(
                        title: 'Top Universities',
                        subtitle: 'World-renowned institutions',
                        icon: Icons.school,
                        actionText: 'See All',
                        onActionPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UniversityListPage(
                                country: 'all',
                                title: 'All Universities',
                              ),
                            ),
                          );
                        },
                      ),
                      _buildUniversitiesSection(),

                      // Quick Actions
                      SectionHeader(
                        title: 'Quick Actions',
                        subtitle: 'Explore additional resources',
                        icon: Icons.rocket_launch,
                      ),
                      _buildQuickActionsSection(),

                      const SizedBox(height: AppConstants.spaceXXL),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
  }

  Widget _buildModernHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Back button
                        Container(
                          margin: const EdgeInsets.only(right: AppConstants.spaceM),
                          decoration: BoxDecoration(
                            color: AppColors.textOnPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.textOnPrimary,
                              size: 20,
                            ),
                            onPressed: _navigateToOnboarding,
                          ),
                        ),
                        // App name and description
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6, // Limit width
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppConstants.appName,
                                style: AppTextStyles.h2.copyWith(
                                  color: AppColors.textOnPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppConstants.spaceXS),
                              Text(
                                AppConstants.appDescription,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textOnPrimary.withOpacity(0.9),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ModernIconButton(
                      icon: Icons.person_outline,
                      backgroundColor: AppColors.textOnPrimary.withOpacity(0.2),
                      iconColor: AppColors.textOnPrimary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                      tooltip: 'Profile',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.spaceL),
              
              // Modern Search Bar
              ModernSearchBar(
                hintText: 'Find Universities, Courses & More...',
                controller: _searchController,
                showFilter: true,
                onChanged: (value) {
                  // Handle search
                },
                onFilterPressed: () {
                  // Show filter options
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedBanners() {
    return SizedBox(
      height: 160,
      child: PageView(
        controller: _bannerController,
        children: [
          _buildBannerCard(
            title: 'Swansea University',
            subtitle: '83% employability rate',
            description: 'High student satisfaction',
            imageAsset: AssetPaths.abroad11,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SwanseaUniversityPage()),
              );
            },
          ),
          _buildBannerCard(
            title: 'Australia Scholarships',
            subtitle: 'Up to 100% funding',
            description: 'Apply now for 2025 intake',
            imageAsset: AssetPaths.australiaScholar,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AustraliaDetailsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard({
    required String title,
    required String subtitle,
    required String description,
    required String imageAsset,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceS),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              image: DecorationImage(
                image: AssetImage(imageAsset),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(AppConstants.spaceM),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceXS),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnPrimary.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnPrimary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationsSection() {
    return SizedBox(
      height: 160, // Increased height for circular design
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
        physics: const BouncingScrollPhysics(), // Smooth scrolling
        itemCount: _destinationData.length,
        itemBuilder: (context, index) {
          final destination = _destinationData[index];
          return CircularDestinationCard(
            title: destination['title']!,
            count: destination['count'],
            imageAsset: destination['imageAsset']!,
            onTap: destination['onTap'],
          );
        },
      ),
    );
  }

  // Destination data for better organization
  List<Map<String, dynamic>> get _destinationData => [
    {
      'title': 'United Kingdom',
      'count': 108,
      'imageAsset': AssetPaths.ukFlag,
      'onTap': () {
   Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UKDetailsPage()),
      );
      },
    },
    {
      'title': 'United States',
      'count': 137,
      'imageAsset': AssetPaths.abroad13,
      'onTap': () {
        // Navigate to US details
      },
    },
    {
      'title': 'Canada',
      'count': 39,
      'imageAsset': AssetPaths.canadaFlag,
      'onTap': () {
        // Navigate to Canada details
      },
    },
    {
      'title': 'Australia',
      'count': 15,
      'imageAsset': AssetPaths.australiaFlag,
      'onTap': () {
        // Navigate to Australia details
      },
    },
  ];

  Widget _buildCoursesSection() {
    final courses = [
      {'name': 'Computer Science', 'field': 'Technology', 'level': 'Masters'},
      {'name': 'International Business', 'field': 'Business', 'level': 'Masters'},
      {'name': 'Mechanical Engineering', 'field': 'Engineering', 'level': 'Bachelors'},
      {'name': 'Data Science', 'field': 'Technology', 'level': 'Masters'},
      {'name': 'Medicine', 'field': 'Healthcare', 'level': 'Bachelors'},
      {'name': 'Psychology', 'field': 'Social Sciences', 'level': 'Bachelors'},
      {'name': 'Finance', 'field': 'Business', 'level': 'Masters'},
      {'name': 'Electrical Engineering', 'field': 'Engineering', 'level': 'Bachelors'},
      {'name': 'Marketing', 'field': 'Business', 'level': 'Bachelors'},
      {'name': 'Biotechnology', 'field': 'Science', 'level': 'Masters'},
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: AppConstants.spaceM),
            padding: const EdgeInsets.all(AppConstants.spaceM),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['name']!,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spaceS),
                    Text(
                      'Field: ${course['field']!}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceS,
                    vertical: AppConstants.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    course['level']!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUniversitiesSection() {
    return SizedBox(
      height: 220, // Optimized height for circular design
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
        physics: const BouncingScrollPhysics(), // Smooth scrolling
        itemCount: _universityData.length,
        itemBuilder: (context, index) {
          final university = _universityData[index];
          return CircularUniversityCard(
            title: university['title']!,
            location: university['location']!,
            imageUrl: university['imageUrl']!,
            ranking: university['ranking'],
            rating: university['rating'],
            subtitle: university['subtitle'],
            onTap: university['onTap'],
          );
        },
      ),
    );
  }

  // University data for better organization
  List<Map<String, dynamic>> get _universityData => [
    {
      'title': 'University of Oxford',
      'location': 'Oxford, United Kingdom',
      'imageUrl': AssetPaths.oxford,
      'ranking': 1,
      'rating': 4.8,
      'subtitle': 'World\'s oldest English-speaking university',
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  OxfordUniversityPage()),
        );
      },
    },
    {
      'title': 'University of Cambridge',
      'location': 'Cambridge, United Kingdom',
      'imageUrl': AssetPaths.cambridge,
      'ranking': 2,
      'rating': 4.8,
      'subtitle': 'Excellence in research and education',
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  CambridgeUniversityPage()),
        );
      },
    },
    {
      'title': 'Imperial College London',
      'location': 'London, United Kingdom',
      'imageUrl': AssetPaths.imperial,
      'ranking': 3,
      'rating': 4.7,
      'subtitle': 'World-leading science and technology',
      'onTap': () {
        // Navigate to Imperial page when implemented
      },
    },
  ];



  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              icon: Icons.people_outline,
              title: 'Community',
              subtitle: 'Connect with Students',
              color: AppColors.secondary,
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommunityFeedPage()
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppConstants.spaceM),
          Expanded(
            child: _buildActionCard(
              icon: Icons.home_work,
              title: 'Find Accommodation',
              subtitle: 'Discover student housing',
              color: AppColors.cta,
              onTap: () {
                // Navigate to accommodation
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccommodationPage()
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: AppConstants.spaceS),
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spaceXS),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
