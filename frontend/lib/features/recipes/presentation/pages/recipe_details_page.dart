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
                        : _RecipeDetailsContent(recipe: recipe),
                  ),
                ),
              ],
            ),
            _RecipeDetailsHeaderShell(
              height: headerHeight,
              child: const AppHeader(),
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
}

class _RecipeDetailsContent extends StatelessWidget {
  const _RecipeDetailsContent({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey('recipe-details-page-${recipe.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecipeHeroPanel(recipe: recipe),
        const SizedBox(height: AppSpacing.lg),
        _RecipeOverviewPanel(recipe: recipe),
      ],
    );
  }
}

class _RecipeHeroPanel extends StatelessWidget {
  const _RecipeHeroPanel({required this.recipe});

  final RecipeModel recipe;

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
                  Padding(
                    padding: EdgeInsets.all(panelPadding),
                    child: Align(
                      alignment: compact
                          ? Alignment.bottomLeft
                          : Alignment.centerRight,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: compact ? double.infinity : 548,
                        ),
                        child: _RecipeHeroDetails(recipe: recipe),
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
  const _RecipeHeroDetails({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final categories = _categoriesFor(recipe);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  recipe.categoryName.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: palette.categoryTags,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
              _RecipeDetailsBookmarkButton(recipe: recipe),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(recipe.title, style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: AppSpacing.md),
          Text(
            _descriptionFor(recipe),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _RecipeMetaChip(
                icon: Icons.schedule_rounded,
                label: '${recipe.minutes} min',
              ),
              _RecipeMetaChip(
                icon: Icons.star_rounded,
                label: recipe.rating.toStringAsFixed(1),
              ),
              _RecipeMetaChip(icon: Icons.person_rounded, label: recipe.author),
            ],
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final category in categories)
                  _RecipeCategoryChip(category: category),
              ],
            ),
          ],
        ],
      ),
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

List<CategoryModel> _categoriesFor(RecipeModel recipe) {
  final category =
      CategoryCatalog.findById(recipe.categoryId) ??
      CategoryCatalog.findById(recipe.categoryName);
  if (category == null) {
    return const [];
  }

  return [category];
}

String _descriptionFor(RecipeModel recipe) {
  final description = recipe.description.trim();
  if (description.isNotEmpty) {
    return description;
  }

  return 'A practical Chefify recipe built for repeat cooking, balanced flavor, and a clean weeknight workflow.';
}

String _difficultyText(RecipeModel recipe) {
  if (recipe.minutes <= 20) {
    return 'Quick and low-friction for busy days.';
  }
  if (recipe.minutes <= 35) {
    return 'Comfortable weeknight cooking with a few focused steps.';
  }
  return 'Best when you have a little more room for prep and finishing.';
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
