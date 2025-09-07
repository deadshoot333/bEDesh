import '../constants/api_constants.dart';
import '../models/auth_response.dart';
import '../models/signup_response.dart';
import '../models/user.dart';
import '../models/api_error.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'auth_storage.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  // User signup
  Future<SignupResponse> signup({
    required String email,
    required String mobile,
    required String password,
  }) async {
    print('\n🚀 FLUTTER - AuthService.signup called');
    print('📝 Parameters:');
    print('  - email: $email');
    print('  - mobile: $mobile');
    print('  - password: ${password.isNotEmpty ? '[REDACTED]' : 'EMPTY'}');
    
    try {
      print('🌐 Calling API...');
      final response = await _apiService.post(
        ApiConstants.signupEndpoint,
        {
          'email': email,
          'mobile': mobile,
          'password': password,
        },
      );
      
      print('✅ API call successful, response: $response');
      return SignupResponse.fromJson(response);
    } catch (e) {
      print('❌ ERROR in AuthService.signup:');
      print('  - Error type: ${e.runtimeType}');
      print('  - Error message: $e');
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Signup failed: ${e.toString()}');
    }
  }

  // User login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.loginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response);
      
      // Save tokens to storage
      await StorageService.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );

      // Extract and save user ID from JWT token
      final userId = _extractUserIdFromToken(authResponse.accessToken);
      if (userId != null) {
        await AuthStorage.storeUserId(userId);
        print('✅ [AUTH] User ID extracted and stored: $userId');
      }

      return authResponse;
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Login failed: ${e.toString()}');
    }
  }

  // Extract user ID from JWT token
  String? _extractUserIdFromToken(String token) {
    try {
      // JWT has 3 parts separated by dots: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      // Decode the payload (second part)
      String payload = parts[1];
      
      // Add padding if needed (JWT base64 encoding might not have padding)
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      
      // Decode base64
      final decoded = utf8.decode(base64Decode(payload));
      final Map<String, dynamic> tokenData = json.decode(decoded);
      
      return tokenData['userId'] as String?;
    } catch (e) {
      print('❌ [AUTH] Error extracting user ID from token: $e');
      return null;
    }
  }

  // Get user profile
  Future<User> getProfile() async {
    try {
      final response = await _apiService.get(
        ApiConstants.profileEndpoint,
        requiresAuth: true,
      );

      final user = User.fromJson(response['user'] as Map<String, dynamic>);
      
      // Save user data to storage
      await StorageService.saveUserData(user);
      
      return user;
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Failed to get profile: ${e.toString()}');
    }
  }

  // Refresh access token
  Future<String> refreshToken() async {
    try {
      final refreshToken = StorageService.getRefreshToken();
      if (refreshToken == null) {
        throw ApiError(message: 'No refresh token found', statusCode: 401);
      }

      final response = await _apiService.post(
        ApiConstants.refreshEndpoint,
        {'refreshToken': refreshToken},
      );

      final newAccessToken = response['accessToken'] as String;
      
      // Save new access token
      await StorageService.saveAccessToken(newAccessToken);
      
      return newAccessToken;
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Token refresh failed: ${e.toString()}');
    }
  }

  // User logout
  Future<void> logout() async {
    try {
      final refreshToken = StorageService.getRefreshToken();
      
      if (refreshToken != null) {
        // Attempt to logout from backend
        try {
          await _apiService.delete(
            ApiConstants.logoutEndpoint,
            {'refreshToken': refreshToken},
          );
        } catch (e) {
          // Continue with local logout even if backend call fails
          print('Backend logout failed: $e');
        }
      }

      // Clear local authentication data
      await StorageService.clearAuthData();
    } catch (e) {
      // Ensure local data is cleared even if there's an error
      await StorageService.clearAuthData();
      throw ApiError(message: 'Logout failed: ${e.toString()}');
    }
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return StorageService.isLoggedIn();
  }

  // Get current user from storage
  User? getCurrentUser() {
    return StorageService.getUserData();
  }

  // Login with stored credentials (for auto-login)
  Future<bool> autoLogin() async {
    try {
      if (!isAuthenticated()) return false;

      // Try to get profile to verify token is still valid
      await getProfile();
      return true;
    } catch (e) {
      // If token is invalid, try to refresh
      try {
        await refreshToken();
        await getProfile();
        return true;
      } catch (refreshError) {
        // If refresh fails, logout
        await logout();
        return false;
      }
    }
  }
}
