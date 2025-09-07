class ApiConstants {
  // Base URL for the Node.js backend
  // static const String baseUrl = 'http://10.103.133.199:5000'; // Old IP
  static const String baseUrl = 'http://localhost:5000'; // For web testing
  // static const String baseUrl = 'http://10.0.2.2:5000'; // For Android emulator

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
