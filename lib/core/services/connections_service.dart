import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'storage_service.dart';

/// Service for managing peer connections
class ConnectionsService {
  
  /// Fetch all accepted connections for the current user
  static Future<List<Map<String, dynamic>>> getMyConnections() async {
    try {
      final user = StorageService.getUserData();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/peer/connections/${user.id}');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔗 ConnectionsService: GET $url -> ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load connections: ${response.body}');
      }
    } catch (e) {
      print('❌ ConnectionsService: Error fetching connections - $e');
      rethrow;
    }
  }

  /// Get connection count for the current user
  static Future<int> getConnectionsCount() async {
    try {
      final connections = await getMyConnections();
      return connections.length;
    } catch (e) {
      print('❌ ConnectionsService: Error getting connections count - $e');
      return 0;
    }
  }

  /// Get connection details by user ID
  static Future<Map<String, dynamic>?> getConnectionDetails(String userId) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/peer/user/$userId');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('⚠️ ConnectionsService: Failed to get user details: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ ConnectionsService: Error getting connection details - $e');
      return null;
    }
  }

  /// Remove a connection
  static Future<bool> removeConnection(String connectionId) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/peer/disconnect');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'connectionId': connectionId}),
      );

      print('🔗 ConnectionsService: POST $url -> ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('⚠️ ConnectionsService: Failed to remove connection: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ ConnectionsService: Error removing connection - $e');
      return false;
    }
  }

  /// Check if two users are connected
  static Future<bool> areUsersConnected(String userId1, String userId2) async {
    try {
      final connections = await getMyConnections();
      
      return connections.any((connection) => 
        (connection['requester_id'] == userId1 && connection['receiver_id'] == userId2) ||
        (connection['requester_id'] == userId2 && connection['receiver_id'] == userId1)
      );
    } catch (e) {
      print('❌ ConnectionsService: Error checking connection status - $e');
      return false;
    }
  }
}