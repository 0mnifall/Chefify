import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/responsive_wrap_grid.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/home/presentation/widgets/recipe_card.dart';
import 'package:frontend/shared/models/home_models.dart';

class TrendingRecipesSection extends StatelessWidget {
  const TrendingRecipesSection({
    super.key,
    required this.recipes,
    this.isLoading = false,
  });

  final List<RecipeModel> recipes;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.sectionInsets(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.contentMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: 'TRENDING NOW',
                title: 'Recipes everyone is saving',
                subtitle:
                    'Hand-picked weekly from the most cooked dishes in the Chefify community.',
                action: AppButton(
                  key: const ValueKey('trending-see-all-button'),
                  label: 'See all',
                  variant: AppButtonVariant.ghost,
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.recipes,
                      (route) => false,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (isLoading)
                const _TrendingRecipesLoading()
              else
                ResponsiveWrapGrid<RecipeModel>(
                  items: recipes,
                  minItemWidth: 250,
                  maxColumns: 4,
                  itemHeightBuilder: _recipeCardHeight,
                  itemBuilder: (context, recipe) {
                    return RecipeCard(recipe: recipe);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

double _recipeCardHeight(double width, int columns) {
  if (columns == 1 || width < 280) {
    return 334;
  }

  return 348;
}

class _TrendingRecipesLoading extends StatelessWidget {
  const _TrendingRecipesLoading();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      height: 348,
      child: Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: palette.activeElements,
          ),
        ),
      ),
    );
  }
}
