import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/core/widgets/responsive_sliver_grid.dart';
import 'package:frontend/features/categories/data/category_catalog.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/home/presentation/widgets/category_card.dart';
import 'package:frontend/features/recipes/data/recipe_catalog.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({
    super.key,
    this.recipeRepository = const ApiRecipeRepository(),
  });

  final RecipeRepository recipeRepository;

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _savedOnly = false;
  List<RecipeModel> _recipes = RecipeCatalog.items;
  List<CategoryModel> _categories = CategoryCatalog.withRecipeCounts(
    RecipeCatalog.items,
  );

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  @override
  void didUpdateWidget(covariant CategoriesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipeRepository != widget.recipeRepository) {
      _loadRecipes();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    final recipes = await widget.recipeRepository.fetchRecipes();
    if (!mounted || _sameRecipeLists(_recipes, recipes)) {
      return;
    }

    setState(() {
      _recipes = recipes;
      _categories = CategoryCatalog.withRecipeCounts(recipes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);
    final bottomPadding = AppSpacing.sectionGapForWidth(viewportWidth);
    final categories = _visibleCategories;

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
              // ignore: deprecated_member_use
              cacheExtent: 160,
              slivers: [
                _CategoriesContentSliver(
                  topPadding: headerHeight + AppSpacing.xl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoriesHeader(totalCount: categories.length),
                      const SizedBox(height: AppSpacing.lg),
                      _CategorySearch(
                        controller: _searchController,
                        savedOnly: _savedOnly,
                        onChanged: (value) {
                          setState(() {
                            _query = value;
                          });
                        },
                        onClear: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                        onSavedOnlyChanged: (value) {
                          setState(() {
                            _savedOnly = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (categories.isEmpty)
                  _CategoriesContentSliver(
                    topPadding: AppSpacing.lg,
                    bottomPadding: bottomPadding,
                    child: const _EmptyCategoriesState(),
                  )
                else
                  _CategoriesGrid(
                    categories: categories,
                    topPadding: AppSpacing.lg,
                    bottomPadding: bottomPadding,
                  ),
              ],
            ),
            _CategoriesHeaderShell(
              height: headerHeight,
              child: const AppHeader(),
            ),
          ],
        ),
      ),
    );
  }

  List<CategoryModel> get _visibleCategories {
    final bookmarks = BookmarkScope.of(context);
    final normalizedQuery = _query.trim().toLowerCase();

    return _categories
        .where(
          (category) =>
              (normalizedQuery.isEmpty ||
                  category.title.toLowerCase().contains(normalizedQuery)) &&
              (!_savedOnly || bookmarks.isCategorySaved(category)),
        )
        .toList(growable: false);
  }
}

class _CategoriesHeader extends StatelessWidget {
  const _CategoriesHeader({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORIES',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: palette.categoryTags,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final title = Text(
              'Explore every category',
              style: compact
                  ? Theme.of(context).textTheme.headlineMedium
                  : Theme.of(context).textTheme.displayMedium,
            );
            final count = _CategoryCountBadge(totalCount: totalCount);

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: AppSpacing.sm),
                  count,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: title),
                const SizedBox(width: AppSpacing.lg),
                count,
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'From quick dinners to baking projects, every Chefify lane is here.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _CategoryCountBadge extends StatelessWidget {
  const _CategoryCountBadge({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: Text(
        '$totalCount categories',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _CategorySearch extends StatelessWidget {
  const _CategorySearch({
    required this.controller,
    required this.savedOnly,
    required this.onChanged,
    required this.onClear,
    required this.onSavedOnlyChanged,
  });

  final TextEditingController controller;
  final bool savedOnly;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<bool> onSavedOnlyChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 640;
          final searchField = TextField(
            key: const ValueKey('categories-search-field'),
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Search categories',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear category search',
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          );
          final savedButton = _SavedOnlyButton(
            selected: savedOnly,
            onChanged: onSavedOnlyChanged,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                const SizedBox(height: AppSpacing.sm),
                savedButton,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: AppSpacing.md),
              SizedBox(width: 168, child: savedButton),
            ],
          );
        },
      ),
    );
  }
}

class _SavedOnlyButton extends StatelessWidget {
  const _SavedOnlyButton({required this.selected, required this.onChanged});

  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final icon = selected
        ? Icons.bookmark_rounded
        : Icons.bookmark_border_rounded;
    final label = Text(
      'Saved only',
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );

    if (selected) {
      return FilledButton.icon(
        onPressed: () => onChanged(false),
        icon: Icon(icon, size: 18),
        label: label,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => onChanged(true),
      icon: Icon(icon, size: 18),
      label: label,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({
    required this.categories,
    required this.topPadding,
    required this.bottomPadding,
  });

  final List<CategoryModel> categories;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ResponsiveSliverGrid<CategoryModel>(
      items: categories,
      minItemWidth: 250,
      maxColumns: 4,
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      itemHeightBuilder: _categoryCardHeight,
      itemBuilder: (context, category) {
        return CategoryCard(
          category: category,
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(AppRouter.recipes, arguments: category.id);
          },
        );
      },
    );
  }
}

double _categoryCardHeight(double width, int columns) {
  if (columns >= 4) {
    return 272;
  }

  if (columns == 1 || width < 280) {
    return 244;
  }

  return 260;
}

class _CategoriesContentSliver extends StatelessWidget {
  const _CategoriesContentSliver({
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

class _EmptyCategoriesState extends StatelessWidget {
  const _EmptyCategoriesState();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_rounded, size: 40, color: palette.icons),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No categories found',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesHeaderShell extends StatelessWidget {
  const _CategoriesHeaderShell({required this.height, required this.child});

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

bool _sameRecipeLists(List<RecipeModel> left, List<RecipeModel> right) {
  if (identical(left, right)) {
    return true;
  }
  if (left.length != right.length) {
    return false;
  }

  for (var index = 0; index < left.length; index++) {
    if (!_sameRecipe(left[index], right[index])) {
      return false;
    }
  }
  return true;
}

bool _sameRecipe(RecipeModel left, RecipeModel right) {
  return left.id == right.id &&
      left.title == right.title &&
      left.categoryId == right.categoryId &&
      left.categoryName == right.categoryName &&
      left.author == right.author &&
      left.minutes == right.minutes &&
      left.rating == right.rating &&
      left.accentColor == right.accentColor &&
      left.description == right.description &&
      left.imageUrl == right.imageUrl &&
      left.thumbnailUrl == right.thumbnailUrl &&
      left.popularityScore == right.popularityScore &&
      left.isSaved == right.isSaved &&
      _sameStringLists(left.tags, right.tags);
}

bool _sameStringLists(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}
