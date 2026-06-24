import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/core/widgets/responsive_sliver_grid.dart';
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
  static const _recipesPerPage = 20;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _query = '';
  Set<String> _selectedCategoryIds = const {};
  _TimeFilter _timeFilter = _TimeFilter.any;
  _RecipeSort _sort = _RecipeSort.featured;
  bool _savedOnly = false;
  List<RecipeModel> _recipes = RecipeCatalog.items;
  int _currentPage = 1;

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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    final recipes = await widget.recipeRepository.fetchRecipes();
    if (!mounted) {
      return;
    }

    setState(() {
      _recipes = recipes;
      _currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);
    final bottomPadding = AppSpacing.sectionGapForWidth(viewportWidth);
    final recipes = _visibleRecipes(context);
    final pageCount = _pageCount(recipes.length);
    final currentPage = _currentPage.clamp(1, pageCount).toInt();
    final pageRecipes = _recipesForPage(recipes, currentPage);
    final categories = CategoryCatalog.withRecipeCounts(_recipes);

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
              controller: _scrollController,
              scrollCacheExtent: const ScrollCacheExtent.pixels(720),
              slivers: [
                _RecipesContentSliver(
                  topPadding: headerHeight + AppSpacing.xl,
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
                            _currentPage = 1;
                          });
                        },
                        onClearSearch: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                            _currentPage = 1;
                          });
                        },
                        onCategoryToggled: _toggleCategory,
                        onClearCategories: () {
                          setState(() {
                            _selectedCategoryIds = const {};
                            _currentPage = 1;
                          });
                        },
                        onTimeFilterChanged: (filter) {
                          setState(() {
                            _timeFilter = filter;
                            _currentPage = 1;
                          });
                        },
                        onSortChanged: (sort) {
                          setState(() {
                            _sort = sort;
                            _currentPage = 1;
                          });
                        },
                        onSavedOnlyChanged: (value) {
                          setState(() {
                            _savedOnly = value;
                            _currentPage = 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (recipes.isEmpty)
                  _RecipesContentSliver(
                    topPadding: AppSpacing.lg,
                    bottomPadding: bottomPadding,
                    child: const _EmptyRecipesState(),
                  )
                else
                  _RecipesGrid(
                    recipes: pageRecipes,
                    topPadding: AppSpacing.lg,
                    bottomPadding: pageCount > 1
                        ? AppSpacing.lg
                        : bottomPadding,
                  ),
                if (pageCount > 1)
                  _RecipesContentSliver(
                    bottomPadding: bottomPadding,
                    child: _RecipePagination(
                      currentPage: currentPage,
                      pageCount: pageCount,
                      onPageChanged: _changePage,
                    ),
                  ),
              ],
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
    final normalizedSlugQuery = CategoryCatalog.slug(normalizedQuery);
    final sourceRecipes = _recipes;
    final recipes = sourceRecipes.where((recipe) {
      final searchText = _recipeSearchText(recipe);
      final matchesSearch =
          normalizedQuery.isEmpty ||
          searchText.contains(normalizedQuery) ||
          (normalizedSlugQuery.isNotEmpty &&
              CategoryCatalog.slug(searchText).contains(normalizedSlugQuery));
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
      _currentPage = 1;
    });
  }

  int _pageCount(int itemCount) {
    if (itemCount <= 0) {
      return 1;
    }

    return ((itemCount - 1) ~/ _recipesPerPage) + 1;
  }

  List<RecipeModel> _recipesForPage(List<RecipeModel> recipes, int page) {
    if (recipes.isEmpty) {
      return const [];
    }

    final startIndex = (page - 1) * _recipesPerPage;
    return recipes
        .skip(startIndex)
        .take(_recipesPerPage)
        .toList(growable: false);
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    }
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

  String _recipeSearchText(RecipeModel recipe) {
    final category = CategoryCatalog.findById(recipe.categoryId);
    final tagText = recipe.tags.expand(
      (tag) => [tag.toLowerCase(), _readableTagLabel(tag).toLowerCase()],
    );

    return [
      recipe.title.toLowerCase(),
      recipe.categoryName.toLowerCase(),
      recipe.author.toLowerCase(),
      if (category != null) category.title.toLowerCase(),
      ...tagText,
    ].join(' ');
  }

  String _readableTagLabel(String tag) {
    return tag.trim().replaceAll(RegExp(r'[_-]+'), ' ');
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
          final compact = constraints.maxWidth < 900;
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
          final sortPicker = _SortDropdown(
            sort: sort,
            onChanged: onSortChanged,
          );
          final savedButton = _SavedOnlyButton(
            selected: savedOnly,
            onChanged: onSavedOnlyChanged,
          );
          final sideControlWidth = constraints.maxWidth < 1040 ? 184.0 : 204.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    search,
                    const SizedBox(height: AppSpacing.sm),
                    if (constraints.maxWidth < 520)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          sortPicker,
                          const SizedBox(height: AppSpacing.sm),
                          savedButton,
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(child: sortPicker),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: savedButton),
                        ],
                      ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(flex: 3, child: search),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(width: sideControlWidth, child: sortPicker),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(width: sideControlWidth, child: savedButton),
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
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.sort, required this.onChanged});

  final _RecipeSort sort;
  final ValueChanged<_RecipeSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<_RecipeSort>(
      key: const ValueKey('recipes-sort-dropdown'),
      initialSelection: sort,
      expandedInsets: EdgeInsets.zero,
      requestFocusOnTap: false,
      label: const Text('Sort by'),
      menuHeight: 216,
      dropdownMenuEntries: const [
        DropdownMenuEntry(value: _RecipeSort.featured, label: 'Featured'),
        DropdownMenuEntry(value: _RecipeSort.rating, label: 'Highest rated'),
        DropdownMenuEntry(value: _RecipeSort.quickest, label: 'Quickest'),
        DropdownMenuEntry(value: _RecipeSort.title, label: 'A-Z'),
      ],
      onSelected: (value) {
        if (value == null) {
          return;
        }
        onChanged(value);
      },
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = _buildCategoryChipRows(
          context,
          sortedCategories,
          constraints.maxWidth,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: rowIndex == rows.length - 1 ? 0 : AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    for (
                      var itemIndex = 0;
                      itemIndex < rows[rowIndex].length;
                      itemIndex++
                    ) ...[
                      if (itemIndex > 0) const SizedBox(width: AppSpacing.xs),
                      SizedBox(
                        width: rows[rowIndex][itemIndex].width,
                        child: _CategoryFilterChip(
                          category: rows[rowIndex][itemIndex].category,
                          selected: selectedCategoryIds.contains(
                            rows[rowIndex][itemIndex].category.id,
                          ),
                          atLimit: atLimit,
                          onCategoryToggled: onCategoryToggled,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  List<List<_CategoryChipLayout>> _buildCategoryChipRows(
    BuildContext context,
    List<CategoryModel> categories,
    double maxWidth,
  ) {
    final safeWidth = maxWidth.isFinite ? maxWidth : AppSpacing.contentMaxWidth;
    final rows = <List<_CategoryChipSeed>>[];
    var currentRow = <_CategoryChipSeed>[];
    var currentWidth = 0.0;

    for (final category in categories) {
      final baseWidth = _categoryChipBaseWidth(context, category, safeWidth);
      final nextWidth =
          currentWidth + (currentRow.isEmpty ? 0 : AppSpacing.xs) + baseWidth;

      if (currentRow.isNotEmpty && nextWidth > safeWidth) {
        rows.add(currentRow);
        currentRow = [_CategoryChipSeed(category, baseWidth)];
        currentWidth = baseWidth;
      } else {
        currentRow.add(_CategoryChipSeed(category, baseWidth));
        currentWidth = nextWidth;
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    return [for (final row in rows) _justifyCategoryChipRow(row, safeWidth)];
  }

  List<_CategoryChipLayout> _justifyCategoryChipRow(
    List<_CategoryChipSeed> row,
    double maxWidth,
  ) {
    final spacing = AppSpacing.xs * (row.length - 1);
    final baseWidth = row.fold<double>(0, (sum, item) => sum + item.baseWidth);
    final extra = (maxWidth - spacing - baseWidth).clamp(0, double.infinity);
    final extraPerChip = row.length <= 1 ? 0.0 : extra / row.length;

    return [
      for (final item in row)
        _CategoryChipLayout(
          category: item.category,
          width: item.baseWidth + extraPerChip,
        ),
    ];
  }

  double _categoryChipBaseWidth(
    BuildContext context,
    CategoryModel category,
    double maxWidth,
  ) {
    final label = '${category.title} ${category.recipesCount}';
    final textStyle =
        Theme.of(context).textTheme.labelLarge ??
        DefaultTextStyle.of(context).style;
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    return (textPainter.width + 72).clamp(118, maxWidth).toDouble();
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.category,
    required this.selected,
    required this.atLimit,
    required this.onCategoryToggled,
  });

  final CategoryModel category;
  final bool selected;
  final bool atLimit;
  final ValueChanged<String> onCategoryToggled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final enabled = selected || !atLimit;
    final borderRadius = BorderRadius.circular(AppSpacing.radiusSm);
    final textStyle = Theme.of(context).textTheme.labelLarge;
    final foregroundColor = enabled
        ? palette.mainText
        : palette.secondaryText.withValues(alpha: 0.58);
    final accentColor = enabled
        ? palette.primaryButtons
        : palette.primaryButtons.withValues(alpha: 0.45);
    final borderColor = selected
        ? palette.primaryButtons
        : palette.mainText.withValues(alpha: enabled ? 0.86 : 0.35);
    final backgroundColor = selected
        ? palette.primaryButtons.withValues(alpha: 0.18)
        : Colors.transparent;

    return Material(
      key: ValueKey('recipes-category-chip-${category.id}'),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? () => onCategoryToggled(category.id) : null,
        borderRadius: borderRadius,
        mouseCursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                selected ? Icons.check_rounded : category.icon,
                size: 17,
                color: accentColor,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  '${category.title} ${category.recipesCount}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle?.copyWith(color: foregroundColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChipSeed {
  const _CategoryChipSeed(this.category, this.baseWidth);

  final CategoryModel category;
  final double baseWidth;
}

class _CategoryChipLayout {
  const _CategoryChipLayout({required this.category, required this.width});

  final CategoryModel category;
  final double width;
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
  const _RecipesGrid({
    required this.recipes,
    required this.topPadding,
    required this.bottomPadding,
  });

  final List<RecipeModel> recipes;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ResponsiveSliverGrid<RecipeModel>(
      items: recipes,
      minItemWidth: 240,
      maxColumns: 4,
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      itemHeightBuilder: _recipeCardHeight,
      itemBuilder: (context, recipe) {
        return RecipeCard(
          key: ValueKey('recipes-card-${recipe.id}'),
          recipe: recipe,
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRouter.recipeDetailsPath(recipe.id),
              arguments: recipe,
            );
          },
        );
      },
    );
  }
}

double _recipeCardHeight(double width, int columns) {
  if (columns == 1 || width < 280) {
    return 350;
  }

  return 364;
}

class _RecipesContentSliver extends StatelessWidget {
  const _RecipesContentSliver({
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

class _RecipePagination extends StatelessWidget {
  const _RecipePagination({
    required this.currentPage,
    required this.pageCount,
    required this.onPageChanged,
  });

  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final pages = _visiblePages;

    return Center(
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _PaginationIconButton(
            icon: Icons.chevron_left_rounded,
            enabled: currentPage > 1,
            onPressed: () => onPageChanged(currentPage - 1),
          ),
          for (var index = 0; index < pages.length; index++) ...[
            if (index > 0 && pages[index] - pages[index - 1] > 1)
              const _PaginationGap(),
            _PaginationPageButton(
              page: pages[index],
              selected: pages[index] == currentPage,
              onPressed: () => onPageChanged(pages[index]),
            ),
          ],
          _PaginationIconButton(
            icon: Icons.chevron_right_rounded,
            enabled: currentPage < pageCount,
            onPressed: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }

  List<int> get _visiblePages {
    if (pageCount <= 7) {
      return [for (var page = 1; page <= pageCount; page++) page];
    }

    final pages = <int>{1, pageCount};
    for (var page = currentPage - 1; page <= currentPage + 1; page++) {
      if (page > 1 && page < pageCount) {
        pages.add(page);
      }
    }

    return pages.toList()..sort();
  }
}

class _PaginationPageButton extends StatelessWidget {
  const _PaginationPageButton({
    required this.page,
    required this.selected,
    required this.onPressed,
  });

  final int page;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final child = Text('$page', overflow: TextOverflow.ellipsis);

    if (selected) {
      return SizedBox.square(
        dimension: 42,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox.square(
      dimension: 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _PaginationIconButton extends StatelessWidget {
  const _PaginationIconButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 42,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),
    );
  }
}

class _PaginationGap extends StatelessWidget {
  const _PaginationGap();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 42,
      child: Center(
        child: Text('...', style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
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
