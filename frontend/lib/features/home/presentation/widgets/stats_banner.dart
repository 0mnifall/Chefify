import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/responsive_wrap_grid.dart';
import 'package:frontend/shared/models/home_models.dart';

class StatsBanner extends StatelessWidget {
  const StatsBanner({super.key, required this.stats});

  final List<StatItemModel> stats;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSpacing.sectionGapOf(context)),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding(context),
        vertical: AppSpacing.xl,
      ),
      color: palette.navbarBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.contentMaxWidth,
          ),
          child: ResponsiveWrapGrid<StatItemModel>(
            items: stats,
            minItemWidth: 180,
            maxColumns: 4,
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            itemBuilder: (context, item) {
              return StatItem(item: item);
            },
          ),
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  const StatItem({super.key, required this.item});

  final StatItemModel item;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.value,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: palette.mainText,
            fontSize: 38,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          item.label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: palette.secondaryText),
        ),
      ],
    );
  }
}
