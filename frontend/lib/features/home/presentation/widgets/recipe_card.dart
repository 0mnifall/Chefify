import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/shared/models/home_models.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              gradient: LinearGradient(
                colors: [
                  recipe.accentColor.withValues(alpha: 0.9),
                  recipe.accentColor.withValues(alpha: 0.55),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.restaurant_menu_rounded, size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            recipe.tag,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: palette.categoryTags,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(recipe.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: palette.icons),
              const SizedBox(width: AppSpacing.xs),
              Text('${recipe.minutes} min', style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              Icon(Icons.star_rounded, size: 18, color: palette.activeElements),
              const SizedBox(width: AppSpacing.xxs),
              Text(recipe.rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
