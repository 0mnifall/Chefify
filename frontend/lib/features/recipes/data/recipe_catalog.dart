import 'package:flutter/material.dart';
import 'package:frontend/shared/models/home_models.dart';

class RecipeCatalog {
  RecipeCatalog._();

  static const List<RecipeModel> items = [
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
          'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?auto=format&fit=crop&w=900&q=80',
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
    ),
  ];

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
