import 'package:flutter/material.dart';
import 'package:frontend/features/home/domain/home_content.dart';
import 'package:frontend/shared/models/home_models.dart';

class HomeMockData {
  HomeMockData._();

  static const HomeContent content = HomeContent(
    heroTitle: 'Cook with confidence.\nServe with style.',
    heroSubtitle:
        'Chefify helps you discover recipes, manage meal plans, and cook faster without sacrificing flavor.',
    categories: [
      CategoryModel(
        title: 'Quick Meals',
        description: '30-minute dishes for busy days.',
        icon: Icons.flash_on_rounded,
        recipesCount: 124,
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1200&q=80',
        isSaved: true,
      ),
      CategoryModel(
        title: 'Plant-Based',
        description: 'Colorful bowls, soups, and mains.',
        icon: Icons.eco_rounded,
        recipesCount: 89,
        imageUrl:
            'https://images.unsplash.com/photo-1514996937319-344454492b37?auto=format&fit=crop&w=1200&q=80',
      ),
      CategoryModel(
        title: 'Comfort Classics',
        description: 'Family favorites with modern twists.',
        icon: Icons.restaurant_rounded,
        recipesCount: 156,
        imageUrl:
            'https://images.unsplash.com/photo-1523986371872-9d3ba2e2f642?auto=format&fit=crop&w=1200&q=80',
      ),
      CategoryModel(
        title: 'Desserts',
        description: 'Sweet ideas for every occasion.',
        icon: Icons.cake_rounded,
        recipesCount: 72,
        imageUrl:
            'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=1200&q=80',
      ),
    ],
    trendingRecipes: [
      RecipeModel(
        title: 'Roasted Tomato Pasta',
        tag: 'Italian',
        author: 'Chef Aria',
        minutes: 25,
        rating: 4.8,
        accentColor: Color(0xFFED7A3A),
      ),
      RecipeModel(
        title: 'Miso Glazed Salmon',
        tag: 'Japanese',
        author: 'Chef Kaito',
        minutes: 35,
        rating: 4.9,
        accentColor: Color(0xFF5E8B7E),
      ),
      RecipeModel(
        title: 'Spiced Chickpea Bowl',
        tag: 'Healthy',
        author: 'Chef Noor',
        minutes: 20,
        rating: 4.7,
        accentColor: Color(0xFFB1784A),
      ),
      RecipeModel(
        title: 'Lemon Ricotta Pancakes',
        tag: 'Breakfast',
        author: 'Chef Mila',
        minutes: 18,
        rating: 4.6,
        accentColor: Color(0xFFC89B3C),
      ),
    ],
    benefits: [
      BenefitModel(
        title: 'Step-by-Step Guidance',
        description:
            'Follow clear cooking steps with timers and ingredient tips.',
        icon: Icons.menu_book_rounded,
      ),
      BenefitModel(
        title: 'Smart Grocery Lists',
        description:
            'Automatically generate and organize shopping lists from recipes.',
        icon: Icons.shopping_basket_rounded,
      ),
      BenefitModel(
        title: 'Nutrition Insights',
        description: 'Track calories and macros for every serving you cook.',
        icon: Icons.monitor_heart_rounded,
      ),
    ],
    featuredRecipe: RecipeModel(
      title: 'Citrus Herb Chicken with Warm Quinoa',
      tag: 'Chef Pick',
      author: 'Chef Luna',
      minutes: 40,
      rating: 4.9,
      accentColor: Color(0xFF5F7C67),
    ),
    stats: [
      StatItemModel(label: 'Active users', value: '120K+'),
      StatItemModel(label: 'Recipes curated', value: '9,300'),
      StatItemModel(label: 'Avg. cook time saved', value: '42 min'),
      StatItemModel(label: '5-star reviews', value: '18K+'),
    ],
    testimonials: [
      TestimonialModel(
        name: 'Sophie Lang',
        role: 'Product Designer',
        message:
            'Chefify turned weeknight cooking from stressful to genuinely fun.',
      ),
      TestimonialModel(
        name: 'Marcus Hill',
        role: 'Fitness Coach',
        message:
            'I plan macros in minutes and still get restaurant-level flavor.',
      ),
      TestimonialModel(
        name: 'Nina Petrova',
        role: 'Founder, Food Studio',
        message:
            'The interface is clean, and the recipes are always practical.',
      ),
    ],
  );
}
