import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/inputs/modern_search_bar.dart';
import '../widgets/accommodation_card.dart';
import '../../../profile/presentation/pages/profile_page.dart';

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
  
  // New comprehensive filter system
  String _selectedCountry = 'All Countries';
  String _selectedCity = 'All Cities';
  List<double> _priceRange = [0, 2500];
  String _selectedRoomType = 'All Types';
  String _selectedGender = 'All';
  DateTime? _availableFrom;
  DateTime? _availableTo;
  List<String> _selectedFacilities = [];
  
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
    'All',
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Mock data for listings - comprehensive accommodation data
  List<Map<String, dynamic>> get _mockListings => [
    {
      'title': 'Looking for Female Roommate - Modern Studio',
      'location': 'Bloomsbury, London',
      'country': 'UK',
      'city': 'London',
      'propertyType': 'Studio',
      'rent': 1200.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['WiFi', 'Furnished', 'Laundry'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['UCL', 'King\'s College London'],
      'availableFrom': 'Sept 2025',
      'availableTo': 'June 2026',
      'genderPreference': 'Female',
      'facilities': ['WiFi', 'Kitchen', 'Laundry', 'Furnished'],
      'description': 'Looking for a female roommate for a modern studio in Bloomsbury. Perfect for UCL students. Quiet environment with all amenities included.',
      'contactEmail': 'sarah.bloomsbury@student.ucl.ac.uk',
      'postedBy': 'Sarah Johnson',
      'postedDate': '2025-07-20T10:30:00Z',
    },
    {
      'title': 'Male Student Seeking Flatmate - Shared Apartment',
      'location': 'Camden, London',
      'country': 'UK',
      'city': 'London',
      'propertyType': 'Apartment',
      'rent': 750.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Shared Kitchen', 'WiFi', 'Near Tube'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['UCL', 'University of Westminster'],
      'availableFrom': 'Oct 2025',
      'availableTo': 'July 2026',
      'genderPreference': 'Male',
      'facilities': ['WiFi', 'Kitchen', 'Parking'],
      'description': 'Male student looking for a flatmate in Camden. Great location with easy access to central London. Shared kitchen and living areas.',
      'contactEmail': 'tom.camden@gmail.com',
      'postedBy': 'Tom Wilson',
      'postedDate': '2025-07-22T14:15:00Z',
    },
    {
      'title': 'Room Available in Student House - 3 Current Flatmates',
      'location': 'Fallowfield, Manchester',
      'country': 'UK',
      'city': 'Manchester',
      'propertyType': 'House',
      'rent': 450.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 2,
      'amenities': ['Garden', 'Study Room', 'Parking'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['University of Manchester'],
      'availableFrom': 'Sept 2025',
      'availableTo': 'June 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Garden', 'Study Room', 'Parking'],
      'description': 'Student house with 3 friendly flatmates looking for one more person. Great location in Fallowfield with garden and study room. Perfect for University of Manchester students.',
      'contactEmail': 'manchester.studenthouse@gmail.com',
      'postedBy': 'Manchester Student House',
      'postedDate': '2025-07-25T09:45:00Z',
    },
    {
      'title': 'Luxury Penthouse - Birmingham City Center',
      'location': 'Birmingham City Center, Birmingham',
      'country': 'UK',
      'city': 'Birmingham',
      'propertyType': 'Apartment',
      'rent': 1800.0,
      'rentPeriod': 'month',
      'bedrooms': 2,
      'bathrooms': 2,
      'amenities': ['Balcony', 'Concierge', 'Gym'],
      'isRoommateRequest': false,
      'nearbyUniversities': ['University of Birmingham', 'Birmingham City University'],
      'availableFrom': 'Jan 2026',
      'availableTo': 'Dec 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Gym', 'Air Conditioning', 'Balcony'],
    },
    {
      'title': 'Female-Only House Share - Edinburgh',
      'location': 'Old Town, Edinburgh',
      'country': 'UK',
      'city': 'Edinburgh',
      'propertyType': 'Room',
      'rent': 650.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Historic Building', 'Garden', 'Study Room'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['University of Edinburgh', 'Heriot-Watt University'],
      'availableFrom': 'Aug 2025',
      'availableTo': 'May 2026',
      'genderPreference': 'Female',
      'facilities': ['WiFi', 'Kitchen', 'Garden', 'Study Room', 'Laundry'],
    },
    {
      'title': 'Studio Apartment in Brooklyn',
      'location': 'Brooklyn, New York',
      'country': 'USA',
      'city': 'New York',
      'propertyType': 'Studio',
      'rent': 1800.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Modern Kitchen', 'Gym Access', 'Doorman'],
      'isRoommateRequest': false,
      'nearbyUniversities': ['NYU', 'Brooklyn College'],
      'availableFrom': 'Aug 2025',
      'availableTo': 'May 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Gym', 'Air Conditioning'],
    },
    {
      'title': 'Shared House Near Harvard - Male Students',
      'location': 'Cambridge, Boston',
      'country': 'USA',
      'city': 'Boston',
      'propertyType': 'House',
      'rent': 1100.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 2,
      'amenities': ['Near Campus', 'Study Room', 'Parking'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['Harvard University', 'MIT'],
      'availableFrom': 'Sept 2025',
      'availableTo': 'June 2026',
      'genderPreference': 'Male',
      'facilities': ['WiFi', 'Kitchen', 'Study Room', 'Parking', 'Garden'],
    },
    {
      'title': 'Downtown Apartment - Los Angeles',
      'location': 'Downtown, Los Angeles',
      'country': 'USA',
      'city': 'Los Angeles',
      'propertyType': 'Apartment',
      'rent': 2200.0,
      'rentPeriod': 'month',
      'bedrooms': 2,
      'bathrooms': 2,
      'amenities': ['Pool', 'Gym', 'Rooftop Terrace'],
      'isRoommateRequest': false,
      'nearbyUniversities': ['USC', 'UCLA'],
      'availableFrom': 'July 2025',
      'availableTo': 'June 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Gym', 'Air Conditioning', 'Balcony', 'Pool'],
    },
    {
      'title': 'Budget-Friendly Room in Chicago',
      'location': 'Hyde Park, Chicago',
      'country': 'USA',
      'city': 'Chicago',
      'propertyType': 'Room',
      'rent': 550.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Near University', 'Furnished'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['University of Chicago'],
      'availableFrom': 'Sept 2025',
      'availableTo': 'August 2026',
      'genderPreference': 'Female',
      'facilities': ['WiFi', 'Kitchen', 'Furnished', 'Laundry'],
    },
    {
      'title': 'Shared Room in Sydney CBD',
      'location': 'Sydney CBD, Sydney',
      'country': 'Australia',
      'city': 'Sydney',
      'propertyType': 'Room',
      'rent': 900.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['City Views', 'Transport Links'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['University of Sydney', 'UTS'],
      'availableFrom': 'Feb 2026',
      'availableTo': 'Nov 2026',
      'genderPreference': 'Female',
      'facilities': ['WiFi', 'Kitchen', 'Balcony'],
    },
    {
      'title': 'Male Student House - Melbourne',
      'location': 'Carlton, Melbourne',
      'country': 'Australia',
      'city': 'Melbourne',
      'propertyType': 'House',
      'rent': 700.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Near Trams', 'Garden', 'Study Area'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['University of Melbourne', 'RMIT'],
      'availableFrom': 'March 2026',
      'availableTo': 'February 2027',
      'genderPreference': 'Male',
      'facilities': ['WiFi', 'Kitchen', 'Garden', 'Study Room'],
    },
    {
      'title': 'Luxury Studio - Brisbane',
      'location': 'South Brisbane, Brisbane',
      'country': 'Australia',
      'city': 'Brisbane',
      'propertyType': 'Studio',
      'rent': 1300.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['River Views', 'Pool', 'Gym'],
      'isRoommateRequest': false,
      'nearbyUniversities': ['University of Queensland', 'QUT'],
      'availableFrom': 'January 2026',
      'availableTo': 'December 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Air Conditioning', 'Pool', 'Gym'],
    },
    {
      'title': 'Downtown Toronto Apartment',
      'location': 'Downtown, Toronto',
      'country': 'Canada',
      'city': 'Toronto',
      'propertyType': 'Apartment',
      'rent': 1400.0,
      'rentPeriod': 'month',
      'bedrooms': 2,
      'bathrooms': 1,
      'amenities': ['Modern Kitchen', 'WiFi', 'Heating'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['University of Toronto', 'Ryerson University'],
      'availableFrom': 'Sept 2025',
      'availableTo': 'April 2026',
      'genderPreference': 'Male',
      'facilities': ['WiFi', 'Kitchen', 'Heating', 'Dishwasher'],
    },
    {
      'title': 'Female House Share - Vancouver',
      'location': 'Kitsilano, Vancouver',
      'country': 'Canada',
      'city': 'Vancouver',
      'propertyType': 'House',
      'rent': 950.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 2,
      'amenities': ['Near Beach', 'Garden', 'Parking'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['UBC', 'SFU'],
      'availableFrom': 'May 2026',
      'availableTo': 'April 2027',
      'genderPreference': 'Female',
      'facilities': ['WiFi', 'Kitchen', 'Garden', 'Parking', 'Laundry'],
    },
    {
      'title': 'Budget Room in Montreal',
      'location': 'Plateau, Montreal',
      'country': 'Canada',
      'city': 'Montreal',
      'propertyType': 'Room',
      'rent': 400.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Historic Area', 'Near Metro'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['McGill University', 'Concordia University'],
      'availableFrom': 'September 2025',
      'availableTo': 'May 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Furnished'],
    },
    {
      'title': 'Luxury Condo - Calgary',
      'location': 'Beltline, Calgary',
      'country': 'Canada',
      'city': 'Calgary',
      'propertyType': 'Apartment',
      'rent': 1600.0,
      'rentPeriod': 'month',
      'bedrooms': 2,
      'bathrooms': 2,
      'amenities': ['Mountain Views', 'Concierge', 'Gym'],
      'isRoommateRequest': false,
      'nearbyUniversities': ['University of Calgary'],
      'availableFrom': 'August 2025',
      'availableTo': 'July 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Gym', 'Air Conditioning', 'Balcony'],
    },
    // Additional listings to ensure all filter combinations have results
    {
      'title': 'Affordable Studio - Glasgow Student Area',
      'location': 'West End, Glasgow',
      'country': 'UK',
      'city': 'Glasgow',
      'propertyType': 'Studio',
      'rent': 550.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Near University', 'WiFi', 'Study Area'],
      'isRoommateRequest': false,
      'nearbyUniversities': ['University of Glasgow', 'Glasgow Caledonian University'],
      'availableFrom': 'September 2025',
      'availableTo': 'June 2026',
      'genderPreference': 'Female',
      'facilities': ['WiFi', 'Kitchen', 'Study Room', 'Laundry'],
    },
    {
      'title': 'Male Student House - Bristol',
      'location': 'Clifton, Bristol',
      'country': 'UK',
      'city': 'Bristol',
      'propertyType': 'House',
      'rent': 480.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Garden', 'Near Campus', 'Parking'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['University of Bristol', 'UWE Bristol'],
      'availableFrom': 'August 2025',
      'availableTo': 'July 2026',
      'genderPreference': 'Male',
      'facilities': ['WiFi', 'Kitchen', 'Garden', 'Parking', 'Furnished'],
    },
    {
      'title': 'Luxury Apartment - Liverpool City Center',
      'location': 'City Center, Liverpool',
      'country': 'UK',
      'city': 'Liverpool',
      'propertyType': 'Apartment',
      'rent': 1500.0,
      'rentPeriod': 'month',
      'bedrooms': 2,
      'bathrooms': 2,
      'amenities': ['City Views', 'Concierge', 'Gym'],
      'isRoommateRequest': false,
      'nearbyUniversities': ['University of Liverpool', 'Liverpool John Moores University'],
      'availableFrom': 'October 2025',
      'availableTo': 'September 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Gym', 'Air Conditioning', 'Balcony', 'Dishwasher'],
    },
    {
      'title': 'Student Room in Leeds',
      'location': 'Headingley, Leeds',
      'country': 'UK',
      'city': 'Leeds',
      'propertyType': 'Room',
      'rent': 380.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Student Area', 'Near Transport'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['University of Leeds', 'Leeds Beckett University'],
      'availableFrom': 'September 2025',
      'availableTo': 'June 2026',
      'genderPreference': 'Female',
      'facilities': ['WiFi', 'Kitchen', 'Study Room', 'Laundry'],
    },
    {
      'title': 'Modern Studio - Seattle Tech Hub',
      'location': 'Capitol Hill, Seattle',
      'country': 'USA',
      'city': 'Seattle',
      'propertyType': 'Studio',
      'rent': 1900.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Tech Area', 'Modern Amenities', 'Transit'],
      'isRoommateRequest': false,
      'nearbyUniversities': ['University of Washington', 'Seattle University'],
      'availableFrom': 'August 2025',
      'availableTo': 'August 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Gym', 'Air Conditioning', 'Dishwasher'],
    },
    {
      'title': 'Shared House Near Stanford - Male Students',
      'location': 'Palo Alto, San Francisco',
      'country': 'USA',
      'city': 'San Francisco',
      'propertyType': 'House',
      'rent': 1600.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 2,
      'amenities': ['Near Stanford', 'Tech Area', 'Garden'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['Stanford University', 'UC Berkeley'],
      'availableFrom': 'September 2025',
      'availableTo': 'June 2026',
      'genderPreference': 'Male',
      'facilities': ['WiFi', 'Kitchen', 'Garden', 'Study Room', 'Parking'],
    },
    {
      'title': 'Female Student Apartment - Washington DC',
      'location': 'Georgetown, Washington DC',
      'country': 'USA',
      'city': 'Washington DC',
      'propertyType': 'Apartment',
      'rent': 1300.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Historic Area', 'Near Metro', 'Safe Area'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['Georgetown University', 'George Washington University'],
      'availableFrom': 'August 2025',
      'availableTo': 'May 2026',
      'genderPreference': 'Female',
      'facilities': ['WiFi', 'Kitchen', 'Study Room', 'Air Conditioning', 'Furnished'],
    },
    {
      'title': 'Budget Room in Perth',
      'location': 'Northbridge, Perth',
      'country': 'Australia',
      'city': 'Perth',
      'propertyType': 'Room',
      'rent': 600.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['City Close', 'Public Transport'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['University of Western Australia', 'Curtin University'],
      'availableFrom': 'February 2026',
      'availableTo': 'November 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Laundry'],
    },
    {
      'title': 'Female House Share - Adelaide',
      'location': 'North Adelaide, Adelaide',
      'country': 'Australia',
      'city': 'Adelaide',
      'propertyType': 'House',
      'rent': 520.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Garden', 'Quiet Area', 'Parking'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['University of Adelaide', 'University of South Australia'],
      'availableFrom': 'March 2026',
      'availableTo': 'February 2027',
      'genderPreference': 'Female',
      'facilities': ['WiFi', 'Kitchen', 'Garden', 'Parking', 'Study Room'],
    },
    {
      'title': 'Modern Studio - Canberra',
      'location': 'Civic, Canberra',
      'country': 'Australia',
      'city': 'Canberra',
      'propertyType': 'Studio',
      'rent': 800.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Government Area', 'Modern', 'Transport'],
      'isRoommateRequest': false,
      'nearbyUniversities': ['Australian National University', 'University of Canberra'],
      'availableFrom': 'January 2026',
      'availableTo': 'December 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Air Conditioning', 'Gym', 'Furnished'],
    },
    {
      'title': 'Male Student Room - Ottawa',
      'location': 'Sandy Hill, Ottawa',
      'country': 'Canada',
      'city': 'Ottawa',
      'propertyType': 'Room',
      'rent': 650.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Near University', 'Transit', 'Safe'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['University of Ottawa', 'Carleton University'],
      'availableFrom': 'September 2025',
      'availableTo': 'April 2026',
      'genderPreference': 'Male',
      'facilities': ['WiFi', 'Kitchen', 'Study Room', 'Heating', 'Laundry'],
    },
    {
      'title': 'Female House Share - Edmonton',
      'location': 'Strathcona, Edmonton',
      'country': 'Canada',
      'city': 'Edmonton',
      'propertyType': 'House',
      'rent': 500.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Near Campus', 'Garden', 'Parking'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['University of Alberta'],
      'availableFrom': 'August 2025',
      'availableTo': 'April 2026',
      'genderPreference': 'Female',
      'facilities': ['WiFi', 'Kitchen', 'Garden', 'Parking', 'Heating', 'Study Room'],
    },
    {
      'title': 'Luxury Apartment - Vancouver Downtown',
      'location': 'Yaletown, Vancouver',
      'country': 'Canada',
      'city': 'Vancouver',
      'propertyType': 'Apartment',
      'rent': 2000.0,
      'rentPeriod': 'month',
      'bedrooms': 2,
      'bathrooms': 2,
      'amenities': ['Waterfront', 'Luxury', 'Concierge'],
      'isRoommateRequest': false,
      'nearbyUniversities': ['UBC', 'SFU'],
      'availableFrom': 'July 2025',
      'availableTo': 'June 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Gym', 'Air Conditioning', 'Balcony', 'Dishwasher'],
    },
    {
      'title': 'Budget Student Room - Montreal East',
      'location': 'Mile End, Montreal',
      'country': 'Canada',
      'city': 'Montreal',
      'propertyType': 'Room',
      'rent': 350.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Artistic Area', 'Affordable', 'Culture'],
      'isRoommateRequest': true,
      'nearbyUniversities': ['McGill University', 'Concordia University'],
      'availableFrom': 'September 2025',
      'availableTo': 'May 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Furnished', 'Heating'],
    },
    // High-end luxury options for higher price ranges
    {
      'title': 'Premium Studio - Central London',
      'location': 'Mayfair, London',
      'country': 'UK',
      'city': 'London',
      'propertyType': 'Studio',
      'rent': 2400.0,
      'rentPeriod': 'month',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Luxury', 'Prime Location', 'Concierge'],
      'isRoommateRequest': false,
      'nearbyUniversities': ['LSE', 'Imperial College'],
      'availableFrom': 'August 2025',
      'availableTo': 'July 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Gym', 'Air Conditioning', 'Balcony', 'Dishwasher', 'Furnished'],
    },
    {
      'title': 'Executive Apartment - Manhattan',
      'location': 'Upper East Side, New York',
      'country': 'USA',
      'city': 'New York',
      'propertyType': 'Apartment',
      'rent': 2800.0,
      'rentPeriod': 'month',
      'bedrooms': 2,
      'bathrooms': 2,
      'amenities': ['Luxury', 'Doorman', 'Rooftop'],
      'isRoommateRequest': false,
      'nearbyUniversities': ['Columbia University', 'NYU'],
      'availableFrom': 'September 2025',
      'availableTo': 'August 2026',
      'genderPreference': 'All',
      'facilities': ['WiFi', 'Kitchen', 'Gym', 'Air Conditioning', 'Balcony', 'Dishwasher', 'Furnished'],
    },
  ];

  List<Map<String, dynamic>> get _filteredListings {
    var listings = _mockListings;
    
    // Filter by country
    if (_selectedCountry != 'All Countries') {
      listings = listings.where((l) => l['country'] == _selectedCountry).toList();
    }
    
    // Filter by city
    if (_selectedCity != 'All Cities') {
      listings = listings.where((l) => l['city'] == _selectedCity).toList();
    }
    
    // Filter by price range
    listings = listings.where((l) => 
      l['rent'] >= _priceRange[0] && l['rent'] <= _priceRange[1]
    ).toList();
    
    // Filter by room type
    if (_selectedRoomType != 'All Types') {
      listings = listings.where((l) => l['propertyType'] == _selectedRoomType).toList();
    }
    
    // Filter by gender preference
    if (_selectedGender != 'All') {
      listings = listings.where((l) => 
        l['genderPreference'] == _selectedGender || l['genderPreference'] == 'All'
      ).toList();
    }
    
    // Filter by facilities
    if (_selectedFacilities.isNotEmpty) {
      listings = listings.where((l) {
        final listingFacilities = List<String>.from(l['facilities'] ?? []);
        return _selectedFacilities.every((facility) => 
          listingFacilities.contains(facility)
        );
      }).toList();
    }
    
    // TODO: Add date filtering when we implement proper date handling
    
    return _showAllListings ? listings : listings.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
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
                          _buildHorizontalFilterTag('Price', '£${_priceRange[0].toInt()}-£${_priceRange[1].toInt()}', () => _showPriceFilter()),
                          const SizedBox(width: AppConstants.spaceS),
                          _buildHorizontalFilterTag('Gender', _selectedGender, () => _showGenderFilter()),
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
                    
                    // List View
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
          nearbyUniversities: List<String>.from(listing['nearbyUniversities']),
          availableFrom: listing['availableFrom'],
          country: listing['country'],
          genderPreference: listing['genderPreference'],
          facilities: List<String>.from(listing['facilities'] ?? []),
          onTap: () => _showAccommodationDetails(listing),
        );
      }).toList(),
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
    // This method is now replaced by individual filter methods
    // but keeping it for backwards compatibility
    _showCountryFilter();
  }

  // Horizontal filter tag for scrollable row
  Widget _buildHorizontalFilterTag(String label, String value, VoidCallback onTap) {
    final isDefault = value.contains('All') || value.isEmpty || value == 'Any Time' || value == 'Any Facilities';
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

  bool _hasActiveFilters() {
    return _selectedCountry != 'All Countries' ||
           _selectedCity != 'All Cities' ||
           _priceRange[0] != 0 || _priceRange[1] != 2500 ||
           _selectedRoomType != 'All Types' ||
           _selectedGender != 'All' ||
           _availableFrom != null ||
           _availableTo != null ||
           _selectedFacilities.isNotEmpty;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCountry = 'All Countries';
      _selectedCity = 'All Cities';
      _priceRange = [0, 2500];
      _selectedRoomType = 'All Types';
      _selectedGender = 'All';
      _availableFrom = null;
      _availableTo = null;
      _selectedFacilities.clear();
    });
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
              'Select City',
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
                '£${_priceRange[0].toInt()} - £${_priceRange[1].toInt()}',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spaceM),
              RangeSlider(
                values: RangeValues(_priceRange[0], _priceRange[1]),
                min: 0,
                max: 3000,
                divisions: 30,
                activeColor: AppColors.primary,
                onChanged: (values) {
                  setModalState(() {
                    _priceRange = [values.start, values.end];
                  });
                },
              ),
              const SizedBox(height: AppConstants.spaceL),
              PrimaryButton(
                text: 'Apply Filter',
                isExpanded: true,
                onPressed: () {
                  setState(() {
                    // Update main state
                  });
                  Navigator.pop(context);
                },
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
            PrimaryButton(
              text: 'Apply Filter',
              isExpanded: true,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
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
              PrimaryButton(
                text: 'Apply Filter',
                isExpanded: true,
                onPressed: () {
                  setState(() {
                    // Update main state
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePostAccommodation() {
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
      ),
    );
  }

  void _showAccommodationDetails(Map<String, dynamic> listing) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _AccommodationDetailsDialog(listing: listing),
    );
  }
}

// Post Accommodation Form Widget
class _PostAccommodationForm extends StatefulWidget {
  final List<String> countries;
  final Map<String, List<String>> citiesByCountry;
  final List<String> roomTypes;
  final List<String> genderOptions;
  final List<String> availableFacilities;

  const _PostAccommodationForm({
    required this.countries,
    required this.citiesByCountry,
    required this.roomTypes,
    required this.genderOptions,
    required this.availableFacilities,
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
    _selectedGender = widget.genderOptions.isNotEmpty ? widget.genderOptions.first : 'All';
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
                              decoration: _buildInputDecoration('Monthly rent (£)'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter rent amount';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
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
              border: Border.all(color: AppColors.borderLight),
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
                      color: date != null 
                          ? AppColors.textPrimary 
                          : AppColors.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
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
    return Container(
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
            'Upload Photos',
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
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement photo upload functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Photo upload feature coming soon!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            icon: Icon(Icons.add_photo_alternate),
            label: const Text('Choose Photos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
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

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Create the accommodation data
      final accommodationData = {
        'title': _titleController.text.trim(),
        'location': '$_selectedCity, $_selectedCountry',
        'country': _selectedCountry,
        'city': _selectedCity,
        'propertyType': _selectedRoomType,
        'rent': double.parse(_rentController.text),
        'rentPeriod': 'month',
        'contactEmail': _contactEmailController.text.trim(),
        'availableFrom': '${_availableFrom!.day}/${_availableFrom!.month}/${_availableFrom!.year}',
        'availableTo': _availableTo != null 
            ? '${_availableTo!.day}/${_availableTo!.month}/${_availableTo!.year}'
            : 'Open-ended',
        'genderPreference': _selectedGender,
        'facilities': _selectedFacilities,
        'description': _descriptionController.text.trim(),
        'isRoommateRequest': true,
        'postedDate': DateTime.now().toIso8601String(),
      };

      // TODO: Send accommodationData to backend API
      print('Accommodation data to be sent: $accommodationData');

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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting accommodation: ${e.toString()}'),
            backgroundColor: AppColors.error,
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

  // Mock photos list - in real app, this would come from the listing data
  List<String> get _photos {
    // Return empty list if no photos, or mock photos for demo
    final photos = widget.listing['photos'] as List<String>?;
    return photos ?? [];
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
            content: '📍 ${widget.listing['country']}, ${widget.listing['city']}',
          ),

          const SizedBox(height: AppConstants.spaceM),

          // Room Type
          _buildInfoRow(
            icon: Icons.home,
            iconColor: AppColors.primary,
            title: 'Room Type',
            content: '🛏️ ${widget.listing['propertyType']}',
          ),

          const SizedBox(height: AppConstants.spaceM),

          // Price
          _buildInfoRow(
            icon: Icons.attach_money,
            iconColor: Colors.green,
            title: 'Price per Month',
            content: '💰 £${widget.listing['rent']} ${widget.listing['rentPeriod']}',
          ),

          const SizedBox(height: AppConstants.spaceM),

          // Gender Preference
          _buildInfoRow(
            icon: Icons.people,
            iconColor: AppColors.secondary,
            title: 'Gender Preference',
            content: '🚻 ${widget.listing['genderPreference']}',
          ),

          const SizedBox(height: AppConstants.spaceM),

          // Availability
          _buildInfoRow(
            icon: Icons.calendar_today,
            iconColor: AppColors.accent.withOpacity(0.8),
            title: 'Availability',
            content: '🗓️ From: ${widget.listing['availableFrom']}\n🕒 Until: ${widget.listing['availableTo'] ?? 'Open-ended'}',
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
                    content: '🛏️ ${widget.listing['bedrooms']}',
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.bathroom,
                    iconColor: AppColors.secondary,
                    title: 'Bathrooms',
                    content: '🛁 ${widget.listing['bathrooms']}',
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
                '📧 ',
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
                widget.listing['postedBy'] ?? 'Anonymous User',
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

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
