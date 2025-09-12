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

  User? currentUser;

  // Persisted per-item states
  final Map<String, bool> _isSending = {}; // in-flight request lock
  final Map<String, String> _statusOverride =
      {}; // optimistic status: pending/accepted/rejected

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // + Requests tab [4]
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = StorageService.getUserData();
      if (user != null) {
        setState(() {
          currentUser = user;
        });
      } else {
        // ignore: avoid_print
        print("⚠️ No user data found in StorageService");
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchPeers(String filterType) async {
    if (currentUser == null) {
      // ignore: avoid_print
      print("⚠️ currentUser is null, cannot fetch peers");
      return [];
    }
    final url = Uri.parse(
      "${ApiConstants.baseUrl}/api/peer/$filterType/${currentUser!.id}",
    );
    final token = StorageService.getAccessToken();
    if (token == null) {
      throw Exception("No access token found");
    }
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    // ignore: avoid_print
    print("GET $url -> ${response.statusCode}");
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load peers: ${response.body}");
    }
  }

  Future<void> sendConnectionRequest(String receiverId) async {
    if (currentUser == null) throw Exception("Not authenticated");
    final url = Uri.parse("${ApiConstants.baseUrl}/api/peer/connect");
    final token = StorageService.getAccessToken();
    if (token == null) throw Exception("No access token found");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "requesterId": currentUser!.id,
        "receiverId": receiverId,
      }),
    );
    // ignore: avoid_print
    print("POST $url -> ${response.statusCode} ${response.body}");
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to send connection: ${response.body}");
    }
  }

  Future<List<Map<String, dynamic>>> fetchReceivedRequests() async {
    if (currentUser == null) return [];
    final url = Uri.parse(
      "${ApiConstants.baseUrl}/api/peer/requests/received/${currentUser!.id}",
    );
    final token = StorageService.getAccessToken();
    if (token == null) throw Exception("No access token found");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load received requests: ${response.body}");
    }
  }

  Future<List<Map<String, dynamic>>> fetchSentRequests() async {
    if (currentUser == null) return [];
    final url = Uri.parse(
      "${ApiConstants.baseUrl}/api/peer/requests/sent/${currentUser!.id}",
    );
    final token = StorageService.getAccessToken();
    if (token == null) throw Exception("No access token found");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load sent requests: ${response.body}");
    }
  }

  Future<void> respondToRequest({
    required String connectionId,
    required String action, // "accept" or "reject"
  }) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/api/peer/respond");
    final token = StorageService.getAccessToken();
    if (token == null) throw Exception("No access token found");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"connectionId": connectionId, "action": action}),
    );
    // ignore: avoid_print
    print("POST $url -> ${response.statusCode} ${response.body}");
    if (response.statusCode != 200) {
      throw Exception("Failed to respond: ${response.body}");
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
              tabs: const [
                Tab(text: "University"),
                Tab(text: "City"),
                Tab(text: "Requests"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceM),
            child: ModernSearchBar(
              hintText: "Search students...",
              controller: _searchController,
              onChanged: (query) {
                setState(() {}); // refresh list on search [17]
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildStudentList("university"),
                buildStudentList("city"),
                buildRequestsTab(),
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
        final query = _searchController.text.toLowerCase();
        bool matches(Map<String, dynamic> peer, String field) {
          final v = (peer[field] ?? "").toString().toLowerCase();
          return v.contains(query);
        }

        final filteredPeers =
            peers.where((peer) {
              if (query.isEmpty) return true;
              return matches(peer, 'name') ||
                  matches(peer, 'university') ||
                  matches(peer, 'city');
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

            final String peerId = peer['id'].toString();
            final bool sending = _isSending[peerId] == true;

            // Use optimistic override if present
            final String effectiveStatus =
                (_statusOverride[peerId] ?? (peer['connection_status'] ?? ''))
                    .toString();

            final bool canConnect =
                !sending &&
                (effectiveStatus.isEmpty || effectiveStatus == "rejected");

            final String connectLabel =
                sending
                    ? "Pending…"
                    : effectiveStatus == "accepted"
                    ? "Connected"
                    : effectiveStatus == "pending"
                    ? "Pending"
                    : "Connect";

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
                            (peer['name'] ?? 'U')
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),
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
                                (peer['name'] ?? '').toString(),
                                style: AppTextStyles.h5.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 16 : null,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spaceXS),
                              Text(
                                filterType == 'university'
                                    ? (peer['university'] ?? '').toString()
                                    : "Lives in ${(peer['city'] ?? '').toString()}",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: isSmallScreen ? 12 : null,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spaceS),
                              const Wrap(
                                spacing: AppConstants.spaceS,
                                runSpacing: AppConstants.spaceXS,
                                children: [
                                  // optional tags
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
                            key: ValueKey(
                              "connect-$peerId-$sending-$effectiveStatus",
                            ), // force rebuild of button when state changes [4][3]
                            text: connectLabel,
                            icon:
                                sending
                                    ? Icons.hourglass_top
                                    : effectiveStatus == "accepted"
                                    ? Icons.check_circle_outline
                                    : Icons.person_add_alt,
                            size:
                                isSmallScreen
                                    ? ButtonSize.small
                                    : ButtonSize.medium,
                            onPressed:
                                canConnect
                                    ? () async {
                                      // lock immediately and show Pending…
                                      if (mounted) {
                                        setState(() {
                                          _isSending[peerId] = true;
                                        });
                                      }
                                      try {
                                        await sendConnectionRequest(peerId);
                                        if (!mounted) return;
                                        // optimistic: show Pending status and unlock
                                        setState(() {
                                          _statusOverride[peerId] =
                                              'pending'; // guarantees label change [16]
                                          _isSending[peerId] = false;
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Connection request sent to ${peer['name']}",
                                            ),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                        // Optional: trigger a refresh to pull authoritative status
                                        // setState(() {});
                                      } catch (e) {
                                        if (!mounted) return;
                                        setState(() {
                                          _isSending[peerId] =
                                              false; // re-enable button on failure [8][14]
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text("Failed: $e"),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                    : null, // disabled while sending or if already pending/accepted [8][11]
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
                                        peerId: peerId,
                                        peerName:
                                            (peer['name'] ?? '').toString(),
                                        peerUniversity:
                                            (peer['university'] ?? '')
                                                .toString(),
                                        currentUserId: currentUser!.id,
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

  Widget buildRequestsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Received",
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppConstants.spaceS),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchReceivedRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Text("No received requests");
                  }
                  return Column(
                    children:
                        items.map((req) {
                          final isPending = (req['status'] ?? '') == 'pending';
                          return Card(
                            color: AppColors.backgroundCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusL,
                              ),
                              side: BorderSide(color: AppColors.borderLight),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  ((req['name'] ?? 'U') as String)
                                      .substring(0, 1)
                                      .toUpperCase(),
                                ),
                              ),
                              title: Text((req['name'] ?? '').toString()),
                              subtitle: Text(
                                "${req['university'] ?? ''} • ${req['city'] ?? ''} • ${(req['status'] ?? '').toString()}",
                              ),
                              trailing:
                                  isPending
                                      ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            ),
                                            onPressed: () async {
                                              try {
                                                await respondToRequest(
                                                  connectionId:
                                                      req['connection_id']
                                                          .toString(),
                                                  action: "accept",
                                                );
                                                if (!mounted) return;
                                                setState(() {});
                                              } catch (e) {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Failed: $e"),
                                                    backgroundColor:
                                                        AppColors.error,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              try {
                                                await respondToRequest(
                                                  connectionId:
                                                      req['connection_id']
                                                          .toString(),
                                                  action: "reject",
                                                );
                                                if (!mounted) return;
                                                setState(() {});
                                              } catch (e) {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Failed: $e"),
                                                    backgroundColor:
                                                        AppColors.error,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                      : const SizedBox.shrink(),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
              const SizedBox(height: AppConstants.spaceL),
              Text(
                "Sent",
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppConstants.spaceS),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchSentRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Text("No sent requests");
                  }
                  return Column(
                    children:
                        items.map((req) {
                          return Card(
                            color: AppColors.backgroundCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusL,
                              ),
                              side: BorderSide(color: AppColors.borderLight),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  ((req['name'] ?? 'U') as String)
                                      .substring(0, 1)
                                      .toUpperCase(),
                                ),
                              ),
                              title: Text((req['name'] ?? '').toString()),
                              subtitle: Text(
                                "${req['university'] ?? ''} • ${req['city'] ?? ''} • ${(req['status'] ?? '').toString()}",
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
