import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../../../../shared/widgets/inputs/modern_search_bar.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class PeerConnectPage extends StatefulWidget {
  const PeerConnectPage({super.key});

  @override
  State<PeerConnectPage> createState() => _PeerConnectPageState();
}

class _PeerConnectPageState extends State<PeerConnectPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Column(
        children: [
          // Modern Header (like home page)
          _buildModernHeader(),
          
          // Tab Bar
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
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceM),
            child: ModernSearchBar(
              hintText: "Search students...",
              controller: _searchController,
              onChanged: (query) {
                setState(() {}); // For live filtering
              },
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildStudentList(context, "university"),
                buildStudentList(context, "city"),
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
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              // Peer Connect title
              Expanded(
                child: Text(
                  'Peer Connect',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              // Profile button
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

  Widget buildStudentList(BuildContext context, String filterType) {
    // Dummy data
    final List<Map<String, String>> peers = [
      {
        'name': 'Ayaan Khan',
        'university': 'University of Glasgow',
        'city': 'Glasgow',
        'course': 'Computer Science',
        'year': '2nd Year',
      },
      {
        'name': 'Zara Rahman',
        'university': 'University of Toronto',
        'city': 'Toronto',
        'course': 'Business Administration',
        'year': '3rd Year',
      },
      {
        'name': 'Tanisha Chowdhury',
        'university': 'University of Sydney',
        'city': 'Sydney',
        'course': 'Medicine',
        'year': '1st Year',
      },
      {
        'name': 'Rafi Ahmed',
        'university': 'University of Edinburgh',
        'city': 'Edinburgh',
        'course': 'Engineering',
        'year': '4th Year',
      },
      {
        'name': 'Samira Hassan',
        'university': 'University of Manchester',
        'city': 'Manchester',
        'course': 'Psychology',
        'year': '2nd Year',
      },
    ];

    final query = _searchController.text.toLowerCase();

    final filteredPeers = peers.where((peer) {
      final target = filterType == 'university'
          ? peer['university']!
          : peer['city']!;
      return peer['name']!.toLowerCase().contains(query) ||
          target.toLowerCase().contains(query) ||
          peer['course']!.toLowerCase().contains(query);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      itemCount: filteredPeers.length,
      itemBuilder: (context, index) {
        final peer = filteredPeers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spaceM),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppConstants.spaceM),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 25,
              child: Text(
                peer['name']!.substring(0, 1).toUpperCase(),
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            title: Text(
              peer['name']!,
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.spaceXS),
                Text(
                  filterType == 'university'
                      ? peer['university']!
                      : "Lives in ${peer['city']!}",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXS),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceS,
                        vertical: AppConstants.spaceXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Text(
                        peer['course']!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceS,
                        vertical: AppConstants.spaceXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Text(
                        peer['year']!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  text: "Connect",
                  icon: Icons.person_add_alt,
                  size: ButtonSize.small,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Connection request sent to ${peer['name']}"),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                PrimaryButton(
                  text: "Message",
                  icon: Icons.chat_bubble_outline,
                  size: ButtonSize.small,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Messaging ${peer['name']}"),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
