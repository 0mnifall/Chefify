import 'package:flutter/material.dart';
import 'package:frontend/features/categories/data/category_catalog.dart';
import 'package:frontend/features/home/domain/home_content.dart';
import 'package:frontend/shared/models/home_models.dart';

class HomeMockData {
  HomeMockData._();

  static const HomeContent content = HomeContent(
    heroTitle: 'Cook with confidence.\nServe with style.',
    heroSubtitle:
        'Chefify helps you discover recipes, manage meal plans, and cook faster without sacrificing flavor.',
    categories: CategoryCatalog.items,
    trendingRecipes: [
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
      id: 'citrus-herb-chicken-quinoa',
      title: 'Citrus Herb Chicken with Warm Quinoa',
      tag: 'Chef Pick',
      author: 'Chef Luna',
      minutes: 40,
      rating: 4.9,
      accentColor: Color(0xFF5F7C67),
      imageUrl:
          'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=900&q=80',
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
