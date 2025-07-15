import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Main theme configuration for the application
/// Provides consistent styling throughout the app
class AppTheme {
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnPrimary,
        tertiary: AppColors.cta,
        onTertiary: AppColors.textOnPrimary,
        surface: AppColors.backgroundCard,
        onSurface: AppColors.textPrimary,
        background: AppColors.backgroundPrimary,
        onBackground: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        shadowColor: AppColors.shadowMedium,
        scrolledUnderElevation: 4,
        titleTextStyle: AppTextStyles.h5.copyWith(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textOnPrimary,
          size: 24,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundCard,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.backgroundCard,
        shadowColor: AppColors.shadowLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.textTertiary,
          disabledForegroundColor: AppColors.textSecondary,
          elevation: 2,
          shadowColor: AppColors.shadowMedium,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textTertiary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.accent,
        disabledColor: AppColors.backgroundSecondary,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textOnPrimary,
        ),
        brightness: Brightness.light,
        elevation: 1,
        pressElevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(color: AppColors.borderLight),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),
      primaryIconTheme: const IconThemeData(
        color: AppColors.textOnPrimary,
        size: 24,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
        displayMedium: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        displaySmall: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        headlineLarge: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
        headlineMedium: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
        headlineSmall: AppTextStyles.h6.copyWith(color: AppColors.textPrimary),
        titleLarge: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
        titleMedium: AppTextStyles.h6.copyWith(color: AppColors.textPrimary),
        titleSmall: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.backgroundPrimary,

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.backgroundSecondary,
        circularTrackColor: AppColors.backgroundSecondary,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.cta,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        highlightElevation: 8,
        shape: CircleBorder(),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelLarge,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textOnPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
    );
  }

  /// Custom gradient decorations
  static const BoxDecoration primaryGradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: AppColors.primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const BoxDecoration secondaryGradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: AppColors.secondaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  /// Common border radius values
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXLarge = BorderRadius.all(Radius.circular(24));

  /// Common shadows
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: AppColors.shadowMedium,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: AppColors.shadowDark,
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
}
