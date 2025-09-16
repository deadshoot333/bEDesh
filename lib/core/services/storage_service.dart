import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/user.dart';

class StorageService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call StorageService.init() first.');
    }
    return _prefs!;
  }

  // Token management
  static Future<void> saveAccessToken(String token) async {
    await _instance.setString(ApiConstants.accessTokenKey, token);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _instance.setString(ApiConstants.refreshTokenKey, token);
  }

  static String? getAccessToken() {
    return _instance.getString(ApiConstants.accessTokenKey);
  }

  static String? getRefreshToken() {
    return _instance.getString(ApiConstants.refreshTokenKey);
  }

  // User data management
  static Future<void> saveUserData(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _instance.setString(ApiConstants.userDataKey, userJson);
  }

  static User? getUserData() {
    final userJson = _instance.getString(ApiConstants.userDataKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        // If parsing fails, return null
        return null;
      }
    }
    return null;
  }

  // Authentication state
  static bool isLoggedIn() {
    final accessToken = getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Clear all authentication data
  static Future<void> clearAuthData() async {
    await _instance.remove(ApiConstants.accessTokenKey);
    await _instance.remove(ApiConstants.refreshTokenKey);
    await _instance.remove(ApiConstants.userDataKey);
  }

  // Save both tokens at once
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  // Profile photo management
  static Future<void> setProfilePhotoPath(String imagePath) async {
    await _instance.setString('profile_photo_path', imagePath);
  }

  static String? getProfilePhotoPath() {
    return _instance.getString('profile_photo_path');
  }

  static Future<void> removeProfilePhotoPath() async {
    await _instance.remove('profile_photo_path');
  }
}
