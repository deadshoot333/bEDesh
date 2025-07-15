import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/profile_option_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // Modern App Bar with Profile Header
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: AppConstants.spaceXL),
                          // Profile Picture
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.textOnPrimary,
                                    width: 4,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.shadowDark,
                                      offset: Offset(0, 4),
                                      blurRadius: 16,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 50,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.textOnPrimary,
                                      width: 2,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: _showEditProfileDialog,
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: AppColors.textOnPrimary,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spaceM),
                          // Name and Email
                          Text(
                            "Arqam Bin Almas",
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceXS),
                          Text(
                            "arqam@email.com",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textOnPrimary.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceS),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spaceM,
                              vertical: AppConstants.spaceXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textOnPrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: AppColors.textOnPrimary,
                                  size: 16,
                                ),
                                const SizedBox(width: AppConstants.spaceXS),
                                Text(
                                  'Verified Student',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: _showSettings,
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceS),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Column(
                    children: [
                      // Stats Section
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spaceL),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            ProfileStatCard(label: "Posts", value: "8"),
                            ProfileStatCard(label: "Connections", value: "42"),
                            ProfileStatCard(label: "Saved", value: "12"),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceL),

                      // Quick Actions
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spaceL),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Actions',
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spaceM),
                            Row(
                              children: [
                                Expanded(
                                  child: SecondaryButton(
                                    text: 'Apply Now',
                                    icon: Icons.edit_outlined,
                                    onPressed: () => _showFeatureComingSoon('Apply Now'),
                                  ),
                                ),
                                const SizedBox(width: AppConstants.spaceM),
                                Expanded(
                                  child: SecondaryButton(
                                    text: 'View Community',
                                    icon: Icons.people_outline,
                                    onPressed: () => _showFeatureComingSoon('View Community'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceL),

                      // Menu Options
                      Container(
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
                        child: Column(
                          children: [
                            ProfileOptionCard(
                              icon: Icons.article_outlined,
                              title: "My Posts",
                              subtitle: "View and manage your community posts",
                              onTap: () => _showFeatureComingSoon('My Posts'),
                            ),
                            const Divider(color: AppColors.borderLight, height: 1),
                            ProfileOptionCard(
                              icon: Icons.people_outline,
                              title: "My Connections",
                              subtitle: "Connect with other students",
                              onTap: () => _showFeatureComingSoon('My Connections'),
                            ),
                            const Divider(color: AppColors.borderLight, height: 1),
                            ProfileOptionCard(
                              icon: Icons.bookmark_outline,
                              title: "Saved Content",
                              subtitle: "View your saved universities & posts",
                              onTap: () => _showFeatureComingSoon('Saved Content'),
                            ),
                            const Divider(color: AppColors.borderLight, height: 1),
                            ProfileOptionCard(
                              icon: Icons.notifications_outlined,
                              title: "Notifications",
                              subtitle: "Manage your preferences",
                              onTap: () => _showFeatureComingSoon('Notifications'),
                            ),
                            const Divider(color: AppColors.borderLight, height: 1),
                            ProfileOptionCard(
                              icon: Icons.support_agent_outlined,
                              title: "Help & Support",
                              subtitle: "Get help when you need it",
                              onTap: () => _showFeatureComingSoon('Help & Support'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceL),

                      // Logout Section
                      Container(
                        width: double.infinity,
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
                        child: ProfileOptionCard(
                          icon: Icons.logout_outlined,
                          title: "Logout",
                          subtitle: "Sign out of your account",
                          isDestructive: true,
                          onTap: _showLogoutDialog,
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceXL),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Profile editing feature coming soon!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    _showFeatureComingSoon('Settings');
  }

  void _showFeatureComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature feature coming soon!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.info,
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.textOnPrimary,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Logout',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          PrimaryButton(
            text: 'Logout',
            size: ButtonSize.small,
            backgroundColor: AppColors.error,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
