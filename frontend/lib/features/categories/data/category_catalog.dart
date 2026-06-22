import 'package:flutter/material.dart';
import 'package:frontend/shared/models/home_models.dart';

class CategoryCatalog {
  CategoryCatalog._();

  static const List<CategoryModel> items = [
    CategoryModel(
      id: 'quick-meals',
      title: 'Quick Meals',
      description: 'Fast dinners and lunches that stay practical on busy days.',
      icon: Icons.flash_on_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'plant-based',
      title: 'Plant-Based',
      description: 'Vegetable-forward bowls, curries, noodles, and mains.',
      icon: Icons.eco_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1514996937319-344454492b37?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'comfort-classics',
      title: 'Comfort Classics',
      description: 'Cozy family-style favorites with a modern Chefify twist.',
      icon: Icons.restaurant_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1523986371872-9d3ba2e2f642?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'desserts',
      title: 'Desserts',
      description: 'Cakes, tarts, cookies, and sweet finishes for any table.',
      icon: Icons.cake_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'healthy',
      title: 'Healthy',
      description: 'Balanced recipes with bright produce and smart macros.',
      icon: Icons.monitor_heart_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'italian',
      title: 'Italian',
      description: 'Pasta, tomato-rich mains, herbs, and rustic sauces.',
      icon: Icons.local_pizza_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'japanese',
      title: 'Japanese',
      description: 'Miso, rice bowls, clean broths, noodles, and glazed fish.',
      icon: Icons.rice_bowl_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'breakfast',
      title: 'Breakfast',
      description: 'Morning plates, skillets, pancakes, and quick starts.',
      icon: Icons.free_breakfast_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'seafood',
      title: 'Seafood',
      description: 'Fish, shrimp, citrus marinades, and lighter coastal meals.',
      icon: Icons.set_meal_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1559847844-5315695dadae?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'salads',
      title: 'Salads',
      description: 'Crisp greens, grains, dressings, and buildable bowls.',
      icon: Icons.spa_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'soups',
      title: 'Soups',
      description: 'Brothy, creamy, and hearty pots for slow evenings.',
      icon: Icons.soup_kitchen_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'grill',
      title: 'Grill',
      description: 'Charred proteins, vegetables, marinades, and smoke.',
      icon: Icons.outdoor_grill_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1558030006-450675393462?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'weeknight',
      title: 'Weeknight',
      description: 'Reliable recipes for repeat cooking after work.',
      icon: Icons.nightlight_round,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'pasta',
      title: 'Pasta',
      description: 'Noodles, baked pasta, creamy sauces, and tomato classics.',
      icon: Icons.dinner_dining_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'chicken',
      title: 'Chicken',
      description: 'Roasts, skillets, grills, soups, and meal-prep staples.',
      icon: Icons.lunch_dining_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'vegetarian',
      title: 'Vegetarian',
      description: 'Meat-free recipes with grains, dairy, legumes, and greens.',
      icon: Icons.grass_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'vegan',
      title: 'Vegan',
      description: 'Fully plant-based recipes with satisfying texture.',
      icon: Icons.energy_savings_leaf_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1514996937319-344454492b37?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'low-carb',
      title: 'Low-Carb',
      description: 'Lower-carb dinners, breakfasts, and protein-heavy plates.',
      icon: Icons.fitness_center_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1605478371310-a9f1e96b4ff4?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'high-protein',
      title: 'High-Protein',
      description: 'Meals built around lean proteins, legumes, and grains.',
      icon: Icons.local_fire_department_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1558030006-450675393462?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'brunch',
      title: 'Brunch',
      description: 'Late-morning plates, baked goods, and relaxed hosting.',
      icon: Icons.brunch_dining_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'snacks',
      title: 'Snacks',
      description: 'Small bites, dips, party plates, and afternoon fixes.',
      icon: Icons.tapas_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'baking',
      title: 'Baking',
      description: 'Oven projects from breads and tarts to cookies and cakes.',
      icon: Icons.bakery_dining_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1488477304112-4944851de03d?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'mexican',
      title: 'Mexican',
      description: 'Tacos, bowls, salsas, beans, citrus, and chili heat.',
      icon: Icons.local_dining_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'mediterranean',
      title: 'Mediterranean',
      description: 'Olive oil, herbs, grains, seafood, yogurt, and vegetables.',
      icon: Icons.wb_sunny_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'indian',
      title: 'Indian',
      description: 'Curries, dals, spices, rice dishes, and warming sauces.',
      icon: Icons.ramen_dining_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'asian-fusion',
      title: 'Asian Fusion',
      description: 'Noodles, rice bowls, glazed proteins, and pantry sauces.',
      icon: Icons.rice_bowl_outlined,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'meal-prep',
      title: 'Meal Prep',
      description: 'Batch-friendly recipes that reheat and travel well.',
      icon: Icons.inventory_2_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'budget-friendly',
      title: 'Budget-Friendly',
      description: 'Low-cost recipes built with smart staples.',
      icon: Icons.savings_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'family-style',
      title: 'Family Style',
      description: 'Large-format mains and sides for sharing around the table.',
      icon: Icons.groups_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1523986371872-9d3ba2e2f642?auto=format&fit=crop&w=900&q=80',
    ),
    CategoryModel(
      id: 'spicy',
      title: 'Spicy',
      description: 'Chili-forward recipes with heat, acid, and big aromatics.',
      icon: Icons.whatshot_rounded,
      recipesCount: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=900&q=80',
    ),
  ];

  static List<CategoryModel> withRecipeCounts(List<RecipeModel> recipes) {
    return [
      for (final category in items)
        category.copyWith(recipesCount: _recipesFor(category, recipes).length),
    ];
  }

  static List<CategoryModel> popularForRecipes(
    List<RecipeModel> recipes, {
    int take = 4,
  }) {
    final ranked = [
      for (final category in items)
        _CategoryRanking(
          category: category,
          recipes: _recipesFor(category, recipes),
        ),
    ]..removeWhere((ranking) => ranking.recipes.isEmpty);

    ranked.sort((left, right) {
      final rating = right.averageRating.compareTo(left.averageRating);
      if (rating != 0) {
        return rating;
      }

      final count = right.recipes.length.compareTo(left.recipes.length);
      if (count != 0) {
        return count;
      }

      return left.category.title.compareTo(right.category.title);
    });

    final safeTake = ranked.isEmpty ? 0 : take.clamp(1, ranked.length).toInt();
    return ranked
        .take(safeTake)
        .map(
          (ranking) =>
              ranking.category.copyWith(recipesCount: ranking.recipes.length),
        )
        .toList(growable: false);
  }

  static CategoryModel? findById(String categoryId) {
    final normalizedId = slug(categoryId);
    for (final category in items) {
      if (category.id == normalizedId) {
        return category;
      }
    }
    return null;
  }

  static bool recipeMatchesCategoryId(RecipeModel recipe, String categoryId) {
    final category = findById(categoryId);
    if (category == null) {
      return false;
    }

    return recipeMatchesCategory(recipe, category);
  }

  static bool recipeMatchesCategory(
    RecipeModel recipe,
    CategoryModel category,
  ) {
    final recipeCategoryIds = recipe.categoryIds.map(slug).toSet();
    if (recipeCategoryIds.contains(category.id)) {
      return true;
    }

    final normalizedTag = slug(recipe.tag);
    return normalizedTag == category.id ||
        normalizedTag == slug(category.title);
  }

  static String slug(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  static List<RecipeModel> _recipesFor(
    CategoryModel category,
    List<RecipeModel> recipes,
  ) {
    return recipes
        .where((recipe) => recipeMatchesCategory(recipe, category))
        .toList(growable: false);
  }
}

class _CategoryRanking {
  const _CategoryRanking({required this.category, required this.recipes});

  final CategoryModel category;
  final List<RecipeModel> recipes;

  double get averageRating {
    final total = recipes.fold<double>(0, (sum, recipe) => sum + recipe.rating);
    return total / recipes.length;
  }
}
