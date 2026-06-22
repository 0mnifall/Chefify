import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/shared/bookmarks/bookmark_button.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bookmarks = BookmarkScope.of(context);
    final isSaved = bookmarks.isRecipeSaved(recipe);

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 162,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (recipe.imageUrl == null || recipe.imageUrl!.isEmpty)
                    DecoratedBox(
                      decoration: BoxDecoration(
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
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
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
                            child: Icon(
                              Icons.restaurant_menu_rounded,
                              size: 52,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: BookmarkButton(
                      isSaved: isSaved,
                      onPressed: () {
                        bookmarks.toggleRecipe(recipe);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.tag,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: palette.categoryTags,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: palette.icons,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${recipe.minutes} min',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: palette.activeElements,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        recipe.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
