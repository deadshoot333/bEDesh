import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/inputs/modern_search_bar.dart';
import '../widgets/accommodation_card.dart';
import 'verification_page.dart';

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
  bool _isMapView = false;
  String _selectedFilter = 'All';
  String _selectedLocation = 'All Cities';
  String _selectedPropertyType = 'All Types';
  bool _isUserVerified = false; // This would come from user state
  
  final List<String> _filterOptions = [
    'All',
    'Rooms',
    'Apartments',
    'Dorms',
    'Studios',
    'Houses',
  ];
  
  final List<String> _locationOptions = [
    'All Cities',
    'London',
    'Manchester',
    'Birmingham',
    'Edinburgh',
    'Glasgow',
  ];
  
  final List<String> _propertyTypes = [
    'All Types',
    'Studio',
    'Room',
    'Apartment',
    'House',
    'Dorm',
    'Shared House',
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Mock data for listings - all roommate-related
  List<Map<String, dynamic>> get _mockListings => [
    {
      'title': 'Looking for Female Roommate - Modern Studio',
      'location': 'Bloomsbury, London',
      'propertyType': 'Studio',
      'rent': 1200.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['WiFi', 'Furnished', 'Laundry'],
      'isRoommateRequest': true,
      'isVerified': true,
      'nearbyUniversities': ['UCL', 'King\'s College London'],
      'availableFrom': 'Sept 2025',
    },
    {
      'title': 'Male Student Seeking Flatmate - Shared Apartment',
      'location': 'Camden, London',
      'propertyType': 'Room',
      'rent': 750.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Shared Kitchen', 'WiFi', 'Near Tube'],
      'isRoommateRequest': true,
      'isVerified': true,
      'nearbyUniversities': ['UCL', 'University of Westminster'],
      'availableFrom': 'Oct 2025',
    },
    {
      'title': 'Room Available in Student House - 3 Current Flatmates',
      'location': 'Fallowfield, Manchester',
      'propertyType': 'House',
      'rent': 450.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 2,
      'amenities': ['Garden', 'Study Room', 'Parking'],
      'isRoommateRequest': true,
      'isVerified': true,
      'nearbyUniversities': ['University of Manchester'],
      'availableFrom': 'Sept 2025',
    },
    {
      'title': 'University Dorm Room Available for Exchange',
      'location': 'Selly Oak, Birmingham',
      'propertyType': 'Dorm',
      'rent': 500.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Catering', 'WiFi', 'Study Areas'],
      'isRoommateRequest': true,
      'isVerified': true,
      'nearbyUniversities': ['University of Birmingham'],
      'availableFrom': 'Aug 2025',
    },
    {
      'title': 'Looking for Quiet Flatmate - Shared Apartment',
      'location': 'Marchmont, Edinburgh',
      'propertyType': 'Apartment',
      'rent': 600.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Central Heating', 'WiFi', 'Dishwasher'],
      'isRoommateRequest': true,
      'isVerified': true,
      'nearbyUniversities': ['University of Edinburgh'],
      'availableFrom': 'Sept 2025',
    },
    {
      'title': 'Female Roommate Wanted - Shared Studio',
      'location': 'Kelvinbridge, Glasgow',
      'propertyType': 'Studio',
      'rent': 550.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Modern Kitchen', 'WiFi', 'Gym Access'],
      'isRoommateRequest': true,
      'isVerified': true,
      'nearbyUniversities': ['University of Glasgow'],
      'availableFrom': 'Sept 2025',
    },
  ];

  List<Map<String, dynamic>> get _filteredListings {
    var listings = _mockListings;
    
    if (_selectedFilter != 'All') {
      switch (_selectedFilter) {
        case 'Rooms':
          listings = listings.where((l) => l['propertyType'] == 'Room').toList();
          break;
        case 'Apartments':
          listings = listings.where((l) => l['propertyType'] == 'Apartment').toList();
          break;
        case 'Dorms':
          listings = listings.where((l) => l['propertyType'] == 'Dorm').toList();
          break;
        case 'Studios':
          listings = listings.where((l) => l['propertyType'] == 'Studio').toList();
          break;
        case 'Houses':
          listings = listings.where((l) => l['propertyType'] == 'House').toList();
          break;
      }
    }
    
    if (_selectedLocation != 'All Cities') {
      listings = listings.where((l) => 
        l['location'].toString().contains(_selectedLocation)
      ).toList();
    }
    
    if (_selectedPropertyType != 'All Types') {
      listings = listings.where((l) => 
        l['propertyType'] == _selectedPropertyType
      ).toList();
    }
    
    return _showAllListings ? listings : listings.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isMapView = !_isMapView;
          });
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        tooltip: _isMapView ? 'Switch to List View' : 'Switch to Map View',
        child: Icon(
          _isMapView ? Icons.list : Icons.map_outlined,
          size: 24,
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
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
                        Text(
                          'bEDesh',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w800,
                          ),
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
                              // TODO: Implement notifications
                              _showComingSoonDialog('Notifications');
                            },
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: AppColors.textOnPrimary,
                              size: 24,
                            ),
                            tooltip: 'Notifications',
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
                    // Accommodation Title
                    Text(
                      'Accommodation',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spaceL),
                    
                    // Search Bar
                    ModernSearchBar(
                      hintText: 'Search accommodations...',
                      showFilter: true,
                      onFilterPressed: _showFilterDialog,
                    ),
                    
                    const SizedBox(height: AppConstants.spaceL),
                    
                    // Quick Actions
                    PrimaryButton(
                      text: 'Post Roommate Request',
                      icon: Icons.add_home,
                      isExpanded: true,
                      size: ButtonSize.large,
                      onPressed: _handlePostAccommodation,
                    ),
                    
                    const SizedBox(height: AppConstants.spaceXL),
                    
                    // Filter Chips
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filterOptions.length,
                        itemBuilder: (context, index) {
                          final filter = _filterOptions[index];
                          final isSelected = _selectedFilter == filter;
                          return Container(
                            margin: const EdgeInsets.only(right: AppConstants.spaceS),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = isSelected ? 'All' : filter;
                                  });
                                },
                                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.spaceM,
                                    vertical: AppConstants.spaceS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.accent,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.borderLight,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    filter,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spaceL),
                    
                    // Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Roommate Requests',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                    
                    // Map View Toggle
                    if (_isMapView) 
                      _buildMapView()
                    else
                      _buildListView(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    final listings = _filteredListings;
    
    if (listings.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      children: listings.map((listing) {
        return AccommodationCard(
          title: listing['title'],
          location: listing['location'],
          propertyType: listing['propertyType'],
          rent: listing['rent'],
          rentPeriod: listing['rentPeriod'],
          bedrooms: listing['bedrooms'],
          bathrooms: listing['bathrooms'],
          amenities: List<String>.from(listing['amenities']),
          isRoommateRequest: listing['isRoommateRequest'],
          isVerified: listing['isVerified'],
          nearbyUniversities: List<String>.from(listing['nearbyUniversities']),
          availableFrom: listing['availableFrom'],
          onTap: () => _showAccommodationDetails(listing),
        );
      }).toList(),
    );
  }

  Widget _buildMapView() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppConstants.spaceM),
          Text(
            'Map View',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            'Interactive map coming soon!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppConstants.spaceM),
          Text(
            'No listings found',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            'Try adjusting your filters or search terms',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
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
              'Filter Listings',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppConstants.spaceL),
            
            // Location Filter
            Text(
              'Location',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spaceS),
            DropdownButton<String>(
              value: _selectedLocation,
              isExpanded: true,
              items: _locationOptions.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value!;
                });
                Navigator.pop(context);
              },
            ),
            
            const SizedBox(height: AppConstants.spaceM),
            
            // Property Type Filter
            Text(
              'Property Type',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spaceS),
            DropdownButton<String>(
              value: _selectedPropertyType,
              isExpanded: true,
              items: _propertyTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPropertyType = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handlePostAccommodation() {
    if (!_isUserVerified) {
      _showVerificationDialog();
    } else {
      _showComingSoonDialog('Post Roommate Request');
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Row(
          children: [
            Icon(
              Icons.security,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppConstants.spaceS),
            Text(
              'Verification Required',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'To post roommate requests, you need to verify your student status first.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          PrimaryButton(
            text: 'Verify Now',
            size: ButtonSize.small,
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VerificationPage(),
                ),
              );
              if (result == true) {
                setState(() {
                  _isUserVerified = true;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Coming Soon!',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '$feature feature is currently being developed and will be available soon.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          PrimaryButton(
            text: 'OK',
            size: ButtonSize.small,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAccommodationDetails(Map<String, dynamic> listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Accommodation Details',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Detailed accommodation page coming soon!\n\nThis will include:\n• Full property details\n• Photo gallery\n• Contact information\n• Booking options',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          PrimaryButton(
            text: 'OK',
            size: ButtonSize.small,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
