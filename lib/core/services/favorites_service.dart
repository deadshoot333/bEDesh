import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user's favorite universities
class FavoritesService {
  static const String _favoritesKey = 'user_favorite_universities';
  static SharedPreferences? _prefs;

  /// Initialize the service
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      print('✅ FavoritesService: Initialized successfully');
      
      // Debug: Check if there are existing favorites
      final existingFavorites = getFavoriteUniversities();
      print('🔍 FavoritesService: Found ${existingFavorites.length} existing favorites');
    } catch (e) {
      print('❌ FavoritesService: Failed to initialize - $e');
      rethrow;
    }
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
      print('🔍 FavoritesService: Getting favorites from storage - $favoritesJson');
      
      if (favoritesJson == null || favoritesJson.isEmpty) {
        print('📝 FavoritesService: No favorites found in storage');
        return [];
      }
      
      final favoritesList = jsonDecode(favoritesJson) as List;
      final result = favoritesList.cast<Map<String, dynamic>>();
      print('✅ FavoritesService: Successfully loaded ${result.length} favorites');
      return result;
    } catch (e) {
      print('❌ Error getting favorite universities: $e');
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
      print('➕ FavoritesService: Adding university to favorites - $name ($universityId)');
      final favorites = getFavoriteUniversities();
      
      // Check if already exists
      if (favorites.any((fav) => fav['id'] == universityId)) {
        print('⚠️ FavoritesService: University already in favorites');
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
      final success = await _instance.setString(_favoritesKey, favoritesJson);
      
      if (success) {
        print('✅ FavoritesService: Successfully added to favorites. Total: ${favorites.length}');
        // Verify storage
        final verification = _instance.getString(_favoritesKey);
        print('🔍 FavoritesService: Verification - stored data: $verification');
      } else {
        print('❌ FavoritesService: Failed to save to SharedPreferences');
      }
      
      return success;
    } catch (e) {
      print('❌ Error adding to favorites: $e');
      return false;
    }
  }

  /// Remove university from favorites
  static Future<bool> removeFromFavorites(String universityId) async {
    try {
      print('➖ FavoritesService: Removing university from favorites - $universityId');
      final favorites = getFavoriteUniversities();
      final initialLength = favorites.length;
      
      favorites.removeWhere((fav) => fav['id'] == universityId);
      
      if (favorites.length == initialLength) {
        print('⚠️ FavoritesService: University was not in favorites');
        return false; // University was not in favorites
      }

      final favoritesJson = jsonEncode(favorites);
      final success = await _instance.setString(_favoritesKey, favoritesJson);
      
      if (success) {
        print('✅ FavoritesService: Successfully removed from favorites. Total: ${favorites.length}');
      } else {
        print('❌ FavoritesService: Failed to save after removal');
      }
      
      return success;
    } catch (e) {
      print('❌ Error removing from favorites: $e');
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