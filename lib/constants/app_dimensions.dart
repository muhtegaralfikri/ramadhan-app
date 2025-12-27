import 'package:flutter/material.dart';

class AppDimensions {
  // Spacing System (8pt grid)
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  static const double spacingXXXL = 64.0;

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 28.0;
  static const double radiusXXXL = 32.0;

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 48.0;
  static const double iconXXXL = 64.0;

  // Avatar Sizes
  static const double avatarXS = 24.0;
  static const double avatarS = 32.0;
  static const double avatarM = 40.0;
  static const double avatarL = 48.0;
  static const double avatarXL = 56.0;

  // Button Heights
  static const double buttonS = 36.0;
  static const double buttonM = 44.0;
  static const double buttonL = 52.0;

  // Card Elevations
  static const double cardElevationS = 2.0;
  static const double cardElevationM = 4.0;
  static const double cardElevationL = 8.0;
  static const double cardElevationXL = 12.0;

  // Screen Padding
  static const double screenPadding = AppDimensions.spacingM;
  static const double screenPaddingL = AppDimensions.spacingL;

  // Bottom Nav Height
  static const double bottomNavHeight = 65.0;

  // AppBar Height
  static const double appBarHeight = 56.0;

  // Minimum Tap Target
  static const double minTapTarget = 44.0;

  // Chart Dimensions
  static const double chartHeight = 200.0;
  static const double chartHeightL = 250.0;

  // Progress Bar Height
  static const double progressBarHeight = 8.0;
  static const double progressBarHeightL = 12.0;

  // Divider Height
  static const double dividerHeight = 1.0;

  // Image Heights
  static const double imageCardHeight = 150.0;
  static const double imageBannerHeight = 200.0;
  static const double imageHeroHeight = 250.0;

  // Shimmer Dimensions
  static const double shimmerBaseWidth = 100.0;
  static const double shimmerBaseHeight = 16.0;

  // Glass Blur
  static const double glassBlur = 10.0;
  static const double glassBlurL = 20.0;

  // Animation Durations
  static const int animationFast = 150;
  static const int animationMedium = 300;
  static const int animationSlow = 500;
  static const int animationExtraSlow = 800;
}

// Edge Insets shortcuts
class AppPadding {
  static const EdgeInsets allXS = EdgeInsets.all(AppDimensions.spacingXS);
  static const EdgeInsets allS = EdgeInsets.all(AppDimensions.spacingS);
  static const EdgeInsets allM = EdgeInsets.all(AppDimensions.spacingM);
  static const EdgeInsets allL = EdgeInsets.all(AppDimensions.spacingL);
  static const EdgeInsets allXL = EdgeInsets.all(AppDimensions.spacingXL);

  static const EdgeInsets hXS = EdgeInsets.symmetric(horizontal: AppDimensions.spacingXS);
  static const EdgeInsets hS = EdgeInsets.symmetric(horizontal: AppDimensions.spacingS);
  static const EdgeInsets hM = EdgeInsets.symmetric(horizontal: AppDimensions.spacingM);
  static const EdgeInsets hL = EdgeInsets.symmetric(horizontal: AppDimensions.spacingL);
  static const EdgeInsets hXL = EdgeInsets.symmetric(horizontal: AppDimensions.spacingXL);

  static const EdgeInsets vXS = EdgeInsets.symmetric(vertical: AppDimensions.spacingXS);
  static const EdgeInsets vS = EdgeInsets.symmetric(vertical: AppDimensions.spacingS);
  static const EdgeInsets vM = EdgeInsets.symmetric(vertical: AppDimensions.spacingM);
  static const EdgeInsets vL = EdgeInsets.symmetric(vertical: AppDimensions.spacingL);
  static const EdgeInsets vXL = EdgeInsets.symmetric(vertical: AppDimensions.spacingXL);

  static const EdgeInsets onlyLeftS = EdgeInsets.only(left: AppDimensions.spacingS);
  static const EdgeInsets onlyLeftM = EdgeInsets.only(left: AppDimensions.spacingM);
  static const EdgeInsets onlyRightS = EdgeInsets.only(right: AppDimensions.spacingS);
  static const EdgeInsets onlyRightM = EdgeInsets.only(right: AppDimensions.spacingM);
  static const EdgeInsets onlyTopS = EdgeInsets.only(top: AppDimensions.spacingS);
  static const EdgeInsets onlyTopM = EdgeInsets.only(top: AppDimensions.spacingM);
  static const EdgeInsets onlyBottomS = EdgeInsets.only(bottom: AppDimensions.spacingS);
  static const EdgeInsets onlyBottomM = EdgeInsets.only(bottom: AppDimensions.spacingM);
}

// BorderRadius shortcuts
class AppRadius {
  static const BorderRadius allXS = BorderRadius.all(Radius.circular(AppDimensions.radiusXS));
  static const BorderRadius allS = BorderRadius.all(Radius.circular(AppDimensions.radiusS));
  static const BorderRadius allM = BorderRadius.all(Radius.circular(AppDimensions.radiusM));
  static const BorderRadius allL = BorderRadius.all(Radius.circular(AppDimensions.radiusL));
  static const BorderRadius allXL = BorderRadius.all(Radius.circular(AppDimensions.radiusXL));
  static const BorderRadius allXXL = BorderRadius.all(Radius.circular(AppDimensions.radiusXXL));
  static const BorderRadius allXXXL = BorderRadius.all(Radius.circular(AppDimensions.radiusXXXL));

  static const BorderRadius topM = BorderRadius.only(
    topLeft: Radius.circular(AppDimensions.radiusM),
    topRight: Radius.circular(AppDimensions.radiusM),
  );
  static const BorderRadius bottomM = BorderRadius.only(
    bottomLeft: Radius.circular(AppDimensions.radiusM),
    bottomRight: Radius.circular(AppDimensions.radiusM),
  );
}
