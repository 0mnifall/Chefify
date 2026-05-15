import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/shared/models/home_models.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.featuredRecipe,
  });

  final String title;
  final String subtitle;
  final RecipeModel featuredRecipe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, AppSpacing.sectionGap),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 960;

              return Flex(
                direction: stacked ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: stacked ? 0 : 7,
                    child: HeroTextBlock(
                      title: title,
                      subtitle: subtitle,
                    ),
                  ),
                  SizedBox(
                    width: stacked ? 0 : AppSpacing.xl,
                    height: stacked ? AppSpacing.xl : 0,
                  ),
                  SizedBox(
                    width: stacked ? double.infinity : 360,
                    child: FeaturedHeroCard(recipe: featuredRecipe),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class HeroTextBlock extends StatelessWidget {
  const HeroTextBlock({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: palette.searchBarBackground,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            'Trusted by 120K+ home cooks',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: palette.categoryTags,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const HeroActions(),
      ],
    );
  }
}

class HeroActions extends StatelessWidget {
  const HeroActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        AppButton(
          label: 'Start free trial',
          icon: Icons.play_arrow_rounded,
          onPressed: () {},
        ),
        AppButton(
          label: 'Browse recipes',
          variant: AppButtonVariant.outlined,
          onPressed: () {},
        ),
      ],
    );
  }
}

class FeaturedHeroCard extends StatelessWidget {
  const FeaturedHeroCard({
    super.key,
    required this.recipe,
  });

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: palette.recipeCardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: recipe.accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.local_fire_department, color: recipe.accentColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Recipe of the day',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              gradient: LinearGradient(
                colors: [
                  recipe.accentColor.withValues(alpha: 0.95),
                  recipe.accentColor.withValues(alpha: 0.55),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.play_circle_fill_rounded, size: 70, color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(recipe.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${recipe.minutes} min - ${recipe.author}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

