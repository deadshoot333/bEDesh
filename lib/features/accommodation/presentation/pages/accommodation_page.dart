import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/inputs/modern_search_bar.dart';
import '../widgets/accommodation_card.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/accommodation_api_service.dart';
import '../../../../core/models/api_error.dart';
import '../../../auth/presentation/pages/login_page.dart';

/// Enum for listing view types
enum ListingViewType { allListings, myListings }

/// Main accommodation page with listings and filters
class AccommodationPage extends StatefulWidget {
  const AccommodationPage({super.key});

  @override
  State<AccommodationPage> createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _showAllListings = false;
  
  // Listing view toggle state
  ListingViewType _currentListingView = ListingViewType.allListings;
  
  // New comprehensive filter system
  String _selectedCountry = 'All Countries';
  String _selectedCity = 'All Cities';
  List<double> _priceRange = [0, 10000];
  String _selectedRoomType = 'All Types';
  String _selectedGender = 'Any';
  DateTime? _availableFrom;
  DateTime? _availableTo;
  List<String> _selectedFacilities = [];
  
  // Data loading state management
  List<Map<String, dynamic>> _accommodations = [];
  List<Map<String, dynamic>> _userAccommodations = []; // Separate list for user accommodations
  bool _isLoading = true;
  String? _errorMessage;
  final AccommodationApiService _apiService = AccommodationApiService();
  
  // Filter options
  final List<String> _countries = [
    'All Countries',
    'UK',
    'USA', 
    'Australia',
    'Canada',
  ];
  
  final Map<String, List<String>> _citiesByCountry = {
    'All Countries': ['All Cities'],
    'UK': ['All Cities', 'London', 'Manchester', 'Birmingham', 'Edinburgh', 'Glasgow', 'Bristol', 'Liverpool', 'Leeds'],
    'USA': ['All Cities', 'New York', 'Los Angeles', 'Chicago', 'Boston', 'San Francisco', 'Washington DC', 'Seattle'],
    'Australia': ['All Cities', 'Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Adelaide', 'Canberra'],
    'Canada': ['All Cities', 'Toronto', 'Vancouver', 'Montreal', 'Calgary', 'Ottawa', 'Edmonton'],
  };
  
  final List<String> _roomTypes = [
    'All Types',
    'Room',
    'Apartment', 
    'Studio',
    'House',
  ];
  
  final List<String> _genderOptions = [
    'Any',
    'Male',
    'Female',
  ];
  
  final List<String> _availableFacilities = [
    'WiFi',
    'Kitchen',
    'Laundry',
    'Parking',
    'Gym',
    'Study Room',
    'Garden',
    'Balcony',
    'Air Conditioning',
    'Heating',
    'Dishwasher',
    'Furnished',
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
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    
    // Load accommodations when page initializes
    _loadAccommodations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Check if user is authenticated before posting accommodation
  bool _checkAuthentication() {
    final token = StorageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if user should be able to see accommodation listings
  bool _shouldShowListings() {
    return _checkAuthentication();
  }

  /// Show login required dialog
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Login Required',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'You need to be logged in to post accommodation requests. Please log in to continue.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          PrimaryButton(
            text: 'Login',
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            size: ButtonSize.small,
          ),
        ],
      ),
    );
  }

  /// Load accommodations from API
  /// Load accommodations based on current view type
  Future<void> _loadAccommodations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check authentication for both All Listings and My Listings
      if (!_shouldShowListings()) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Login required to view accommodations';
        });
        return;
      }

      if (_currentListingView == ListingViewType.allListings) {
        print('🔍 Loading all accommodations from API...');
        
        // Get public accommodations with current filter parameters
        final accommodations = await _apiService.getAccommodations(
          location: _selectedCity != 'All Cities' ? _selectedCity : null,
          maxRent: _priceRange[1] > 0 ? _priceRange[1] : null,
          minRent: _priceRange[0] > 0 ? _priceRange[0] : null,
          genderPreference: _selectedGender != 'Any' ? _selectedGender : null,
          limit: 50,
          offset: 0,
        );

        print('✅ Loaded ${accommodations.length} public accommodations from API');
        
        setState(() {
          _accommodations = accommodations;
          _isLoading = false;
        });
      } else {
        print('👤 Loading user accommodations from API...');
        
        // Check if user is authenticated
        if (!_checkAuthentication()) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Please log in to view your listings.';
          });
          _showLoginRequiredDialog();
          return;
        }
        
        // Get user's accommodations WITH booked posts included and all filters applied
        // My Listings should show user posts with all filters except status filtering
        final userAccommodations = await _apiService.getUserAccommodations(
          location: _selectedCity != 'All Cities' ? _selectedCity : null,
          maxRent: _priceRange[1] > 0 ? _priceRange[1] : null,
          minRent: _priceRange[0] > 0 ? _priceRange[0] : null,
          genderPreference: _selectedGender != 'Any' ? _selectedGender : null,
          roomType: _selectedRoomType != 'All Types' ? _selectedRoomType : null,
          facilities: _selectedFacilities.isNotEmpty ? _selectedFacilities : null,
          availableFrom: _availableFrom,
          availableTo: _availableTo,
          limit: 50,
          offset: 0,
          includeBooked: true,
        );

        print('✅ Loaded ${userAccommodations.length} user accommodations from API');
        
        setState(() {
          _userAccommodations = userAccommodations;
          _isLoading = false;
        });
      }
      
    } catch (e) {
      print('❌ Error loading accommodations: $e');
      
      setState(() {
        _isLoading = false;
        _errorMessage = e is ApiError ? e.message : 'Failed to load accommodations. Please try again.';
      });
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Error loading accommodations'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadAccommodations,
            ),
          ),
        );
      }
    }
  }

  /// Refresh both public and user accommodation lists
  /// Used when an accommodation is edited to ensure data consistency across views
  Future<void> _refreshBothLists() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('🔄 Refreshing public accommodations...');
      // Load public accommodations with current filter parameters
      final accommodations = await _apiService.getAccommodations(
        location: _selectedCity != 'All Cities' ? _selectedCity : null,
        maxRent: _priceRange[1] > 0 ? _priceRange[1] : null,
        minRent: _priceRange[0] > 0 ? _priceRange[0] : null,
        genderPreference: _selectedGender != 'Any' ? _selectedGender : null,
        limit: 50,
        offset: 0,
      );
      
      print('✅ Loaded ${accommodations.length} public accommodations');

      // Load user accommodations if authenticated
      List<Map<String, dynamic>> userAccommodations = [];
      if (_checkAuthentication()) {
        print('🔄 Refreshing user accommodations...');
        userAccommodations = await _apiService.getUserAccommodations(
          location: _selectedCity != 'All Cities' ? _selectedCity : null,
          maxRent: _priceRange[1] > 0 ? _priceRange[1] : null,
          minRent: _priceRange[0] > 0 ? _priceRange[0] : null,
          genderPreference: _selectedGender != 'Any' ? _selectedGender : null,
          roomType: _selectedRoomType != 'All Types' ? _selectedRoomType : null,
          facilities: _selectedFacilities.isNotEmpty ? _selectedFacilities : null,
          availableFrom: _availableFrom,
          availableTo: _availableTo,
          limit: 50,
          offset: 0,
          includeBooked: true,
        );
        print('✅ Loaded ${userAccommodations.length} user accommodations');
      }

      setState(() {
        _accommodations = accommodations;
        _userAccommodations = userAccommodations;
        _isLoading = false;
      });
      
    } catch (e) {
      print('❌ Error refreshing lists: $e');
      
      setState(() {
        _isLoading = false;
        _errorMessage = e is ApiError ? e.message : 'Failed to refresh accommodations.';
      });
    }
  }

  /// Switch between All Listings and My Listings
  void _switchListingView(ListingViewType viewType) {
    if (_currentListingView != viewType) {
      setState(() {
        _currentListingView = viewType;
      });
      _loadAccommodations();
    }
  }

  /// Refresh accommodations (for pull-to-refresh)
  Future<void> _refreshAccommodations() async {
    await _loadAccommodations();
  }

  List<Map<String, dynamic>> get _filteredListings {
    // Use appropriate data based on current view
    var listings = _currentListingView == ListingViewType.allListings 
        ? _accommodations 
        : _userAccommodations;
    
    // Apply client-side filters for both All Listings and My Listings
    // (Status filtering is handled at the backend level)
    // Filter by country
    if (_selectedCountry != 'All Countries') {
      listings = listings.where((l) {
        final country = l['country']?.toString() ?? '';
        return country.contains(_selectedCountry);
      }).toList();
    }
    
    // Filter by room type
    if (_selectedRoomType != 'All Types') {
      listings = listings.where((l) => 
        l['roomType'] == _selectedRoomType
      ).toList();
    }

    // Filter by gender preference
    if (_selectedGender != 'Any') {
      listings = listings.where((l) =>
        l['genderPreference'] == _selectedGender
      ).toList();
    }

    // Filter by price range
    listings = listings.where((l) {
      final rent = _parseDouble(l['rent'] ?? l['monthly_rent']) ?? 0.0;
      return rent >= _priceRange[0] && rent <= _priceRange[1];
    }).toList();

    // Filter by facilities
    if (_selectedFacilities.isNotEmpty) {
      listings = listings.where((l) {
        final facilities = List<String>.from(l['facilities'] ?? []);
        // Convert both selected and available facilities to lowercase for case-insensitive comparison
        final facilitiesLower = facilities.map((f) => f.toLowerCase().trim()).toList();
        final selectedFacilitiesLower = _selectedFacilities.map((f) => f.toLowerCase().trim()).toList();
        
        // Check if all selected facilities are available in the accommodation
        return selectedFacilitiesLower.every((selectedFacility) => 
          facilitiesLower.any((availableFacility) => availableFacility.contains(selectedFacility))
        );
      }).toList();
    }

    // Apply date range filter if set
    if (_availableFrom != null || _availableTo != null) {
      listings = listings.where((l) {
        final availableFromStr = l['availableFrom']?.toString();
        if (availableFromStr == null) return false;

        final availableFrom = DateTime.tryParse(availableFromStr);
        if (availableFrom == null) return false;

        if (_availableFrom != null && availableFrom.isBefore(_availableFrom!)) {
          return false;
        }

        if (_availableTo != null && availableFrom.isAfter(_availableTo!)) {
          return false;
        }

        return true;
      }).toList();
    }
    
    // Apply show all toggle for public listings only
    if (_currentListingView == ListingViewType.allListings) {
      return _showAllListings ? listings : listings.take(3).toList();
    }
    
    return listings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshAccommodations,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Ensures refresh works even with little content
            slivers: [
            // Modern App Bar - consistent with homepage
            SliverToBoxAdapter(
              child: Container(
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
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            // Accommodation title
                            Text(
                              'Accommodation',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        // Using the same ModernIconButton as homepage
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.textOnPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppConstants.radiusL),
                          ),
                          child: IconButton(
                            onPressed: () {
                              // Navigate to profile page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfilePage(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.person,
                              color: AppColors.textOnPrimary,
                              size: 24,
                            ),
                            tooltip: 'Profile',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    ModernSearchBar(
                      hintText: 'Search accommodations...',
                      showFilter: true,
                      onFilterPressed: _showFilterDialog,
                    ),
                    
                    const SizedBox(height: AppConstants.spaceL),
                    
                    // Quick Actions
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: PrimaryButton(
                        text: 'Post Accommodation Request',
                        icon: Icons.add_home_outlined,
                        isExpanded: true,
                        size: ButtonSize.large,
                        backgroundColor: Colors.transparent,
                        onPressed: _handlePostAccommodation,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spaceXL),
                    
                    // New Comprehensive Filter Tags
                    Text(
                      'Filter Accommodations',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spaceM),
                    
                    // Filter Tags - Horizontal Scrollable
                    SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                        children: [
                          _buildHorizontalFilterTag('Country', _selectedCountry, () => _showCountryFilter()),
                          const SizedBox(width: AppConstants.spaceS),
                          _buildHorizontalFilterTag('City', _selectedCity, () => _showCityFilter()),
                          const SizedBox(width: AppConstants.spaceS),
                          _buildHorizontalFilterTag('Room Type', _selectedRoomType, () => _showRoomTypeFilter()),
                          const SizedBox(width: AppConstants.spaceS),
                          _buildHorizontalFilterTag('Price', _getPriceDisplayText(), () => _showPriceFilter()),
                          const SizedBox(width: AppConstants.spaceS),
                          _buildHorizontalFilterTag('Gender', _getGenderDisplayText(), () => _showGenderFilter()),
                          const SizedBox(width: AppConstants.spaceS),
                          _buildHorizontalFilterTag('Availability', _getAvailabilityText(), () => _showAvailabilityFilter()),
                          const SizedBox(width: AppConstants.spaceS),
                          _buildHorizontalFilterTag('Facilities', _getFacilitiesText(), () => _showFacilitiesFilter()),
                          const SizedBox(width: AppConstants.spaceM),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spaceM),
                    
                    // Clear Filters Button
                    if (_hasActiveFilters())
                      TextButton.icon(
                        onPressed: _clearAllFilters,
                        icon: Icon(
                          Icons.clear_all,
                          color: AppColors.error,
                          size: 18,
                        ),
                        label: Text(
                          'Clear All Filters',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: AppConstants.spaceL),
                    
                    // Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _currentListingView == ListingViewType.allListings 
                                ? 'Accommodation Listings' 
                                : 'My Listings',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_currentListingView == ListingViewType.allListings)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showAllListings = !_showAllListings;
                              });
                            },
                            icon: Icon(
                              _showAllListings ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              _showAllListings ? 'Show Less' : 'View All',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.spaceM),
                    
                    // Listing View Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _switchListingView(ListingViewType.allListings),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppConstants.spaceS,
                                  horizontal: AppConstants.spaceM,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentListingView == ListingViewType.allListings
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                ),
                                child: Text(
                                  'All Listings',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: _currentListingView == ListingViewType.allListings
                                        ? AppColors.textOnPrimary
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _switchListingView(ListingViewType.myListings),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppConstants.spaceS,
                                  horizontal: AppConstants.spaceM,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentListingView == ListingViewType.myListings
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                ),
                                child: Text(
                                  'My Listings',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: _currentListingView == ListingViewType.myListings
                                        ? AppColors.textOnPrimary
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spaceM),
                    
                    // List View
                    _buildListView(),
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

  Widget _buildListView() {
    // Check if user should be able to see listings
    if (!_shouldShowListings()) {
      return _buildAuthenticationRequiredState();
    }
    
    final listings = _filteredListings;
    if (listings.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      children: listings.map((listing) {
        return AccommodationCard(
          title: listing['title'] ?? 'Accommodation',
          location: listing['location'] ?? 'Location not specified',
          propertyType: listing['roomType'] ?? 'Room', // Backend returns 'roomType'
          rent: _parseDouble(listing['rent'] ?? listing['monthly_rent']) ?? 0.0,
          imageUrls: (listing['imageUrls'] as List<dynamic>?)
              ?.map((url) => url.toString())
              .toList(), // Pass the full imageUrls array
          availableFrom: _formatDateString(listing['availableFrom']?.toString()),
          country: listing['country']?.toString(),
          genderPreference: listing['genderPreference']?.toString(),
          facilities: listing['facilities'] != null 
              ? List<String>.from(listing['facilities']) 
              : [], // Get facilities from backend
          status: _formatStatus(listing['status']?.toString()), // Format status from backend
          onTap: () => _showAccommodationDetails(listing),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    final isMyListings = _currentListingView == ListingViewType.myListings;
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      child: Column(
        children: [
          Icon(
            isMyListings ? Icons.home_work_outlined : Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppConstants.spaceM),
          Text(
            isMyListings ? 'No listings yet' : 'No listings found',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            isMyListings 
                ? 'Post your first accommodation to get started'
                : 'Try adjusting your filters or search terms',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          if (isMyListings) ...[
            const SizedBox(height: AppConstants.spaceM),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: PrimaryButton(
                text: '🏠 Post Your First Accommodation',
                icon: Icons.add_circle_outline,
                size: ButtonSize.medium,
                backgroundColor: Colors.transparent,
                onPressed: _handlePostAccommodation,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuthenticationRequiredState() {
    final isMyListings = _currentListingView == ListingViewType.myListings;
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceL),
          Text(
            'Login Required',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            isMyListings 
                ? 'Please log in to view and manage your accommodation posts'
                : 'Please log in to browse accommodation listings from students worldwide',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spaceL),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: PrimaryButton(
              text: 'Login Now',
              icon: Icons.login_outlined,
              size: ButtonSize.medium,
              backgroundColor: Colors.transparent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ),
          const SizedBox(height: AppConstants.spaceM),
          Text(
            'Join thousands of students finding accommodation worldwide',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // This method is now replaced by individual filter methods
    // but keeping it for backwards compatibility
    _showCountryFilter();
  }

  // Horizontal filter tag for scrollable row
  Widget _buildHorizontalFilterTag(String label, String value, VoidCallback onTap) {
    final isDefault = value.contains('All') || value.contains('Any') || value.isEmpty || value == 'Any Time' || value == 'Any Facilities';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceS,
          vertical: AppConstants.spaceXS,
        ),
        decoration: BoxDecoration(
          color: isDefault ? AppColors.accent : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: isDefault ? AppColors.borderLight : AppColors.primary,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.labelMedium.copyWith(
                color: isDefault ? AppColors.textSecondary : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getAvailabilityText() {
    if (_availableFrom == null && _availableTo == null) {
      return 'Any Time';
    } else if (_availableFrom != null && _availableTo != null) {
      return '${_formatDate(_availableFrom!)} - ${_formatDate(_availableTo!)}';
    } else if (_availableFrom != null) {
      return 'From ${_formatDate(_availableFrom!)}';
    } else {
      return 'Until ${_formatDate(_availableTo!)}';
    }
  }

  String _getFacilitiesText() {
    if (_selectedFacilities.isEmpty) {
      return 'Any Facilities';
    } else if (_selectedFacilities.length == 1) {
      return _selectedFacilities.first;
    } else {
      return '${_selectedFacilities.length} selected';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format status text for display
  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'Available';
    // Capitalize first letter
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  // Helper function to format date string from backend
  String _formatDateString(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Available now';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Available now'; // Return default if parsing fails
    }
  }

  bool _hasActiveFilters() {
    return _selectedCountry != 'All Countries' ||
           _selectedCity != 'All Cities' ||
           _priceRange[0] != 0 || _priceRange[1] != 10000 ||
           _selectedRoomType != 'All Types' ||
           _selectedGender != 'Any' ||
           _availableFrom != null ||
           _availableTo != null ||
           _selectedFacilities.isNotEmpty;
  }

  String _getPriceDisplayText() {
    // Check if price range is at default values
    if (_priceRange[0] == 0 && _priceRange[1] == 10000) {
      return 'Any Price';
    }
    return '\$${_priceRange[0].toInt()}-\$${_priceRange[1].toInt()}';
  }

  String _getGenderDisplayText() {
    // Check if gender is at default value
    if (_selectedGender == 'Any') {
      return 'Any Gender';
    }
    return _selectedGender;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCountry = 'All Countries';
      _selectedCity = 'All Cities';
      _priceRange = [0, 10000];
      _selectedRoomType = 'All Types';
      _selectedGender = 'Any';
      _availableFrom = null;
      _availableTo = null;
      _selectedFacilities.clear();
    });
    // Auto-refresh listings after clearing filters
    _loadAccommodations();
  }

  // Individual filter dialogs
  void _showCountryFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spaceL),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Country',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),
            Expanded(
              child: ListView.builder(
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  final country = _countries[index];
                  return ListTile(
                    title: Text(country),
                    leading: Radio<String>(
                      value: country,
                      groupValue: _selectedCountry,
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value!;
                          // Reset city when country changes
                          _selectedCity = _citiesByCountry[_selectedCountry]!.first;
                        });
                        Navigator.pop(context);
                        // Auto-refresh listings after country selection
                        _loadAccommodations();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCityFilter() {
    // Check if a country is selected first
    if (_selectedCountry == 'All Countries') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.backgroundSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          title: Text(
            'Select Country First',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Please select a country first before choosing a city.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    final cities = _citiesByCountry[_selectedCountry] ?? ['All Cities'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spaceL),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select City in $_selectedCountry',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),
            Expanded(
              child: ListView.builder(
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  return ListTile(
                    title: Text(city),
                    leading: Radio<String>(
                      value: city,
                      groupValue: _selectedCity,
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value!;
                        });
                        Navigator.pop(context);
                        // Auto-refresh listings after city selection
                        _loadAccommodations();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(AppConstants.spaceL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price Range (per month)',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),
              Text(
                '\$${_priceRange[0].toInt()} - \$${_priceRange[1].toInt()}',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spaceM),
              RangeSlider(
                values: RangeValues(_priceRange[0], _priceRange[1]),
                min: 0,
                max: 10000,
                divisions: 100,
                activeColor: AppColors.primary,
                onChanged: (values) {
                  setModalState(() {
                    _priceRange = [values.start, values.end];
                  });
                },
              ),
              const SizedBox(height: AppConstants.spaceL),
              // Show reset and apply buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setModalState(() {
                          _priceRange = [0, 10000]; // Reset to default range
                        });
                        setState(() {
                          // Update main state
                        });
                        Navigator.pop(context);
                        // Auto-refresh listings after price reset
                        _loadAccommodations();
                      },
                      icon: Icon(
                        Icons.restart_alt,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      label: Text(
                        'Reset',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Apply Filter',
                      onPressed: () {
                        setState(() {
                          // Update main state - price range is already updated in setModalState
                        });
                        Navigator.pop(context);
                        // Auto-refresh listings after price selection
                        _loadAccommodations();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoomTypeFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spaceL),
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Room Type',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),
            Expanded(
              child: ListView.builder(
                itemCount: _roomTypes.length,
                itemBuilder: (context, index) {
                  final type = _roomTypes[index];
                  return ListTile(
                    title: Text(type),
                    leading: Radio<String>(
                      value: type,
                      groupValue: _selectedRoomType,
                      onChanged: (value) {
                        setState(() {
                          _selectedRoomType = value!;
                        });
                        Navigator.pop(context);
                        // Auto-refresh listings after room type selection
                        _loadAccommodations();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenderFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spaceL),
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender Preference',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),
            Expanded(
              child: ListView.builder(
                itemCount: _genderOptions.length,
                itemBuilder: (context, index) {
                  final gender = _genderOptions[index];
                  return ListTile(
                    title: Text(gender),
                    leading: Radio<String>(
                      value: gender,
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                        Navigator.pop(context);
                        // Auto-refresh listings after gender selection
                        _loadAccommodations();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvailabilityFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Availability Period',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available From',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceS),
                      GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _availableFrom ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                          );
                          if (date != null) {
                            setState(() {
                              _availableFrom = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppConstants.spaceM),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                          child: Text(
                            _availableFrom != null ? _formatDate(_availableFrom!) : 'Select Date',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _availableFrom != null ? AppColors.textPrimary : AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available To',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceS),
                      GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _availableTo ?? DateTime.now().add(const Duration(days: 365)),
                            firstDate: _availableFrom ?? DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                          );
                          if (date != null) {
                            setState(() {
                              _availableTo = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppConstants.spaceM),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                          child: Text(
                            _availableTo != null ? _formatDate(_availableTo!) : 'Select Date',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _availableTo != null ? AppColors.textPrimary : AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceL),
            // Show clear button if any dates are selected
            if (_availableFrom != null || _availableTo != null) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _availableFrom = null;
                          _availableTo = null;
                        });
                        Navigator.pop(context);
                        // Auto-refresh listings after clearing dates
                        _loadAccommodations();
                      },
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.error,
                        size: 18,
                      ),
                      label: Text(
                        'Clear Dates',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Apply Filter',
                      onPressed: () {
                        Navigator.pop(context);
                        // Auto-refresh listings after availability selection
                        _loadAccommodations();
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              PrimaryButton(
                text: 'Apply Filter',
                isExpanded: true,
                onPressed: () {
                  Navigator.pop(context);
                  // Auto-refresh listings after availability selection
                  _loadAccommodations();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFacilitiesFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(AppConstants.spaceL),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Facilities',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: AppConstants.spaceS,
                    runSpacing: AppConstants.spaceS,
                    children: _availableFacilities.map((facility) {
                      final isSelected = _selectedFacilities.contains(facility);
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            if (isSelected) {
                              _selectedFacilities.remove(facility);
                            } else {
                              _selectedFacilities.add(facility);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceM,
                            vertical: AppConstants.spaceS,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.accent,
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.borderLight,
                            ),
                          ),
                          child: Text(
                            facility,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),
              // Show clear button if any facilities are selected
              if (_selectedFacilities.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setModalState(() {
                            _selectedFacilities.clear();
                          });
                          setState(() {
                            // Update main state
                          });
                          Navigator.pop(context);
                          // Auto-refresh listings after clearing facilities
                          _loadAccommodations();
                        },
                        icon: Icon(
                          Icons.clear_all,
                          color: AppColors.error,
                          size: 18,
                        ),
                        label: Text(
                          'Clear All',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Apply Filter',
                        onPressed: () {
                          setState(() {
                            // Update main state - facilities are already updated in setModalState
                          });
                          Navigator.pop(context);
                          // Auto-refresh listings after facility selection
                          _loadAccommodations();
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                PrimaryButton(
                  text: 'Apply Filter',
                  isExpanded: true,
                  onPressed: () {
                    setState(() {
                      // Update main state - facilities are already updated in setModalState
                    });
                    Navigator.pop(context);
                    // Auto-refresh listings after facility selection
                    _loadAccommodations();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handlePostAccommodation() {
    // Check if user is authenticated
    if (!_checkAuthentication()) {
      _showLoginRequiredDialog();
      return;
    }
    
    _showPostAccommodationForm();
  }

  void _showPostAccommodationForm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PostAccommodationForm(
        countries: _countries.where((c) => c != 'All Countries').toList(),
        citiesByCountry: _citiesByCountry.map((key, value) => MapEntry(
          key == 'All Countries' ? 'UK' : key, // Default to UK if All Countries
          value.where((c) => c != 'All Cities').toList(),
        )),
        roomTypes: _roomTypes.where((type) => type != 'All Types').toList(),
        genderOptions: _genderOptions,
        availableFacilities: _availableFacilities,
        onAccommodationCreated: () {
          // Refresh the accommodation list when a new accommodation is created
          _loadAccommodations();
        },
      ),
    );
  }

  void _showAccommodationDetails(Map<String, dynamic> listing) async {
    print('🔍 Opening accommodation details dialog');
    
    if (!mounted) return; // Safety check before showing dialog
    
    // Store the original accommodation ID to check if it was deleted
    final originalAccommodationId = listing['id']?.toString();
    
    final result = await showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _AccommodationDetailsDialog(listing: listing),
    );
    
    print('🔄 Dialog closed with result: $result');
    
    // Additional safety check after dialog closes
    if (!mounted) {
      print('⚠️ Widget disposed after dialog close, skipping result handling');
      return;
    }
    
    // Always refresh the data when dialog closes to catch any changes
    print('🔄 Refreshing accommodations after dialog close');
    
    // If accommodation was edited, refresh both lists to ensure data consistency
    if (result == 'edited') {
      print('✅ Edit operation detected - refreshing both public and user lists');
      await _refreshBothLists();
    } else if (result == true) {
      // True result indicates delete operation - refresh normally
      print('✅ Delete operation detected - refreshing accommodations');
      await _loadAccommodations();
    } else {
      // Standard refresh based on current view for other cases
      await _loadAccommodations();
    }
    
    print('✅ Data refresh completed');
    
    // Check if the accommodation was deleted by comparing before/after
    bool wasDeleted = false;
    if (originalAccommodationId != null) {
      print('🔍 Checking if accommodation $originalAccommodationId was deleted...');
      
      final stillExistsInPublic = _accommodations.any((acc) => acc['id']?.toString() == originalAccommodationId);
      final stillExistsInUser = _userAccommodations.any((acc) => acc['id']?.toString() == originalAccommodationId);
      final stillExists = stillExistsInPublic || stillExistsInUser;
      
      wasDeleted = !stillExists;
      
      print('🔍 Public accommodations count: ${_accommodations.length}');
      print('🔍 User accommodations count: ${_userAccommodations.length}');
      print('🔍 Still exists in public: $stillExistsInPublic');
      print('🔍 Still exists in user: $stillExistsInUser');
      print('🔍 Was deleted: $wasDeleted');
    }
    
    // Handle different return types or detect deletion
    if (result == 'edited') {
      // Edit success case - show edit success message
      print('✅ Edit success detected - showing edit success message');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Accommodation updated successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else if (result == true || wasDeleted) {
      // Delete success case - show delete success message
      print('✅ Delete success detected - result: $result, wasDeleted: $wasDeleted');
      
      if (mounted && wasDeleted) {
        print('✅ Showing success message for deleted accommodation');
        
        // Small delay to ensure UI is ready for the success message
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Accommodation deleted successfully'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (mounted && result == true) {
        print('✅ Showing success message for delete dialog result');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Accommodation deleted successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        print('⚠️ Delete success detected but not showing message - mounted: $mounted, wasDeleted: $wasDeleted, result: $result');
      }
    } else if (result is String && result.startsWith('error:')) {
      // Error case - show error message
      final errorMessage = result.substring(6); // Remove 'error:' prefix
      print('❌ Delete operation failed: $errorMessage');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to delete accommodation: $errorMessage'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Helper method to safely parse double values from dynamic data
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}

// Post Accommodation Form Widget
class _PostAccommodationForm extends StatefulWidget {
  final List<String> countries;
  final Map<String, List<String>> citiesByCountry;
  final List<String> roomTypes;
  final List<String> genderOptions;
  final List<String> availableFacilities;
  final VoidCallback? onAccommodationCreated;

  const _PostAccommodationForm({
    required this.countries,
    required this.citiesByCountry,
    required this.roomTypes,
    required this.genderOptions,
    required this.availableFacilities,
    this.onAccommodationCreated,
  });

  @override
  State<_PostAccommodationForm> createState() => _PostAccommodationFormState();
}

class _PostAccommodationFormState extends State<_PostAccommodationForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rentController = TextEditingController();
  final _contactEmailController = TextEditingController();
  
  String _selectedCountry = 'UK';
  String _selectedCity = 'London';
  late String _selectedRoomType; // Will be set in initState
  late String _selectedGender; // Will be set in initState
  DateTime? _availableFrom;
  DateTime? _availableTo;
  List<String> _selectedFacilities = [];
  bool _isSubmitting = false;
  
  // Image picker variables
  List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  static const int _maxImages = 5;

  /// Helper function to create image widget that works on both web and mobile
  Widget _buildImageFromXFile(XFile imageFile, {double? width, double? height, BoxFit? fit}) {
    if (kIsWeb) {
      // On web, XFile.path returns a blob URL that works with Image.network
      return Image.network(
        imageFile.path,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
        },
      );
    } else {
      // On mobile platforms, use Image.file with File
      return Image.file(
        File(imageFile.path),
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize with first available options (no 'All' options)
    _selectedCountry = widget.countries.isNotEmpty ? widget.countries.first : 'UK';
    _selectedCity = widget.citiesByCountry[_selectedCountry]?.isNotEmpty == true 
        ? widget.citiesByCountry[_selectedCountry]!.first 
        : 'London';
    // Initialize room type with the first option from the provided list
    _selectedRoomType = widget.roomTypes.isNotEmpty ? widget.roomTypes.first : 'Room';
    // Initialize gender with the first option from the provided list
    _selectedGender = widget.genderOptions.isNotEmpty ? widget.genderOptions.first : 'Any';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rentController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 800;
    final dialogWidth = isWideScreen ? 600.0 : screenSize.width * 0.95;
    final dialogHeight = screenSize.height * (isWideScreen ? 0.8 : 0.95);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 40 : 10,
        vertical: isWideScreen ? 40 : 20,
      ),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceL),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusXL),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Post Accommodation',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: 500, // Fixed width to ensure horizontal scrolling
                    padding: const EdgeInsets.all(AppConstants.spaceL),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                      // Title Field
                      _buildSectionTitle('Property Title'),
                      TextFormField(
                        controller: _titleController,
                        decoration: _buildInputDecoration('e.g., "Cozy room near university"'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: AppConstants.spaceL),
                      
                      // Location Section
                      _buildSectionTitle('Location'),
                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: _buildDropdownField(
                              'Country',
                              _selectedCountry,
                              widget.countries.where((c) => c != 'All Countries').toList(),
                              (value) {
                                setState(() {
                                  _selectedCountry = value!;
                                  // Set city to first available city for the selected country
                                  final availableCities = widget.citiesByCountry[_selectedCountry] ?? [];
                                  _selectedCity = availableCities.isNotEmpty ? availableCities.first : 'London';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          SizedBox(
                            width: 200,
                            child: _buildDropdownField(
                              'City',
                              _selectedCity,
                              widget.citiesByCountry[_selectedCountry] ?? ['London'],
                              (value) {
                                setState(() {
                                  _selectedCity = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppConstants.spaceL),
                      
                      // Property Details Section
                      _buildSectionTitle('Property Details'),
                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: _buildDropdownField(
                              'Room Type',
                              _selectedRoomType,
                              widget.roomTypes,
                              (value) {
                                setState(() {
                                  _selectedRoomType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          SizedBox(
                            width: 200,
                            child: TextFormField(
                              controller: _rentController,
                              decoration: _buildInputDecoration('Monthly rent (\$)'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter rent amount';
                                }
                                final rent = double.tryParse(value);
                                if (rent == null) {
                                  return 'Please enter a valid number';
                                }
                                if (rent < 0) {
                                  return 'Rent cannot be negative';
                                }
                                if (rent > 10000) {
                                  return 'Rent cannot exceed \$10,000';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppConstants.spaceL),
                      
                      // Availability Section
                      _buildSectionTitle('Availability'),
                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: _buildDateField(
                              'Available From',
                              _availableFrom,
                              (date) => setState(() => _availableFrom = date),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          SizedBox(
                            width: 200,
                            child: _buildDateField(
                              'Available Until',
                              _availableTo,
                              (date) => setState(() => _availableTo = date),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppConstants.spaceL),
                      
                      // Contact Email Field
                      _buildSectionTitle('Contact Email *'),
                      SizedBox(
                        width: 416, // 200 + 16 + 200 to match the width of two fields above
                        child: TextFormField(
                          controller: _contactEmailController,
                          decoration: _buildInputDecoration('e.g., john.doe@email.com'),
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your contact email';
                            }
                            // Basic email validation
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.spaceL),
                      
                      // Gender Preference
                      _buildSectionTitle('Gender Preference'),
                      SizedBox(
                        width: 416, // Full width to match contact email
                        child: _buildDropdownField(
                          'Gender Preference',
                          _selectedGender,
                          widget.genderOptions,
                          (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.spaceL),
                      
                      // Facilities Section
                      _buildSectionTitle('Facilities'),
                      _buildFacilitiesSelection(),
                      
                      const SizedBox(height: AppConstants.spaceL),
                      
                      // Description Field
                      _buildSectionTitle('Description'),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _buildInputDecoration(
                          'Describe your accommodation, rules, preferences...',
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: AppConstants.spaceL),
                      
                      // Photo Upload Section
                      _buildSectionTitle('Photos (Optional)'),
                      _buildPhotoUploadSection(),
                      
                      const SizedBox(height: AppConstants.spaceXL),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceL),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusL),
                            ),
                          ),
                          child: _isSubmitting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(AppColors.textOnPrimary),
                                      ),
                                    ),
                                    const SizedBox(width: AppConstants.spaceS),
                                    Text(
                                      'Posting...',
                                      style: AppTextStyles.buttonLarge.copyWith(
                                        color: AppColors.textOnPrimary,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Post Accommodation',
                                  style: AppTextStyles.buttonLarge.copyWith(
                                    color: AppColors.textOnPrimary,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceS),
      child: Text(
        title,
        style: AppTextStyles.h5.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceM,
        vertical: AppConstants.spaceM,
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXS),
        Container(
          height: 48, // Fixed height to make dropdowns more compact
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceM,
                vertical: 8, // Reduced padding
              ),
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              dropdownColor: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    void Function(DateTime?) onDateSelected,
  ) {
    // Check for date validation error
    String? errorMessage;
    if (label == 'Available Until' && _availableFrom != null && date != null) {
      if (date.isBefore(_availableFrom!) || date.isAtSameMomentAs(_availableFrom!)) {
        errorMessage = 'End date must be after start date';
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXS),
        GestureDetector(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (selectedDate != null) {
              onDateSelected(selectedDate);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceM,
              vertical: AppConstants.spaceM,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: errorMessage != null ? AppColors.error : AppColors.borderLight,
                width: errorMessage != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    date != null 
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select date',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: errorMessage != null 
                          ? AppColors.error
                          : date != null 
                              ? AppColors.textPrimary 
                              : AppColors.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: errorMessage != null ? AppColors.error : AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        // Show error message if validation fails
        if (errorMessage != null) ...[
          const SizedBox(height: AppConstants.spaceXS),
          Text(
            errorMessage,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFacilitiesSelection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select available facilities:',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Wrap(
            spacing: AppConstants.spaceS,
            runSpacing: AppConstants.spaceS,
            children: widget.availableFacilities.map((facility) {
              final isSelected = _selectedFacilities.contains(facility);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedFacilities.remove(facility);
                    } else {
                      _selectedFacilities.add(facility);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceM,
                    vertical: AppConstants.spaceS,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.accent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderLight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      if (isSelected) const SizedBox(width: AppConstants.spaceXS),
                      Text(
                        facility,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected 
                              ? AppColors.primary 
                              : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload Button and Info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spaceL),
          decoration: BoxDecoration(
            color: AppColors.accent,
            border: Border.all(
              color: AppColors.borderLight,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppConstants.spaceS),
              Text(
                'Upload Photos (${_selectedImages.length}/$_maxImages)',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXS),
              Text(
                'Add photos to make your listing more attractive',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spaceM),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _selectedImages.length >= _maxImages ? null : () => _pickImages(ImageSource.gallery),
                    icon: Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  OutlinedButton.icon(
                    onPressed: _selectedImages.length >= _maxImages ? null : () => _pickImages(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Selected Images Preview
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spaceM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Photos:',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: _clearAllImages,
                icon: Icon(Icons.clear_all, size: 18),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceS),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: EdgeInsets.only(
                    right: index < _selectedImages.length - 1 ? AppConstants.spaceS : 0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Stack(
                    children: [
                      // Image
                      GestureDetector(
                        onTap: () => _showImagePreview(index),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          child: _buildImageFromXFile(
                            _selectedImages[index],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Remove Button
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // Image picker methods
  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        // Pick single image from gallery (user can repeat to add multiple)
        final XFile? singleImage = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        
        List<XFile> images = [];
        if (singleImage != null) {
          images = [singleImage];
        }
        if (images.isNotEmpty) {
          // Validate and filter images
          final List<XFile> validImages = [];
          final List<String> validationErrors = [];
          
          for (final image in images) {
            // Check file type
            if (!_isValidImageFile(image)) {
              validationErrors.add('${image.name}: Invalid file type. Only JPG, PNG, and WebP are allowed.');
              continue;
            }
            
            // Check file size
            if (!await _isValidImageSize(image)) {
              validationErrors.add('${image.name}: File too large. Maximum 10MB per image.');
              continue;
            }
            
            validImages.add(image);
          }
          
          if (validImages.isNotEmpty) {
            final remainingSlots = _maxImages - _selectedImages.length;
            final imagesToAdd = validImages.take(remainingSlots).toList();
            
            setState(() {
              // Add new images but don't exceed max limit
              _selectedImages.addAll(imagesToAdd);
            });
            
            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${imagesToAdd.length} photo(s) successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
          
          // Show validation errors if any
          if (validationErrors.isNotEmpty && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Some images were skipped: ${validationErrors.join(' ')}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        // Pick single image from camera
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85, // Compress to reduce file size
        );
        
        if (image != null) {
          // Validate image
          if (!_isValidImageFile(image)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Invalid file type. Only JPG, PNG, and WebP are allowed.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          }
          
          if (!await _isValidImageSize(image)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Image too large. Maximum 10MB per image.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          }
          
          setState(() {
            _selectedImages.add(image);
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Photo added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting images: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo removed'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearAllImages() {
    if (_selectedImages.isEmpty) return;
    
    setState(() {
      _selectedImages.clear();
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All photos cleared'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Image validation helper methods
  bool _isValidImageFile(XFile imageFile) {
    final String fileName = imageFile.name.toLowerCase();
    final List<String> allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    
    return allowedExtensions.any((ext) => fileName.endsWith(ext));
  }

  Future<bool> _isValidImageSize(XFile imageFile, {double maxSizeMB = 10.0}) async {
    try {
      // Use XFile.length() instead of File for cross-platform compatibility
      final int lengthInBytes = await imageFile.length();
      final double sizeInMB = lengthInBytes / (1024 * 1024);
      
      // Log file size for debugging
      print('📏 Image size check: ${imageFile.name} is ${sizeInMB.toStringAsFixed(2)}MB (max: ${maxSizeMB}MB)');
      
      return sizeInMB <= maxSizeMB;
    } catch (e) {
      print('❌ Error checking image size: $e');
      return false;
    }
  }

  void _showImagePreview(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: _buildImageFromXFile(
                    _selectedImages[index],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 40,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation for dropdowns
    if (_selectedCountry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a country'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a city'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedRoomType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a room type'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a gender preference'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_availableFrom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select availability start date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_availableTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select availability end date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Critical date validation - this should prevent the database constraint error
    if (_availableTo!.isBefore(_availableFrom!) || _availableTo!.isAtSameMomentAs(_availableFrom!)) {
      print('❌ DATE VALIDATION FAILED: availableFrom: $_availableFrom, availableTo: $_availableTo');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Available end date must be after the start date'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create the accommodation data in the format expected by the API
      final accommodationData = {
        'title': _titleController.text.trim(),
        'location': '$_selectedCity, $_selectedCountry',
        'rent': double.parse(_rentController.text),
        'roomType': _selectedRoomType, // Added missing roomType field
        'contactEmail': _contactEmailController.text.trim(),
        'availableFrom': _availableFrom!.toIso8601String(),
        'availableTo': _availableTo?.toIso8601String(),
        'genderPreference': _selectedGender,
        'facilities': _selectedFacilities,
        'description': _descriptionController.text.trim(),
      };

      print('🏠 Creating accommodation via API...');
      print('📝 Accommodation data: $accommodationData');

      // Create accommodation via API
      final apiService = AccommodationApiService();
      final createdAccommodation = await apiService.createAccommodation(accommodationData);
      
      print('✅ Accommodation created with ID: ${createdAccommodation['id']}');

      // Upload images if any were selected (hybrid approach)
      if (_selectedImages.isNotEmpty) {
        print('🖼️ Uploading ${_selectedImages.length} images...');
        try {
          final imageUrls = await apiService.uploadImagesToAccommodation(
            createdAccommodation['id'], 
            _selectedImages
          );
          print('✅ Images uploaded successfully: ${imageUrls.length} URLs');
        } catch (imageError) {
          print('⚠️ Image upload failed but accommodation was created: $imageError');
          // Continue with success - accommodation was created even if images failed
        }
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppConstants.spaceS),
                Expanded(
                  child: Text(
                    'Accommodation posted successfully!',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pop(context);
        
        // Call the callback to refresh the accommodation list
        widget.onAccommodationCreated?.call();
      }
    } catch (e) {
      print('❌ Form submission error: $e');
      
      if (mounted) {
        String errorMessage = 'Error posting accommodation. Please try again.';
        
        // Handle different types of errors
        if (e is ApiError) {
          if (e.statusCode == 401) {
            errorMessage = 'Your session has expired. Please log in again.';
            // Close form and redirect to login
            Navigator.pop(context); // Close form
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
            return;
          } else if (e.statusCode == 403) {
            errorMessage = 'You do not have permission to post accommodations.';
          } else if (e.statusCode == 400) {
            errorMessage = 'Please check your input data and try again.';
          } else if (e.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            errorMessage = e.message;
          }
        } else if (e.toString().contains('network') || e.toString().contains('connection')) {
          errorMessage = 'Network error. Please check your internet connection.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

// Accommodation Details Dialog Widget
class _AccommodationDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> listing;

  const _AccommodationDetailsDialog({
    required this.listing,
  });

  @override
  State<_AccommodationDetailsDialog> createState() => _AccommodationDetailsDialogState();
}

class _AccommodationDetailsDialogState extends State<_AccommodationDetailsDialog> {
  int _currentPhotoIndex = 0;
  final PageController _photoPageController = PageController();

  @override
  void dispose() {
    _photoPageController.dispose();
    super.dispose();
  }

  // Check if current user owns this accommodation
  bool get _isOwner {
    // Check authentication status first
    final isAuthenticated = StorageService.isLoggedIn();
    final accessToken = StorageService.getAccessToken();
    final currentUser = StorageService.getUserData();
    
    // Try multiple field names for posted_by (backend inconsistency)
    final postedBy = widget.listing['posted_by']?.toString() ?? 
                     widget.listing['postedBy']?.toString() ?? 
                     widget.listing['posted_by_id']?.toString();
    
    print('🔍 OWNERSHIP DEBUG:');
    print('  Is authenticated: $isAuthenticated');
    print('  Access token exists: ${accessToken != null}');
    if (accessToken != null && accessToken.length > 20) {
      print('  Access token preview: ${accessToken.substring(0, 20)}...');
    }
    print('  Current user ID: ${currentUser?.id} (type: ${currentUser?.id.runtimeType})');
    print('  Posted by field: $postedBy (type: ${postedBy.runtimeType})');
    print('  Available listing keys: ${widget.listing.keys.toList()}');
    
    if (currentUser == null || postedBy == null) {
      print('  ❌ Missing data: currentUser=${currentUser != null}, postedBy=${postedBy != null}');
      
      // If user is authenticated but currentUser is null, try to fetch profile
      if (isAuthenticated && currentUser == null) {
        print('  🔄 User authenticated but data missing - attempting to fetch profile...');
        _fetchUserProfileIfNeeded();
      }
      
      return false;
    }
    
    // Ensure both IDs are strings for comparison
    final currentUserId = currentUser.id.toString().trim();
    final postedById = postedBy.toString().trim();
    
    print('  Normalized current user ID: "$currentUserId"');
    print('  Normalized posted by ID: "$postedById"');
    print('  String comparison result: ${currentUserId == postedById}');
    
    final isOwner = currentUserId == postedById;
    print('  🏆 Final ownership result: $isOwner');
    
    return isOwner;
  }

  // Handle edit accommodation
  void _handleEdit() async {
    // Don't close details dialog yet - keep it open until edit completes
    // Use the current context for the edit dialog
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => EditAccommodationDialog(
        listing: widget.listing,
        onUpdated: () {
          Navigator.pop(context, 'edited'); // Return 'edited' to indicate edit success
        },
      ),
    );
    
    print('🔄 Edit completed. Result: $result');
    
    // If edit was successful, close details dialog and signal refresh to main page
    if (result == 'edited') {
      print('✅ Edit successful - closing details dialog with refresh signal');
      Navigator.pop(context, 'edited'); // Close details dialog and pass edit result to main page
    }
  }

  // Handle delete accommodation
  Future<void> _handleDelete() async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Delete Accommodation',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this accommodation? This action cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          PrimaryButton(
            text: 'Delete',
            size: ButtonSize.small,
            backgroundColor: AppColors.error,
            onPressed: () async {
              try {
                final accommodationId = widget.listing['id']?.toString();
                if (accommodationId == null) {
                  throw Exception('Invalid accommodation ID');
                }

                print('🗑️ Attempting to delete accommodation: $accommodationId');
                
                final apiService = AccommodationApiService();
                final success = await apiService.deleteAccommodation(accommodationId);

                if (success) {
                  print('✅ Delete successful, closing dialog with success');
                  Navigator.pop(context, true); // Return true to indicate successful deletion
                } else {
                  throw Exception('Delete operation failed');
                }
              } catch (e) {
                print('❌ Delete error: $e');
                Navigator.pop(context, 'error:${e.toString()}');
              }
            },
          ),
        ],
      ),
    );
    
    // Handle the result
    if (result == true) {
      print('✅ Delete operation successful, refreshing accommodations');
      // Close the details dialog with delete success signal
      if (mounted && context.mounted) {
        Navigator.pop(context, true);
      }
    } else if (result != null && result.toString().startsWith('error:')) {
      print('❌ Delete operation failed: $result');
      // Show error message but don't close details dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete accommodation: ${result.toString().substring(6)}'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Photos from backend API - imageUrls field
  List<String> get _photos {
    // Get photos from backend data - backend returns 'imageUrls' field
    final photos = widget.listing['imageUrls'] as List<dynamic>?;
    return photos?.cast<String>() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 800;
    final dialogWidth = isWideScreen ? 700.0 : screenSize.width * 0.95;
    final dialogHeight = screenSize.height * (isWideScreen ? 0.85 : 0.9);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 40 : 10,
        vertical: isWideScreen ? 30 : 20,
      ),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        child: Column(
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceL),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusXL),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.listing['title'] ?? 'Accommodation Details',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textOnPrimary,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: math.max(dialogWidth - 40, 600), // Ensure minimum width for horizontal scroll
                    padding: const EdgeInsets.all(AppConstants.spaceL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo Gallery Section
                        if (_photos.isNotEmpty) _buildPhotoGallery(),
                        if (_photos.isEmpty) _buildNoPhotosSection(),
                        
                        const SizedBox(height: AppConstants.spaceL),

                        // Property Information
                        _buildPropertyInfo(),

                        const SizedBox(height: AppConstants.spaceL),

                        // Description Section
                        if (widget.listing['description'] != null) ...[
                          _buildDescriptionSection(),
                          const SizedBox(height: AppConstants.spaceL),
                        ],

                        // Contact Information
                        _buildContactSection(),

                        const SizedBox(height: AppConstants.spaceL),

                        // Posted Information
                        _buildPostedInfoSection(),
                        
                        // Action buttons for owner
                        if (_isOwner) ...[
                          const SizedBox(height: AppConstants.spaceXL),
                          _buildActionButtons(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        color: AppColors.accent,
      ),
      child: Stack(
        children: [
          // Photo PageView
          PageView.builder(
            controller: _photoPageController,
            onPageChanged: (index) {
              setState(() {
                _currentPhotoIndex = index;
              });
            },
            itemCount: _photos.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                child: Image.network(
                  _photos[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.accent,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: AppConstants.spaceS),
                            Text(
                              'Image not available',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Navigation arrows (if more than 1 photo)
          if (_photos.length > 1) ...[
            // Left arrow
            Positioned(
              left: AppConstants.spaceS,
              top: 0,
              bottom: 0,
              child: Center(
                child: CircleAvatar(
                  backgroundColor: AppColors.backgroundCard.withOpacity(0.8),
                  child: IconButton(
                    onPressed: _currentPhotoIndex > 0
                        ? () {
                            _photoPageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: _currentPhotoIndex > 0
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),

            // Right arrow
            Positioned(
              right: AppConstants.spaceS,
              top: 0,
              bottom: 0,
              child: Center(
                child: CircleAvatar(
                  backgroundColor: AppColors.backgroundCard.withOpacity(0.8),
                  child: IconButton(
                    onPressed: _currentPhotoIndex < _photos.length - 1
                        ? () {
                            _photoPageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: _currentPhotoIndex < _photos.length - 1
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Photo indicator dots
          if (_photos.length > 1)
            Positioned(
              bottom: AppConstants.spaceS,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _photos.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPhotoIndex == entry.key
                          ? AppColors.primary
                          : AppColors.textTertiary.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoPhotosSection() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        color: AppColors.accent,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppConstants.spaceS),
            Text(
              'No Photos Available',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXS),
            Text(
              'Photos not provided by the host',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Information',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceL),

          // Location
          _buildInfoRow(
            icon: Icons.location_on,
            iconColor: AppColors.error,
            title: 'Location',
            content: '${widget.listing['country']}, ${widget.listing['city']}',
          ),

          const SizedBox(height: AppConstants.spaceM),

          // Room Type
          _buildInfoRow(
            icon: Icons.home,
            iconColor: AppColors.primary,
            title: 'Room Type',
            content: '${widget.listing['roomType'] ?? 'Room'}',
          ),

          const SizedBox(height: AppConstants.spaceM),

          // Price
          _buildInfoRow(
            icon: Icons.attach_money,
            iconColor: Colors.green,
            title: 'Price per Month',
            content: '${_formatRent(widget.listing['monthly_rent'] ?? widget.listing['rent'])}',
          ),

          const SizedBox(height: AppConstants.spaceM),

          // Gender Preference
          _buildInfoRow(
            icon: Icons.people,
            iconColor: AppColors.secondary,
            title: 'Gender Preference',
            content: '${widget.listing['genderPreference']}',
          ),

          const SizedBox(height: AppConstants.spaceM),

          // Availability
          _buildInfoRow(
            icon: Icons.calendar_today,
            iconColor: AppColors.accent.withOpacity(0.8),
            title: 'Availability',
            content: 'From: ${_formatDate(widget.listing['availableFrom'])}\n🕒 Until: ${_formatDate(widget.listing['availableTo']) ?? 'Open-ended'}',
          ),

          const SizedBox(height: AppConstants.spaceM),

          // Facilities
          _buildFacilitiesSection(),

          const SizedBox(height: AppConstants.spaceM),

          // Bedrooms and Bathrooms (if available)
          if (widget.listing['bedrooms'] != null && widget.listing['bathrooms'] != null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.bed,
                    iconColor: AppColors.primary,
                    title: 'Bedrooms',
                    content: '${widget.listing['bedrooms']}',
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.bathroom,
                    iconColor: AppColors.secondary,
                    title: 'Bathrooms',
                    content: '${widget.listing['bathrooms']}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceM),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXS),
              Text(
                content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFacilitiesSection() {
    final facilities = List<String>.from(widget.listing['facilities'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Icon(
                Icons.build,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppConstants.spaceM),
            Text(
              'Facilities',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceS),
        Padding(
          padding: const EdgeInsets.only(left: 48), // Align with content above
          child: Wrap(
            spacing: AppConstants.spaceS,
            runSpacing: AppConstants.spaceS,
            children: facilities.map((facility) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceM,
                  vertical: AppConstants.spaceS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppConstants.spaceXS),
                    Text(
                      _getFacilityDisplayText(facility),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
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

  String _getFacilityDisplayText(String facility) {
    // Add emojis to facilities for better visual appeal
    final facilityEmojis = {
      'WiFi': '📶 WiFi',
      'Kitchen': '🍽️ Kitchen',
      'Gym': '🏋️ Gym',
      'Air Conditioning': '❄️ Air Conditioning',
      'Balcony': '🏠 Balcony',
      'Pool': '🏊 Pool',
      'Garden': '🌿 Garden',
      'Study Room': '📚 Study Room',
      'Laundry': '🧺 Laundry',
      'Parking': '🚗 Parking',
      'Furnished': '🛋️ Furnished',
      'Heating': '🔥 Heating',
      'Dishwasher': '🍽️ Dishwasher',
    };
    
    return facilityEmojis[facility] ?? '✅ $facility';
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppConstants.spaceS),
              Text(
                'Description / Notes',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceM),
          Text(
            '📝 ${widget.listing['description']}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    final contactEmail = widget.listing['contactEmail'] ?? 'contact@example.com';
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_mail,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppConstants.spaceS),
              Text(
                'Contact Information',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceM),
          Row(
            children: [
              Icon(
                Icons.email,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceS),
              Text(
                ' ',
                style: AppTextStyles.bodyMedium,
              ),
              Expanded(
                child: Text(
                  contactEmail,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement email copying functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email copied to clipboard'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: Icon(
                  Icons.copy,
                  color: AppColors.primary,
                  size: 20,
                ),
                tooltip: 'Copy email',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostedInfoSection() {
    final postedDate = widget.listing['postedDate'] != null 
        ? DateTime.tryParse(widget.listing['postedDate']) ?? DateTime.now()
        : DateTime.now();
    
    final formattedDate = '${postedDate.day} ${_getMonthName(postedDate.month)} ${postedDate.year}';
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceL),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: AppConstants.spaceS),
              Text(
                'Posted Information',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceM),
          
          Row(
            children: [
              Icon(
                Icons.person,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceS),
              Text(
                '👤 Posted by: ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                () {
                  final userName = widget.listing['posted_by_name'] ?? widget.listing['postedByName'] ?? 'Anonymous User';
                  print('🔍 USER NAME DEBUG: $userName');
                  print('  posted_by_name: ${widget.listing['posted_by_name']}');
                  print('  postedByName: ${widget.listing['postedByName']}');
                  return userName;
                }(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spaceS),
          
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceS),
              Text(
                '📆 Posted on: ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                formattedDate,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Listing',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spaceM),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Edit',
                  icon: Icons.edit,
                  onPressed: _handleEdit,
                ),
              ),
              const SizedBox(width: AppConstants.spaceM),
              Expanded(
                child: PrimaryButton(
                  text: 'Delete',
                  icon: Icons.delete,
                  backgroundColor: AppColors.error,
                  onPressed: _handleDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to format rent display
  String _formatRent(dynamic rent) {
    if (rent == null) return '\$0/month';
    
    double? rentValue;
    if (rent is double) {
      rentValue = rent;
    } else if (rent is int) {
      rentValue = rent.toDouble();
    } else if (rent is String) {
      rentValue = double.tryParse(rent);
    }
    
    if (rentValue == null) return '\$0/month';
    
    // Format as integer if it's a whole number, otherwise with decimal
    if (rentValue == rentValue.toInt()) {
      return '\$${rentValue.toInt()}/month';
    } else {
      return '\$${rentValue.toStringAsFixed(2)}/month';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String? _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  // Fetch user profile if missing
  void _fetchUserProfileIfNeeded() async {
    try {
      print('🔄 Attempting to fetch user profile...');
      final authService = AuthService();
      await authService.getProfile();
      print('✅ User profile fetched successfully');
      
      // Trigger a rebuild to refresh ownership status
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('❌ Failed to fetch user profile: $e');
    }
  }
}

// Edit Accommodation Dialog
class EditAccommodationDialog extends StatefulWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onUpdated;

  const EditAccommodationDialog({
    Key? key,
    required this.listing,
    required this.onUpdated,
  }) : super(key: key);

  @override
  State<EditAccommodationDialog> createState() => _EditAccommodationDialogState();
}

class _EditAccommodationDialogState extends State<EditAccommodationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController();
  
  String _selectedStatus = 'available';
  String _selectedCountry = 'UK';
  String _selectedCity = 'London';
  String _selectedRoomType = 'Room';
  String _selectedGender = 'Any';
  DateTime? _availableFrom;
  DateTime? _availableTo;
  List<String> _selectedFacilities = [];
  List<XFile> _selectedImages = [];
  List<String> _existingImageUrls = [];
  final ImagePicker _imagePicker = ImagePicker();
  static const int _maxImages = 5;
  bool _isLoading = false;

  // Available options (matching the post form)
  final List<String> _countries = ['UK', 'USA', 'Canada', 'Australia'];
  final Map<String, List<String>> _citiesByCountry = {
    'UK': ['London', 'Birmingham', 'Manchester', 'Edinburgh', 'Cardiff'],
    'USA': ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'],
    'Canada': ['Toronto', 'Vancouver', 'Montreal', 'Calgary', 'Ottawa'],
    'Australia': ['Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Adelaide'],
  };
  final List<String> _roomTypes = ['Room', 'Studio', 'Apartment', 'House'];
  final List<String> _genderOptions = ['Any', 'Male', 'Female'];
  final List<String> _availableFacilities = [
    'Wifi', 'Kitchen', 'Washing Machine', 'Dryer', 'Garden', 'Parking',
    'Gym', 'Pool', 'Air Conditioning', 'Heating', 'Furnished', 'Balcony'
  ];

  /// Helper function to create image widget that works on both web and mobile
  Widget _buildImageFromXFile(XFile imageFile, {double? width, double? height, BoxFit? fit}) {
    if (kIsWeb) {
      // On web, XFile.path returns a blob URL that works with Image.network
      return Image.network(
        imageFile.path,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
        },
      );
    } else {
      // On mobile platforms, use Image.file with File
      return Image.file(
        File(imageFile.path),
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    // Debug: Print all available fields in the listing
    print('🔍 EDIT DIALOG - Available listing fields:');
    widget.listing.forEach((key, value) {
      print('  $key: $value');
    });
    
    _titleController.text = widget.listing['title'] ?? '';
    _descriptionController.text = widget.listing['description'] ?? '';
    
    // Try multiple possible field names for rent
    final rentValue = widget.listing['monthly_rent'] ?? 
                     widget.listing['rent'] ?? 
                     widget.listing['price'];
    _priceController.text = rentValue?.toString() ?? '';
    print('🔍 RENT VALUE: $rentValue (from monthly_rent: ${widget.listing['monthly_rent']}, rent: ${widget.listing['rent']}, price: ${widget.listing['price']})');
    
    // Try multiple possible field names for contact
    final contactValue = widget.listing['contact_info'] ?? 
                        widget.listing['contactEmail'] ?? 
                        widget.listing['contact_email'];
    _contactController.text = contactValue ?? '';
    print('🔍 CONTACT VALUE: $contactValue (from contact_info: ${widget.listing['contact_info']}, contactEmail: ${widget.listing['contactEmail']})');
    
    _selectedStatus = widget.listing['status'] ?? 'available';
    
    // Initialize country and city with validation
    final listingCountry = widget.listing['country'] ?? 'UK';
    final listingCity = widget.listing['city'] ?? 'London';
    
    // Validate if the city belongs to the country
    if (_citiesByCountry[listingCountry]?.contains(listingCity) == true) {
      // Valid combination - use as is
      _selectedCountry = listingCountry;
      _selectedCity = listingCity;
    } else {
      // Invalid combination - find the correct country for the city or use defaults
      String? correctCountry;
      for (String country in _citiesByCountry.keys) {
        if (_citiesByCountry[country]?.contains(listingCity) == true) {
          correctCountry = country;
          break;
        }
      }
      
      if (correctCountry != null) {
        // Found the correct country for this city
        _selectedCountry = correctCountry;
        _selectedCity = listingCity;
        print('🔧 Fixed country/city mismatch: $listingCity is in $correctCountry, not $listingCountry');
      } else {
        // City not found in any country - use defaults
        _selectedCountry = listingCountry.isNotEmpty ? listingCountry : 'UK';
        _selectedCity = _citiesByCountry[_selectedCountry]?.first ?? 'London';
        print('⚠️ Unknown city "$listingCity" - using defaults: $_selectedCountry/$_selectedCity');
      }
    }
    
    _selectedRoomType = widget.listing['roomType'] ?? 'Room';
    _selectedGender = widget.listing['genderPreference'] ?? 'Any';
    
    // Initialize dates - try multiple possible field names
    print('🔍 DATE FIELDS: availableFrom: ${widget.listing['availableFrom']}, availability_from: ${widget.listing['availability_from']}');
    print('🔍 DATE FIELDS: availableTo: ${widget.listing['availableTo']}, availability_to: ${widget.listing['availability_to']}');
    
    // Available From date
    final availableFromValue = widget.listing['availableFrom'] ?? 
                              widget.listing['availability_from'];
    if (availableFromValue != null) {
      try {
        _availableFrom = DateTime.parse(availableFromValue);
        print('✅ Parsed availableFrom: $_availableFrom');
      } catch (e) {
        print('❌ Failed to parse availableFrom: $e');
        _availableFrom = null;
      }
    }
    
    // Available To date  
    final availableToValue = widget.listing['availableTo'] ?? 
                            widget.listing['availability_to'];
    if (availableToValue != null) {
      try {
        _availableTo = DateTime.parse(availableToValue);
        print('✅ Parsed availableTo: $_availableTo');
      } catch (e) {
        print('❌ Failed to parse availableTo: $e');
        _availableTo = null;
      }
    }
    
    // Initialize facilities
    if (widget.listing['facilities'] != null) {
      _selectedFacilities = List<String>.from(widget.listing['facilities']);
    }
    
    // Initialize existing images
    if (widget.listing['imageUrls'] != null) {
      _existingImageUrls = List<String>.from(widget.listing['imageUrls']);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Reserve space for title, padding, and action buttons
    final availableHeight = screenHeight * 0.75; // Use 75% instead of 85%
    final dialogWidth = screenWidth > 600 ? 600.0 : screenWidth * 0.9;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.9, // Maximum dialog height
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title section with fixed height
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceL),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusL),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit Accommodation',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(height: 1, color: AppColors.borderLight),
            
            // Scrollable content area
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: availableHeight,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spaceL),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title *',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spaceM),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description *',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spaceM),

                // Price Field
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price (per month) *',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    prefixText: '৳ ',
                    filled: true,
                    fillColor: AppColors.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Price is required';
                    }
                    final price = double.tryParse(value.trim());
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spaceM),

                // Contact Field
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: 'Contact Information *',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Contact information is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spaceM),

                // Country Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: InputDecoration(
                    labelText: 'Country *',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  items: _countries.map((String country) {
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Text(country, style: AppTextStyles.bodyMedium),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCountry = newValue;
                        // Reset city when country changes
                        _selectedCity = _citiesByCountry[newValue]?.first ?? 'London';
                      });
                    }
                  },
                  validator: (value) => value == null ? 'Please select a country' : null,
                ),
                const SizedBox(height: AppConstants.spaceM),

                // City Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: InputDecoration(
                    labelText: 'City *',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  items: (_citiesByCountry[_selectedCountry] ?? []).map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city, style: AppTextStyles.bodyMedium),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCity = newValue;
                      });
                    }
                  },
                  validator: (value) => value == null ? 'Please select a city' : null,
                ),
                const SizedBox(height: AppConstants.spaceM),

                // Room Type Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRoomType,
                  decoration: InputDecoration(
                    labelText: 'Room Type *',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  items: _roomTypes.map((String roomType) {
                    return DropdownMenuItem<String>(
                      value: roomType,
                      child: Text(roomType, style: AppTextStyles.bodyMedium),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedRoomType = newValue;
                      });
                    }
                  },
                  validator: (value) => value == null ? 'Please select a room type' : null,
                ),
                const SizedBox(height: AppConstants.spaceM),

                // Gender Preference Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender Preference',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  items: _genderOptions.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender, style: AppTextStyles.bodyMedium),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppConstants.spaceM),

                // Available From Date
                TextFormField(
                  readOnly: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (_availableFrom == null) {
                      return 'Please select an available from date';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Available From',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    hintText: _availableFrom != null 
                        ? '${_availableFrom!.day}/${_availableFrom!.month}/${_availableFrom!.year}'
                        : 'Select date',
                    filled: true,
                    fillColor: AppColors.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _availableFrom ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _availableFrom = picked;
                        // Reset availableTo if it's now invalid
                        if (_availableTo != null && _availableTo!.isBefore(picked)) {
                          _availableTo = null;
                        }
                      });
                      // Trigger form validation
                      _formKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: AppConstants.spaceM),

                // Available To Date
                TextFormField(
                  readOnly: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (_availableTo == null) {
                      return 'Please select an available to date';
                    }
                    if (_availableFrom != null && _availableTo != null) {
                      if (_availableTo!.isBefore(_availableFrom!) || _availableTo!.isAtSameMomentAs(_availableFrom!)) {
                        return 'Available to date must be after available from date';
                      }
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Available To',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    hintText: _availableTo != null 
                        ? '${_availableTo!.day}/${_availableTo!.month}/${_availableTo!.year}'
                        : 'Select date',
                    filled: true,
                    fillColor: AppColors.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _availableTo ?? (_availableFrom != null ? _availableFrom!.add(const Duration(days: 30)) : DateTime.now().add(const Duration(days: 30))),
                      firstDate: _availableFrom ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _availableTo = picked;
                      });
                      // Trigger form validation to show any errors
                      _formKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: AppConstants.spaceM),

                // Facilities Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Facilities',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceS),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _availableFacilities.map((facility) {
                        final isSelected = _selectedFacilities.contains(facility);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedFacilities.remove(facility);
                              } else {
                                _selectedFacilities.add(facility);
                              }
                            });
                          },
                          child: Chip(
                            label: Text(
                              facility,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                              ),
                            ),
                            backgroundColor: isSelected ? AppColors.primary : AppColors.backgroundPrimary,
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.borderLight,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceM),

                // Images Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Photos',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_existingImageUrls.length + _selectedImages.length}/$_maxImages',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceS),
                    
                    // Existing Images
                    if (_existingImageUrls.isNotEmpty) ...[
                      Text(
                        'Current Photos',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceXS),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingImageUrls.length,
                          itemBuilder: (context, index) {
                            final imageUrl = _existingImageUrls[index];
                            return Container(
                              margin: const EdgeInsets.only(right: AppConstants.spaceS),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                    child: Image.network(
                                      imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: AppColors.backgroundTertiary,
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: AppColors.textTertiary,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _existingImageUrls.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: AppColors.textOnPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceS),
                    ],
                    
                    // New Images
                    if (_selectedImages.isNotEmpty) ...[
                      Text(
                        'New Photos',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceXS),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            final image = _selectedImages[index];
                            return Container(
                              margin: const EdgeInsets.only(right: AppConstants.spaceS),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                    child: _buildImageFromXFile(
                                      image,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: AppColors.textOnPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceS),
                    ],
                    
                    // Add Photo Button
                    if (_existingImageUrls.length + _selectedImages.length < _maxImages)
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.add_photo_alternate, color: AppColors.primary),
                        label: Text(
                          'Add Photo',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceM),

                // Status Field
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status *',
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  dropdownColor: AppColors.backgroundSecondary,
                  items: [
                    DropdownMenuItem(
                      value: 'available',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: AppConstants.spaceS),
                          Text('Available'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'booked',
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_busy,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: AppConstants.spaceS),
                          Text('Booked'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        ),
      ),
            
            // Action buttons section
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceL),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppConstants.radiusL),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _isLoading ? AppColors.textTertiary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  PrimaryButton(
                    text: _isLoading ? 'Updating...' : 'Update',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleUpdate,
                    size: ButtonSize.small,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional date validation for edit form
    if (_availableFrom != null && _availableTo != null) {
      if (_availableTo!.isBefore(_availableFrom!) || _availableTo!.isAtSameMomentAs(_availableFrom!)) {
        print('❌ EDIT DATE VALIDATION FAILED: availableFrom: $_availableFrom, availableTo: $_availableTo');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Available end date must be after the start date'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final accommodationId = widget.listing['id']?.toString();
      if (accommodationId == null) {
        throw Exception('Invalid accommodation ID');
      }

      final price = double.tryParse(_priceController.text.trim());
      if (price == null) {
        throw Exception('Invalid price format');
      }

      final updatedData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': price,
        'monthly_rent': price, // Include both for compatibility
        'contact_info': _contactController.text.trim(),
        'status': _selectedStatus,
        'country': _selectedCountry,
        'city': _selectedCity,
        'roomType': _selectedRoomType,
        'genderPreference': _selectedGender,
        'availableFrom': _availableFrom?.toIso8601String(),
        'availableTo': _availableTo?.toIso8601String(),
        'facilities': _selectedFacilities,
      };

      print('🔍 UPDATE DATA BEING SENT:');
      updatedData.forEach((key, value) {
        print('  $key: $value');
      });

      final apiService = AccommodationApiService();
      final result = await apiService.updateAccommodation(accommodationId, updatedData);

      print('🔍 UPDATE RESULT RECEIVED: $result');

      // Check if update was successful
      if (result['success'] == true) {
        print('✅ Update successful, uploading images if any...');
        
        // Upload new images if any were selected
        if (_selectedImages.isNotEmpty) {
          try {
            print('🖼️ Uploading ${_selectedImages.length} new images...');
            final imageUrls = await apiService.uploadImagesToAccommodation(
              accommodationId, 
              _selectedImages
            );
            print('✅ Images uploaded successfully: ${imageUrls.length} URLs');
          } catch (imageError) {
            print('⚠️ Image upload failed but accommodation was updated: $imageError');
            // Continue with success - accommodation was updated even if images failed
          }
        }
        
        print('✅ All updates complete, showing success message...');
        
        // Show success message BEFORE closing dialog
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Accommodation updated successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        // Small delay to ensure snackbar is shown, then close dialog
        await Future.delayed(Duration(milliseconds: 100));
        
        print('✅ Closing dialog and triggering refresh...');
        if (mounted) {
          widget.onUpdated(); // This will close the dialog and trigger refresh
        }
        
      } else {
        throw Exception(result['message'] ?? 'Failed to update accommodation');
      }
    } catch (e) {
      print('❌ Update failed: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update accommodation: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
