import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Premium Green
  static const Color primary = Color(0xFF0D5C38);
  static const Color primaryDark = Color(0xFF073B22);
  static const Color primaryLight = Color(0xFF1E8A54);
  static const Color primarySurface = Color(0xFFE8F5EC);

  // Accent Colors - Gold for premium feel
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldDark = Color(0xFFB8962F);
  static const Color goldLight = Color(0xFFE8C860);

  // Secondary Colors
  static const Color secondary = Color(0xFF2E7D32);
  static const Color teal = Color(0xFF009688);
  static const Color cyan = Color(0xFF00BCD4);
  static const Color indigo = Color(0xFF3F51B5);

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF1F2937);
  static const Color grey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFFD1D5DB);
  static const Color veryLightGrey = Color(0xFFF3F4F6);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF0D5C38),
    Color(0xFF2E7D32),
  ];
  static const List<Color> goldGradient = [
    Color(0xFFD4AF37),
    Color(0xFFF4CF57),
  ];
  static const List<Color> darkGradient = [
    Color(0xFF1F2937),
    Color(0xFF111827),
  ];
  static const List<Color> cardGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF9FAFB),
  ];

  // Glassmorphism Colors
  static Color glassWhite = Colors.white.withValues(alpha: 0.8);
  static Color glassBlack = Colors.black.withValues(alpha: 0.3);
  static Color glassGrey = Colors.grey.withValues(alpha: 0.1);

  // Shadow Colors
  static Color shadowColor = Colors.black.withValues(alpha: 0.1);
  static Color shadowColorDark = Colors.black.withValues(alpha: 0.2);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
}
