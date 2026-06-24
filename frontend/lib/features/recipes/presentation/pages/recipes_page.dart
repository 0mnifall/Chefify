import 'dart:async';

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

class _SearchTagToken {
  const _SearchTagToken({required this.id, required this.label});

  final String id;
  final String label;
}

class _SearchAuthorToken {
  const _SearchAuthorToken({required this.id, required this.name});

  final String id;
  final String name;
}

enum _RecipeSearchSuggestionType { recipe, tag, author }

class _RecipeSearchSuggestion {
  const _RecipeSearchSuggestion({
    required this.type,
    required this.label,
    required this.value,
    this.trailingLabel,
  });

  final _RecipeSearchSuggestionType type;
  final String label;
  final String value;
  final String? trailingLabel;
}

class RecipesPage extends StatefulWidget {
  const RecipesPage({
    super.key,
    this.recipeRepository = const ApiRecipeRepository(),
    this.initialCategoryIds = const [],
    this.initialTagIds = const [],
    this.initialAuthorIds = const [],
    this.initialQuery,
  });

  final RecipeRepository recipeRepository;
  final List<String> initialCategoryIds;
  final List<String> initialTagIds;
  final List<String> initialAuthorIds;
  final String? initialQuery;

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
  Set<String> _selectedTagIds = const {};
  Set<String> _selectedAuthorIds = const {};
  _TimeFilter _timeFilter = _TimeFilter.any;
  _RecipeSort _sort = _RecipeSort.featured;
  bool _savedOnly = false;
  List<RecipeModel> _recipes = RecipeCatalog.items;
  late _RecipeQueryIndex _recipeIndex;
  _RecipeFilterCacheKey? _visibleRecipesCacheKey;
  List<RecipeModel> _visibleRecipesCache = const [];
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _recipeIndex = _RecipeQueryIndex(_recipes);
    _selectedCategoryIds = _normalizedInitialCategoryIds(
      widget.initialCategoryIds,
    );
    _selectedTagIds = _normalizedTagIds(widget.initialTagIds);
    _selectedAuthorIds = _normalizedAuthorIds(widget.initialAuthorIds);
    _query = widget.initialQuery?.trim() ?? '';
    _searchController.text = _query;
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
      _currentPage = 1;
    }
    if (!_sameNormalizedIds(oldWidget.initialTagIds, widget.initialTagIds)) {
      _selectedTagIds = _normalizedTagIds(widget.initialTagIds);
      _currentPage = 1;
    }
    if (!_sameNormalizedIds(
      oldWidget.initialAuthorIds,
      widget.initialAuthorIds,
    )) {
      _selectedAuthorIds = _normalizedAuthorIds(widget.initialAuthorIds);
      _currentPage = 1;
    }
    if (oldWidget.initialQuery != widget.initialQuery) {
      _query = widget.initialQuery?.trim() ?? '';
      _searchController.text = _query;
      _currentPage = 1;
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
    if (!mounted || _sameRecipeLists(_recipes, recipes)) {
      return;
    }

    setState(() {
      _replaceRecipes(recipes);
    });
  }

  void _replaceRecipes(List<RecipeModel> recipes) {
    _recipes = recipes;
    _recipeIndex = _RecipeQueryIndex(recipes);
    _visibleRecipesCacheKey = null;
    _visibleRecipesCache = const [];
    _currentPage = 1;
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
    final categories = _recipeIndex.categories;

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
              scrollCacheExtent: const ScrollCacheExtent.pixels(160),
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
                        selectedTags: _recipeIndex.selectedTagTokens(
                          _selectedTagIds,
                        ),
                        selectedAuthors: _recipeIndex.selectedAuthorTokens(
                          _selectedAuthorIds,
                        ),
                        timeFilter: _timeFilter,
                        sort: _sort,
                        savedOnly: _savedOnly,
                        categories: categories,
                        recipeIndex: _recipeIndex,
                        onSearchChanged: (value) {
                          setState(() {
                            _query = value;
                            _currentPage = 1;
                          });
                        },
                        onClearSearch: _clearSearchFilters,
                        onTagSelected: _selectTag,
                        onTagRemoved: _removeSelectedTag,
                        onAuthorSelected: _selectAuthor,
                        onAuthorRemoved: _removeSelectedAuthor,
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
    final cacheKey = _RecipeFilterCacheKey(
      query: _query,
      selectedCategoryIds: _selectedCategoryIds,
      selectedTagIds: _selectedTagIds,
      selectedAuthorIds: _selectedAuthorIds,
      timeFilter: _timeFilter,
      sort: _sort,
      savedOnly: _savedOnly,
      bookmarkVersion: _savedOnly ? bookmarkStore.version : 0,
    );

    if (_visibleRecipesCacheKey == cacheKey) {
      return _visibleRecipesCache;
    }

    final recipes = _recipeIndex.visibleRecipes(
      query: _query,
      selectedCategoryIds: _selectedCategoryIds,
      selectedTagIds: _selectedTagIds,
      selectedAuthorIds: _selectedAuthorIds,
      timeFilter: _timeFilter,
      sort: _sort,
      savedOnly: _savedOnly,
      isRecipeSaved: bookmarkStore.isRecipeSaved,
    );

    _visibleRecipesCacheKey = cacheKey;
    _visibleRecipesCache = recipes;
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

  Set<String> _normalizedTagIds(Iterable<String> tagIds) {
    return tagIds.map(_tagId).where((tagId) => tagId.isNotEmpty).toSet();
  }

  Set<String> _normalizedAuthorIds(Iterable<String> authorIds) {
    return authorIds
        .map(_authorId)
        .where((authorId) => authorId.isNotEmpty)
        .toSet();
  }

  bool _sameNormalizedIds(Iterable<String> left, Iterable<String> right) {
    final normalizedLeft = left.map(_tagId).toSet();
    final normalizedRight = right.map(_tagId).toSet();
    return normalizedLeft.length == normalizedRight.length &&
        normalizedLeft.containsAll(normalizedRight);
  }

  void _removeSelectedTag(String tagId) {
    setState(() {
      _selectedTagIds = {..._selectedTagIds}..remove(tagId);
      _currentPage = 1;
    });
  }

  void _selectTag(String tag) {
    final tagId = _tagId(tag);
    if (tagId.isEmpty || _selectedTagIds.contains(tagId)) {
      return;
    }

    _searchController.clear();
    setState(() {
      _query = '';
      _selectedTagIds = {..._selectedTagIds, tagId};
      _currentPage = 1;
    });
  }

  void _selectAuthor(String author) {
    final authorId = _authorId(author);
    if (authorId.isEmpty || _selectedAuthorIds.contains(authorId)) {
      return;
    }

    _searchController.clear();
    setState(() {
      _query = '';
      _selectedAuthorIds = {..._selectedAuthorIds, authorId};
      _currentPage = 1;
    });
  }

  void _removeSelectedAuthor(String authorId) {
    setState(() {
      _selectedAuthorIds = {..._selectedAuthorIds}..remove(authorId);
      _currentPage = 1;
    });
  }

  void _clearSearchFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedTagIds = const {};
      _selectedAuthorIds = const {};
      _currentPage = 1;
    });
  }

  String _tagId(String tag) {
    return CategoryCatalog.slug(tag);
  }

  String _authorId(String author) {
    return CategoryCatalog.slug(author);
  }
}

class _RecipeFilterCacheKey {
  _RecipeFilterCacheKey({
    required String query,
    required Set<String> selectedCategoryIds,
    required Set<String> selectedTagIds,
    required Set<String> selectedAuthorIds,
    required this.timeFilter,
    required this.sort,
    required this.savedOnly,
    required this.bookmarkVersion,
  }) : query = query.trim().toLowerCase(),
       categoryKey = _setKey(selectedCategoryIds),
       tagKey = _setKey(selectedTagIds),
       authorKey = _setKey(selectedAuthorIds);

  final String query;
  final String categoryKey;
  final String tagKey;
  final String authorKey;
  final _TimeFilter timeFilter;
  final _RecipeSort sort;
  final bool savedOnly;
  final int bookmarkVersion;

  @override
  bool operator ==(Object other) {
    return other is _RecipeFilterCacheKey &&
        query == other.query &&
        categoryKey == other.categoryKey &&
        tagKey == other.tagKey &&
        authorKey == other.authorKey &&
        timeFilter == other.timeFilter &&
        sort == other.sort &&
        savedOnly == other.savedOnly &&
        bookmarkVersion == other.bookmarkVersion;
  }

  @override
  int get hashCode {
    return Object.hash(
      query,
      categoryKey,
      tagKey,
      authorKey,
      timeFilter,
      sort,
      savedOnly,
      bookmarkVersion,
    );
  }

  static String _setKey(Set<String> values) {
    if (values.isEmpty) {
      return '';
    }

    return (values.toList()..sort()).join('|');
  }
}

class _RecipeQueryIndex {
  _RecipeQueryIndex(List<RecipeModel> recipes)
    : entries = _buildEntries(recipes),
      categories = _buildCategories(recipes),
      _tagSuggestions = _buildTagSuggestions(recipes),
      _authorSuggestions = _buildAuthorSuggestions(recipes),
      _tagLabelsById = _buildTagLabels(recipes),
      _authorNamesById = _buildAuthorNames(recipes);

  final List<_RecipeIndexEntry> entries;
  final List<CategoryModel> categories;
  final List<_TagSuggestionEntry> _tagSuggestions;
  final List<_AuthorSuggestionEntry> _authorSuggestions;
  final Map<String, String> _tagLabelsById;
  final Map<String, String> _authorNamesById;

  List<RecipeModel> visibleRecipes({
    required String query,
    required Set<String> selectedCategoryIds,
    required Set<String> selectedTagIds,
    required Set<String> selectedAuthorIds,
    required _TimeFilter timeFilter,
    required _RecipeSort sort,
    required bool savedOnly,
    required bool Function(RecipeModel recipe) isRecipeSaved,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final normalizedSlugQuery = CategoryCatalog.slug(normalizedQuery);
    final matches = <_RecipeIndexEntry>[];

    for (final entry in entries) {
      if (!_matchesSearch(entry, normalizedQuery, normalizedSlugQuery)) {
        continue;
      }
      if (selectedCategoryIds.isNotEmpty &&
          !selectedCategoryIds.any(entry.categoryIds.contains)) {
        continue;
      }
      if (selectedTagIds.isNotEmpty &&
          !selectedTagIds.every(entry.tagIds.contains)) {
        continue;
      }
      if (selectedAuthorIds.isNotEmpty &&
          !selectedAuthorIds.contains(entry.authorId)) {
        continue;
      }
      if (!_matchesTime(entry.recipe, timeFilter)) {
        continue;
      }
      if (savedOnly && !isRecipeSaved(entry.recipe)) {
        continue;
      }

      matches.add(entry);
    }

    matches.sort((left, right) {
      return switch (sort) {
        _RecipeSort.featured => left.sourceIndex.compareTo(right.sourceIndex),
        _RecipeSort.rating => right.recipe.rating.compareTo(left.recipe.rating),
        _RecipeSort.quickest => left.recipe.minutes.compareTo(
          right.recipe.minutes,
        ),
        _RecipeSort.title => left.recipe.title.compareTo(right.recipe.title),
      };
    });

    return [for (final entry in matches) entry.recipe];
  }

  List<_SearchTagToken> selectedTagTokens(Set<String> selectedTagIds) {
    return [
      for (final tagId in selectedTagIds)
        _SearchTagToken(
          id: tagId,
          label: _tagLabelsById[tagId] ?? _readableSearchLabel(tagId),
        ),
    ];
  }

  List<_SearchAuthorToken> selectedAuthorTokens(Set<String> selectedAuthorIds) {
    return [
      for (final authorId in selectedAuthorIds)
        _SearchAuthorToken(
          id: authorId,
          name: _authorNamesById[authorId] ?? _readableSearchLabel(authorId),
        ),
    ];
  }

  List<_RecipeSearchSuggestion> suggestions({
    required String query,
    required Set<String> selectedTagIds,
    required Set<String> selectedAuthorIds,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final slugQuery = CategoryCatalog.slug(query);
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    return [
      ..._matchingTagSuggestions(
        normalizedQuery: normalizedQuery,
        slugQuery: slugQuery,
        selectedTagIds: selectedTagIds,
      ),
      ..._matchingAuthorSuggestions(
        normalizedQuery: normalizedQuery,
        slugQuery: slugQuery,
        selectedAuthorIds: selectedAuthorIds,
      ),
      ..._matchingRecipeSuggestions(
        normalizedQuery: normalizedQuery,
        slugQuery: slugQuery,
      ),
    ].take(8).toList(growable: false);
  }

  List<_RecipeSearchSuggestion> _matchingRecipeSuggestions({
    required String normalizedQuery,
    required String slugQuery,
  }) {
    final matches = <_RecipeIndexEntry>[];
    final seenRecipeIds = <String>{};

    for (final entry in entries) {
      final matchesTitle =
          entry.titleLower.contains(normalizedQuery) ||
          (slugQuery.isNotEmpty && entry.titleSlug.contains(slugQuery));
      if (!matchesTitle || !seenRecipeIds.add(entry.recipe.id)) {
        continue;
      }

      matches.add(entry);
    }

    matches.sort((left, right) {
      final rating = right.recipe.rating.compareTo(left.recipe.rating);
      if (rating != 0) {
        return rating;
      }
      return left.recipe.title.compareTo(right.recipe.title);
    });

    return [
      for (final entry in matches)
        _RecipeSearchSuggestion(
          type: _RecipeSearchSuggestionType.recipe,
          label: entry.recipe.title,
          value: entry.recipe.title,
        ),
    ];
  }

  List<_RecipeSearchSuggestion> _matchingTagSuggestions({
    required String normalizedQuery,
    required String slugQuery,
    required Set<String> selectedTagIds,
  }) {
    final matches =
        [
          for (final tag in _tagSuggestions)
            if (!selectedTagIds.contains(tag.id) &&
                (tag.labelLower.contains(normalizedQuery) ||
                    tag.id.contains(slugQuery)))
              tag,
        ]..sort((left, right) {
          final count = right.count.compareTo(left.count);
          if (count != 0) {
            return count;
          }
          return left.label.compareTo(right.label);
        });

    return [
      for (final tag in matches)
        _RecipeSearchSuggestion(
          type: _RecipeSearchSuggestionType.tag,
          label: tag.label,
          value: tag.id,
          trailingLabel: 'tag',
        ),
    ];
  }

  List<_RecipeSearchSuggestion> _matchingAuthorSuggestions({
    required String normalizedQuery,
    required String slugQuery,
    required Set<String> selectedAuthorIds,
  }) {
    final matches =
        [
          for (final author in _authorSuggestions)
            if (!selectedAuthorIds.contains(author.id) &&
                (author.nameLower.contains(normalizedQuery) ||
                    author.id.contains(slugQuery)))
              author,
        ]..sort((left, right) {
          final count = right.count.compareTo(left.count);
          if (count != 0) {
            return count;
          }
          return left.name.compareTo(right.name);
        });

    return [
      for (final author in matches)
        _RecipeSearchSuggestion(
          type: _RecipeSearchSuggestionType.author,
          label: author.name,
          value: author.id,
          trailingLabel: 'user',
        ),
    ];
  }

  static bool _matchesSearch(
    _RecipeIndexEntry entry,
    String normalizedQuery,
    String normalizedSlugQuery,
  ) {
    return normalizedQuery.isEmpty ||
        entry.searchText.contains(normalizedQuery) ||
        (normalizedSlugQuery.isNotEmpty &&
            entry.searchSlug.contains(normalizedSlugQuery));
  }

  static bool _matchesTime(RecipeModel recipe, _TimeFilter timeFilter) {
    return switch (timeFilter) {
      _TimeFilter.any => true,
      _TimeFilter.under20 => recipe.minutes <= 20,
      _TimeFilter.under30 => recipe.minutes <= 30,
      _TimeFilter.over30 => recipe.minutes > 30,
    };
  }

  static List<_RecipeIndexEntry> _buildEntries(List<RecipeModel> recipes) {
    return [
      for (var index = 0; index < recipes.length; index++)
        _RecipeIndexEntry(recipe: recipes[index], sourceIndex: index),
    ];
  }

  static List<CategoryModel> _buildCategories(List<RecipeModel> recipes) {
    final countsByCategoryId = <String, int>{
      for (final category in CategoryCatalog.items) category.id: 0,
    };

    for (final recipe in recipes) {
      for (final categoryId in _categoryIdsForRecipe(recipe)) {
        countsByCategoryId[categoryId] =
            (countsByCategoryId[categoryId] ?? 0) + 1;
      }
    }

    return [
      for (final category in CategoryCatalog.items)
        category.copyWith(recipesCount: countsByCategoryId[category.id] ?? 0),
    ];
  }

  static Map<String, String> _buildTagLabels(List<RecipeModel> recipes) {
    final labelsById = <String, String>{};
    for (final recipe in recipes) {
      for (final tag in recipe.tags) {
        final tagId = CategoryCatalog.slug(tag);
        if (tagId.isEmpty) {
          continue;
        }
        labelsById.putIfAbsent(tagId, () => _readableSearchLabel(tag));
      }
    }
    return labelsById;
  }

  static Map<String, String> _buildAuthorNames(List<RecipeModel> recipes) {
    final namesById = <String, String>{};
    for (final recipe in recipes) {
      final authorId = CategoryCatalog.slug(recipe.author);
      if (authorId.isEmpty) {
        continue;
      }
      namesById.putIfAbsent(authorId, () => recipe.author);
    }
    return namesById;
  }

  static List<_TagSuggestionEntry> _buildTagSuggestions(
    List<RecipeModel> recipes,
  ) {
    final countsById = <String, int>{};
    final labelsById = <String, String>{};

    for (final recipe in recipes) {
      for (final tag in recipe.tags) {
        final tagId = CategoryCatalog.slug(tag);
        if (tagId.isEmpty) {
          continue;
        }
        labelsById.putIfAbsent(tagId, () => _readableSearchLabel(tag));
        countsById[tagId] = (countsById[tagId] ?? 0) + 1;
      }
    }

    return [
      for (final tagId in countsById.keys)
        _TagSuggestionEntry(
          id: tagId,
          label: labelsById[tagId]!,
          count: countsById[tagId]!,
        ),
    ];
  }

  static List<_AuthorSuggestionEntry> _buildAuthorSuggestions(
    List<RecipeModel> recipes,
  ) {
    final countsById = <String, int>{};
    final namesById = <String, String>{};

    for (final recipe in recipes) {
      final authorId = CategoryCatalog.slug(recipe.author);
      if (authorId.isEmpty) {
        continue;
      }
      namesById.putIfAbsent(authorId, () => recipe.author);
      countsById[authorId] = (countsById[authorId] ?? 0) + 1;
    }

    return [
      for (final authorId in countsById.keys)
        _AuthorSuggestionEntry(
          id: authorId,
          name: namesById[authorId]!,
          count: countsById[authorId]!,
        ),
    ];
  }

  static Set<String> _categoryIdsForRecipe(RecipeModel recipe) {
    final categoryIds = <String>{};
    for (final category in CategoryCatalog.items) {
      if (CategoryCatalog.recipeMatchesCategory(recipe, category)) {
        categoryIds.add(category.id);
      }
    }
    return categoryIds;
  }
}

class _RecipeIndexEntry {
  _RecipeIndexEntry({required this.recipe, required this.sourceIndex})
    : titleLower = recipe.title.toLowerCase(),
      titleSlug = CategoryCatalog.slug(recipe.title),
      authorId = CategoryCatalog.slug(recipe.author),
      categoryIds = _RecipeQueryIndex._categoryIdsForRecipe(recipe),
      tagIds = {
        for (final tag in recipe.tags)
          if (CategoryCatalog.slug(tag).isNotEmpty) CategoryCatalog.slug(tag),
      },
      searchText = _searchTextFor(recipe),
      searchSlug = CategoryCatalog.slug(_searchTextFor(recipe));

  final RecipeModel recipe;
  final int sourceIndex;
  final String titleLower;
  final String titleSlug;
  final String authorId;
  final Set<String> categoryIds;
  final Set<String> tagIds;
  final String searchText;
  final String searchSlug;

  static String _searchTextFor(RecipeModel recipe) {
    final category = CategoryCatalog.findById(recipe.categoryId);
    final tagText = recipe.tags.expand(
      (tag) => [tag.toLowerCase(), _readableSearchLabel(tag).toLowerCase()],
    );

    return [
      recipe.title.toLowerCase(),
      recipe.categoryName.toLowerCase(),
      recipe.author.toLowerCase(),
      if (category != null) category.title.toLowerCase(),
      ...tagText,
    ].join(' ');
  }
}

class _TagSuggestionEntry {
  _TagSuggestionEntry({
    required this.id,
    required this.label,
    required this.count,
  }) : labelLower = label.toLowerCase();

  final String id;
  final String label;
  final String labelLower;
  final int count;
}

class _AuthorSuggestionEntry {
  _AuthorSuggestionEntry({
    required this.id,
    required this.name,
    required this.count,
  }) : nameLower = name.toLowerCase();

  final String id;
  final String name;
  final String nameLower;
  final int count;
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
    required this.selectedTags,
    required this.selectedAuthors,
    required this.timeFilter,
    required this.sort,
    required this.savedOnly,
    required this.categories,
    required this.recipeIndex,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onTagSelected,
    required this.onTagRemoved,
    required this.onAuthorSelected,
    required this.onAuthorRemoved,
    required this.onCategoryToggled,
    required this.onClearCategories,
    required this.onTimeFilterChanged,
    required this.onSortChanged,
    required this.onSavedOnlyChanged,
  });

  final TextEditingController searchController;
  final Set<String> selectedCategoryIds;
  final List<_SearchTagToken> selectedTags;
  final List<_SearchAuthorToken> selectedAuthors;
  final _TimeFilter timeFilter;
  final _RecipeSort sort;
  final bool savedOnly;
  final List<CategoryModel> categories;
  final _RecipeQueryIndex recipeIndex;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onTagSelected;
  final ValueChanged<String> onTagRemoved;
  final ValueChanged<String> onAuthorSelected;
  final ValueChanged<String> onAuthorRemoved;
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
          final search = _RecipeSearchBox(
            controller: searchController,
            selectedTags: selectedTags,
            selectedAuthors: selectedAuthors,
            recipeIndex: recipeIndex,
            onChanged: onSearchChanged,
            onClearSearch: onClearSearch,
            onTagSelected: onTagSelected,
            onTagRemoved: onTagRemoved,
            onAuthorSelected: onAuthorSelected,
            onAuthorRemoved: onAuthorRemoved,
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

class _RecipeSearchBox extends StatefulWidget {
  const _RecipeSearchBox({
    required this.controller,
    required this.selectedTags,
    required this.selectedAuthors,
    required this.recipeIndex,
    required this.onChanged,
    required this.onClearSearch,
    required this.onTagSelected,
    required this.onTagRemoved,
    required this.onAuthorSelected,
    required this.onAuthorRemoved,
  });

  final TextEditingController controller;
  final List<_SearchTagToken> selectedTags;
  final List<_SearchAuthorToken> selectedAuthors;
  final _RecipeQueryIndex recipeIndex;
  final ValueChanged<String> onChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onTagSelected;
  final ValueChanged<String> onTagRemoved;
  final ValueChanged<String> onAuthorSelected;
  final ValueChanged<String> onAuthorRemoved;

  @override
  State<_RecipeSearchBox> createState() => _RecipeSearchBoxState();
}

class _RecipeSearchBoxState extends State<_RecipeSearchBox> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _chipsScrollController = ScrollController();
  final LayerLink _suggestionsLayerLink = LayerLink();
  final GlobalKey _searchBoxKey = GlobalKey();
  OverlayEntry? _suggestionsOverlay;
  Timer? _changeDebounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant _RecipeSearchBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncSuggestionsOverlay();
      }
    });
  }

  @override
  void dispose() {
    _changeDebounce?.cancel();
    _removeSuggestionsOverlay();
    widget.controller.removeListener(_handleControllerChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    _chipsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final focused = _focusNode.hasFocus;
    final hasQuery = widget.controller.text.trim().isNotEmpty;
    final hasActiveSearch =
        hasQuery ||
        widget.selectedTags.isNotEmpty ||
        widget.selectedAuthors.isNotEmpty;
    final borderColor = focused ? palette.activeElements : palette.borders;

    return LayoutBuilder(
      builder: (context, constraints) {
        final inputWidth = (constraints.maxWidth * 0.48)
            .clamp(160.0, 360.0)
            .toDouble();

        return CompositedTransformTarget(
          link: _suggestionsLayerLink,
          child: GestureDetector(
            key: _searchBoxKey,
            behavior: HitTestBehavior.opaque,
            onTap: () => _focusNode.requestFocus(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: palette.searchBarBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 21, color: palette.icons),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        controller: _chipsScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final author in widget.selectedAuthors) ...[
                              _AuthorSearchTokenChip(
                                author: author,
                                onRemoved: widget.onAuthorRemoved,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                            for (final tag in widget.selectedTags) ...[
                              _TagSearchTokenChip(
                                tag: tag,
                                onRemoved: widget.onTagRemoved,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                            SizedBox(
                              width: inputWidth,
                              child: TextField(
                                key: const ValueKey('recipes-search-field'),
                                focusNode: _focusNode,
                                controller: widget.controller,
                                onChanged: _handleSearchChanged,
                                textInputAction: TextInputAction.search,
                                style: Theme.of(context).textTheme.bodyMedium,
                                decoration: InputDecoration(
                                  hintText:
                                      widget.selectedAuthors.isEmpty &&
                                          widget.selectedTags.isEmpty
                                      ? 'Search recipes'
                                      : '',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (hasActiveSearch)
                    IconButton(
                      tooltip: 'Clear search',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleFocusChanged() {
    setState(() {});
    _syncSuggestionsOverlay();
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
    _syncSuggestionsOverlay();
  }

  void _handleSearchChanged(String value) {
    _changeDebounce?.cancel();
    _changeDebounce = Timer(const Duration(milliseconds: 120), () {
      if (mounted) {
        widget.onChanged(value);
      }
    });
  }

  void _clearSearch() {
    _changeDebounce?.cancel();
    widget.onClearSearch();
  }

  void _syncSuggestionsOverlay() {
    if (!_focusNode.hasFocus || _suggestions().isEmpty) {
      _removeSuggestionsOverlay();
      return;
    }

    _showSuggestionsOverlay();
  }

  void _showSuggestionsOverlay() {
    if (_suggestionsOverlay != null) {
      _suggestionsOverlay!.markNeedsBuild();
      return;
    }

    _suggestionsOverlay = OverlayEntry(
      builder: (overlayContext) {
        final suggestions = _focusNode.hasFocus
            ? _suggestions()
            : const <_RecipeSearchSuggestion>[];
        if (suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        return CompositedTransformFollower(
          link: _suggestionsLayerLink,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, AppSpacing.xs),
          showWhenUnlinked: false,
          child: Material(
            type: MaterialType.transparency,
            child: Align(
              alignment: Alignment.topLeft,
              widthFactor: 1,
              heightFactor: 1,
              child: SizedBox(
                width: _searchBoxWidth(),
                child: _RecipeSearchSuggestionsPanel(
                  suggestions: suggestions,
                  onSelected: _selectSuggestion,
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_suggestionsOverlay!);
  }

  void _removeSuggestionsOverlay() {
    _suggestionsOverlay?.remove();
    _suggestionsOverlay = null;
  }

  double _searchBoxWidth() {
    final renderObject = _searchBoxKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.size.width;
    }

    return 320;
  }

  List<_RecipeSearchSuggestion> _suggestions() {
    return widget.recipeIndex.suggestions(
      query: widget.controller.text,
      selectedTagIds: {for (final tag in widget.selectedTags) tag.id},
      selectedAuthorIds: {
        for (final author in widget.selectedAuthors) author.id,
      },
    );
  }

  void _selectSuggestion(_RecipeSearchSuggestion suggestion) {
    _changeDebounce?.cancel();
    _removeSuggestionsOverlay();

    switch (suggestion.type) {
      case _RecipeSearchSuggestionType.recipe:
        widget.controller.value = TextEditingValue(
          text: suggestion.value,
          selection: TextSelection.collapsed(offset: suggestion.value.length),
        );
        widget.onChanged(suggestion.value);
      case _RecipeSearchSuggestionType.tag:
        widget.onTagSelected(suggestion.value);
      case _RecipeSearchSuggestionType.author:
        widget.onAuthorSelected(suggestion.value);
    }

    _focusNode.requestFocus();
  }
}

class _RecipeSearchSuggestionsPanel extends StatelessWidget {
  const _RecipeSearchSuggestionsPanel({
    required this.suggestions,
    required this.onSelected,
  });

  final List<_RecipeSearchSuggestion> suggestions;
  final ValueChanged<_RecipeSearchSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 292),
      child: Container(
        decoration: BoxDecoration(
          color: palette.cardsSurface.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: palette.borders.withValues(alpha: 0.76)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < suggestions.length; index++)
                _RecipeSearchSuggestionTile(
                  suggestion: suggestions[index],
                  showDivider: index < suggestions.length - 1,
                  onSelected: onSelected,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeSearchSuggestionTile extends StatelessWidget {
  const _RecipeSearchSuggestionTile({
    required this.suggestion,
    required this.showDivider,
    required this.onSelected,
  });

  final _RecipeSearchSuggestion suggestion;
  final bool showDivider;
  final ValueChanged<_RecipeSearchSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final trailingLabel = suggestion.trailingLabel;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: showDivider
              ? BorderSide(color: palette.borders.withValues(alpha: 0.42))
              : BorderSide.none,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey(
            'recipe-search-suggestion-${suggestion.type.name}-${CategoryCatalog.slug(suggestion.value)}',
          ),
          onTapDown: (_) => onSelected(suggestion),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    suggestion.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (trailingLabel != null && trailingLabel.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _SuggestionTypeBadge(label: trailingLabel),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionTypeBadge extends StatelessWidget {
  const _SuggestionTypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: palette.primaryButtons.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: palette.primaryButtons.withValues(alpha: 0.24),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: palette.primaryButtons,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TagSearchTokenChip extends StatelessWidget {
  const _TagSearchTokenChip({required this.tag, required this.onRemoved});

  final _SearchTagToken tag;
  final ValueChanged<String> onRemoved;

  @override
  Widget build(BuildContext context) {
    return _SearchTokenShell(
      key: ValueKey('recipe-search-tag-token-${tag.id}'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag.label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(width: AppSpacing.xxs),
          _SearchTokenRemoveButton(onPressed: () => onRemoved(tag.id)),
        ],
      ),
    );
  }
}

class _AuthorSearchTokenChip extends StatelessWidget {
  const _AuthorSearchTokenChip({required this.author, required this.onRemoved});

  final _SearchAuthorToken author;
  final ValueChanged<String> onRemoved;

  @override
  Widget build(BuildContext context) {
    return _SearchTokenShell(
      key: ValueKey('recipe-search-author-token-${author.id}'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SearchAuthorAvatar(authorName: author.name),
          const SizedBox(width: AppSpacing.xs),
          Text(author.name, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(width: AppSpacing.xxs),
          _SearchTokenRemoveButton(onPressed: () => onRemoved(author.id)),
        ],
      ),
    );
  }
}

class _SearchTokenShell extends StatelessWidget {
  const _SearchTokenShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: 34,
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: palette.cardsSurface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borders.withValues(alpha: 0.84)),
      ),
      child: Center(child: child),
    );
  }
}

class _SearchTokenRemoveButton extends StatelessWidget {
  const _SearchTokenRemoveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
      child: IconButton(
        tooltip: 'Remove filter',
        onPressed: onPressed,
        icon: const Icon(Icons.close_rounded, size: 15),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _SearchAuthorAvatar extends StatelessWidget {
  const _SearchAuthorAvatar({required this.authorName});

  final String authorName;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.primaryButtons.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(
          color: palette.primaryButtons.withValues(alpha: 0.32),
        ),
      ),
      child: Text(
        _initials(authorName),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: palette.primaryButtons,
          fontWeight: FontWeight.w800,
        ),
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

String _initials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);

  if (words.isEmpty) {
    return '?';
  }

  if (words.length == 1) {
    return words.first[0].toUpperCase();
  }

  return '${words.first[0]}${words.last[0]}'.toUpperCase();
}

String _readableSearchLabel(String value) {
  final words = value
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
