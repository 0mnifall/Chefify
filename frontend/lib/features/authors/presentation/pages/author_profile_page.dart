import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/core/widgets/responsive_sliver_grid.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/home/presentation/widgets/recipe_card.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/shared/models/home_models.dart';

class AuthorProfilePageArguments {
  const AuthorProfilePageArguments({required this.authorSlug, this.authorName});

  factory AuthorProfilePageArguments.from(
    Object? arguments, {
    required String fallbackAuthorSlug,
  }) {
    if (arguments is AuthorProfilePageArguments) {
      return arguments;
    }

    if (arguments is String && arguments.trim().isNotEmpty) {
      return AuthorProfilePageArguments(
        authorSlug: _slug(arguments),
        authorName: arguments.trim(),
      );
    }

    return AuthorProfilePageArguments(authorSlug: fallbackAuthorSlug);
  }

  final String authorSlug;
  final String? authorName;
}

class AuthorProfilePage extends StatefulWidget {
  const AuthorProfilePage({
    super.key,
    required this.authorSlug,
    this.authorName,
    this.recipeRepository = const ApiRecipeRepository(),
  });

  final String authorSlug;
  final String? authorName;
  final RecipeRepository recipeRepository;

  @override
  State<AuthorProfilePage> createState() => _AuthorProfilePageState();
}

class _AuthorProfilePageState extends State<AuthorProfilePage> {
  List<RecipeModel> _recipes = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  @override
  void didUpdateWidget(covariant AuthorProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authorSlug != widget.authorSlug ||
        oldWidget.recipeRepository != widget.recipeRepository) {
      _loadRecipes();
    }
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    final recipes = await widget.recipeRepository.fetchRecipes();
    if (!mounted) {
      return;
    }

    setState(() {
      _recipes = recipes
          .where((recipe) => _slug(recipe.author) == widget.authorSlug)
          .toList(growable: false);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);
    final bottomPadding = AppSpacing.sectionGapForWidth(viewportWidth);
    final authorName = _recipes.isNotEmpty
        ? _recipes.first.author
        : widget.authorName ?? _readableAuthorName(widget.authorSlug);

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
                _AuthorContentSliver(
                  topPadding: headerHeight + AppSpacing.xl,
                  child: _AuthorHeader(
                    authorName: authorName,
                    recipeCount: _recipes.length,
                  ),
                ),
                if (_isLoading)
                  _AuthorContentSliver(
                    topPadding: AppSpacing.lg,
                    bottomPadding: bottomPadding,
                    child: const _AuthorLoadingState(),
                  )
                else if (_recipes.isEmpty)
                  _AuthorContentSliver(
                    topPadding: AppSpacing.lg,
                    bottomPadding: bottomPadding,
                    child: _AuthorEmptyState(authorName: authorName),
                  )
                else
                  ResponsiveSliverGrid<RecipeModel>(
                    items: _recipes,
                    minItemWidth: 240,
                    maxColumns: 4,
                    padding: EdgeInsets.only(
                      top: AppSpacing.lg,
                      bottom: bottomPadding,
                    ),
                    itemHeightBuilder: _recipeCardHeight,
                    itemBuilder: (context, recipe) {
                      return RecipeCard(
                        key: ValueKey('author-recipe-card-${recipe.id}'),
                        recipe: recipe,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.recipeDetailsPath(recipe.id),
                            arguments: recipe,
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
            _AuthorHeaderShell(height: headerHeight, child: const AppHeader()),
          ],
        ),
      ),
    );
  }
}

class _AuthorHeader extends StatelessWidget {
  const _AuthorHeader({required this.authorName, required this.recipeCount});

  final String authorName;
  final int recipeCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      key: ValueKey('author-profile-page-${_slug(authorName)}'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          _AuthorAvatar(authorName: authorName, size: 72),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AUTHOR',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: palette.categoryTags,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  authorName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$recipeCount recipes by this author',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({required this.authorName, required this.size});

  final String authorName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.primaryButtons.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: palette.borders.withValues(alpha: 0.82)),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(authorName),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: palette.primaryButtons,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AuthorLoadingState extends StatelessWidget {
  const _AuthorLoadingState();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
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

class _AuthorEmptyState extends StatelessWidget {
  const _AuthorEmptyState({required this.authorName});

  final String authorName;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search_rounded, size: 44, color: palette.icons),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No recipes from $authorName yet',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthorContentSliver extends StatelessWidget {
  const _AuthorContentSliver({
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

class _AuthorHeaderShell extends StatelessWidget {
  const _AuthorHeaderShell({required this.height, required this.child});

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

double _recipeCardHeight(double width, int columns) {
  if (columns == 1 || width < 280) {
    return 350;
  }

  return 364;
}

String _initials(String authorName) {
  final words = authorName
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

String _readableAuthorName(String slug) {
  final words = slug
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);

  return words
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String _slug(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
