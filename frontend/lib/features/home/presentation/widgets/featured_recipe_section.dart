import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/shared/models/home_models.dart';

class FeaturedRecipeSection extends StatelessWidget {
  const FeaturedRecipeSection({super.key, required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: AppSpacing.sectionInsets(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.contentMaxWidth,
          ),
          child: AppCard(
            backgroundColor: palette.navbarBackground,
            radius: AppSpacing.radiusLg,
            padding: EdgeInsets.all(
              AppSpacing.panelPaddingForWidth(viewportWidth),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 900;

                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RecipeVideoPreview(accentColor: recipe.accentColor),
                      const SizedBox(height: AppSpacing.xl),
                      FeaturedRecipeInfo(recipe: recipe),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: RecipeVideoPreview(
                        accentColor: recipe.accentColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      flex: 6,
                      child: FeaturedRecipeInfo(recipe: recipe),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class RecipeVideoPreview extends StatelessWidget {
  const RecipeVideoPreview({super.key, required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxWidth < 360 ? 240.0 : 310.0;

        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            gradient: LinearGradient(
              colors: [
                accentColor.withValues(alpha: 0.95),
                accentColor.withValues(alpha: 0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.ramen_dining_rounded,
                  size: 130,
                  color: Color(0x28FFFFFF),
                ),
              ),
              Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FeaturedRecipeInfo extends StatelessWidget {
  const FeaturedRecipeInfo({super.key, required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FEATURED RECIPE',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: palette.categoryTags,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          recipe.title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: palette.mainText),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'A bright and savory dinner packed with herbs, citrus, and texture. Perfect for guests or a premium weeknight meal.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: [
            _MetaChip(
              icon: Icons.schedule_rounded,
              text: '${recipe.minutes} min',
            ),
            _MetaChip(
              icon: Icons.star_rounded,
              text: recipe.rating.toStringAsFixed(1),
            ),
            _MetaChip(icon: Icons.person_rounded, text: recipe.author),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Open full recipe',
          icon: Icons.arrow_forward_rounded,
          onPressed: () {
            Navigator.of(context).pushNamed(
              AppRouter.recipeDetailsPath(recipe.id),
              arguments: recipe,
            );
          },
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.searchBarBackground,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: palette.borders),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: palette.icons),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.mainText),
          ),
        ],
      ),
    );
  }
}
