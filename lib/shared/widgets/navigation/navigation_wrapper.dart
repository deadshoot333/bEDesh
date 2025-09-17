import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../MainNavigationPage.dart';

/// A wrapper widget that provides consistent bottom navigation across all pages.
/// This ensures the navbar is visible on secondary pages like country details,
/// university pages, and profile sub-pages.
class NavigationWrapper extends StatelessWidget {
  final Widget child;
  final int? selectedIndex;
  final Function(int)? onTap;

  const NavigationWrapper({
    super.key,
    required this.child,
    this.selectedIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: selectedIndex != null 
        ? BottomNavigationBar(
            currentIndex: selectedIndex!,
            onTap: onTap ?? (index) => _handleNavigation(context, index),
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
          )
        : null,
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    // Navigate to MainNavigationPage with specific tab, replacing current route stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MainNavigationPage(initialIndex: index),
      ),
      (route) => false, // Remove all previous routes
    );
  }
}