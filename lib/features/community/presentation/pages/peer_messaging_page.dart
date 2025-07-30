import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';

class PeerMessagingPage extends StatefulWidget {
  final String peerName;
  final String peerUniversity;
  final String peerCourse;
  final String peerYear;

  const PeerMessagingPage({
    super.key,
    required this.peerName,
    required this.peerUniversity,
    required this.peerCourse,
    required this.peerYear,
  });

  @override
  State<PeerMessagingPage> createState() => _PeerMessagingPageState();
}

class _PeerMessagingPageState extends State<PeerMessagingPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  List<Message> messages = [
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
      text:
          "It's been quite challenging but exciting! I love the practical projects we're working on. What about you?",
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    ),
    Message(
      text:
          "Same here! The coursework is intense but really rewarding. Are you planning to join any study groups?",
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add(
          Message(
            text: _messageController.text.trim(),
            isMe: true,
            timestamp: DateTime.now(),
          ),
        );
      });
      _messageController.clear();
      _scrollToBottom();
    }
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
                    child: ListView.builder(
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
