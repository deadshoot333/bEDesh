import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../models/api_error.dart';
import 'storage_service.dart';

/// Service for handling accommodation API calls
class AccommodationApiService {
  static final AccommodationApiService _instance = AccommodationApiService._internal();
  factory AccommodationApiService() => _instance;
  AccommodationApiService._internal();

  // Base URL - Update this to match your backend server
  static const String _baseUrl = 'http://192.168.68.107:5000';
  
  // API endpoints
  static const String _accommodationsEndpoint = '/accommodations';
  static const String _uploadImagesEndpoint = '/accommodations/upload-images';
  static const String _userAccommodationsEndpoint = '/accommodations/user/my';

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _headersWithAuth(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  /// Get auth token from storage or throw error
  String _getAuthToken() {
    final token = StorageService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw ApiError(message: 'Authentication required. Please log in.', statusCode: 401);
    }
    return token;
  }

  /// Handle auth errors and provide user-friendly messages
  void _handleAuthError(int statusCode) {
    if (statusCode == 401) {
      throw ApiError(message: 'Your session has expired. Please log in again.', statusCode: 401);
    } else if (statusCode == 403) {
      throw ApiError(message: 'You do not have permission to perform this action.', statusCode: 403);
    }
  }

  /// Upload images to backend and return image URLs (with automatic auth)
  Future<List<String>> uploadImages(List<XFile> imageFiles) async {
    final authToken = _getAuthToken();
    return _uploadImagesWithToken(imageFiles, authToken);
  }

  /// Upload images to backend with explicit token
  Future<List<String>> _uploadImagesWithToken(List<XFile> imageFiles, String authToken) async {
    if (imageFiles.isEmpty) return [];

    try {
      print('🖼️ Uploading ${imageFiles.length} images to backend...');
      
      final uri = Uri.parse('$_baseUrl$_uploadImagesEndpoint');
      final request = http.MultipartRequest('POST', uri);
      
      // Add authorization header
      request.headers.addAll({
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
      });

      // Add image files
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final multipartFile = await http.MultipartFile.fromPath(
          'images',
          imageFile.path,
          filename: imageFile.name,
        );
        request.files.add(multipartFile);
        print('📎 Added image ${i + 1}: ${imageFile.name}');
      }

      print('📤 Sending upload request to: $uri');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('📥 Upload response status: ${response.statusCode}');
      print('📥 Upload response body: $responseBody');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(responseBody);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<String> imageUrls = List<String>.from(responseData['data']['imageUrls']);
          print('✅ Images uploaded successfully. URLs: ${imageUrls.length}');
          return imageUrls;
        } else {
          throw ApiError(message: 'Upload failed: ${responseData['error'] ?? 'Unknown error'}');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(responseBody);
        throw ApiError(message: 'Upload failed: ${errorData['error'] ?? 'Server error'}');
      }
    } catch (e) {
      print('❌ Image upload error: ${e.toString()}');
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Failed to upload images: ${e.toString()}');
    }
  }

  /// Create new accommodation (with automatic auth)
  Future<Map<String, dynamic>> createAccommodation(
    Map<String, dynamic> accommodationData
  ) async {
    final authToken = _getAuthToken();
    return _createAccommodationWithToken(accommodationData, authToken);
  }

  /// Create new accommodation with explicit token
  Future<Map<String, dynamic>> _createAccommodationWithToken(
    Map<String, dynamic> accommodationData, 
    String authToken
  ) async {
    try {
      print('🏠 Creating accommodation via API...');
      print('📝 Data: ${json.encode(accommodationData)}');
      
      final uri = Uri.parse('$_baseUrl$_accommodationsEndpoint');
      final response = await http.post(
        uri,
        headers: _headersWithAuth(authToken),
        body: json.encode(accommodationData),
      );

      print('📥 Create response status: ${response.statusCode}');
      print('📥 Create response body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        if (responseData['success'] == true) {
          print('✅ Accommodation created successfully');
          return responseData['data'];
        } else {
          throw ApiError(message: responseData['error'] ?? 'Creation failed');
        }
      } else if (response.statusCode == 400) {
        throw ApiError(message: responseData['message'] ?? 'Validation error');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        _handleAuthError(response.statusCode);
        throw ApiError(message: 'Authentication error'); // This won't be reached but satisfies analyzer
      } else {
        throw ApiError(message: responseData['error'] ?? 'Server error');
      }
    } catch (e) {
      print('❌ Create accommodation error: ${e.toString()}');
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Failed to create accommodation: ${e.toString()}');
    }
  }

  /// Get all accommodations with filters
  Future<List<Map<String, dynamic>>> getAccommodations({
    String? location,
    double? maxRent,
    double? minRent,
    String? genderPreference,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      print('🔍 Fetching accommodations from API...');
      
      // Build query parameters
      final Map<String, String> queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (maxRent != null) {
        queryParams['max_rent'] = maxRent.toString();
      }
      if (minRent != null) {
        queryParams['min_rent'] = minRent.toString();
      }
      if (genderPreference != null && genderPreference.isNotEmpty) {
        queryParams['gender_preference'] = genderPreference;
      }
      // Removed isRoommateRequest parameter as backend doesn't support it

      final uri = Uri.parse('$_baseUrl$_accommodationsEndpoint').replace(
        queryParameters: queryParams,
      );
      
      print('📤 GET request to: $uri');
      final response = await http.get(uri, headers: _headers);

      print('📥 Get response status: ${response.statusCode}');
      print('📥 Get response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<Map<String, dynamic>> accommodations = 
              List<Map<String, dynamic>>.from(responseData['data']);
          print('✅ Fetched ${accommodations.length} accommodations');
          return accommodations;
        } else {
          throw ApiError(message: 'Failed to fetch accommodations');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw ApiError(message: errorData['error'] ?? 'Server error');
      }
    } catch (e) {
      print('❌ Get accommodations error: ${e.toString()}');
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Failed to fetch accommodations: ${e.toString()}');
    }
  }

  /// Get accommodation by ID
  Future<Map<String, dynamic>?> getAccommodationById(String id) async {
    try {
      print('🔍 Fetching accommodation by ID: $id');
      
      final uri = Uri.parse('$_baseUrl$_accommodationsEndpoint/$id');
      final response = await http.get(uri, headers: _headers);

      print('📥 Get by ID response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          print('✅ Accommodation fetched successfully');
          return responseData['data'];
        } else {
          return null;
        }
      } else if (response.statusCode == 404) {
        print('ℹ️ Accommodation not found');
        return null;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw ApiError(message: errorData['error'] ?? 'Server error');
      }
    } catch (e) {
      print('❌ Get accommodation by ID error: ${e.toString()}');
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Failed to fetch accommodation: ${e.toString()}');
    }
  }

  /// Get user's accommodations (with automatic auth)
  Future<List<Map<String, dynamic>>> getUserAccommodations() async {
    final authToken = _getAuthToken();
    return _getUserAccommodationsWithToken(authToken);
  }

  /// Get user's accommodations with explicit token
  Future<List<Map<String, dynamic>>> _getUserAccommodationsWithToken(String authToken) async {
    try {
      print('👤 Fetching user accommodations...');
      
      final uri = Uri.parse('$_baseUrl$_userAccommodationsEndpoint');
      final response = await http.get(uri, headers: _headersWithAuth(authToken));

      print('📥 User accommodations response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<Map<String, dynamic>> accommodations = 
              List<Map<String, dynamic>>.from(responseData['data']);
          print('✅ Fetched ${accommodations.length} user accommodations');
          
          // Debug: Print first accommodation to see structure
          if (accommodations.isNotEmpty) {
            print('🔍 DEBUG - First accommodation structure:');
            print(accommodations.first);
          }
          
          return accommodations;
        } else {
          throw ApiError(message: 'Failed to fetch user accommodations');
        }
      } else if (response.statusCode == 401) {
        throw ApiError(message: 'Authentication required');
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw ApiError(message: errorData['error'] ?? 'Server error');
      }
    } catch (e) {
      print('❌ Get user accommodations error: ${e.toString()}');
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Failed to fetch user accommodations: ${e.toString()}');
    }
  }

  /// Update accommodation (with automatic auth)
  Future<Map<String, dynamic>> updateAccommodation(
    String id, 
    Map<String, dynamic> accommodationData
  ) async {
    final authToken = _getAuthToken();
    return _updateAccommodationWithToken(id, accommodationData, authToken);
  }

  /// Update accommodation with explicit token
  Future<Map<String, dynamic>> _updateAccommodationWithToken(
    String id, 
    Map<String, dynamic> accommodationData, 
    String authToken
  ) async {
    try {
      print('✏️ Updating accommodation ID: $id');
      
      final uri = Uri.parse('$_baseUrl$_accommodationsEndpoint/$id');
      final response = await http.put(
        uri,
        headers: _headersWithAuth(authToken),
        body: json.encode(accommodationData),
      );

      print('📥 Update response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          print('✅ Accommodation updated successfully');
          return responseData; // Return full response including 'success' field
        } else {
          throw ApiError(message: responseData['error'] ?? 'Update failed');
        }
      } else if (response.statusCode == 401) {
        throw ApiError(message: 'Authentication required');
      } else if (response.statusCode == 403) {
        throw ApiError(message: 'Unauthorized to update this accommodation');
      } else if (response.statusCode == 404) {
        throw ApiError(message: 'Accommodation not found');
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw ApiError(message: errorData['error'] ?? 'Server error');
      }
    } catch (e) {
      print('❌ Update accommodation error: ${e.toString()}');
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Failed to update accommodation: ${e.toString()}');
    }
  }

  /// Delete accommodation (with automatic auth)
  Future<bool> deleteAccommodation(String id) async {
    final authToken = _getAuthToken();
    return _deleteAccommodationWithToken(id, authToken);
  }

  /// Delete accommodation with explicit token
  Future<bool> _deleteAccommodationWithToken(String id, String authToken) async {
    try {
      print('🗑️ Deleting accommodation ID: $id');
      
      final uri = Uri.parse('$_baseUrl$_accommodationsEndpoint/$id');
      final response = await http.delete(uri, headers: _headersWithAuth(authToken));

      print('📥 Delete response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          print('✅ Accommodation deleted successfully');
          return true;
        } else {
          throw ApiError(message: responseData['error'] ?? 'Delete failed');
        }
      } else if (response.statusCode == 401) {
        throw ApiError(message: 'Authentication required');
      } else if (response.statusCode == 403) {
        throw ApiError(message: 'Unauthorized to delete this accommodation');
      } else if (response.statusCode == 404) {
        throw ApiError(message: 'Accommodation not found');
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw ApiError(message: errorData['error'] ?? 'Server error');
      }
    } catch (e) {
      print('❌ Delete accommodation error: ${e.toString()}');
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Failed to delete accommodation: ${e.toString()}');
    }
  }

  // Upload images to specific accommodation
  Future<List<String>> uploadImagesToAccommodation(String accommodationId, List<XFile> imageFiles) async {
    try {
      String authToken = _getAuthToken();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_accommodationsEndpoint/$accommodationId/images'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $authToken',
      });

      // Add image files to request
      for (XFile imageFile in imageFiles) {
        var multipartFile = http.MultipartFile.fromBytes(
          'images',
          await imageFile.readAsBytes(),
          filename: imageFile.name,
          contentType: MediaType.parse(imageFile.mimeType ?? 'image/jpeg'),
        );
        request.files.add(multipartFile);
      }

      print('🔄 Uploading ${imageFiles.length} images to accommodation $accommodationId...');
      print('🌐 Request URL: $_baseUrl$_accommodationsEndpoint/$accommodationId/images');
      print('🔑 Auth token: ${authToken.substring(0, 20)}...');
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response headers: ${response.headers}');
      print('📡 Response body: ${response.body}');

      // Handle auth errors
      if (response.statusCode == 401 || response.statusCode == 403) {
        _handleAuthError(response.statusCode);
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> imageUrlsData = responseData['data']['imageUrls'];
          final List<String> imageUrls = imageUrlsData.cast<String>();
          print('✅ ${imageUrls.length} images uploaded to accommodation $accommodationId successfully');
          return imageUrls;
        } else {
          throw ApiError(message: responseData['error'] ?? 'Upload failed');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw ApiError(message: errorData['error'] ?? 'Server error', statusCode: response.statusCode);
      }
    } catch (e) {
      print('❌ Upload images to accommodation error: ${e.toString()}');
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Failed to upload images: ${e.toString()}');
    }
  }
}
