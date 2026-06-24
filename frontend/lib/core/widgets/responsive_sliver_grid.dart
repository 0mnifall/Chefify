import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:frontend/core/constants/app_spacing.dart';

class ResponsiveSliverGrid<T> extends StatelessWidget {
  const ResponsiveSliverGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.minItemWidth,
    required this.maxColumns,
    required this.itemHeightBuilder,
    this.spacing = AppSpacing.md,
    this.runSpacing = AppSpacing.md,
    this.maxWidth = AppSpacing.contentMaxWidth,
    this.padding = EdgeInsets.zero,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;
  final double runSpacing;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final double Function(double itemWidth, int columns) itemHeightBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.crossAxisExtent;
        final basePadding = AppSpacing.horizontalPaddingForWidth(viewportWidth);
        final availableWidth = math.max(0.0, viewportWidth - basePadding * 2);
        final contentWidth = math.min(maxWidth, availableWidth);
        final sidePadding = basePadding + ((availableWidth - contentWidth) / 2);
        final columns = AppSpacing.gridColumns(
          width: contentWidth,
          minItemWidth: minItemWidth,
          maxColumns: maxColumns,
          spacing: spacing,
        );
        final itemWidth = (contentWidth - (spacing * (columns - 1))) / columns;
        final itemHeight = itemHeightBuilder(itemWidth, columns);

        return SliverPadding(
          padding: padding.add(EdgeInsets.symmetric(horizontal: sidePadding)),
          sliver: SliverGrid.builder(
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: runSpacing,
              mainAxisExtent: itemHeight,
            ),
            itemBuilder: (context, index) {
              return itemBuilder(context, items[index]);
            },
            addAutomaticKeepAlives: false,
          ),
        );
      },
    );
  }
}
