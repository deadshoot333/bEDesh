import 'dart:convert';

import '../constants/api_constants.dart';
import '../models/auth_response.dart';
import '../models/signup_response.dart';
import '../models/user.dart';
import '../models/api_error.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  // User signup with enhanced null safety checks
  Future<SignupResponse> signup({
    required String name,
    required String email,
    required String mobile,
    required String university,
    required String city,
    required String password,
  }) async {
    print('\n🚀 FLUTTER - AuthService.signup called');
    print('📝 Parameters:');
    print('  - name: ${name.isNotEmpty ? name : 'EMPTY'}');
    print('  - email: ${email.isNotEmpty ? email : 'EMPTY'}');
    print('  - mobile: ${mobile.isNotEmpty ? mobile : 'EMPTY'}');
    print('  - university: ${university.isNotEmpty ? university : 'EMPTY'}');
    print('  - city: ${city.isNotEmpty ? city : 'EMPTY'}');
    print('  - password: ${password.isNotEmpty ? '[REDACTED]' : 'EMPTY'}');

    // Additional validation to prevent null/empty values
    if (name.trim().isEmpty) {
      throw ApiError(message: 'Name cannot be empty');
    }
    if (email.trim().isEmpty) {
      throw ApiError(message: 'Email cannot be empty');
    }
    if (mobile.trim().isEmpty) {
      throw ApiError(message: 'Mobile cannot be empty');
    }
    if (university.trim().isEmpty) {
      throw ApiError(message: 'University cannot be empty');
    }
    if (city.trim().isEmpty) {
      throw ApiError(message: 'City cannot be empty');
    }
    if (password.isEmpty) {
      throw ApiError(message: 'Password cannot be empty');
    }

    try {
      print('🌐 Calling API...');

      final requestBody = {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'mobile': mobile.trim(),
        'university': university.trim(),
        'city': city.trim(),
        'password': password,
      };

      print('📤 Request body: ${jsonEncode(requestBody)}');

      final response = await _apiService.post(
        ApiConstants.signupEndpoint,
        requestBody,
      );

      print('✅ API call successful, response: $response');

      if (response == null) {
        throw ApiError(message: 'No response received from server');
      }

      return SignupResponse.fromJson(response);
    } catch (e) {
      print('❌ ERROR in AuthService.signup:');
      print('  - Error type: ${e.runtimeType}');
      print('  - Error message: $e');

      if (e is ApiError) {
        rethrow;
      }

      // Handle specific error types
      if (e is TypeError) {
        throw ApiError(
          message: 'Data format error: Please check your input data',
        );
      }
      if (e is FormatException) {
        throw ApiError(message: 'Invalid data format: ${e.message}');
      }

      throw ApiError(message: 'Signup failed: ${e.toString()}');
    }
  }

  // User login with null safety improvements
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    // Validate inputs
    if (email.trim().isEmpty) {
      throw ApiError(message: 'Email cannot be empty');
    }
    if (password.isEmpty) {
      throw ApiError(message: 'Password cannot be empty');
    }

    try {
      final response = await _apiService.post(ApiConstants.loginEndpoint, {
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      if (response == null) {
        throw ApiError(message: 'No response received from server');
      }

      final authResponse = AuthResponse.fromJson(response);

      // Validate response data before saving
      if (authResponse.accessToken.isEmpty ||
          authResponse.refreshToken.isEmpty) {
        throw ApiError(message: 'Invalid authentication tokens received');
      }

      // Save tokens to storage
      await StorageService.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );

      // Safely extract user data
      final userData = response['user'];
      if (userData == null) {
        throw ApiError(message: 'User data not found in response');
      }

      final user = User.fromJson(userData as Map<String, dynamic>);
      await StorageService.saveUserData(user);

      return authResponse;
    } catch (e) {
      print('❌ ERROR in AuthService.login:');
      print('  - Error type: ${e.runtimeType}');
      print('  - Error message: $e');

      if (e is ApiError) rethrow;
      if (e is TypeError) {
        throw ApiError(message: 'Login response format error');
      }
      throw ApiError(message: 'Login failed: ${e.toString()}');
    }
  }

  // Get user profile with improved error handling
  Future<User> getProfile() async {
    try {
      final response = await _apiService.get(
        ApiConstants.profileEndpoint,
        requiresAuth: true,
      );

      if (response == null) {
        throw ApiError(message: 'No profile data received');
      }

      final userData = response['user'];
      if (userData == null) {
        throw ApiError(message: 'User profile data not found');
      }

      final user = User.fromJson(userData as Map<String, dynamic>);

      // Save user data to storage
      await StorageService.saveUserData(user);

      return user;
    } catch (e) {
      print('❌ ERROR in AuthService.getProfile:');
      print('  - Error type: ${e.runtimeType}');
      print('  - Error message: $e');

      if (e is ApiError) rethrow;
      if (e is TypeError) {
        throw ApiError(message: 'Profile data format error');
      }
      throw ApiError(message: 'Failed to get profile: ${e.toString()}');
    }
  }

  // Refresh access token
  Future<String> refreshToken() async {
    try {
      final refreshToken = StorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw ApiError(
          message: 'No valid refresh token found',
          statusCode: 401,
        );
      }

      final response = await _apiService.post(ApiConstants.refreshEndpoint, {
        'refreshToken': refreshToken,
      });

      if (response == null) {
        throw ApiError(message: 'No response from token refresh');
      }

      final newAccessToken = response['accessToken'];
      if (newAccessToken == null || newAccessToken.toString().isEmpty) {
        throw ApiError(message: 'Invalid access token received');
      }

      final tokenString = newAccessToken.toString();

      // Save new access token
      await StorageService.saveAccessToken(tokenString);

      return tokenString;
    } catch (e) {
      print('❌ ERROR in AuthService.refreshToken:');
      print('  - Error type: ${e.runtimeType}');
      print('  - Error message: $e');

      if (e is ApiError) rethrow;
      throw ApiError(message: 'Token refresh failed: ${e.toString()}');
    }
  }

  // User logout
  Future<void> logout() async {
    try {
      final refreshToken = StorageService.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        // Attempt to logout from backend
        try {
          await _apiService.delete(ApiConstants.logoutEndpoint, {
            'refreshToken': refreshToken,
          });
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
