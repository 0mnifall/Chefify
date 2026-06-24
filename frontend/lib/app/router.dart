import 'package:flutter/material.dart';
import 'package:frontend/features/categories/presentation/pages/categories_page.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/features/recipes/presentation/pages/recipe_details_page.dart';
import 'package:frontend/features/recipes/presentation/pages/recipes_page.dart';

class AppRouter {
  static const String home = '/';
  static const String recipes = '/recipes';
  static const String categories = '/categories';

  static String recipeDetailsPath(String recipeId) {
    return '$recipes/${Uri.encodeComponent(recipeId)}';
  }

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    RecipeRepository recipeRepository = const ApiRecipeRepository(),
  }) {
    final routeName = settings.name ?? home;
    final recipeId = _recipeIdFromRoute(routeName);

    if (recipeId != null) {
      final arguments = RecipeDetailsPageArguments.from(
        settings.arguments,
        fallbackRecipeId: recipeId,
      );
      return MaterialPageRoute<void>(
        builder: (_) => RecipeDetailsPage(
          recipeRepository: recipeRepository,
          recipeId: arguments.recipeId,
          initialRecipe: arguments.initialRecipe,
        ),
        settings: settings,
      );
    }

    switch (routeName) {
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => HomePage(recipeRepository: recipeRepository),
          settings: settings,
        );
      case recipes:
        final arguments = RecipesPageArguments.from(settings.arguments);
        return MaterialPageRoute<void>(
          builder: (_) => RecipesPage(
            recipeRepository: recipeRepository,
            initialCategoryIds: arguments.categoryIds,
          ),
          settings: settings,
        );
      case categories:
        return MaterialPageRoute<void>(
          builder: (_) => CategoriesPage(recipeRepository: recipeRepository),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => HomePage(recipeRepository: recipeRepository),
          settings: settings,
        );
    }
  }

  static String? _recipeIdFromRoute(String routeName) {
    const prefix = '$recipes/';
    if (!routeName.startsWith(prefix)) {
      return null;
    }

    final recipeId = routeName.substring(prefix.length).trim();
    if (recipeId.isEmpty) {
      return null;
    }

    return Uri.decodeComponent(recipeId);
  }
}
