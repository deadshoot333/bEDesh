import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/country.dart';

class CountryApiService {
  static const String _baseUrl = ApiConstants.baseUrl;

  // Get all countries
  static Future<List<Country>> getAllCountries() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/country/all-countries'),
        headers: ApiConstants.defaultHeaders,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> countriesJson = data['countries'] ?? [];
        
        return countriesJson
            .map((json) => Country.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching countries: $e');
    }
  }

  // Get country by name
  static Future<Country?> getCountryByName(String countryName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/country/by-name/${Uri.encodeComponent(countryName)}'),
        headers: ApiConstants.defaultHeaders,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> countryJson = data['country'];
        
        return Country.fromJson(countryJson);
      } else if (response.statusCode == 404) {
        return null; // Country not found
      } else {
        throw Exception('Failed to load country: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching country: $e');
    }
  }
}
