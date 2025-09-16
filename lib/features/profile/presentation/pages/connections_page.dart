import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/connections_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/navigation/navigation_wrapper.dart';
import '../../../community/presentation/pages/peer_messaging_page.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  List<Map<String, dynamic>> _connections = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _loadConnections();
  }

  void _initializeUser() {
    final user = StorageService.getUserData();
    _currentUserId = user?.id;
  }

  Future<void> _loadConnections() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final connections = await ConnectionsService.getMyConnections();
      
      setState(() {
        _connections = connections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeConnection(String connectionId, String userName) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Remove Connection',
          style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to remove $userName from your connections?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Remove',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await ConnectionsService.removeConnection(connectionId);
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Connection removed successfully',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.backgroundPrimary,
                  ),
                ),
                backgroundColor: AppColors.success,
              ),
            );
            _loadConnections(); // Refresh the list
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to remove connection',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.backgroundPrimary,
                  ),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${e.toString()}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.backgroundPrimary,
                ),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationWrapper(
      selectedIndex: 4, // Profile tab context
      child: Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: Text(
          'My Connections',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadConnections,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadConnections,
        color: AppColors.primary,
        child: _buildBody(),
      ),
    ), // Scaffold closes here
  ); // NavigationWrapper closes here
  } // build method closes here

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_connections.isEmpty) {
      return _buildEmptyState();
    }

    return _buildConnectionsList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppConstants.spaceM),
          Text(
            'Loading connections...',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.spaceM),
            Text(
              'Failed to load connections',
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spaceS),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spaceL),
            PrimaryButton(
              text: 'Retry',
              onPressed: _loadConnections,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.spaceM),
            Text(
              'No Connections Yet',
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppConstants.spaceS),
            Text(
              'Start connecting with other students in the Peer Connect tab to build your network!',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spaceL),
            PrimaryButton(
              text: 'Find Peers',
              onPressed: () {
                Navigator.pop(context);
                // Navigate to peer connect page
              },
              icon: Icons.person_search,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      itemCount: _connections.length,
      itemBuilder: (context, index) {
        final connection = _connections[index];
        return _buildConnectionCard(connection);
      },
    );
  }

  Widget _buildConnectionCard(Map<String, dynamic> connection) {
    // Extract user info from connection data
    // The connection might have either requester or receiver info
    final String userId = connection['user_id']?.toString() ?? 
                         connection['requester_id']?.toString() ?? 
                         connection['receiver_id']?.toString() ?? '';
    final String userName = connection['name'] ?? 
                           connection['requester_name'] ?? 
                           connection['receiver_name'] ?? 
                           'Unknown User';
    final String userEmail = connection['email'] ?? 
                            connection['requester_email'] ?? 
                            connection['receiver_email'] ?? 
                            '';
    final String university = connection['university'] ?? 
                             connection['requester_university'] ?? 
                             connection['receiver_university'] ?? 
                             'Unknown University';
    final String city = connection['city'] ?? 
                       connection['requester_city'] ?? 
                       connection['receiver_city'] ?? 
                       'Unknown City';
    final String connectionId = connection['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceM),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        child: Column(
          children: [
            Row(
              children: [
                // Profile Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (userEmail.isNotEmpty)
                        Text(
                          userEmail,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: AppConstants.spaceXS),
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppConstants.spaceXS),
                          Expanded(
                            child: Text(
                              university,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (city.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppConstants.spaceXS),
                            Text(
                              city,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Action Buttons
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  color: AppColors.backgroundCard,
                  onSelected: (value) {
                    switch (value) {
                      case 'message':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PeerMessagingPage(
                              peerId: userId,
                              peerName: userName,
                              peerUniversity: university,
                              currentUserId: _currentUserId ?? '',
                            ),
                          ),
                        );
                        break;
                      case 'remove':
                        _removeConnection(connectionId, userName);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'message',
                      child: Row(
                        children: [
                          const Icon(Icons.message_outlined, color: AppColors.primary),
                          const SizedBox(width: AppConstants.spaceS),
                          Text(
                            'Message',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          const Icon(Icons.person_remove_outlined, color: AppColors.error),
                          const SizedBox(width: AppConstants.spaceS),
                          Text(
                            'Remove',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceM),
            // Quick Action Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Message',
                    icon: Icons.message_outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PeerMessagingPage(
                            peerId: userId,
                            peerName: userName,
                            peerUniversity: university,
                            currentUserId: _currentUserId ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}