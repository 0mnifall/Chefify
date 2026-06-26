import 'package:flutter/material.dart';
import 'package:frontend/features/authors/presentation/pages/author_profile_page.dart';
import 'package:frontend/features/categories/presentation/pages/categories_page.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/features/recipes/domain/recipes_page_arguments.dart';
import 'package:frontend/features/recipes/presentation/pages/recipe_create_page.dart';
import 'package:frontend/features/recipes/presentation/pages/recipe_details_page.dart';
import 'package:frontend/features/recipes/presentation/pages/recipes_page.dart';

class AppRouter {
  static const String home = '/';
  static const String recipes = '/recipes';
  static const String recipeCreate = '/recipes/create';
  static const String categories = '/categories';
  static const String authors = '/authors';

  static String recipeDetailsPath(String recipeId) {
    return '$recipes/${Uri.encodeComponent(recipeId)}';
  }

  static String authorProfilePath(String authorName) {
    return '$authors/${Uri.encodeComponent(_slug(authorName))}';
  }

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    RecipeRepository recipeRepository = const ApiRecipeRepository(),
  }) {
    final routeName = settings.name ?? home;
    final recipeId = routeName == recipeCreate
        ? null
        : _recipeIdFromRoute(routeName);
    final authorSlug = _authorSlugFromRoute(routeName);

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

    if (authorSlug != null) {
      final arguments = AuthorProfilePageArguments.from(
        settings.arguments,
        fallbackAuthorSlug: authorSlug,
      );
      return MaterialPageRoute<void>(
        builder: (_) => AuthorProfilePage(
          recipeRepository: recipeRepository,
          authorSlug: arguments.authorSlug,
          authorName: arguments.authorName,
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
            initialTagIds: arguments.tagIds,
            initialAuthorIds: arguments.authorIds,
            initialQuery: arguments.query,
          ),
          settings: settings,
        );
      case recipeCreate:
        return MaterialPageRoute<void>(
          builder: (_) => const RecipeCreatePage(),
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

  static String? _authorSlugFromRoute(String routeName) {
    const prefix = '$authors/';
    if (!routeName.startsWith(prefix)) {
      return null;
    }

    final authorSlug = routeName.substring(prefix.length).trim();
    if (authorSlug.isEmpty) {
      return null;
    }

    return Uri.decodeComponent(authorSlug);
  }

  static String _slug(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}
