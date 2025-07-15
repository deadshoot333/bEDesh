/// Application constants
/// Contains all the constant values used throughout the app
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'bEDesh';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your gateway to global education';

  // Spacing Constants
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Border Radius Constants
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 50.0;

  // Elevation Constants
  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // API Constants (for future use)
  static const String baseUrl = 'https://api.bedesh.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxBioLength = 500;
  static const int maxPostLength = 2000;

  // File Upload
  static const int maxImageSizeMB = 5;
  static const int maxDocumentSizeMB = 10;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentFormats = ['pdf', 'doc', 'docx'];

  // UI Constants
  static const double maxContentWidth = 1200.0;
  static const double minTouchTarget = 48.0;
  static const double cardElevation = 2.0;
  static const double fabElevation = 6.0;

  // Countries with their codes (for future use)
  static const Map<String, String> supportedCountries = {
    'BD': 'Bangladesh',
    'UK': 'United Kingdom',
    'US': 'United States',
    'CA': 'Canada',
    'AU': 'Australia',
    'DE': 'Germany',
    'FR': 'France',
    'NL': 'Netherlands',
  };

  // Study Levels
  static const List<String> studyLevels = [
    'Foundation',
    'Undergraduate',
    'Postgraduate',
    'Doctorate',
    'Certificate',
    'Diploma',
  ];

  // Degree Types
  static const List<String> degreeTypes = [
    'Bachelor\'s',
    'Master\'s',
    'PhD',
    'MBA',
    'Certificate',
    'Diploma',
  ];

  // Popular Subjects
  static const List<String> popularSubjects = [
    'Computer Science',
    'Business Administration',
    'Engineering',
    'Medicine',
    'Law',
    'Psychology',
    'Economics',
    'Mathematics',
    'Physics',
    'Biology',
  ];

  // Scholarship Types
  static const List<String> scholarshipTypes = [
    'Merit-based',
    'Need-based',
    'Sports Scholarship',
    'Academic Excellence',
    'Research Grant',
    'Government Funded',
    'University Scholarship',
  ];

  // Post Categories
  static const List<String> postCategories = [
    'General Discussion',
    'University Applications',
    'Visa Process',
    'Accommodation',
    'Scholarships',
    'Student Life',
    'Career Advice',
    'Roommate Search',
  ];

  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String timeoutErrorMessage = 'Request timed out. Please try again.';
  static const String unauthorizedErrorMessage = 'You are not authorized to perform this action.';

  // Success Messages
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  static const String postCreatedMessage = 'Post created successfully!';
  static const String applicationSubmittedMessage = 'Application submitted successfully!';

  // Feature Flags (for future development)
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableBiometricAuth = false;

  // Cache Duration
  static const Duration cacheDurationShort = Duration(minutes: 5);
  static const Duration cacheDurationMedium = Duration(hours: 1);
  static const Duration cacheDurationLong = Duration(days: 1);
}
