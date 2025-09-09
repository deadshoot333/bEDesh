import 'dart:convert';
import 'package:bedesh/features/community/presentation/pages/peer_messaging_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/inputs/modern_search_bar.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/constants/api_constants.dart';

class PeerConnectPage extends StatefulWidget {
  const PeerConnectPage({super.key});

  @override
  State<PeerConnectPage> createState() => _PeerConnectPageState();
}

class _PeerConnectPageState extends State<PeerConnectPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // 🔹 Replace this with your logged-in userId from auth/session
  final String currentUserId = "1fa5ba70-6a6c-473c-97c2-d0d4e33dea1e";
  // User? currentUser;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    // fetch user from StorageService
    // currentUser = StorageService.getUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchPeers(String filterType) async {
    // if (currentUser == null) return [];

    final url = Uri.parse(
      "${ApiConstants.baseUrl}/api/peer/$filterType/$currentUserId",
    );

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer ${StorageService.getAccessToken()}"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to load peers");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Column(
        children: [
          _buildModernHeader(),

          Container(
            color: AppColors.backgroundCard,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [Tab(text: "University"), Tab(text: "City")],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceM),
            child: ModernSearchBar(
              hintText: "Search students...",
              controller: _searchController,
              onChanged: (query) {
                setState(() {}); // refresh list on search
              },
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildStudentList("university"),
                buildStudentList("city"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
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
          padding: const EdgeInsets.all(AppConstants.spaceM),
          child: Row(
            children: [
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
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: Text(
                  'Peer Connect',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ModernIconButton(
                icon: Icons.person_outline,
                backgroundColor: AppColors.textOnPrimary.withOpacity(0.2),
                iconColor: AppColors.textOnPrimary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                tooltip: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStudentList(String filterType) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchPeers(filterType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final peers = snapshot.data ?? [];
        print(peers);
        // Apply search filtering
        final query = _searchController.text.toLowerCase();
        final filteredPeers =
            peers.where((peer) {
              return peer['name'].contains(query) ||
                  peer['university'].contains(query) ||
                  peer['city'].contains(query);
            }).toList();

        if (filteredPeers.isEmpty) {
          return const Center(child: Text("No peers found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          itemCount: filteredPeers.length,
          itemBuilder: (context, index) {
            final peer = filteredPeers[index];
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 380;

            return Container(
              margin: const EdgeInsets.only(bottom: AppConstants.spaceM),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(color: AppColors.borderLight, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          radius: isSmallScreen ? 20 : 25,
                          child: Text(
                            peer['name'].substring(0, 1).toUpperCase(),
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 16 : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                peer['name'],
                                style: AppTextStyles.h5.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 16 : null,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spaceXS),
                              Text(
                                filterType == 'university'
                                    ? peer['university']
                                    : "Lives in ${peer['city']}",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: isSmallScreen ? 12 : null,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spaceS),
                              Wrap(
                                spacing: AppConstants.spaceS,
                                runSpacing: AppConstants.spaceXS,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          isSmallScreen
                                              ? 6
                                              : AppConstants.spaceS,
                                      vertical: AppConstants.spaceXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.radiusS,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          isSmallScreen
                                              ? 6
                                              : AppConstants.spaceS,
                                      vertical: AppConstants.spaceXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.radiusS,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceM),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: "Connect",
                            icon: Icons.person_add_alt,
                            size:
                                isSmallScreen
                                    ? ButtonSize.small
                                    : ButtonSize.medium,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Connection request sent to ${peer['name']}",
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceS),
                        Expanded(
                          child: PrimaryButton(
                            text: "Message",
                            icon: Icons.chat_bubble_outline,
                            size:
                                isSmallScreen
                                    ? ButtonSize.small
                                    : ButtonSize.medium,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PeerMessagingPage(
                                        peerId: peer['id'],
                                        peerName: peer['name'],
                                        peerUniversity: peer['university'],
                                        currentUserId: currentUserId,
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
          },
        );
      },
    );
  }
}
