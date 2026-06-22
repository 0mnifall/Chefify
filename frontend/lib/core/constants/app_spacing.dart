import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double sectionGap = 88;
  static const double contentMaxWidth = 1160;
  static const double desktopNavigationContentWidth = 1040;
  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 26;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 36,
  );

  static double horizontalPaddingForWidth(double width) {
    if (width < 360) {
      return sm;
    }
    if (width < 600) {
      return md;
    }
    return 20;
  }

  static double horizontalPadding(BuildContext context) {
    return horizontalPaddingForWidth(MediaQuery.sizeOf(context).width);
  }

  static double sectionGapForWidth(double width) {
    if (width < 600) {
      return 56;
    }
    if (width < 920) {
      return 72;
    }
    return sectionGap;
  }

  static double sectionGapOf(BuildContext context) {
    return sectionGapForWidth(MediaQuery.sizeOf(context).width);
  }

  static EdgeInsets sectionInsets(
    BuildContext context, {
    double top = 0,
    double? bottom,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = horizontalPaddingForWidth(width);
    return EdgeInsets.fromLTRB(
      horizontal,
      top,
      horizontal,
      bottom ?? sectionGapForWidth(width),
    );
  }

  static double panelPaddingForWidth(double width) {
    if (width < 360) {
      return md;
    }
    if (width < 600) {
      return 20;
    }
    return lg;
  }

  static bool useDesktopNavigationForContent(double width) {
    return width >= desktopNavigationContentWidth;
  }

  static double headerHeightForViewport(double width) {
    final contentWidth = width - (horizontalPaddingForWidth(width) * 2);
    return useDesktopNavigationForContent(contentWidth) ? 98 : 92;
  }

  static int gridColumns({
    required double width,
    required double minItemWidth,
    required int maxColumns,
    double spacing = md,
  }) {
    for (var columns = maxColumns; columns > 1; columns--) {
      final availableWidth = width - (spacing * (columns - 1));
      if (availableWidth / columns >= minItemWidth) {
        return columns;
      }
    }
    return 1;
  }

  static double gridItemWidth({
    required double width,
    required double minItemWidth,
    required int maxColumns,
    double spacing = md,
  }) {
    final columns = gridColumns(
      width: width,
      minItemWidth: minItemWidth,
      maxColumns: maxColumns,
      spacing: spacing,
    );
    return (width - (spacing * (columns - 1))) / columns;
  }
}
