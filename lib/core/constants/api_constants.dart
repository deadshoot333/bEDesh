class ApiConstants {
  // Base URL for the Node.js backend
  static const String baseUrl = 'http://localhost:5000';
  // static const String baseUrl = 'http://192.168.68.101:5000';  // Use for network access
  // static const String baseUrl = 'http://10.0.2.2:5000';      // Use for Android emulator

  // Authentication endpoints
  static const String signupEndpoint = '/auth/signup';
  static const String loginEndpoint = '/auth/login';
  static const String profileEndpoint = '/auth/me';
  static const String refreshEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';

  // Request configuration
  static const Duration requestTimeout = Duration(seconds: 30);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}
