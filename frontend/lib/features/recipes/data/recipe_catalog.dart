import 'package:flutter/material.dart';
import 'package:frontend/features/categories/data/category_catalog.dart';
import 'package:frontend/shared/models/home_models.dart';

class RecipeCatalog {
  RecipeCatalog._();

  static final List<RecipeModel> items = [..._curatedItems, ..._generatedItems];

  static const List<RecipeModel> _curatedItems = [
    RecipeModel(
      id: 'citrus-herb-chicken-quinoa',
      title: 'Citrus Herb Chicken with Warm Quinoa',
      tag: 'Healthy',
      author: 'Chef Luna',
      minutes: 40,
      rating: 4.9,
      accentColor: Color(0xFF5F7C67),
      imageUrl:
          'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=900&q=80',
      categoryIds: [
        'healthy',
        'chicken',
        'high-protein',
        'meal-prep',
        'weeknight',
      ],
    ),
    RecipeModel(
      id: 'roasted-tomato-pasta',
      title: 'Roasted Tomato Pasta',
      tag: 'Italian',
      author: 'Chef Aria',
      minutes: 25,
      rating: 4.8,
      accentColor: Color(0xFFED7A3A),
      imageUrl:
          'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=900&q=80',
      categoryIds: [
        'italian',
        'pasta',
        'vegetarian',
        'comfort-classics',
        'weeknight',
      ],
    ),
    RecipeModel(
      id: 'miso-glazed-salmon',
      title: 'Miso Glazed Salmon',
      tag: 'Japanese',
      author: 'Chef Kaito',
      minutes: 35,
      rating: 4.9,
      accentColor: Color(0xFF5E8B7E),
      imageUrl:
          'https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=900&q=80',
      categoryIds: ['japanese', 'seafood', 'high-protein', 'asian-fusion'],
    ),
    RecipeModel(
      id: 'spiced-chickpea-bowl',
      title: 'Spiced Chickpea Bowl',
      tag: 'Healthy',
      author: 'Chef Noor',
      minutes: 20,
      rating: 4.7,
      accentColor: Color(0xFFB1784A),
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80',
      categoryIds: [
        'healthy',
        'salads',
        'vegetarian',
        'plant-based',
        'vegan',
        'budget-friendly',
      ],
    ),
    RecipeModel(
      id: 'lemon-ricotta-pancakes',
      title: 'Lemon Ricotta Pancakes',
      tag: 'Breakfast',
      author: 'Chef Mila',
      minutes: 18,
      rating: 4.6,
      accentColor: Color(0xFFC89B3C),
      imageUrl:
          'https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=900&q=80',
      categoryIds: ['breakfast', 'brunch', 'desserts', 'baking'],
    ),
    RecipeModel(
      id: 'crispy-tofu-rice-bowl',
      title: 'Crispy Tofu Rice Bowl',
      tag: 'Plant-Based',
      author: 'Chef Emi',
      minutes: 28,
      rating: 4.8,
      accentColor: Color(0xFF4F8E6B),
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=900&q=80',
      categoryIds: [
        'plant-based',
        'vegan',
        'asian-fusion',
        'quick-meals',
        'meal-prep',
      ],
    ),
    RecipeModel(
      id: 'garlic-butter-steak-bites',
      title: 'Garlic Butter Steak Bites',
      tag: 'Comfort',
      author: 'Chef Mateo',
      minutes: 22,
      rating: 4.7,
      accentColor: Color(0xFF9B5D45),
      imageUrl:
          'https://images.unsplash.com/photo-1558030006-450675393462?auto=format&fit=crop&w=900&q=80',
      categoryIds: ['comfort-classics', 'grill', 'high-protein', 'quick-meals'],
    ),
    RecipeModel(
      id: 'green-shakshuka-skillet',
      title: 'Green Shakshuka Skillet',
      tag: 'Breakfast',
      author: 'Chef Sara',
      minutes: 32,
      rating: 4.5,
      accentColor: Color(0xFF6F8F4E),
      imageUrl:
          'https://images.unsplash.com/photo-1605478371310-a9f1e96b4ff4?auto=format&fit=crop&w=900&q=80',
      categoryIds: [
        'breakfast',
        'brunch',
        'vegetarian',
        'mediterranean',
        'low-carb',
      ],
    ),
    RecipeModel(
      id: 'coconut-lentil-curry',
      title: 'Coconut Lentil Curry',
      tag: 'Plant-Based',
      author: 'Chef Anika',
      minutes: 38,
      rating: 4.8,
      accentColor: Color(0xFFD28245),
      imageUrl:
          'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=900&q=80',
      categoryIds: ['plant-based', 'vegan', 'indian', 'soups', 'spicy'],
    ),
    RecipeModel(
      id: 'sesame-ginger-noodles',
      title: 'Sesame Ginger Noodles',
      tag: 'Quick Meals',
      author: 'Chef Jin',
      minutes: 16,
      rating: 4.6,
      accentColor: Color(0xFFB36B59),
      imageUrl:
          'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?auto=format&fit=crop&w=900&q=80',
      categoryIds: ['quick-meals', 'asian-fusion', 'pasta', 'budget-friendly'],
    ),
    RecipeModel(
      id: 'herbed-turkey-meatballs',
      title: 'Herbed Turkey Meatballs',
      tag: 'Healthy',
      author: 'Chef Sofia',
      minutes: 30,
      rating: 4.7,
      accentColor: Color(0xFF86734E),
      imageUrl:
          'https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=900&q=80',
      categoryIds: ['healthy', 'high-protein', 'comfort-classics', 'meal-prep'],
    ),
    RecipeModel(
      id: 'dark-chocolate-berry-tart',
      title: 'Dark Chocolate Berry Tart',
      tag: 'Dessert',
      author: 'Chef Elise',
      minutes: 55,
      rating: 4.9,
      accentColor: Color(0xFF7A4E68),
      imageUrl:
          'https://images.unsplash.com/photo-1488477304112-4944851de03d?auto=format&fit=crop&w=900&q=80',
      categoryIds: ['desserts', 'baking', 'brunch', 'snacks'],
    ),
  ];

  static final List<RecipeModel> _generatedItems = _buildGeneratedItems();

  static const Map<String, List<String>> _generatedTitles = {
    'quick-meals': [
      'Ginger Lime Noodle Skillet',
      'Crispy Chicken Rice Wraps',
      'Ten-Minute Chili Bean Toasts',
    ],
    'plant-based': [
      'Roasted Cauliflower Tahini Bowl',
      'Green Lentil Garden Curry',
      'Smoky Eggplant Grain Plate',
    ],
    'comfort-classics': [
      'Brown Butter Mushroom Bake',
      'Creamy Chicken Pot Pie Skillet',
      'Sunday Tomato Meatball Casserole',
    ],
    'desserts': [
      'Salted Honey Cheesecake Cups',
      'Vanilla Pear Crumble Bars',
      'Espresso Chocolate Pudding',
    ],
    'healthy': [
      'Cucumber Herb Salmon Plate',
      'Quinoa Crunch Power Bowl',
      'Turkey Avocado Lettuce Cups',
    ],
    'italian': [
      'Tuscan White Bean Rigatoni',
      'Sicilian Lemon Chicken Pasta',
      'Basil Pesto Tomato Gnocchi',
    ],
    'japanese': [
      'Shoyu Mushroom Rice Bowl',
      'Teriyaki Tofu Bento Plate',
      'Sesame Miso Soba Salad',
    ],
    'breakfast': [
      'Maple Oat Breakfast Bake',
      'Soft Egg Breakfast Tacos',
      'Blueberry Yogurt Pancake Stack',
    ],
    'seafood': [
      'Garlic Shrimp Couscous',
      'Citrus Cod Sheet Pan',
      'Chili Lime Salmon Tostadas',
    ],
    'salads': [
      'Crunchy Market Chopped Salad',
      'Warm Farro Beet Salad',
      'Herby Chickpea Cucumber Salad',
    ],
    'soups': [
      'Golden Carrot Ginger Soup',
      'Chicken Orzo Lemon Soup',
      'Smoky Black Bean Soup',
    ],
    'grill': [
      'Charred Pepper Steak Skewers',
      'Grilled Halloumi Veggie Plates',
      'Honey Mustard Chicken Grill',
    ],
    'weeknight': [
      'One-Pan Tomato Chicken Rice',
      'Weeknight Peanut Noodles',
      'Sheet Pan Sausage Vegetables',
    ],
    'pasta': [
      'Creamy Spinach Shells',
      'Roasted Garlic Broccoli Linguine',
      'Spicy Tomato Bucatini',
    ],
    'chicken': [
      'Lemon Pepper Chicken Cutlets',
      'Paprika Yogurt Chicken Bowls',
      'Coconut Chicken Soup',
    ],
    'vegetarian': [
      'Mushroom Walnut Lettuce Cups',
      'Crispy Feta Vegetable Bake',
      'Herbed Zucchini Rice Cakes',
    ],
    'vegan': [
      'Coconut Chickpea Stew',
      'Miso Sweet Potato Bowls',
      'Sesame Broccoli Rice Plates',
    ],
    'low-carb': [
      'Garlic Herb Cauliflower Steaks',
      'Salmon Cucumber Crunch Bowls',
      'Chicken Pesto Zucchini Boats',
    ],
    'high-protein': [
      'Steak Chimichurri Meal Bowl',
      'Turkey Cottage Cheese Flatbread',
      'Miso Salmon Protein Plate',
    ],
    'brunch': [
      'Savory Dutch Baby with Herbs',
      'Smoked Salmon Potato Waffles',
      'Strawberry Ricotta French Toast',
    ],
    'snacks': [
      'Whipped Feta Chili Crunch Dip',
      'Crispy Parmesan Chickpeas',
      'Mini Turkey Lettuce Bites',
    ],
    'baking': [
      'Rosemary Sea Salt Focaccia',
      'Brown Sugar Banana Loaf',
      'Lemon Poppy Seed Muffins',
    ],
    'mexican': [
      'Chipotle Sweet Potato Tacos',
      'Chicken Verde Rice Bowls',
      'Black Bean Breakfast Quesadilla',
    ],
    'mediterranean': [
      'Greek Lemon Chicken Tray',
      'Herbed Couscous Halloumi Bowls',
      'Tomato Olive Fish Bake',
    ],
    'indian': [
      'Butter Chickpea Masala',
      'Tandoori Chicken Rice Plates',
      'Spinach Lentil Dal Bowls',
    ],
    'asian-fusion': [
      'Korean BBQ Mushroom Tacos',
      'Thai Basil Turkey Bowls',
      'Peanut Chili Crunch Noodles',
    ],
    'meal-prep': [
      'Sesame Chicken Prep Boxes',
      'Roasted Veggie Lentil Packs',
      'Turkey Meatball Grain Bowls',
    ],
    'budget-friendly': [
      'Pantry Tomato Chickpea Pasta',
      'Cabbage Egg Fried Rice',
      'Bean Potato Taco Skillet',
    ],
    'family-style': [
      'Big Table Baked Ziti',
      'Roast Chicken Vegetable Platter',
      'Loaded Taco Rice Casserole',
    ],
    'spicy': [
      'Harissa Chicken Couscous',
      'Firecracker Tofu Rice Bowls',
      'Spicy Coconut Ramen Pot',
    ],
  };

  static const Map<String, List<String>> _secondaryCategoryIds = {
    'quick-meals': ['weeknight', 'budget-friendly'],
    'plant-based': ['vegan', 'healthy'],
    'comfort-classics': ['family-style', 'weeknight'],
    'desserts': ['baking', 'brunch'],
    'healthy': ['meal-prep', 'high-protein'],
    'italian': ['pasta', 'comfort-classics'],
    'japanese': ['asian-fusion', 'seafood'],
    'breakfast': ['brunch', 'budget-friendly'],
    'seafood': ['healthy', 'mediterranean'],
    'salads': ['healthy', 'vegetarian'],
    'soups': ['comfort-classics', 'budget-friendly'],
    'grill': ['high-protein', 'family-style'],
    'weeknight': ['quick-meals', 'meal-prep'],
    'pasta': ['italian', 'weeknight'],
    'chicken': ['high-protein', 'weeknight'],
    'vegetarian': ['healthy', 'plant-based'],
    'vegan': ['plant-based', 'budget-friendly'],
    'low-carb': ['healthy', 'high-protein'],
    'high-protein': ['meal-prep', 'healthy'],
    'brunch': ['breakfast', 'baking'],
    'snacks': ['budget-friendly', 'family-style'],
    'baking': ['desserts', 'brunch'],
    'mexican': ['spicy', 'family-style'],
    'mediterranean': ['seafood', 'healthy'],
    'indian': ['spicy', 'plant-based'],
    'asian-fusion': ['quick-meals', 'spicy'],
    'meal-prep': ['healthy', 'budget-friendly'],
    'budget-friendly': ['quick-meals', 'vegetarian'],
    'family-style': ['comfort-classics', 'grill'],
    'spicy': ['indian', 'mexican'],
  };

  static const List<String> _authors = [
    'Chef Aria',
    'Chef Kaito',
    'Chef Luna',
    'Chef Noor',
    'Chef Mateo',
    'Chef Sofia',
    'Chef Emi',
    'Chef Elise',
  ];

  static const List<Color> _accentColors = [
    Color(0xFF5F7C67),
    Color(0xFFED7A3A),
    Color(0xFF5E8B7E),
    Color(0xFFB1784A),
    Color(0xFFC89B3C),
    Color(0xFF4F8E6B),
    Color(0xFF9B5D45),
    Color(0xFF7A4E68),
  ];

  static List<RecipeModel> _buildGeneratedItems() {
    final recipes = <RecipeModel>[];
    for (
      var categoryIndex = 0;
      categoryIndex < CategoryCatalog.items.length;
      categoryIndex++
    ) {
      final category = CategoryCatalog.items[categoryIndex];
      final titles = _generatedTitles[category.id] ?? const <String>[];

      for (var variantIndex = 0; variantIndex < 3; variantIndex++) {
        recipes.add(
          RecipeModel(
            id: 'mock-${category.id}-${variantIndex + 1}',
            title: titles.length > variantIndex
                ? titles[variantIndex]
                : '${category.title} Recipe ${variantIndex + 1}',
            tag: category.title,
            author: _authors[(categoryIndex + variantIndex) % _authors.length],
            minutes: _minutesFor(category.id, categoryIndex, variantIndex),
            rating: _ratingFor(categoryIndex, variantIndex),
            accentColor:
                _accentColors[(categoryIndex + variantIndex) %
                    _accentColors.length],
            description: category.description,
            imageUrl: category.imageUrl,
            categoryIds: _categoryIdsFor(category.id),
            popularityScore: 1600 - (categoryIndex * 14) - (variantIndex * 3),
          ),
        );
      }
    }

    return List.unmodifiable(recipes);
  }

  static List<String> _categoryIdsFor(String categoryId) {
    final categoryIds = <String>{categoryId};
    categoryIds.addAll(_secondaryCategoryIds[categoryId] ?? const []);
    return categoryIds.toList(growable: false);
  }

  static int _minutesFor(
    String categoryId,
    int categoryIndex,
    int variantIndex,
  ) {
    final quickCategories = {'quick-meals', 'weeknight', 'snacks'};
    final slowCategories = {'baking', 'desserts', 'family-style'};

    if (quickCategories.contains(categoryId)) {
      return 16 + (variantIndex * 5);
    }

    if (slowCategories.contains(categoryId)) {
      return 38 + (variantIndex * 9);
    }

    return 22 + (((categoryIndex + variantIndex) % 5) * 7);
  }

  static double _ratingFor(int categoryIndex, int variantIndex) {
    final raw = 4.1 + (((categoryIndex * 5) + (variantIndex * 2)) % 9) / 10;
    return double.parse(raw.toStringAsFixed(1));
  }

  static List<RecipeModel> popular({int take = 4}) {
    final recipes = [...items];
    recipes.sort((left, right) {
      final popularity = right.popularityScore.compareTo(left.popularityScore);
      if (popularity != 0) {
        return popularity;
      }

      final rating = right.rating.compareTo(left.rating);
      if (rating != 0) {
        return rating;
      }

      return items.indexOf(left).compareTo(items.indexOf(right));
    });

    final safeTake = take.clamp(1, recipes.length).toInt();
    return recipes.take(safeTake).toList();
  }
}
