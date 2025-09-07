import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class BackendTestPage extends StatefulWidget {
  const BackendTestPage({super.key});

  @override
  State<BackendTestPage> createState() => _BackendTestPageState();
}

class _BackendTestPageState extends State<BackendTestPage> {
  String connectionStatus = 'Not tested';
  String apiResponse = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Connection Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Backend URL: ${ApiConstants.baseUrl}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spaceM),
            
            // Connection Status
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Text(
                'Status: $connectionStatus',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.spaceM),
            
            // Test Buttons
            ElevatedButton(
              onPressed: isLoading ? null : _testBasicConnection,
              child: isLoading 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Test Basic Connection'),
            ),
            
            const SizedBox(height: AppConstants.spaceS),
            
            ElevatedButton(
              onPressed: isLoading ? null : _testMessageAPI,
              child: const Text('Test Message API'),
            ),
            
            const SizedBox(height: AppConstants.spaceS),
            
            ElevatedButton(
              onPressed: isLoading ? null : _sendTestMessage,
              child: const Text('Send Test Message'),
            ),
            
            const SizedBox(height: AppConstants.spaceM),
            
            // Response Display
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    apiResponse.isEmpty ? 'API responses will appear here...' : apiResponse,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (connectionStatus) {
      case 'Connected':
        return AppColors.success;
      case 'Failed':
        return AppColors.error;
      case 'Testing...':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _testBasicConnection() async {
    setState(() {
      isLoading = true;
      connectionStatus = 'Testing...';
      apiResponse = '';
    });

    try {
      print('🔍 Testing basic connection to: ${ApiConstants.baseUrl}');
      
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      setState(() {
        connectionStatus = response.statusCode == 200 ? 'Connected' : 'Failed';
        apiResponse = '''
✅ BASIC CONNECTION TEST RESULTS:
🌐 URL: ${ApiConstants.baseUrl}/
📡 Status Code: ${response.statusCode}
📝 Response: ${response.body}
⏰ Timestamp: ${DateTime.now()}
        ''';
      });

      print('✅ Basic connection test completed: ${response.statusCode}');
    } catch (e) {
      setState(() {
        connectionStatus = 'Failed';
        apiResponse = '''
❌ BASIC CONNECTION FAILED:
🌐 URL: ${ApiConstants.baseUrl}/
💥 Error: $e
⏰ Timestamp: ${DateTime.now()}

🔧 TROUBLESHOOTING:
1. Make sure the server is running
2. Check if the IP address is correct
3. Verify port 5000 is open
4. Try changing baseUrl to 'http://localhost:5000' if testing on the same machine
        ''';
      });

      print('❌ Basic connection failed: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _testMessageAPI() async {
    setState(() {
      isLoading = true;
      apiResponse = 'Testing message API...';
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/message/user123/peer456'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      setState(() {
        apiResponse = '''
📨 MESSAGE API TEST RESULTS:
🌐 URL: ${ApiConstants.baseUrl}/api/message/user123/peer456
📡 Status Code: ${response.statusCode}
📝 Response: ${response.body}
⏰ Timestamp: ${DateTime.now()}
        ''';
      });

      print('📨 Message API test completed: ${response.statusCode}');
    } catch (e) {
      setState(() {
        apiResponse = '''
❌ MESSAGE API TEST FAILED:
🌐 URL: ${ApiConstants.baseUrl}/api/message/user123/peer456
💥 Error: $e
⏰ Timestamp: ${DateTime.now()}
        ''';
      });

      print('❌ Message API test failed: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendTestMessage() async {
    setState(() {
      isLoading = true;
      apiResponse = 'Sending test message...';
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'senderId': 'user123',
          'receiverId': 'peer456',
          'content': 'Test message from Flutter app at ${DateTime.now()}',
        }),
      ).timeout(const Duration(seconds: 10));

      setState(() {
        apiResponse = '''
📤 SEND MESSAGE TEST RESULTS:
🌐 URL: ${ApiConstants.baseUrl}/api/message
📡 Status Code: ${response.statusCode}
📝 Response: ${response.body}
📋 Sent Data: {
  "senderId": "user123",
  "receiverId": "peer456", 
  "content": "Test message from Flutter app"
}
⏰ Timestamp: ${DateTime.now()}
        ''';
      });

      print('📤 Send message test completed: ${response.statusCode}');
    } catch (e) {
      setState(() {
        apiResponse = '''
❌ SEND MESSAGE TEST FAILED:
🌐 URL: ${ApiConstants.baseUrl}/api/message
💥 Error: $e
⏰ Timestamp: ${DateTime.now()}
        ''';
      });

      print('❌ Send message test failed: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
