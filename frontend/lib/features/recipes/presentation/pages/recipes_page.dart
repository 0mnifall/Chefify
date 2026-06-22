import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/core/widgets/responsive_wrap_grid.dart';
import 'package:frontend/features/categories/data/category_catalog.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/home/presentation/widgets/recipe_card.dart';
import 'package:frontend/features/recipes/data/recipe_catalog.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

enum _RecipeSort { featured, rating, quickest, title }

enum _TimeFilter { any, under20, under30, over30 }

class RecipesPageArguments {
  const RecipesPageArguments({this.categoryIds = const []});

  factory RecipesPageArguments.from(Object? arguments) {
    if (arguments is RecipesPageArguments) {
      return arguments;
    }

    if (arguments is String) {
      return RecipesPageArguments(categoryIds: [arguments]);
    }

    if (arguments is Iterable<String>) {
      return RecipesPageArguments(categoryIds: arguments.toList());
    }

    return const RecipesPageArguments();
  }

  final List<String> categoryIds;
}

class RecipesPage extends StatefulWidget {
  const RecipesPage({
    super.key,
    this.recipeRepository = const ApiRecipeRepository(),
    this.initialCategoryIds = const [],
  });

  final RecipeRepository recipeRepository;
  final List<String> initialCategoryIds;

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  static const _maxSelectedCategories = 3;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  Set<String> _selectedCategoryIds = const {};
  _TimeFilter _timeFilter = _TimeFilter.any;
  _RecipeSort _sort = _RecipeSort.featured;
  bool _savedOnly = false;
  List<RecipeModel>? _recipes;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIds = _normalizedInitialCategoryIds(
      widget.initialCategoryIds,
    );
    _loadRecipes();
  }

  @override
  void didUpdateWidget(covariant RecipesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipeRepository != widget.recipeRepository) {
      _loadRecipes();
    }
    if (!_sameCategoryIds(
      oldWidget.initialCategoryIds,
      widget.initialCategoryIds,
    )) {
      _selectedCategoryIds = _normalizedInitialCategoryIds(
        widget.initialCategoryIds,
      );
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
    final recipes = _visibleRecipes(context);
    final categories = CategoryCatalog.withRecipeCounts(
      _recipes ?? RecipeCatalog.items,
    );
    final isLoading = _recipes == null;

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
                        _RecipesHeader(totalCount: recipes.length),
                        const SizedBox(height: AppSpacing.lg),
                        _RecipeControls(
                          searchController: _searchController,
                          selectedCategoryIds: _selectedCategoryIds,
                          timeFilter: _timeFilter,
                          sort: _sort,
                          savedOnly: _savedOnly,
                          categories: categories,
                          onSearchChanged: (value) {
                            setState(() {
                              _query = value;
                            });
                          },
                          onClearSearch: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                            });
                          },
                          onCategoryToggled: _toggleCategory,
                          onClearCategories: () {
                            setState(() {
                              _selectedCategoryIds = const {};
                            });
                          },
                          onTimeFilterChanged: (filter) {
                            setState(() {
                              _timeFilter = filter;
                            });
                          },
                          onSortChanged: (sort) {
                            setState(() {
                              _sort = sort;
                            });
                          },
                          onSavedOnlyChanged: (value) {
                            setState(() {
                              _savedOnly = value;
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (isLoading)
                          const _RecipesLoadingState()
                        else if (recipes.isEmpty)
                          const _EmptyRecipesState()
                        else
                          _RecipesGrid(recipes: recipes),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _RecipesHeaderShell(height: headerHeight, child: const AppHeader()),
          ],
        ),
      ),
    );
  }

  List<RecipeModel> _visibleRecipes(BuildContext context) {
    final bookmarkStore = BookmarkScope.of(context);
    final normalizedQuery = _query.trim().toLowerCase();
    final sourceRecipes = _recipes ?? const <RecipeModel>[];
    final recipes = sourceRecipes.where((recipe) {
      final categoryText = _recipeCategoryText(recipe);
      final matchesSearch =
          normalizedQuery.isEmpty ||
          recipe.title.toLowerCase().contains(normalizedQuery) ||
          recipe.tag.toLowerCase().contains(normalizedQuery) ||
          recipe.author.toLowerCase().contains(normalizedQuery) ||
          categoryText.contains(normalizedQuery);
      final matchesCategory =
          _selectedCategoryIds.isEmpty ||
          _selectedCategoryIds.any(
            (categoryId) =>
                CategoryCatalog.recipeMatchesCategoryId(recipe, categoryId),
          );
      final matchesTime = switch (_timeFilter) {
        _TimeFilter.any => true,
        _TimeFilter.under20 => recipe.minutes <= 20,
        _TimeFilter.under30 => recipe.minutes <= 30,
        _TimeFilter.over30 => recipe.minutes > 30,
      };
      final matchesSaved = !_savedOnly || bookmarkStore.isRecipeSaved(recipe);

      return matchesSearch && matchesCategory && matchesTime && matchesSaved;
    }).toList();

    recipes.sort((left, right) {
      return switch (_sort) {
        _RecipeSort.featured =>
          sourceRecipes.indexOf(left).compareTo(sourceRecipes.indexOf(right)),
        _RecipeSort.rating => right.rating.compareTo(left.rating),
        _RecipeSort.quickest => left.minutes.compareTo(right.minutes),
        _RecipeSort.title => left.title.compareTo(right.title),
      };
    });

    return recipes;
  }

  void _toggleCategory(String categoryId) {
    final normalizedCategoryId = CategoryCatalog.slug(categoryId);
    setState(() {
      final selectedCategoryIds = {..._selectedCategoryIds};
      if (selectedCategoryIds.contains(normalizedCategoryId)) {
        selectedCategoryIds.remove(normalizedCategoryId);
      } else if (selectedCategoryIds.length < _maxSelectedCategories) {
        selectedCategoryIds.add(normalizedCategoryId);
      }
      _selectedCategoryIds = selectedCategoryIds;
    });
  }

  Set<String> _normalizedInitialCategoryIds(Iterable<String> categoryIds) {
    return categoryIds
        .map(CategoryCatalog.slug)
        .where((categoryId) => CategoryCatalog.findById(categoryId) != null)
        .take(_maxSelectedCategories)
        .toSet();
  }

  bool _sameCategoryIds(List<String> left, List<String> right) {
    final normalizedLeft = _normalizedInitialCategoryIds(left);
    final normalizedRight = _normalizedInitialCategoryIds(right);
    return normalizedLeft.length == normalizedRight.length &&
        normalizedLeft.containsAll(normalizedRight);
  }

  String _recipeCategoryText(RecipeModel recipe) {
    final categoryTitles = recipe.categoryIds
        .map(CategoryCatalog.findById)
        .whereType<CategoryModel>()
        .map((category) => category.title.toLowerCase());

    return [recipe.tag.toLowerCase(), ...categoryTitles].join(' ');
  }
}

class _RecipesHeader extends StatelessWidget {
  const _RecipesHeader({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECIPES',
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
              'Find your next cook',
              style: compact
                  ? Theme.of(context).textTheme.headlineMedium
                  : Theme.of(context).textTheme.displayMedium,
            );

            final count = _RecipeCountBadge(totalCount: totalCount);

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
          'Browse every Chefify recipe and narrow the list by taste, time, saved items, or rating.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _RecipeCountBadge extends StatelessWidget {
  const _RecipeCountBadge({required this.totalCount});

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
        '$totalCount recipes',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _RecipeControls extends StatelessWidget {
  const _RecipeControls({
    required this.searchController,
    required this.selectedCategoryIds,
    required this.timeFilter,
    required this.sort,
    required this.savedOnly,
    required this.categories,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onCategoryToggled,
    required this.onClearCategories,
    required this.onTimeFilterChanged,
    required this.onSortChanged,
    required this.onSavedOnlyChanged,
  });

  final TextEditingController searchController;
  final Set<String> selectedCategoryIds;
  final _TimeFilter timeFilter;
  final _RecipeSort sort;
  final bool savedOnly;
  final List<CategoryModel> categories;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onCategoryToggled;
  final VoidCallback onClearCategories;
  final ValueChanged<_TimeFilter> onTimeFilterChanged;
  final ValueChanged<_RecipeSort> onSortChanged;
  final ValueChanged<bool> onSavedOnlyChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 820;
          final search = TextField(
            key: const ValueKey('recipes-search-field'),
            controller: searchController,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Search recipes',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: onClearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          );
          final sortPicker = DropdownButtonFormField<_RecipeSort>(
            key: const ValueKey('recipes-sort-dropdown'),
            initialValue: sort,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Sort by'),
            items: const [
              DropdownMenuItem(
                value: _RecipeSort.featured,
                child: Text('Featured'),
              ),
              DropdownMenuItem(
                value: _RecipeSort.rating,
                child: Text('Highest rated'),
              ),
              DropdownMenuItem(
                value: _RecipeSort.quickest,
                child: Text('Quickest'),
              ),
              DropdownMenuItem(value: _RecipeSort.title, child: Text('A-Z')),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              onSortChanged(value);
            },
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact)
                Column(
                  children: [
                    search,
                    const SizedBox(height: AppSpacing.sm),
                    sortPicker,
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(flex: 3, child: search),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: constraints.maxWidth < 960 ? 200 : 220,
                      child: sortPicker,
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Categories',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  if (selectedCategoryIds.isNotEmpty)
                    TextButton(
                      onPressed: onClearCategories,
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              _CategoryFilterCloud(
                categories: categories,
                selectedCategoryIds: selectedCategoryIds,
                onCategoryToggled: onCategoryToggled,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Cook time', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _TimeFilterChip(
                    label: 'Any',
                    filter: _TimeFilter.any,
                    selectedFilter: timeFilter,
                    onSelected: onTimeFilterChanged,
                  ),
                  _TimeFilterChip(
                    label: '20 min or less',
                    filter: _TimeFilter.under20,
                    selectedFilter: timeFilter,
                    onSelected: onTimeFilterChanged,
                  ),
                  _TimeFilterChip(
                    label: '30 min or less',
                    filter: _TimeFilter.under30,
                    selectedFilter: timeFilter,
                    onSelected: onTimeFilterChanged,
                  ),
                  _TimeFilterChip(
                    label: 'Over 30 min',
                    filter: _TimeFilter.over30,
                    selectedFilter: timeFilter,
                    onSelected: onTimeFilterChanged,
                  ),
                  FilterChip(
                    avatar: Icon(
                      savedOnly
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 18,
                    ),
                    label: const Text('Saved'),
                    selected: savedOnly,
                    onSelected: onSavedOnlyChanged,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryFilterCloud extends StatelessWidget {
  const _CategoryFilterCloud({
    required this.categories,
    required this.selectedCategoryIds,
    required this.onCategoryToggled,
  });

  final List<CategoryModel> categories;
  final Set<String> selectedCategoryIds;
  final ValueChanged<String> onCategoryToggled;

  @override
  Widget build(BuildContext context) {
    final sortedCategories = [...categories]
      ..sort((left, right) {
        final count = right.recipesCount.compareTo(left.recipesCount);
        if (count != 0) {
          return count;
        }

        return left.title.compareTo(right.title);
      });
    final atLimit =
        selectedCategoryIds.length >= _RecipesPageState._maxSelectedCategories;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final category in sortedCategories)
          FilterChip(
            label: Text('${category.title} ${category.recipesCount}'),
            selected: selectedCategoryIds.contains(category.id),
            avatar: selectedCategoryIds.contains(category.id)
                ? const Icon(Icons.check_rounded, size: 17)
                : Icon(category.icon, size: 17),
            onSelected: selectedCategoryIds.contains(category.id) || !atLimit
                ? (_) => onCategoryToggled(category.id)
                : null,
          ),
      ],
    );
  }
}

class _TimeFilterChip extends StatelessWidget {
  const _TimeFilterChip({
    required this.label,
    required this.filter,
    required this.selectedFilter,
    required this.onSelected,
  });

  final String label;
  final _TimeFilter filter;
  final _TimeFilter selectedFilter;
  final ValueChanged<_TimeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedFilter == filter,
      onSelected: (_) => onSelected(filter),
    );
  }
}

class _RecipesGrid extends StatelessWidget {
  const _RecipesGrid({required this.recipes});

  final List<RecipeModel> recipes;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapGrid<RecipeModel>(
      items: recipes,
      minItemWidth: 240,
      maxColumns: 4,
      itemHeightBuilder: _recipeCardHeight,
      itemBuilder: (context, recipe) {
        return RecipeCard(recipe: recipe);
      },
    );
  }
}

double _recipeCardHeight(double width, int columns) {
  if (columns == 1 || width < 280) {
    return 334;
  }

  return 348;
}

class _EmptyRecipesState extends StatelessWidget {
  const _EmptyRecipesState();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.manage_search_rounded, size: 40, color: palette.icons),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No recipes match these filters',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Try a different search term, category, or cook time.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipesLoadingState extends StatelessWidget {
  const _RecipesLoadingState();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SizedBox(
        height: 220,
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
      ),
    );
  }
}

class _RecipesHeaderShell extends StatelessWidget {
  const _RecipesHeaderShell({required this.height, required this.child});

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
