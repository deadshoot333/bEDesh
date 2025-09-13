import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user's favorite universities
class FavoritesService {
  static const String _favoritesKey = 'user_favorite_universities';
  static SharedPreferences? _prefs;

  /// Initialize the service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception('FavoritesService not initialized. Call FavoritesService.init() first.');
    }
    return _prefs!;
  }

  /// University model for favorites
  static Map<String, dynamic> _createUniversityFavorite({
    required String universityId,
    required String name,
    required String location,
    required String imageUrl,
    int? ranking,
    String? description,
  }) {
    return {
      'id': universityId,
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
      'ranking': ranking,
      'description': description,
      'addedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Get all favorite universities
  static List<Map<String, dynamic>> getFavoriteUniversities() {
    try {
      final favoritesJson = _instance.getString(_favoritesKey);
      if (favoritesJson == null) return [];
      
      final favoritesList = jsonDecode(favoritesJson) as List;
      return favoritesList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting favorite universities: $e');
      return [];
    }
  }

  /// Check if a university is favorited
  static bool isFavorite(String universityId) {
    final favorites = getFavoriteUniversities();
    return favorites.any((fav) => fav['id'] == universityId);
  }

  /// Add university to favorites
  static Future<bool> addToFavorites({
    required String universityId,
    required String name,
    required String location,
    required String imageUrl,
    int? ranking,
    String? description,
  }) async {
    try {
      final favorites = getFavoriteUniversities();
      
      // Check if already exists
      if (favorites.any((fav) => fav['id'] == universityId)) {
        return false; // Already in favorites
      }

      // Add new favorite
      final newFavorite = _createUniversityFavorite(
        universityId: universityId,
        name: name,
        location: location,
        imageUrl: imageUrl,
        ranking: ranking,
        description: description,
      );

      favorites.add(newFavorite);
      
      final favoritesJson = jsonEncode(favorites);
      await _instance.setString(_favoritesKey, favoritesJson);
      
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  /// Remove university from favorites
  static Future<bool> removeFromFavorites(String universityId) async {
    try {
      final favorites = getFavoriteUniversities();
      final initialLength = favorites.length;
      
      favorites.removeWhere((fav) => fav['id'] == universityId);
      
      if (favorites.length == initialLength) {
        return false; // University was not in favorites
      }

      final favoritesJson = jsonEncode(favorites);
      await _instance.setString(_favoritesKey, favoritesJson);
      
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  /// Toggle favorite status
  static Future<bool> toggleFavorite({
    required String universityId,
    required String name,
    required String location,
    required String imageUrl,
    int? ranking,
    String? description,
  }) async {
    if (isFavorite(universityId)) {
      await removeFromFavorites(universityId);
      return false; // Now not favorite
    } else {
      await addToFavorites(
        universityId: universityId,
        name: name,
        location: location,
        imageUrl: imageUrl,
        ranking: ranking,
        description: description,
      );
      return true; // Now favorite
    }
  }

  /// Clear all favorites
  static Future<void> clearAllFavorites() async {
    await _instance.remove(_favoritesKey);
  }

  /// Get favorites count
  static int getFavoritesCount() {
    return getFavoriteUniversities().length;
  }
}