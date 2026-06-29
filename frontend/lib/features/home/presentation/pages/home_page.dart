import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/localization/app_strings.dart';
import 'package:frontend/features/categories/data/category_catalog.dart';
import 'package:frontend/features/home/data/home_mock_data.dart';
import 'package:frontend/features/home/presentation/widgets/app_footer.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/home/presentation/widgets/benefits_section.dart';
import 'package:frontend/features/home/presentation/widgets/category_section.dart';
import 'package:frontend/features/home/presentation/widgets/featured_recipe_section.dart';
import 'package:frontend/features/home/presentation/widgets/hero_section.dart';
import 'package:frontend/features/home/presentation/widgets/mobile_app_promo_section.dart';
import 'package:frontend/features/home/presentation/widgets/newsletter_section.dart';
import 'package:frontend/features/home/presentation/widgets/stats_banner.dart';
import 'package:frontend/features/home/presentation/widgets/testimonials_section.dart';
import 'package:frontend/features/home/presentation/widgets/trending_recipes_section.dart';
import 'package:frontend/features/recipes/data/recipe_catalog.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/shared/models/home_models.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.recipeRepository = const ApiRecipeRepository(),
  });

  final RecipeRepository recipeRepository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<RecipeModel> _trendingRecipes = RecipeCatalog.popular(take: 4);
  List<CategoryModel> _popularCategories = CategoryCatalog.popularForRecipes(
    RecipeCatalog.items,
    take: 4,
  );

  @override
  void initState() {
    super.initState();
    _loadHomeRecipeData();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipeRepository != widget.recipeRepository) {
      _loadHomeRecipeData();
    }
  }

  Future<void> _loadHomeRecipeData() async {
    final recipes = await widget.recipeRepository.fetchRecipes();
    if (!mounted) {
      return;
    }

    final nextTrendingRecipes = _popularRecipesFor(recipes, take: 4);
    final nextPopularCategories = CategoryCatalog.popularForRecipes(
      recipes,
      take: 4,
    );
    if (_sameRecipeList(_trendingRecipes, nextTrendingRecipes) &&
        _sameCategoryList(_popularCategories, nextPopularCategories)) {
      return;
    }

    setState(() {
      _trendingRecipes = nextTrendingRecipes;
      _popularCategories = nextPopularCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = HomeMockData.content;
    final palette = context.palette;
    final strings = AppStrings.of(context);
    final heroRecipe = _trendingRecipes.isEmpty
        ? content.featuredRecipe
        : _trendingRecipes.first;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.pageBackground, palette.cardsSurface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final headerHeight = AppSpacing.headerHeightForViewport(
              constraints.maxWidth,
            );

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: headerHeight),
                      HeroSection(
                        title: strings.heroTitle,
                        subtitle: strings.heroSubtitle,
                        featuredRecipe: heroRecipe,
                      ),
                      CategorySection(categories: _popularCategories),
                      TrendingRecipesSection(recipes: _trendingRecipes),
                      BenefitsSection(benefits: content.benefits),
                      FeaturedRecipeSection(recipe: content.featuredRecipe),
                      StatsBanner(stats: content.stats),
                      TestimonialsSection(testimonials: content.testimonials),
                      const MobileAppPromoSection(),
                      const NewsletterSection(),
                      const AppFooter(),
                    ],
                  ),
                ),
                _StickyHeaderShell(
                  height: headerHeight,
                  child: const AppHeader(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<RecipeModel> _popularRecipesFor(
    List<RecipeModel> recipes, {
    required int take,
  }) {
    final sortedRecipes = [...recipes];
    sortedRecipes.sort((left, right) {
      final rating = right.rating.compareTo(left.rating);
      if (rating != 0) {
        return rating;
      }

      return left.title.compareTo(right.title);
    });

    final safeTake = sortedRecipes.isEmpty
        ? 0
        : take.clamp(1, sortedRecipes.length).toInt();
    return sortedRecipes.take(safeTake).toList(growable: false);
  }
}

bool _sameRecipeList(List<RecipeModel> left, List<RecipeModel> right) {
  if (left.length != right.length) {
    return false;
  }

  for (var index = 0; index < left.length; index++) {
    if (left[index].id != right[index].id ||
        left[index].title != right[index].title ||
        left[index].imageUrl != right[index].imageUrl ||
        left[index].thumbnailUrl != right[index].thumbnailUrl ||
        left[index].rating != right[index].rating ||
        left[index].accentColor != right[index].accentColor ||
        left[index].popularityScore != right[index].popularityScore) {
      return false;
    }
  }
  return true;
}

bool _sameCategoryList(List<CategoryModel> left, List<CategoryModel> right) {
  if (left.length != right.length) {
    return false;
  }

  for (var index = 0; index < left.length; index++) {
    if (left[index].id != right[index].id ||
        left[index].title != right[index].title ||
        left[index].description != right[index].description ||
        left[index].icon != right[index].icon ||
        left[index].recipesCount != right[index].recipesCount ||
        left[index].imageUrl != right[index].imageUrl) {
      return false;
    }
  }
  return true;
}

class _StickyHeaderShell extends StatelessWidget {
  const _StickyHeaderShell({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: palette.navbarBackground.withValues(alpha: 0.84),
              border: Border(
                bottom: BorderSide(
                  color: palette.borders.withValues(alpha: 0.55),
                ),
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
        ),
      ),
    );
  }
}
