import 'package:flutter/material.dart';

/// App Color Palette
/// Based on educational, trustworthy, and modern design principles
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF1A3D7C); // Earthy Deep Blue - trust, intelligence
  static const Color primaryLight = Color(0xFF2E5AA0); // Lighter shade for hover states
  static const Color primaryDark = Color(0xFF0F2A5A); // Darker shade for pressed states

  // Secondary Colors
  static const Color secondary = Color(0xFF6DA34D); // Muted Green - hope, growth, balance
  static const Color secondaryLight = Color(0xFF8BC34A); // Success states
  static const Color secondaryDark = Color(0xFF558B3A); // Dark green accents

  // Accent Colors
  static const Color accent = Color(0xFFF4EBD0); // Warm Beige - simplicity, neutrality
  static const Color accentLight = Color(0xFFF9F4E6); // Very light beige
  static const Color accentDark = Color(0xFFE8D5B7); // Darker beige

  // Call-to-Action
  static const Color cta = Color(0xFFF76C5E); // Coral - action-oriented, youthful
  static const Color ctaLight = Color(0xFFFF8A7A); // Light coral for hover
  static const Color ctaDark = Color(0xFFE55A4C); // Dark coral for pressed

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFAFAFA); // Soft White
  static const Color backgroundSecondary = Color(0xFFF2F2F2); // Light Gray
  static const Color backgroundTertiary = Color(0xFFFFFFFF); // Pure White
  static const Color backgroundCard = Color(0xFFFFFFFF); // Card backgrounds

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Dark gray for primary text
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray for secondary text
  static const Color textTertiary = Color(0xFF9CA3AF); // Light gray for hints/disabled
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White text on primary background
  static const Color textOnDark = Color(0xFFFFFFFF); // White text on dark backgrounds

  // Status Colors
  static const Color success = Color(0xFF10B981); // Success green
  static const Color warning = Color(0xFFF59E0B); // Warning amber
  static const Color error = Color(0xFFEF4444); // Error red
  static const Color info = Color(0xFF3B82F6); // Info blue

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB); // Light border
  static const Color borderMedium = Color(0xFFD1D5DB); // Medium border
  static const Color borderDark = Color(0xFF9CA3AF); // Dark border

  // Shadow Colors
  static const Color shadowLight = Color(0x0D000000); // Light shadow (5% opacity)
  static const Color shadowMedium = Color(0x1A000000); // Medium shadow (10% opacity)
  static const Color shadowDark = Color(0x33000000); // Dark shadow (20% opacity)

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF1A3D7C),
    Color(0xFF2E5AA0),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF6DA34D),
    Color(0xFF8BC34A),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFF4EBD0),
    Color(0xFFF9F4E6),
  ];

  // Material Colors for Flutter Theme
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF1A3D7C,
    <int, Color>{
      50: Color(0xFFE3EAF5),
      100: Color(0xFFBACAE5),
      200: Color(0xFF8DA7D4),
      300: Color(0xFF6084C3),
      400: Color(0xFF3F69B6),
      500: Color(0xFF1A3D7C), // Primary color
      600: Color(0xFF17377A),
      700: Color(0xFF132F75),
      800: Color(0xFF0F2771),
      900: Color(0xFF081969),
    },
  );
}
