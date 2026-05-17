import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/home/presentation/widgets/recipe_card.dart';
import 'package:frontend/shared/models/home_models.dart';

class TrendingRecipesSection extends StatelessWidget {
  const TrendingRecipesSection({super.key, required this.recipes});

  final List<RecipeModel> recipes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, AppSpacing.sectionGap),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: 'TRENDING NOW',
                title: 'Recipes everyone is saving',
                subtitle:
                    'Hand-picked weekly from the most cooked dishes in the Chefify community.',
                action: AppButton(
                  label: 'See all',
                  variant: AppButtonVariant.ghost,
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth >= 960
                      ? (constraints.maxWidth - (AppSpacing.md * 3)) / 4
                      : constraints.maxWidth >= 640
                      ? (constraints.maxWidth - AppSpacing.md) / 2
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      for (final recipe in recipes)
                        SizedBox(
                          width: cardWidth,
                          child: RecipeCard(recipe: recipe),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
