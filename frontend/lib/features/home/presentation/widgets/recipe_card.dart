import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/shared/bookmarks/bookmark_button.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe, this.onTap});

  final RecipeModel recipe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bookmarks = BookmarkScope.of(context);
    final isSaved = bookmarks.isRecipeSaved(recipe);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hasFixedHeight =
                constraints.hasBoundedHeight &&
                constraints.minHeight == constraints.maxHeight;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 162,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (recipe.imageUrl == null || recipe.imageUrl!.isEmpty)
                        _RecipeImageFallback(recipe: recipe)
                      else
                        _RecipeNetworkImage(recipe: recipe),
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
                if (hasFixedHeight)
                  Expanded(
                    child: _RecipeCardBody(recipe: recipe, pinFooter: true),
                  )
                else
                  _RecipeCardBody(recipe: recipe, pinFooter: false),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecipeCardBody extends StatelessWidget {
  const _RecipeCardBody({required this.recipe, required this.pinFooter});

  final RecipeModel recipe;
  final bool pinFooter;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: pinFooter ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.categoryName,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: palette.categoryTags),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            recipe.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (recipe.tags.isNotEmpty) ...[
            _RecipeTagRow(tags: recipe.tags),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (pinFooter) const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: palette.icons),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${recipe.minutes} min',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Icon(Icons.star_rounded, size: 18, color: palette.activeElements),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                recipe.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecipeTagRow extends StatelessWidget {
  const _RecipeTagRow({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: palette.mainText,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.1,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final visibleTags = _visibleTagsForWidth(
          context,
          tags,
          constraints.maxWidth,
          textStyle,
        );

        return SizedBox(
          height: 24,
          child: Row(
            children: [
              for (var index = 0; index < visibleTags.length; index++) ...[
                if (index > 0) const SizedBox(width: AppSpacing.xxs),
                Flexible(
                  flex: 0,
                  child: _RecipeTagChip(
                    label: visibleTags[index],
                    textStyle: textStyle,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<String> _visibleTagsForWidth(
    BuildContext context,
    List<String> tags,
    double maxWidth,
    TextStyle? textStyle,
  ) {
    if (!maxWidth.isFinite || maxWidth <= 0) {
      return tags.take(2).map(_formatRecipeTag).toList(growable: false);
    }

    final visibleTags = <String>[];
    var usedWidth = 0.0;

    for (final tag in tags) {
      final label = _formatRecipeTag(tag);
      final chipWidth = _measureTagWidth(context, label, textStyle);
      final nextWidth =
          usedWidth + (visibleTags.isEmpty ? 0 : AppSpacing.xxs) + chipWidth;

      if (nextWidth > maxWidth) {
        if (visibleTags.isEmpty) {
          visibleTags.add(label);
        }
        break;
      }

      visibleTags.add(label);
      usedWidth = nextWidth;
    }

    return visibleTags;
  }

  double _measureTagWidth(
    BuildContext context,
    String label,
    TextStyle? textStyle,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: textStyle ?? DefaultTextStyle.of(context).style,
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    return textPainter.width + 20;
  }
}

class _RecipeTagChip extends StatelessWidget {
  const _RecipeTagChip({required this.label, required this.textStyle});

  final String label;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      constraints: const BoxConstraints(maxWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      ),
    );
  }
}

class _RecipeNetworkImage extends StatelessWidget {
  const _RecipeNetworkImage({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
        final cacheWidth = _cacheDimension(
          constraints.maxWidth,
          devicePixelRatio,
          max: 720,
        );
        final cacheHeight = _cacheDimension(
          constraints.maxHeight,
          devicePixelRatio,
          max: 520,
        );

        return Image.network(
          recipe.imageUrl!,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          excludeFromSemantics: true,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return _RecipeImageFallback(recipe: recipe);
          },
        );
      },
    );
  }
}

class _RecipeImageFallback extends StatelessWidget {
  const _RecipeImageFallback({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
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
  }
}

int _cacheDimension(
  double logicalPixels,
  double devicePixelRatio, {
  required int max,
}) {
  if (!logicalPixels.isFinite || logicalPixels <= 0) {
    return max;
  }

  return (logicalPixels * devicePixelRatio).round().clamp(1, max).toInt();
}

String _formatRecipeTag(String tag) {
  final words = tag
      .trim()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);

  return words
      .map((word) {
        if (word.length == 1) {
          return word.toUpperCase();
        }

        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      })
      .join(' ');
}
