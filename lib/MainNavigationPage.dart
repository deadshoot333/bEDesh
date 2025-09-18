import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/services/navigation_service.dart';
import 'features/accommodation/presentation/pages/accommodation_page.dart';
import 'features/community/presentation/pages/community_feed_page.dart';
import 'features/community/presentation/pages/peer_connect_page.dart';
import 'features/home/presentation/pages/modern_home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';

/// The main navigation page of the application.
/// This widget handles the bottom navigation bar and page switching.
class MainNavigationPage extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  // List of pages for navigation with lazy loading
  final List<Widget> _pages = const [
    ModernHomePage(),
    CommunityFeedPage(),
    AccommodationPage(),
    PeerConnectPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // Initialize navigation service
    NavigationService.init(_navigatorKey, _switchToTab);
    
    // Set initial tab index in NavigationService
    NavigationService.switchToTab(_currentIndex);
  }

  void _switchToTab(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _navigatorKey,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => NavigationService.switchToTab(index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.backgroundCard,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment_outlined),
            activeIcon: Icon(Icons.apartment),
            label: 'Housing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: 'Peer Connect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
