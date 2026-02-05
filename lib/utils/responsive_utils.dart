import 'package:flutter/material.dart';

class ResponsiveUtils {
  // ---------------------------------------------------------------------------
  // Breakpoints
  // ---------------------------------------------------------------------------

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1440;

  static bool isSmallMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 400;

  // ---------------------------------------------------------------------------
  // Scaled dimensions
  // ---------------------------------------------------------------------------

  static double width(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isMobile(context)) {
      return size * (screenWidth / 375);
    }
    if (isTablet(context)) {
      return size * (screenWidth / 768);
    }

    return size * (screenWidth / 1440);
  }

  static double height(BuildContext context, double size) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (isMobile(context)) {
      return size * (screenHeight / 812);
    }
    if (isTablet(context)) {
      return size * (screenHeight / 1024);
    }

    return size * (screenHeight / 900);
  }

  static double fontSize(BuildContext context, double size) {
    if (isMobile(context)) return size * 0.9;
    if (isTablet(context)) return size * 1.0;
    return size * 1.1;
  }

  static double radius(BuildContext context, double size) {
    return width(context, size);
  }

  // ---------------------------------------------------------------------------
  // Padding & margin helpers
  // ---------------------------------------------------------------------------

  static EdgeInsets paddingAll(BuildContext context, double value) =>
      EdgeInsets.all(width(context, value));

  static EdgeInsets paddingSymmetric(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) =>
      EdgeInsets.symmetric(
        horizontal: width(context, horizontal),
        vertical: height(context, vertical),
      );

  static EdgeInsets paddingOnly(
    BuildContext context, {
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(
        left: width(context, left),
        top: height(context, top),
        right: width(context, right),
        bottom: height(context, bottom),
      );

  // ---------------------------------------------------------------------------
  // Spacing widgets
  // ---------------------------------------------------------------------------

  static SizedBox verticalSpace(BuildContext context, double height) =>
      SizedBox(height: ResponsiveUtils.height(context, height));

  static SizedBox horizontalSpace(BuildContext context, double width) =>
      SizedBox(width: ResponsiveUtils.width(context, width));

  // ---------------------------------------------------------------------------
  // Text styles
  // ---------------------------------------------------------------------------

  static TextStyle headingLarge(BuildContext context) => TextStyle(
        fontSize: fontSize(
          context,
          isMobile(context)
              ? 24
              : isTablet(context)
                  ? 28
                  : 36,
        ),
        fontWeight: FontWeight.bold,
        height: 1.2,
      );

  static TextStyle headingMedium(BuildContext context) => TextStyle(
        fontSize: fontSize(
          context,
          isMobile(context)
              ? 20
              : isTablet(context)
                  ? 22
                  : 24,
        ),
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle headingSmall(BuildContext context) => TextStyle(
        fontSize: fontSize(
          context,
          isMobile(context)
              ? 16
              : isTablet(context)
                  ? 18
                  : 20,
        ),
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontSize: fontSize(
          context,
          isMobile(context)
              ? 16
              : isTablet(context)
                  ? 17
                  : 18,
        ),
        height: 1.6,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontSize: fontSize(
          context,
          isMobile(context)
              ? 14
              : isTablet(context)
                  ? 15
                  : 16,
        ),
        height: 1.5,
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontSize: fontSize(
          context,
          isMobile(context)
              ? 12
              : isTablet(context)
                  ? 13
                  : 14,
        ),
        height: 1.4,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: fontSize(
          context,
          isMobile(context)
              ? 10
              : isTablet(context)
                  ? 11
                  : 12,
        ),
        height: 1.3,
      );

  // ---------------------------------------------------------------------------
  // Layout helpers
  // ---------------------------------------------------------------------------

  static int gridColumns(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static double aspectRatio(
    BuildContext context, {
    double mobile = 1.0,
    double tablet = 1.2,
    double desktop = 1.5,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static EdgeInsets layoutPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 20);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 40);
    }
    return const EdgeInsets.symmetric(horizontal: 80, vertical: 60);
  }

  static EdgeInsets sectionPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 40);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 80);
    }
    return const EdgeInsets.symmetric(horizontal: 80, vertical: 100);
  }
}
