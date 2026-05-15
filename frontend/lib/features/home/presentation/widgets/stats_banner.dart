import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/shared/models/home_models.dart';

class StatsBanner extends StatelessWidget {
  const StatsBanner({super.key, required this.stats});

  final List<StatItemModel> stats;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sectionGap),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: AppSpacing.xl),
      color: palette.navbarBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: AppSpacing.lg,
            spacing: AppSpacing.lg,
            children: [
              for (final item in stats) StatItem(item: item),
            ],
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
    return SizedBox(
      width: 220,
      child: Column(
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: palette.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
