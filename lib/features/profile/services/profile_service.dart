import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/api_error.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  /// Get user profile statistics
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw ApiError(message: 'No access token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/user/$userId/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'posts': data['posts'] ?? 0,
          'connections': data['connections'] ?? 0,
          'saved': data['saved'] ?? 0,
        };
      } else {
        throw ApiError(
          message: 'Failed to load profile statistics',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: ${e.toString()}');
    }
  }

  /// Get user's posts count
  Future<int> getUserPostsCount(String userId) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw ApiError(message: 'No access token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/community/user/$userId/posts/count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        return 0; // Return 0 if endpoint doesn't exist yet
      }
    } catch (e) {
      return 0; // Return 0 on error
    }
  }

  /// Get user's connections count
  Future<int> getUserConnectionsCount(String userId) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw ApiError(message: 'No access token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/peer/connections/$userId/count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        return 0; // Return 0 if endpoint doesn't exist yet
      }
    } catch (e) {
      return 0; // Return 0 on error
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    required String name,
    required String email,
    String? university,
    String? city,
  }) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw ApiError(message: 'No access token found');
      }

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'university': university,
          'city': city,
        }),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw ApiError(
          message: errorData['error'] ?? 'Failed to update profile',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: ${e.toString()}');
    }
  }
}