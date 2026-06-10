import 'package:flutter/material.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.recipesCount,
    this.imageUrl,
    this.isSaved = false,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int recipesCount;
  final String? imageUrl;
  final bool isSaved;
}

class RecipeModel {
  const RecipeModel({
    required this.id,
    required this.title,
    required this.tag,
    required this.author,
    required this.minutes,
    required this.rating,
    required this.accentColor,
    this.isSaved = false,
  });

  final String id;
  final String title;
  final String tag;
  final String author;
  final int minutes;
  final double rating;
  final Color accentColor;
  final bool isSaved;
}

class BenefitModel {
  const BenefitModel({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class TestimonialModel {
  const TestimonialModel({
    required this.name,
    required this.role,
    required this.message,
  });

  final String name;
  final String role;
  final String message;
}

class StatItemModel {
  const StatItemModel({required this.label, required this.value});

  final String label;
  final String value;
}
