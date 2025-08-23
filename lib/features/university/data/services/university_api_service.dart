import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/university.dart';
import '../../domain/models/course.dart';
import '../../domain/models/scholarship.dart';

class UniversityApiService {
  static const String _baseUrl = ApiConstants.baseUrl;

  // Get all universities
  static Future<List<University>> getAllUniversities() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/university/all-universities'),
        headers: ApiConstants.defaultHeaders,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> universitiesJson = data['universities'] ?? [];
        
        return universitiesJson
            .map((json) => University.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load universities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching universities: $e');
    }
  }

  // Get university by ID
  static Future<University> getUniversityById(String universityId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/university/$universityId'),
        headers: ApiConstants.defaultHeaders,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return University.fromJson(data['university']);
      } else {
        throw Exception('Failed to load university: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching university: $e');
    }
  }

  // Get university by name
  static Future<University> getUniversityByName(String universityName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/university/by-name/${Uri.encodeComponent(universityName)}'),
        headers: ApiConstants.defaultHeaders,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return University.fromJson(data['university']);
      } else {
        throw Exception('Failed to load university: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching university by name: $e');
    }
  }

  // Get courses by university name
  static Future<List<Course>> getCoursesByUniversity(String universityName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/university/courses/${Uri.encodeComponent(universityName)}'),
        headers: ApiConstants.defaultHeaders,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> coursesJson = data['courses'] ?? [];
        
        return coursesJson
            .map((json) => Course.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }

  // Get scholarships by university name
  static Future<List<Scholarship>> getScholarshipsByUniversity(String universityName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/university/scholarships/${Uri.encodeComponent(universityName)}'),
        headers: ApiConstants.defaultHeaders,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> scholarshipsJson = data['scholarships'] ?? [];
        
        return scholarshipsJson
            .map((json) => Scholarship.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load scholarships: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching scholarships: $e');
    }
  }

  // Search universities
  static Future<List<University>> searchUniversities(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/university/search?q=${Uri.encodeComponent(query)}'),
        headers: ApiConstants.defaultHeaders,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> universitiesJson = data['universities'] ?? [];
        
        return universitiesJson
            .map((json) => University.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to search universities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching universities: $e');
    }
  }

  // Get universities by country
  static Future<List<University>> getUniversitiesByCountry(String country) async {
    try {
      // Use search endpoint to find universities by country
      return await searchUniversities(country);
    } catch (e) {
      throw Exception('Error fetching universities by country: $e');
    }
  }
}
