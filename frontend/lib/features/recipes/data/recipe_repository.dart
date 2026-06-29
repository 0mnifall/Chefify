import 'dart:async';
import 'dart:convert';

import 'package:frontend/features/recipes/data/recipe_catalog.dart';
import 'package:frontend/shared/models/home_models.dart';
import 'package:http/http.dart' as http;

abstract class RecipeRepository {
  Future<List<RecipeModel>> fetchRecipes();

  Future<List<RecipeModel>> fetchPopularRecipes({int take = 4});

  Future<void> updateRecipeLike({
    required String recipeId,
    required bool isLiked,
  });
}

class ApiRecipeRepository implements RecipeRepository {
  const ApiRecipeRepository({
    this.baseUrl = const String.fromEnvironment(
      'CHEFIFY_API_BASE_URL',
      defaultValue: 'http://localhost:8080/api',
    ),
    this.timeout = const Duration(seconds: 3),
  });

  static List<RecipeModel>? _recipesCache;
  static Future<List<RecipeModel>>? _recipesRequest;

  final String baseUrl;
  final Duration timeout;

  @override
  Future<List<RecipeModel>> fetchRecipes() {
    final cachedRecipes = _recipesCache;
    if (cachedRecipes != null) {
      return Future.value(cachedRecipes);
    }

    final currentRequest = _recipesRequest;
    if (currentRequest != null) {
      return currentRequest;
    }

    final request =
        _fetchRecipes(path: 'Recipes', fallback: RecipeCatalog.items)
            .then((recipes) {
              _recipesCache = recipes;
              return recipes;
            })
            .whenComplete(() {
              _recipesRequest = null;
            });

    _recipesRequest = request;
    return request;
  }

  @override
  Future<List<RecipeModel>> fetchPopularRecipes({int take = 4}) async {
    final recipes = [...await fetchRecipes()];

    recipes.sort((left, right) {
      final rating = right.rating.compareTo(left.rating);
      if (rating != 0) {
        return rating;
      }

      return left.title.compareTo(right.title);
    });

    final safeTake = take.clamp(1, recipes.length).toInt();
    return recipes.take(safeTake).toList();
  }

  @override
  Future<void> updateRecipeLike({
    required String recipeId,
    required bool isLiked,
  }) async {
    try {
      await http
          .post(
            _uri('Recipes/${Uri.encodeComponent(recipeId)}/likes'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'liked': isLiked, 'delta': isLiked ? 1 : -1}),
          )
          .timeout(timeout);
    } on Object {
      // The backend endpoint is not available yet. Keep the optimistic UI stable.
    }
  }

  Future<List<RecipeModel>> _fetchRecipes({
    required String path,
    required List<RecipeModel> fallback,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final response = await http
          .get(_uri(path, queryParameters: queryParameters))
          .timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return fallback;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        return fallback;
      }

      final recipes = decoded
          .whereType<Map<String, dynamic>>()
          .map(RecipeModel.fromJson)
          .toList();

      return recipes.isEmpty ? fallback : recipes;
    } on TimeoutException {
      return fallback;
    } on FormatException {
      return fallback;
    } on http.ClientException {
      return fallback;
    }
  }

  Uri _uri(String path, {Map<String, String>? queryParameters}) {
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return Uri.parse(
      normalizedBaseUrl,
    ).resolve(path).replace(queryParameters: queryParameters);
  }
}

class MockRecipeRepository implements RecipeRepository {
  const MockRecipeRepository();

  @override
  Future<List<RecipeModel>> fetchRecipes() async {
    return RecipeCatalog.items;
  }

  @override
  Future<List<RecipeModel>> fetchPopularRecipes({int take = 4}) async {
    return RecipeCatalog.popular(take: take);
  }

  @override
  Future<void> updateRecipeLike({
    required String recipeId,
    required bool isLiked,
  }) async {}
}
