import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/api_error.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // GET request
  Future<Map<String, dynamic>> get(String endpoint, {bool requiresAuth = false}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = Map<String, String>.from(ApiConstants.defaultHeaders);

      if (requiresAuth) {
        final accessToken = StorageService.getAccessToken();
        if (accessToken == null || accessToken.isEmpty) {
          throw ApiError(message: 'No access token found', statusCode: 401);
        }
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiError(message: 'No internet connection');
    } on HttpException {
      throw ApiError(message: 'Network error occurred');
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Unexpected error: ${e.toString()}');
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    print('\n🌐 API SERVICE - POST request');
    print('📍 URL: ${ApiConstants.baseUrl}$endpoint');
    print('📝 Body: ${jsonEncode(body)}');
    print('🔐 Requires auth: $requiresAuth');
    
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = Map<String, String>.from(ApiConstants.defaultHeaders);
      
      print('📋 Headers before auth: $headers');

      if (requiresAuth) {
        final accessToken = StorageService.getAccessToken();
        if (accessToken == null || accessToken.isEmpty) {
          throw ApiError(message: 'No access token found', statusCode: 401);
        }
        headers['Authorization'] = 'Bearer $accessToken';
      }
      
      print('📋 Final headers: $headers');
      print('🚀 Sending POST request...');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(ApiConstants.requestTimeout);
      
      print('📨 Response received:');
      print('  - Status code: ${response.statusCode}');
      print('  - Response body: ${response.body}');
      print('  - Response headers: ${response.headers}');

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('❌ Network error: $e');
      throw ApiError(message: 'No internet connection');
    } on HttpException catch (e) {
      print('❌ HTTP error: $e');
      throw ApiError(message: 'Network error occurred');
    } catch (e) {
      print('❌ Unexpected error in POST: $e');
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Unexpected error: ${e.toString()}');
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = Map<String, String>.from(ApiConstants.defaultHeaders);

      if (requiresAuth) {
        final accessToken = StorageService.getAccessToken();
        if (accessToken == null || accessToken.isEmpty) {
          throw ApiError(message: 'No access token found', statusCode: 401);
        }
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.delete(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiError(message: 'No internet connection');
    } on HttpException {
      throw ApiError(message: 'Network error occurred');
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Unexpected error: ${e.toString()}');
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('\n🔍 RESPONSE HANDLER');
    print('📊 Status code: ${response.statusCode}');
    print('📝 Response body: ${response.body}');
    
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);
      print('✅ JSON parsed successfully: $data');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Request successful');
        return data;
      } else {
        print('❌ Request failed with status ${response.statusCode}');
        throw ApiError(
          message: data['error'] as String? ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Error parsing response: $e');
      if (e is ApiError) rethrow;
      throw ApiError(
        message: 'Failed to parse response',
        statusCode: response.statusCode,
      );
    }
  }
}
