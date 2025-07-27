import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../shared/widgets/inputs/modern_search_bar.dart';
import '../../../../shared/widgets/chips/modern_chip.dart';
import '../../../../shared/widgets/cards/university_card.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/common/section_header.dart';
import 'oxford_university_page.dart';

class UniversityListPage extends StatefulWidget {
  final String country;
  final String title;

  const UniversityListPage({
    super.key,
    required this.country,
    required this.title,
  });

  @override
  State<UniversityListPage> createState() => _UniversityListPageState();
}

class _UniversityListPageState extends State<UniversityListPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedLevel = 'All Levels';
  String _selectedField = 'All Fields';
  String _sortBy = 'Ranking';
  
  final List<String> _filters = [
    'All',
    'Top 3',
   
  ];

  final List<String> _levels = [
    'All Levels',
    'Undergraduate',
    'Masters',
    'PhD',
    'MBA',
  ];

  final List<String> _fields = [
    'All Fields',
    'Computer Science',
    'Engineering',
    'Business',
    'Medicine',
    'Law',
    'Arts & Humanities',
    'Sciences',
  ];

  final List<String> _sortOptions = [
    'Ranking',
    'Tuition (Low to High)',
    'Tuition (High to Low)',
    'Acceptance Rate',
    'Name A-Z',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
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
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchAndFilters(),
                    const SizedBox(height: AppConstants.spaceL),
                    _buildResultsHeader(),
                    const SizedBox(height: AppConstants.spaceM),
                    _buildUniversityList(),
                  ],
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
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.title,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: 50,
                child: Icon(
                  Icons.school_outlined,
                  size: 150,
                  color: AppColors.textOnPrimary.withOpacity(0.1),
                ),
              ),
              Positioned(
                left: AppConstants.spaceL,
                bottom: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textOnPrimary.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      '${_getFilteredUniversities().length} Universities',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textOnPrimary.withOpacity(0.8),
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

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        ModernSearchBar(
          hintText: 'Search universities, programs...',
          controller: _searchController,
          showFilter: true,
          onChanged: (value) {
            setState(() {});
          },
          onFilterPressed: _showFilterBottomSheet,
        ),
        const SizedBox(height: AppConstants.spaceM),
        _buildQuickFilters(),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.spaceS),
            child: ModernChip(
              label: filter,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultsHeader() {
    final filteredCount = _getFilteredUniversities().length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$filteredCount Universities',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        OutlinedButton(
          onPressed: _showSortBottomSheet,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort: $_sortBy',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppConstants.spaceXS),
              Icon(
                Icons.sort_outlined,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUniversityList() {
    final universities = _getFilteredUniversities();
    
    if (universities.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: universities.length,
      separatorBuilder: (context, index) => const SizedBox(
        height: AppConstants.spaceM,
      ),
      itemBuilder: (context, index) {
        final university = universities[index];
        return UniversityCard(
          title: university['name']!,
          location: university['location']!,
          imageUrl: university['image']!,
          ranking: university['ranking'],
          rating: university['rating'],
          subtitle: university['subtitle'],
          showFavoriteButton: false,
          onTap: () => _navigateToUniversity(university),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      child: Column(
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.spaceL),
          Text(
            'No Universities Found',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            'Try adjusting your search or filters',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceL),
          PrimaryButton(
            text: 'Clear Filters',
            size: ButtonSize.medium,
            onPressed: _clearFilters,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXL),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppConstants.spaceM),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Universities',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceL),
                
                // Level Filter
                const SectionHeader(
                  title: 'Study Level',
                  icon: Icons.school_outlined,
                ),
                const SizedBox(height: AppConstants.spaceM),
                Wrap(
                  spacing: AppConstants.spaceS,
                  runSpacing: AppConstants.spaceS,
                  children: _levels.map((level) {
                    final isSelected = _selectedLevel == level;
                    return ModernChip(
                      label: level,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedLevel = level;
                        });
                      },
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: AppConstants.spaceL),
                
                // Field Filter
                const SectionHeader(
                  title: 'Field of Study',
                  icon: Icons.category_outlined,
                ),
                const SizedBox(height: AppConstants.spaceM),
                Wrap(
                  spacing: AppConstants.spaceS,
                  runSpacing: AppConstants.spaceS,
                  children: _fields.map((field) {
                    final isSelected = _selectedField == field;
                    return ModernChip(
                      label: field,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedField = field;
                        });
                      },
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: AppConstants.spaceXL),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _clearFilters();
                          Navigator.pop(context);
                        },
                        child: Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Apply Filters',
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXL),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort By',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),
            ..._sortOptions.map((option) {
              final isSelected = _sortBy == option;
              return ListTile(
                title: Text(
                  option,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _sortBy = option;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredUniversities() {
    List<Map<String, dynamic>> universities = _getUniversitiesForCountry();
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      universities = universities.where((uni) {
        return uni['name']!.toLowerCase().contains(_searchController.text.toLowerCase()) ||
               uni['location']!.toLowerCase().contains(_searchController.text.toLowerCase()) ||
               (uni['subtitle'] ?? '').toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    }
    
    // Apply category filter
    
    
    // Apply sorting
    universities.sort((a, b) {
      switch (_sortBy) {
        case 'Ranking':
          return (a['ranking'] ?? 999).compareTo(b['ranking'] ?? 999);
        case 'Tuition (Low to High)':
          return (a['tuition'] ?? 0).compareTo(b['tuition'] ?? 0);
        case 'Tuition (High to Low)':
          return (b['tuition'] ?? 0).compareTo(a['tuition'] ?? 0);
        case 'Acceptance Rate':
          return (b['acceptanceRate'] ?? 0).compareTo(a['acceptanceRate'] ?? 0);
        case 'Name A-Z':
          return a['name']!.compareTo(b['name']!);
        default:
          return 0;
      }
    });
    
    return universities;
  }

  List<Map<String, dynamic>> _getUniversitiesForCountry() {
    if (widget.country.toLowerCase() == 'uk') {
      return _ukUniversities;
    }
    return _ukUniversities; // Default for now
  }

  void _clearFilters() {
    setState(() {
      _selectedFilter = 'All';
      _selectedLevel = 'All Levels';
      _selectedField = 'All Fields';
      _sortBy = 'Ranking';
      _searchController.clear();
    });
  }

  void _navigateToUniversity(Map<String, dynamic> university) {
    if (university['name'] == 'University of Oxford') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  OxfordUniversityPage()),
      );
    } else {
      // For now, show a coming soon message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${university['name']} details coming soon!',
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

  // Sample data for UK universities
  final List<Map<String, dynamic>> _ukUniversities = [
    {
      'name': 'University of Oxford',
      'location': 'Oxford, England',
      'image': AssetPaths.oxford,
      'ranking': 1,
      'rating': 4.8,
      'subtitle': 'World\'s oldest English-speaking university',
      'tuition': 35000,
      'acceptanceRate': 18,
      'hasScholarships': true,
    },
    {
      'name': 'University of Cambridge',
      'location': 'Cambridge, England',
      'image': AssetPaths.cambridge,
      'ranking': 2,
      'rating': 4.8,
      'subtitle': 'Historic university with exceptional academics',
      'tuition': 34000,
      'acceptanceRate': 21,
      'hasScholarships': true,
    },
    {
      'name': 'Imperial College London',
      'location': 'London, England',
      'image': AssetPaths.imperial,
      'ranking': 3,
      'rating': 4.7,
      'subtitle': 'Leading science and technology university',
      'tuition': 32000,
      'acceptanceRate': 14,
      'hasScholarships': true,
    },
    
    
  ];
}
