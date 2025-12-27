import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Base Text Style
  static TextStyle _baseStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Display Styles - Large, impactful text
  static TextStyle get displayLarge => _baseStyle(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.25,
      );

  static TextStyle get displayMedium => _baseStyle(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: 0,
      );

  static TextStyle get displaySmall => _baseStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0,
      );

  // Headline Styles - For page titles and headers
  static TextStyle get headlineLarge => _baseStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  static TextStyle get headlineMedium => _baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headlineSmall => _baseStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  // Title Styles - For cards, sections
  static TextStyle get titleLarge => _baseStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleMedium => _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.45,
      );

  static TextStyle get titleSmall => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  // Body Styles - For regular text
  static TextStyle get bodyLarge => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.55,
      );

  // Label Styles - For buttons, tags, labels
  static TextStyle get labelLarge => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get labelMedium => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.45,
      );

  static TextStyle get labelSmall => _baseStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  // Custom Styles with Colors
  static TextStyle get greeting => _baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get userName => _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        height: 1.3,
      );

  static TextStyle get cardTitle => _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get cardSubtitle => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get buttonPrimary => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        height: 1.2,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonSecondary => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        height: 1.2,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonText => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        height: 1.3,
      );

  static TextStyle get currency => _baseStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1.2,
      );

  static TextStyle get currencySmall => _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        height: 1.2,
      );

  static TextStyle get counterValue => _baseStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1.1,
      );

  static TextStyle get counterLabel => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.3,
      );

  static TextStyle get appBarTitle => _baseStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        height: 1.2,
      );

  static TextStyle get overline => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textHint,
        height: 1.5,
        letterSpacing: 1.0,
      );

  // Colored Text Styles
  static TextStyle get success => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.success,
      );

  static TextStyle get error => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.error,
      );

  static TextStyle get warning => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.warning,
      );

  static TextStyle get gold => _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.gold,
      );
}
