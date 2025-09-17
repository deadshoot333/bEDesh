import 'package:flutter/material.dart';

/// Navigation service to help switch between main navigation tabs
/// This allows child pages to switch to specific tabs in MainNavigationPage
class NavigationService {
  static GlobalKey<NavigatorState>? _navigatorKey;
  static Function(int)? _switchToTab;

  /// Set the navigator key and tab switching function
  static void init(GlobalKey<NavigatorState> navigatorKey, Function(int) switchToTab) {
    _navigatorKey = navigatorKey;
    _switchToTab = switchToTab;
  }

  /// Switch to a specific tab in MainNavigationPage
  static void switchToTab(int index) {
    if (_switchToTab != null) {
      _switchToTab!(index);
    }
  }

  /// Navigate to profile tab (index 4)
  static void navigateToProfile() {
    switchToTab(4);
  }

  /// Navigate to home tab (index 0)
  static void navigateToHome() {
    switchToTab(0);
  }

  /// Navigate to community tab (index 1)
  static void navigateToCommunity() {
    switchToTab(1);
  }

  /// Navigate to housing tab (index 2)
  static void navigateToHousing() {
    switchToTab(2);
  }

  /// Navigate to peer connect tab (index 3)
  static void navigateToPeerConnect() {
    switchToTab(3);
  }

  /// Navigate back to main navigation (pop all routes and go to specific tab)
  static void navigateBackToMainNavigation(int tabIndex) {
    if (_navigatorKey?.currentContext != null) {
      // Pop all routes until we reach the main navigation
      Navigator.of(_navigatorKey!.currentContext!).popUntil((route) => route.isFirst);
      
      // Then switch to the desired tab
      switchToTab(tabIndex);
    }
  }
}