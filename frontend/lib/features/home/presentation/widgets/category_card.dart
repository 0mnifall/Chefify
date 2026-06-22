import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/shared/bookmarks/bookmark_button.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, this.onTap});

  final CategoryModel category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bookmarks = BookmarkScope.of(context);
    final isSaved = bookmarks.isCategorySaved(category);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _CategoryBackground(imageUrl: category.imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x521A1714),
                    Color(0x7F1A1714),
                    Color(0xB21A1714),
                    Color(0xD91A1714),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: Colors.white.withValues(alpha: 0.75),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.66),
                          ),
                        ),
                        child: Icon(
                          category.icon,
                          color: const Color(0xFF7B4D32),
                        ),
                      ),
                      const Spacer(),
                      BookmarkButton(
                        isSaved: isSaved,
                        onPressed: () {
                          bookmarks.toggleCategory(category);
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    category.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    category.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${category.recipesCount} recipes',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
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

class _CategoryBackground extends StatelessWidget {
  const _CategoryBackground({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const _CategoryFallbackBackground();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
        final cacheWidth = _cacheDimension(
          constraints.maxWidth,
          devicePixelRatio,
          max: 760,
        );
        final cacheHeight = _cacheDimension(
          constraints.maxHeight,
          devicePixelRatio,
          max: 640,
        );

        return Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          excludeFromSemantics: true,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return const _CategoryFallbackBackground();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return const _CategoryFallbackBackground();
          },
        );
      },
    );
  }
}

class _CategoryFallbackBackground extends StatelessWidget {
  const _CategoryFallbackBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8F684A), Color(0xFF4B5F52)],
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
