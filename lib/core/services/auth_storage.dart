import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthStorage {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';
  static const String _userIdKey = 'user_id';

  // Store user ID after login
  static Future<void> storeUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    print('✅ [AUTH] User ID stored: $userId');
  }

  // Get current user ID
  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      print('🔍 [AUTH] Retrieved User ID: $userId');
      return userId;
    } catch (e) {
      print('❌ [AUTH] Error getting user ID: $e');
      return null;
    }
  }

  // Store access token
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('✅ [AUTH] Token stored');
  }

  // Get access token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('❌ [AUTH] Error getting token: $e');
      return null;
    }
  }

  // Store user data
  static Future<void> storeUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(userData));
    print('✅ [AUTH] User data stored');
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userKey);
      if (userDataString != null) {
        return json.decode(userDataString);
      }
      return null;
    } catch (e) {
      print('❌ [AUTH] Error getting user data: $e');
      return null;
    }
  }

  // Clear all auth data (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_userIdKey);
    print('✅ [AUTH] All auth data cleared');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final userId = await getCurrentUserId();
    return token != null && userId != null;
  }

  // For development/testing - set a demo user ID
  static Future<void> setDemoUserId() async {
    // This will use a real UUID format that your database expects
    const demoUserId = '550e8400-e29b-41d4-a716-446655440000';
    await storeUserId(demoUserId);
    print('🧪 [AUTH] Demo user ID set: $demoUserId');
  }
}
