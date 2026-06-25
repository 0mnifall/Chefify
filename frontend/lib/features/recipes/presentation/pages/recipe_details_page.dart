import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/images/optimized_network_image.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/features/categories/data/category_catalog.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/shared/bookmarks/bookmark_button.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

class RecipeDetailsPageArguments {
  const RecipeDetailsPageArguments({
    required this.recipeId,
    this.initialRecipe,
  });

  factory RecipeDetailsPageArguments.from(
    Object? arguments, {
    required String fallbackRecipeId,
  }) {
    if (arguments is RecipeDetailsPageArguments) {
      return arguments;
    }

    if (arguments is RecipeModel) {
      return RecipeDetailsPageArguments(
        recipeId: arguments.id,
        initialRecipe: arguments,
      );
    }

    if (arguments is String && arguments.trim().isNotEmpty) {
      return RecipeDetailsPageArguments(recipeId: arguments.trim());
    }

    return RecipeDetailsPageArguments(recipeId: fallbackRecipeId);
  }

  final String recipeId;
  final RecipeModel? initialRecipe;
}

class RecipeDetailsPage extends StatefulWidget {
  const RecipeDetailsPage({
    super.key,
    required this.recipeId,
    this.initialRecipe,
    this.recipeRepository = const ApiRecipeRepository(),
  });

  final String recipeId;
  final RecipeModel? initialRecipe;
  final RecipeRepository recipeRepository;

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  RecipeModel? _recipe;
  final Set<String> _likedRecipeIds = <String>{};
  final Map<String, List<_RecipeReview>> _reviewsByRecipeId =
      <String, List<_RecipeReview>>{};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _recipe = widget.initialRecipe;
    if (_recipe == null) {
      _loadRecipe();
    }
  }

  @override
  void didUpdateWidget(covariant RecipeDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipeId != widget.recipeId ||
        oldWidget.recipeRepository != widget.recipeRepository ||
        oldWidget.initialRecipe != widget.initialRecipe) {
      _recipe = widget.initialRecipe;
      if (_recipe == null) {
        _loadRecipe();
      }
    }
  }

  Future<void> _loadRecipe() async {
    setState(() {
      _isLoading = true;
    });

    final recipes = await widget.recipeRepository.fetchRecipes();
    if (!mounted) {
      return;
    }

    setState(() {
      _recipe = _findRecipe(recipes, widget.recipeId);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);
    final bottomPadding = AppSpacing.sectionGapForWidth(viewportWidth);
    final horizontalPadding = AppSpacing.horizontalPaddingForWidth(
      viewportWidth,
    );
    final recipe = _recipe;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.pageBackground, palette.cardsSurface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _RecipeDetailsContentSliver(
                  topPadding: headerHeight + AppSpacing.xl,
                  bottomPadding: bottomPadding,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _isLoading
                        ? const _RecipeDetailsLoading()
                        : recipe == null
                        ? _RecipeNotFound(recipeId: widget.recipeId)
                        : _RecipeDetailsContent(
                            recipe: recipe,
                            likesCount: _displayLikesFor(recipe),
                            reviews: _reviewsFor(recipe),
                          ),
                  ),
                ),
              ],
            ),
            _RecipeDetailsHeaderShell(
              height: headerHeight,
              child: const AppHeader(),
            ),
            if (recipe != null)
              Positioned(
                left: horizontalPadding,
                top: headerHeight + AppSpacing.md,
                child: _RecipeStickyActionButton(
                  icon: _isRecipeLiked(recipe)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  tooltip: _isRecipeLiked(recipe)
                      ? 'Remove recipe like'
                      : 'Like recipe',
                  isActive: _isRecipeLiked(recipe),
                  onPressed: () => _toggleRecipeLike(recipe),
                ),
              ),
            if (recipe != null)
              Positioned(
                right: horizontalPadding,
                bottom: AppSpacing.lg,
                child: _RecipeStickyActionButton(
                  icon: Icons.edit_rounded,
                  tooltip: 'Edit recipe',
                  onPressed: () {},
                ),
              ),
          ],
        ),
      ),
    );
  }

  RecipeModel? _findRecipe(List<RecipeModel> recipes, String recipeId) {
    final normalizedRouteId = CategoryCatalog.slug(recipeId);

    for (final recipe in recipes) {
      if (recipe.id == recipeId ||
          CategoryCatalog.slug(recipe.id) == normalizedRouteId ||
          CategoryCatalog.slug(recipe.title) == normalizedRouteId) {
        return recipe;
      }
    }

    return null;
  }

  bool _isRecipeLiked(RecipeModel recipe) {
    return _likedRecipeIds.contains(recipe.id);
  }

  int _displayLikesFor(RecipeModel recipe) {
    return _likesCountFor(recipe) + (_isRecipeLiked(recipe) ? 1 : 0);
  }

  void _toggleRecipeLike(RecipeModel recipe) {
    final willLike = !_isRecipeLiked(recipe);

    setState(() {
      if (willLike) {
        _likedRecipeIds.add(recipe.id);
      } else {
        _likedRecipeIds.remove(recipe.id);
      }
    });

    unawaited(
      widget.recipeRepository.updateRecipeLike(
        recipeId: recipe.id,
        isLiked: willLike,
      ),
    );
  }

  List<_RecipeReview> _reviewsFor(RecipeModel recipe) {
    return _reviewsByRecipeId.putIfAbsent(
      recipe.id,
      () => _seedReviewsFor(recipe),
    );
  }
}

class _RecipeDetailsContent extends StatelessWidget {
  const _RecipeDetailsContent({
    required this.recipe,
    required this.likesCount,
    required this.reviews,
  });

  final RecipeModel recipe;
  final int likesCount;
  final List<_RecipeReview> reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey('recipe-details-page-${recipe.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecipeHeroPanel(recipe: recipe, likesCount: likesCount),
        const SizedBox(height: AppSpacing.lg),
        _RecipeOverviewPanel(recipe: recipe),
        const SizedBox(height: AppSpacing.lg),
        _RecipeReviewsSection(recipe: recipe, reviews: reviews),
      ],
    );
  }
}

@immutable
class _RecipeReview {
  const _RecipeReview({
    required this.id,
    required this.author,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String author;
  final int rating;
  final String comment;
  final DateTime createdAt;
}

class _RecipeHeroPanel extends StatelessWidget {
  const _RecipeHeroPanel({required this.recipe, required this.likesCount});

  final RecipeModel recipe;
  final int likesCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      padding: EdgeInsets.zero,
      radius: AppSpacing.radiusLg,
      backgroundColor: palette.navbarBackground,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final panelPadding = compact ? AppSpacing.lg : AppSpacing.xxl;

            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: compact ? 620 : 520),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _RecipeDetailImage(recipe: recipe),
                  _RecipeHeroGradientOverlay(compact: compact),
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(panelPadding),
                      child: Align(
                        alignment: compact
                            ? Alignment.bottomLeft
                            : Alignment.centerRight,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: compact ? double.infinity : 548,
                          ),
                          child: _RecipeHeroDetails(
                            recipe: recipe,
                            likesCount: likesCount,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecipeDetailImage extends StatelessWidget {
  const _RecipeDetailImage({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    final imageUrl = recipe.imageUrl?.trim();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl == null || imageUrl.isEmpty)
          _RecipeDetailImageFallback(recipe: recipe)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
              final cacheWidth = _cacheDimension(
                constraints.maxWidth,
                devicePixelRatio,
                max: 1400,
              );
              final cacheHeight = _cacheDimension(
                constraints.maxHeight,
                devicePixelRatio,
                max: 900,
              );
              return OptimizedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                cacheWidth: cacheWidth,
                cacheHeight: cacheHeight,
                quality: 78,
                errorBuilder: (context, error, stackTrace) {
                  return _RecipeDetailImageFallback(recipe: recipe);
                },
              );
            },
          ),
      ],
    );
  }
}

class _RecipeHeroGradientOverlay extends StatelessWidget {
  const _RecipeHeroGradientOverlay({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: compact ? Alignment.topCenter : Alignment.centerLeft,
              end: compact ? Alignment.bottomCenter : Alignment.centerRight,
              colors: [
                Colors.black.withValues(alpha: compact ? 0.16 : 0.08),
                palette.navbarBackground.withValues(
                  alpha: compact ? 0.54 : 0.5,
                ),
                palette.navbarBackground.withValues(
                  alpha: compact ? 0.94 : 0.98,
                ),
              ],
              stops: compact ? const [0, 0.48, 1] : const [0, 0.48, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: compact ? const Alignment(0.2, -0.74) : Alignment.center,
              radius: compact ? 1.1 : 0.95,
              colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.transparent,
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                palette.pageBackground.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RecipeDetailImageFallback extends StatelessWidget {
  const _RecipeDetailImageFallback({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            recipe.accentColor.withValues(alpha: 0.95),
            recipe.accentColor.withValues(alpha: 0.56),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 72,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _RecipeHeroDetails extends StatelessWidget {
  const _RecipeHeroDetails({required this.recipe, required this.likesCount});

  final RecipeModel recipe;
  final int likesCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _RecipeDetailsBookmarkButton(recipe: recipe),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(recipe.title, style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: AppSpacing.md),
        Text(
          _descriptionFor(recipe),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.xl),
        Align(
          alignment: Alignment.centerRight,
          child: _RecipeHeroMetrics(recipe: recipe, likesCount: likesCount),
        ),
        if (recipe.tags.isNotEmpty) ...[
          const Spacer(),
          _RecipeHeroTagGrid(tags: recipe.tags),
        ],
      ],
    );
  }
}

class _RecipeHeroTagGrid extends StatelessWidget {
  const _RecipeHeroTagGrid({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 420 ? 2 : 3;
        final rows = <List<String>>[];

        for (var index = 0; index < tags.length; index += columns) {
          rows.add(tags.skip(index).take(columns).toList(growable: false));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
              if (rowIndex > 0) const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  for (
                    var columnIndex = 0;
                    columnIndex < rows[rowIndex].length;
                    columnIndex++
                  ) ...[
                    if (columnIndex > 0) const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: _RecipeHeroTagChip(
                        tag: rows[rowIndex][columnIndex],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _RecipeHeroTagChip extends StatelessWidget {
  const _RecipeHeroTagChip({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: Text(
        _readableLabel(tag),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _RecipeHeroMetrics extends StatelessWidget {
  const _RecipeHeroMetrics({required this.recipe, required this.likesCount});

  final RecipeModel recipe;
  final int likesCount;

  @override
  Widget build(BuildContext context) {
    final category = _categoryFor(recipe);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 420.0;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _RecipeMetaChip(
                      icon: Icons.schedule_rounded,
                      label: '${recipe.minutes} min',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _RecipeMetaChip(
                      icon: Icons.local_fire_department_rounded,
                      label: _difficultyLabel(recipe),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (category == null)
                _RecipeMetaChip(
                  icon: Icons.restaurant_menu_rounded,
                  label: recipe.categoryName,
                )
              else
                _RecipeCategoryChip(category: category),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _RecipeMetaChip(
                      icon: Icons.favorite_rounded,
                      label: _formatCount(likesCount),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _RecipeMetaChip(
                      icon: Icons.star_rounded,
                      label: recipe.rating.toStringAsFixed(1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecipeDetailsBookmarkButton extends StatelessWidget {
  const _RecipeDetailsBookmarkButton({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    final bookmarks = BookmarkScope.of(context);
    final isSaved = bookmarks.isRecipeSaved(recipe);

    return BookmarkButton(
      isSaved: isSaved,
      onPressed: () {
        bookmarks.toggleRecipe(recipe);
      },
    );
  }
}

class _RecipeOverviewPanel extends StatelessWidget {
  const _RecipeOverviewPanel({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 760;
          final summary = _RecipeOverviewColumn(recipe: recipe);
          final notes = _RecipeNotesColumn(recipe: recipe);

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: AppSpacing.xl),
                notes,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: summary),
              const SizedBox(width: AppSpacing.xl),
              Expanded(child: notes),
            ],
          );
        },
      ),
    );
  }
}

class _RecipeReviewsSection extends StatelessWidget {
  const _RecipeReviewsSection({required this.recipe, required this.reviews});

  final RecipeModel recipe;
  final List<_RecipeReview> reviews;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      key: ValueKey('recipe-reviews-section-${recipe.id}'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REVIEWS',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: palette.categoryTags,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Community rating',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${reviews.length} cooks reviewed this recipe.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _RecipeOverviewColumn extends StatelessWidget {
  const _RecipeOverviewColumn({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return _RecipeTextSection(
      eyebrow: 'OVERVIEW',
      title: 'Cook profile',
      children: [
        _RecipeDetailRow(
          icon: Icons.timer_rounded,
          title: 'Time',
          text: '${recipe.minutes} minutes from prep to plate.',
        ),
        _RecipeDetailRow(
          icon: Icons.local_fire_department_rounded,
          title: 'Difficulty',
          text: _difficultyText(recipe),
        ),
        _RecipeDetailRow(
          icon: Icons.insights_rounded,
          title: 'Rating',
          text: '${recipe.rating.toStringAsFixed(1)} average community rating.',
        ),
      ],
    );
  }
}

class _RecipeNotesColumn extends StatelessWidget {
  const _RecipeNotesColumn({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return _RecipeTextSection(
      eyebrow: 'NOTES',
      title: 'What to expect',
      children: [
        _RecipeDetailRow(
          icon: Icons.restaurant_menu_rounded,
          title: recipe.categoryName,
          text: _descriptionFor(recipe),
        ),
        _RecipeDetailRow(
          icon: Icons.bookmark_added_rounded,
          title: 'Save for later',
          text:
              'Use the bookmark button to keep this recipe in your saved list.',
        ),
      ],
    );
  }
}

class _RecipeTextSection extends StatelessWidget {
  const _RecipeTextSection({
    required this.eyebrow,
    required this.title,
    required this.children,
  });

  final String eyebrow;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: palette.categoryTags,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.lg),
        ...children,
      ],
    );
  }
}

class _RecipeDetailRow extends StatelessWidget {
  const _RecipeDetailRow({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: palette.searchBarBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: palette.borders),
            ),
            child: Icon(icon, size: 18, color: palette.icons),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeMetaChip extends StatelessWidget {
  const _RecipeMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: palette.icons),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _RecipeCategoryChip extends StatelessWidget {
  const _RecipeCategoryChip({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.primaryButtons.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: palette.primaryButtons.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 16, color: palette.primaryButtons),
          const SizedBox(width: AppSpacing.xs),
          Text(category.title, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _RecipeDetailsLoading extends StatelessWidget {
  const _RecipeDetailsLoading();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      key: const ValueKey('recipe-details-loading'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: palette.activeElements,
          ),
        ),
      ),
    );
  }
}

class _RecipeNotFound extends StatelessWidget {
  const _RecipeNotFound({required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      key: ValueKey('recipe-details-not-found-$recipeId'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 44, color: palette.icons),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Recipe not found',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'This recipe is not available in the current catalog.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/recipes', (route) => false);
              },
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Browse recipes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeDetailsContentSliver extends StatelessWidget {
  const _RecipeDetailsContentSliver({
    required this.child,
    this.topPadding = 0,
    this.bottomPadding = 0,
  });

  final Widget child;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = AppSpacing.horizontalPaddingForWidth(
      viewportWidth,
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          topPadding,
          horizontalPadding,
          bottomPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _RecipeDetailsHeaderShell extends StatelessWidget {
  const _RecipeDetailsHeaderShell({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: palette.navbarBackground.withValues(alpha: 0.94),
          border: Border(
            bottom: BorderSide(color: palette.borders.withValues(alpha: 0.55)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _RecipeStickyActionButton extends StatelessWidget {
  const _RecipeStickyActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final activeColor = const Color(0xFFD96D58);
    final background = isActive
        ? activeColor
        : palette.cardsSurface.withValues(alpha: 0.94);
    final foreground = isActive ? Colors.white : palette.mainText;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? activeColor.withValues(alpha: 0.72)
                    : palette.borders.withValues(alpha: 0.84),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: foreground),
          ),
        ),
      ),
    );
  }
}

CategoryModel? _categoryFor(RecipeModel recipe) {
  return CategoryCatalog.findById(recipe.categoryId) ??
      CategoryCatalog.findById(recipe.categoryName);
}

String _descriptionFor(RecipeModel recipe) {
  final description = recipe.description.trim();
  if (description.isNotEmpty) {
    return description;
  }

  return 'A practical Chefify recipe built for repeat cooking, balanced flavor, and a clean weeknight workflow.';
}

String _difficultyLabel(RecipeModel recipe) {
  final difficulty = recipe.difficulty.clamp(1, 5);

  if (difficulty <= 2) {
    return 'Easy';
  }
  if (difficulty == 3) {
    return 'Medium';
  }
  if (difficulty == 4) {
    return 'Hard';
  }
  return 'Expert';
}

String _difficultyText(RecipeModel recipe) {
  final difficulty = recipe.difficulty.clamp(1, 5);

  if (difficulty <= 2) {
    return 'Quick and low-friction for busy days.';
  }
  if (difficulty == 3) {
    return 'Comfortable weeknight cooking with a few focused steps.';
  }
  if (difficulty == 4) {
    return 'Best when you have a little more room for prep and finishing.';
  }
  return 'A more involved cook for confident, detail-focused sessions.';
}

int _likesCountFor(RecipeModel recipe) {
  if (recipe.likesCount > 0) {
    return recipe.likesCount;
  }

  final popularityBoost = recipe.popularityScore > 0
      ? (recipe.popularityScore / 3).round()
      : 0;
  return (recipe.rating * 390).round() + 610 + popularityBoost;
}

String _formatCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}m';
  }
  if (value >= 1000) {
    final formatted = value / 1000;
    return '${formatted.toStringAsFixed(formatted >= 10 ? 0 : 1)}k';
  }
  return value.toString();
}

String _readableLabel(String value) {
  final words = value
      .trim()
      .split(RegExp(r'[-_\s]+'))
      .where((word) => word.isNotEmpty);

  return words
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}

List<_RecipeReview> _seedReviewsFor(RecipeModel recipe) {
  const comments = [
    'Clear steps and the flavor landed exactly where I wanted it.',
    'Cooked this for dinner and it held up well for leftovers.',
    'The timing felt realistic and the result was easy to repeat.',
    'Nice balance of texture, seasoning, and prep effort.',
    'Good weeknight option. I would make it again with a little extra herbs.',
  ];
  const authors = [
    'Marta Cook',
    'Ivan Plate',
    'Sofia Green',
    'Nadia Table',
    'Oleh Spoon',
    'Kate Pantry',
  ];
  final count = 34 + (recipe.id.hashCode.abs() % 15);
  final baseDate = DateTime(2026, 6, 24, 18, 30);

  return List<_RecipeReview>.generate(count, (index) {
    final rating = 5 - ((index + recipe.title.length) % 3);

    return _RecipeReview(
      id: '${recipe.id}-review-$index',
      author: authors[index % authors.length],
      rating: rating,
      comment: comments[(index + recipe.categoryName.length) % comments.length],
      createdAt: baseDate.subtract(Duration(hours: index * 7)),
    );
  }, growable: false);
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
