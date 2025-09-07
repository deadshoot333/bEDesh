import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_storage.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';

class PeerMessagingPage extends StatefulWidget {
  final String peerName;
  final String peerUniversity;
  final String peerCourse;
  final String peerYear;
  final String? peerId; // Add peer ID for API calls

  const PeerMessagingPage({
    super.key,
    required this.peerName,
    required this.peerUniversity,
    required this.peerCourse,
    required this.peerYear,
    this.peerId,
  });

  @override
  State<PeerMessagingPage> createState() => _PeerMessagingPageState();
}

class _PeerMessagingPageState extends State<PeerMessagingPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _isLoading = false;
  
  // Will store the real user ID from authentication
  String? _currentUserId;
  
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  // Initialize user and load messages
  Future<void> _initializeUser() async {
    await _getCurrentUserId();
    if (_currentUserId != null) {
      await _testBackendConnection();
      await _loadMessages();
    } else {
      print('❌ [DEBUG] No user ID found - user not logged in');
      _showErrorDialog('Please log in to send messages');
    }
  }

  // Get current user ID from storage
  Future<void> _getCurrentUserId() async {
    try {
      _currentUserId = await AuthStorage.getCurrentUserId();
      if (_currentUserId == null) {
        print('🧪 [DEBUG] No stored user ID, setting demo user...');
        await AuthStorage.setDemoUserId();
        _currentUserId = await AuthStorage.getCurrentUserId();
      }
      print('👤 [DEBUG] Current User ID: $_currentUserId');
    } catch (e) {
      print('❌ [DEBUG] Error getting user ID: $e');
    }
  }

  // Test backend connection
  Future<void> _testBackendConnection() async {
    print('🔍 [DEBUG] Testing backend connection...');
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('🔍 [DEBUG] Backend test - Status: ${response.statusCode}');
      print('🔍 [DEBUG] Backend test - Response: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ [DEBUG] Backend is connected and responding!');
      } else {
        print('⚠️ [DEBUG] Backend responded but with error code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [DEBUG] Backend connection failed: $e');
      print('❌ [DEBUG] Make sure the server is running on ${ApiConstants.baseUrl}');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  // Load messages from backend when page opens
  Future<void> _loadMessages() async {
    print('🔄 [DEBUG] Starting to load messages...');
    print('🔄 [DEBUG] Current User ID: $_currentUserId');
    print('🔄 [DEBUG] Peer ID: ${widget.peerId ?? 'fffccdd9-ce55-41cf-8eaa-1964dc730329'}');
    
    // Check if user is logged in
    if (_currentUserId == null) {
      print('❌ [DEBUG] No user ID available for loading messages');
      _loadDummyMessages();
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
      });

      final String peerId = widget.peerId ?? "fffccdd9-ce55-41cf-8eaa-1964dc730329"; // Use real Ayaan UUID fallback
      final String url = '${ApiConstants.baseUrl}/api/message/$_currentUserId/$peerId';
      print('🌐 [DEBUG] API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 [DEBUG] Response Status Code: ${response.statusCode}');
      print('📡 [DEBUG] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> messageData = json.decode(response.body);
        print('✅ [DEBUG] Messages loaded successfully: ${messageData.length} messages');
        
        setState(() {
          messages = messageData.map((msg) {
            print('📝 [DEBUG] Processing message: ${msg['content']} from sender: ${msg['sender_id']}');
            return Message(
              text: msg['content'] ?? '',
              isMe: msg['sender_id'] == _currentUserId,
              timestamp: DateTime.tryParse(msg['created_at'] ?? '') ?? DateTime.now(),
            );
          }).toList();
        });
        
        print('✅ [DEBUG] Messages set in UI: ${messages.length} messages');
        
        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        print('❌ [DEBUG] Failed to load messages: ${response.statusCode}');
        print('❌ [DEBUG] Error response: ${response.body}');
        _loadDummyMessages(); // Load dummy data if API fails
      }
    } catch (e) {
      print('💥 [DEBUG] Error loading messages: $e');
      print('💥 [DEBUG] Error type: ${e.runtimeType}');
      _loadDummyMessages(); // Load dummy data on error
    } finally {
      setState(() {
        _isLoading = false;
      });
      print('🏁 [DEBUG] Load messages completed');
    }
  }

  // Load dummy messages as fallback
  void _loadDummyMessages() {
    setState(() {
      messages = [
        Message(
          text: "Hey! I saw your profile on Peer Connect. Nice to meet you!",
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Message(
          text: "Hi there! Nice to meet you too. How are you finding your studies?",
          isMe: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        ),
        Message(
          text: "It's been quite challenging but exciting! I love the practical projects we're working on. What about you?",
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        ),
      ];
    });
  }

  // Send message to backend
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    // Check if user is logged in
    if (_currentUserId == null) {
      _showErrorDialog('Please log in to send messages');
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Add message to UI immediately for better user experience
    setState(() {
      messages.add(
        Message(
          text: messageText,
          isMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();

    // Send to backend
    try {
      final String peerId = widget.peerId ?? "fffccdd9-ce55-41cf-8eaa-1964dc730329"; // Use real Ayaan UUID fallback
      print('📤 [DEBUG] Sending message to backend...');
      print('📤 [DEBUG] Sender ID: $_currentUserId');
      print('📤 [DEBUG] Receiver ID: $peerId');
      print('📤 [DEBUG] Message: $messageText');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'senderId': _currentUserId,
          'receiverId': peerId,
          'content': messageText,
        }),
      );

      print('📤 [DEBUG] Send Response Status: ${response.statusCode}');
      print('📤 [DEBUG] Send Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ [DEBUG] Message sent successfully!');
        // Optionally refresh messages to get server response
        // _loadMessages();
      } else {
        print('❌ [DEBUG] Failed to send message: ${response.statusCode}');
        print('❌ [DEBUG] Error response: ${response.body}');
        // Could show an error indicator or retry option
      }
    } catch (e) {
      print('💥 [DEBUG] Error sending message: $e');
      print('💥 [DEBUG] Error type: ${e.runtimeType}');
      // Could show an error indicator on the message
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 380;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Column(
        children: [
          // Header
          _buildHeader(isSmallScreen),

          // Messages List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusL),
                  topRight: Radius.circular(AppConstants.radiusL),
                ),
              ),
              child: Column(
                children: [
                  // Chat messages
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(
                              isSmallScreen
                                  ? AppConstants.spaceS
                                  : AppConstants.spaceM,
                            ),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessageBubble(
                                messages[index],
                                isSmallScreen,
                                screenWidth,
                              );
                            },
                          ),
                  ),

                  // Message input
                  _buildMessageInput(isSmallScreen, keyboardHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            isSmallScreen ? AppConstants.spaceS : AppConstants.spaceM,
          ),
          child: Row(
            children: [
              // Back button
              Container(
                margin: const EdgeInsets.only(right: AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.textOnPrimary,
                    size: isSmallScreen ? 18 : 20,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              // Profile avatar
              CircleAvatar(
                backgroundColor: AppColors.textOnPrimary,
                radius: isSmallScreen ? 18 : 22,
                child: Text(
                  widget.peerName.substring(0, 1).toUpperCase(),
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),

              const SizedBox(width: AppConstants.spaceM),

              // Peer info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.peerName,
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${widget.peerCourse} • ${widget.peerYear}",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textOnPrimary.withOpacity(0.8),
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // More options button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textOnPrimary,
                    size: isSmallScreen ? 18 : 20,
                  ),
                  onPressed: () {
                    _showOptionsBottomSheet(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    Message message,
    bool isSmallScreen,
    double screenWidth,
  ) {
    final maxWidth = screenWidth * 0.75;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isSmallScreen ? AppConstants.spaceS : AppConstants.spaceM,
        left: message.isMe ? maxWidth * 0.2 : 0,
        right: message.isMe ? 0 : maxWidth * 0.2,
      ),
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : AppConstants.spaceM,
              vertical: isSmallScreen ? 8 : AppConstants.spaceS,
            ),
            decoration: BoxDecoration(
              color:
                  message.isMe ? AppColors.primary : AppColors.backgroundCard,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppConstants.radiusM),
                topRight: const Radius.circular(AppConstants.radiusM),
                bottomLeft: Radius.circular(
                  message.isMe ? AppConstants.radiusM : AppConstants.spaceXS,
                ),
                bottomRight: Radius.circular(
                  message.isMe ? AppConstants.spaceXS : AppConstants.radiusM,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color:
                    message.isMe
                        ? AppColors.textOnPrimary
                        : AppColors.textPrimary,
                fontSize: isSmallScreen ? 14 : 15,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceXS),

          // Timestamp
          Text(
            _formatTimestamp(message.timestamp),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: isSmallScreen ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isSmallScreen, double keyboardHeight) {
    return Container(
      padding: EdgeInsets.all(
        isSmallScreen ? AppConstants.spaceS : AppConstants.spaceM,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: isSmallScreen ? 40 : 48,
                  maxHeight: isSmallScreen ? 100 : 120,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  border: Border.all(color: AppColors.borderLight, width: 1),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: isSmallScreen ? 14 : 15,
                  ),
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: isSmallScreen ? 14 : 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : AppConstants.spaceM,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: AppConstants.spaceS),

            // Send button
            Container(
              width: isSmallScreen ? 40 : 48,
              height: isSmallScreen ? 40 : 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: AppColors.textOnPrimary,
                  size: isSmallScreen ? 18 : 20,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 380;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusL),
        ),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spaceL),

                  // Options
                  _buildOptionTile(
                    Icons.person_outline,
                    "View Profile",
                    isSmallScreen,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to peer profile
                    },
                  ),

                  _buildOptionTile(
                    Icons.block_outlined,
                    "Block User",
                    isSmallScreen,
                    () {
                      Navigator.pop(context);
                      _showBlockConfirmation(context);
                    },
                  ),

                  _buildOptionTile(
                    Icons.report_outlined,
                    "Report User",
                    isSmallScreen,
                    () {
                      Navigator.pop(context);
                      // TODO: Show report dialog
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String title,
    bool isSmallScreen,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textSecondary,
        size: isSmallScreen ? 20 : 24,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: isSmallScreen ? 14 : 16,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? AppConstants.spaceS : AppConstants.spaceM,
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundCard,
            title: Text("Block ${widget.peerName}?", style: AppTextStyles.h5),
            content: Text(
              "They won't be able to message you or see your profile.",
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to peer connect page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${widget.peerName} has been blocked"),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
                child: Text(
                  "Block",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inDays < 1) {
      return "${difference.inHours}h ago";
    } else {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    }
  }
}

class Message {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  Message({required this.text, required this.isMe, required this.timestamp});
}
