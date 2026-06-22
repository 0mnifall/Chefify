import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/core/widgets/responsive_wrap_grid.dart';
import 'package:frontend/features/categories/data/category_catalog.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/home/presentation/widgets/category_card.dart';
import 'package:frontend/features/recipes/data/recipe_catalog.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
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
  List<RecipeModel> _recipes = RecipeCatalog.items;

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
    if (!mounted) {
      return;
    }

    setState(() {
      _recipes = recipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);
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
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.horizontalPaddingForWidth(viewportWidth),
                  headerHeight + AppSpacing.xl,
                  AppSpacing.horizontalPaddingForWidth(viewportWidth),
                  AppSpacing.sectionGapForWidth(viewportWidth),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpacing.contentMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CategoriesHeader(totalCount: categories.length),
                        const SizedBox(height: AppSpacing.lg),
                        _CategorySearch(
                          controller: _searchController,
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
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (categories.isEmpty)
                          const _EmptyCategoriesState()
                        else
                          _CategoriesGrid(categories: categories),
                      ],
                    ),
                  ),
                ),
              ),
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
    final normalizedQuery = _query.trim().toLowerCase();
    final categories = CategoryCatalog.withRecipeCounts(_recipes);

    if (normalizedQuery.isEmpty) {
      return categories;
    }

    return categories
        .where(
          (category) => category.title.toLowerCase().contains(normalizedQuery),
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
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
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
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapGrid<CategoryModel>(
      items: categories,
      minItemWidth: 210,
      maxColumns: 5,
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
  if (columns >= 5) {
    return 236;
  }

  if (columns == 1 || width < 260) {
    return 226;
  }

  return 242;
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
