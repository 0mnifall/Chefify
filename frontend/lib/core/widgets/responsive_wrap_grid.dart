import 'package:flutter/widgets.dart';
import 'package:frontend/core/constants/app_spacing.dart';

class ResponsiveWrapGrid<T> extends StatelessWidget {
  const ResponsiveWrapGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.minItemWidth,
    required this.maxColumns,
    this.spacing = AppSpacing.md,
    this.runSpacing = AppSpacing.md,
    this.itemHeightBuilder,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;
  final double runSpacing;
  final double Function(double itemWidth, int columns)? itemHeightBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = AppSpacing.gridColumns(
          width: constraints.maxWidth,
          minItemWidth: minItemWidth,
          maxColumns: maxColumns,
          spacing: spacing,
        );
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        final itemHeight = itemHeightBuilder?.call(itemWidth, columns);

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: itemBuilder(context, item),
              ),
          ],
        );
      },
    );
  }
}
