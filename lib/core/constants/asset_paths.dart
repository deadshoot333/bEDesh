/// Asset paths for images, icons, and other static resources
class AssetPaths {
  AssetPaths._();

  // Base paths
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _animations = 'assets/animations';

  // Country Images
  static const String uk = 'assets/uk.jpg';
  static const String ukFlag = 'assets/uk.jpg';
  static const String britishFlag = 'assets/british_flag2.jpg';
  static const String canadaFlag = 'assets/canada.jpg';
  static const String usaFlag = 'assets/usa.jpg';
  static const String australiaFlag = 'assets/autrallia.jpg';

  // University Images
  static const String oxford = 'assets/oxford.jpg';
  static const String cambridge = 'assets/cambridge.jpg';
  static const String mit = 'assets/mit.jpg';
  static const String imperial = 'assets/imperial.jpg';
  static const String ucl = 'assets/ucl.jpg';
  static const String swanseaUni = 'assets/swanseauni.jpg';
  static const String aston = 'assets/aston.jpg';
  static const String aston2 = 'assets/aston2.jpg';
  static const String canadaUni = 'assets/canadauni.jpg';
  static const String australiaUni = 'assets/australliauni.jpg';
  static const String victoria = 'assets/victoria.jpg';
  static const String harvard = 'assets/harvard.jpg';
  static const String stanford = 'assets/stanford.jpg';
  static const String mit_uni = 'assets/mit_uni.jpg';
  static const String yale = 'assets/yale.jpg';
  static const String liberty = 'assets/liberty.jpg';
  static const String USA_f = 'assets/US_flag.jpg';

  // Scholarship Images
  static const String australiaScholar = 'assets/australliascolar.jpg';
  static const String ukScholar = 'assets/ukscolar.jpg';

  // General Study Abroad Images
  static const String abroad1 = 'assets/abroad1.jpg';
  static const String abroad2 = 'assets/abroad2.jpg';
  static const String abroad3 = 'assets/abroad3.jpg';
  static const String abroad4 = 'assets/abroad4.jpg';
  static const String abroad6 = 'assets/abroad6.jpg';
  static const String abroad7 = 'assets/abroad7.jpg';
  static const String abroad8 = 'assets/abroad8.jpg';
  static const String abroad9 = 'assets/abroad9.jpg';
  static const String abroad11 = 'assets/abroad11.png';
  static const String abroad12 = 'assets/abroad12.jpg';
  static const String abroad13 = 'assets/abroad13.jpg';

  // Placeholder Images
  static const String placeholder = 'assets/img.png';

  // User Profile Images (placeholder paths)
  static const String defaultProfileImage = 'assets/default_profile.png';
  static const String user1 = 'assets/user1.jpg';
  static const String user2 = 'assets/user2.jpg';
  static const String user3 = 'assets/user3.jpg';
  static const String user4 = 'assets/user4.jpg';
  static const String user5 = 'assets/user5.jpg';

  // Banner Images for different sections
  static const String homeBanner = abroad1;
  static const String onboardingBanner = abroad1;
  static const String loginBanner = abroad8;
  static const String signupBanner = abroad8;

  // Default images for different categories
  static const String defaultUniversityImage = oxford;
  static const String defaultCountryImage = ukFlag;
  static const String defaultScholarshipImage = australiaScholar;

  // Icon paths (for custom icons if needed)
  static const String homeIcon = '$_icons/home.svg';
  static const String searchIcon = '$_icons/search.svg';
  static const String profileIcon = '$_icons/profile.svg';
  static const String communityIcon = '$_icons/community.svg';
  static const String scholarshipIcon = '$_icons/scholarship.svg';
  static const String universityIcon = '$_icons/university.svg';

  // Animation paths (for future use)
  static const String loadingAnimation = '$_animations/loading.json';
  static const String successAnimation = '$_animations/success.json';
  static const String errorAnimation = '$_animations/error.json';

  // Helper method to get asset path
  static String getAssetPath(String fileName) {
    return 'assets/$fileName';
  }

  // Helper method to get image path
  static String getImagePath(String fileName) {
    return '$_images/$fileName';
  }

  // Helper method to get icon path
  static String getIconPath(String fileName) {
    return '$_icons/$fileName';
  }

  // List of all country images
  static const List<String> countryImages = [
    ukFlag,
    canadaFlag,
    usaFlag,
    australiaFlag,
  ];

  // List of all university images
  static const List<String> universityImages = [
    oxford,
    cambridge,
    mit,
    imperial,
    ucl,
    swanseaUni,
    aston,
    canadaUni,
    australiaUni,
    victoria,
  ];

  // List of all abroad images
  static const List<String> abroadImages = [
    abroad1,
    abroad2,
    abroad3,
    abroad4,
    abroad6,
    abroad7,
    abroad8,
    abroad9,
    abroad11,
    abroad12,
    abroad13,
  ];
}
