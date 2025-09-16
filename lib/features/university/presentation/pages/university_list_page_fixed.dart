import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/inputs/modern_search_bar.dart';
import '../../../../shared/widgets/chips/modern_chip.dart';
import '../../../../shared/widgets/cards/university_card.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../domain/models/university.dart';
import '../../data/services/university_api_service.dart';
import 'dynamic_university_page.dart';

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
  
  List<University> _universities = [];
  List<University> _filteredUniversities = [];
  bool _isLoading = true;
  String? _error;
  
  final List<String> _filters = [
    'All',
    'Top 10',
    'With Scholarships',
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
    _loadUniversities();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUniversities() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<University> universities;
      
      // Try to get universities by country first
      try {
        universities = await UniversityApiService.getUniversitiesByCountry(widget.country);
      } catch (e) {
        // If by-country fails, try search with country name
        universities = await UniversityApiService.searchUniversities(widget.country);
      }

      setState(() {
        _universities = universities;
        _applyFiltersAndSorting();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSorting() {
    List<University> filtered = List.from(_universities);
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((uni) {
        return uni.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
               uni.location.toLowerCase().contains(_searchController.text.toLowerCase()) ||
               uni.description.toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    }
    
    // Apply category filter
    if (_selectedFilter == 'Top 10') {
      filtered = filtered.where((uni) => uni.worldRanking <= 10).toList();
    } else if (_selectedFilter == 'With Scholarships') {
      // Most top-ranked universities offer scholarships
      filtered = filtered.where((uni) => uni.worldRanking <= 200).toList();
    }
    
    // Apply level filter
    if (_selectedLevel != 'All Levels') {
      // Filter universities that typically offer the selected level
      filtered = filtered.where((uni) => _universitySupportsLevel(uni, _selectedLevel)).toList();
    }
    
    // Apply field filter
    if (_selectedField != 'All Fields') {
      // Filter universities that typically offer the selected field
      filtered = filtered.where((uni) => _universitySupportsField(uni, _selectedField)).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'Ranking':
          return a.worldRanking.compareTo(b.worldRanking);
        case 'Tuition (Low to High)':
          final aTuition = a.tuitionFeeUSD ?? 0.0;
          final bTuition = b.tuitionFeeUSD ?? 0.0;
          return aTuition.compareTo(bTuition);
        case 'Tuition (High to Low)':
          final aTuition = a.tuitionFeeUSD ?? 0.0;
          final bTuition = b.tuitionFeeUSD ?? 0.0;
          return bTuition.compareTo(aTuition);
        case 'Acceptance Rate':
          final aRate = a.acceptanceRate ?? 100.0;
          final bRate = b.acceptanceRate ?? 100.0;
          return aRate.compareTo(bRate);
        case 'Name A-Z':
          return a.name.compareTo(b.name);
        default:
          return a.worldRanking.compareTo(b.worldRanking);
      }
    });
    
    setState(() {
      _filteredUniversities = filtered;
    });
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
                    if (!_isLoading && _error == null)
                      _buildResultsHeader(),
                    const SizedBox(height: AppConstants.spaceM),
                    _buildContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_error != null) {
      return _buildErrorState();
    } else {
      return _buildUniversityList();
    }
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          const SizedBox(height: AppConstants.spaceL),
          Text(
            'Loading universities...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.spaceL),
          Text(
            'Error Loading Universities',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            _error!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spaceL),
          PrimaryButton(
            text: 'Retry',
            size: ButtonSize.medium,
            onPressed: _loadUniversities,
          ),
        ],
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
                      '${_filteredUniversities.length} Universities',
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
            _applyFiltersAndSorting();
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
                _applyFiltersAndSorting();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultsHeader() {
    final filteredCount = _filteredUniversities.length;
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
    final universities = _filteredUniversities;
    
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
          title: university.name,
          location: university.location,
          imageUrl: university.imageUrl,
          ranking: university.worldRanking,
          rating: 4.5, // Default rating since it's not in the model
          subtitle: university.description,
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
                        child: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Apply Filters',
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFiltersAndSorting();
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXL),
        ),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppConstants.spaceM),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spaceL),
                child: Column(
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
                        contentPadding: EdgeInsets.zero,
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
                          _applyFiltersAndSorting();
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedFilter = 'All';
      _selectedLevel = 'All Levels';
      _selectedField = 'All Fields';
      _sortBy = 'Ranking';
      _searchController.clear();
    });
    _applyFiltersAndSorting();
  }

  // Helper method to check if university supports a specific level
  bool _universitySupportsLevel(University university, String level) {
    switch (level) {
      case 'Undergraduate':
        // Most universities offer undergraduate programs
        return true;
      case 'Masters':
        // Universities with good rankings typically offer masters
        return university.worldRanking <= 500;
      case 'PhD':
        // Top research universities offer PhD programs
        return university.worldRanking <= 300;
      case 'MBA':
        // Business schools and comprehensive universities offer MBA
        final businessKeywords = ['business', 'management', 'harvard', 'stanford', 'wharton', 'insead', 'london business'];
        final hasBusinessFocus = businessKeywords.any((keyword) => 
          university.name.toLowerCase().contains(keyword) || 
          university.description.toLowerCase().contains(keyword)
        );
        return hasBusinessFocus || university.worldRanking <= 100;
      default:
        return true;
    }
  }

  // Helper method to check if university supports a specific field
  bool _universitySupportsField(University university, String field) {
    final uniName = university.name.toLowerCase();
    
    switch (field) {
      case 'Computer Science':
        final techKeywords = ['technology', 'institute', 'tech', 'mit', 'stanford', 'carnegie', 'berkeley'];
        return techKeywords.any((keyword) => uniName.contains(keyword)) || university.worldRanking <= 200;
      case 'Engineering':
        final engKeywords = ['technology', 'institute', 'tech', 'engineering', 'polytechnic'];
        return engKeywords.any((keyword) => uniName.contains(keyword)) || university.worldRanking <= 250;
      case 'Business':
        final businessKeywords = ['business', 'management', 'harvard', 'stanford', 'wharton', 'insead'];
        return businessKeywords.any((keyword) => uniName.contains(keyword)) || university.worldRanking <= 150;
      case 'Medicine':
        final medKeywords = ['medical', 'medicine', 'health', 'johns hopkins', 'mayo'];
        return medKeywords.any((keyword) => uniName.contains(keyword)) || university.worldRanking <= 100;
      case 'Law':
        final lawKeywords = ['law', 'harvard', 'yale', 'stanford', 'oxford', 'cambridge'];
        return lawKeywords.any((keyword) => uniName.contains(keyword)) || university.worldRanking <= 80;
      case 'Arts & Humanities':
        final artsKeywords = ['arts', 'liberal', 'humanities', 'oxford', 'cambridge', 'harvard', 'yale'];
        return artsKeywords.any((keyword) => uniName.contains(keyword)) || university.worldRanking <= 200;
      case 'Sciences':
        // Most comprehensive universities offer sciences
        return university.worldRanking <= 300;
      default:
        return true;
    }
  }

  void _navigateToUniversity(University university) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicUniversityPage(
          universityName: university.name,
        ),
      ),
    );
  }
}
