import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.teal,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        titleTextStyle: AppTextStyles.appBarTitle,
        iconTheme: const IconThemeData(
          color: AppColors.white,
          size: 24,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevationM,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.allM,
        ),
        color: AppColors.surface,
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingL,
            vertical: AppDimensions.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.allS,
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          textStyle: AppTextStyles.buttonPrimary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.buttonSecondary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingL,
            vertical: AppDimensions.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.allS,
            side: const BorderSide(color: AppColors.primary),
          ),
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.buttonSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: AppPadding.allM,
        border: OutlineInputBorder(
          borderRadius: AppRadius.allS,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.allS,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.allS,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.allS,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.allS,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primarySurface,
        selectedColor: AppColors.primary,
        labelStyle: AppTextStyles.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.allM,
        ),
        padding: AppPadding.hS,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        extendedTextStyle: AppTextStyles.buttonPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.allXL,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGrey,
        thickness: AppDimensions.dividerHeight,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkGrey,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.allS,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.lightGrey,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.allL,
        ),
        elevation: AppDimensions.cardElevationL,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.cyan,
        surface: AppColors.darkGrey,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.darkGrey,
        foregroundColor: AppColors.white,
        titleTextStyle: AppTextStyles.appBarTitle,
        iconTheme: const IconThemeData(
          color: AppColors.white,
          size: 24,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevationM,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.allM,
        ),
        color: AppColors.darkGrey,
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      ),
      // ... (similar styling for dark mode)
    );
  }

  // Box Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.shadowColor,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadowL => [
        BoxShadow(
          color: AppColors.shadowColorDark,
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  // Gradients
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get goldGradient => const LinearGradient(
        colors: AppColors.goldGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get darkGradient => const LinearGradient(
        colors: AppColors.darkGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get cardGradient => const LinearGradient(
        colors: AppColors.cardGradient,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  // Glassmorphism Decoration
  static BoxDecoration get glassDecoration {
    return BoxDecoration(
      color: AppColors.glassWhite,
      borderRadius: AppRadius.allL,
      border: Border.all(
        color: AppColors.white.withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: cardShadow,
    );
  }

  static BoxDecoration glassDecorationWithBlur({
    double borderRadius = AppDimensions.radiusL,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.glassWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.white.withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: cardShadow,
    );
  }
}
