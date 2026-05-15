import 'package:flutter/material.dart';

class CategoryModel {
  const CategoryModel({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class RecipeModel {
  const RecipeModel({
    required this.title,
    required this.tag,
    required this.author,
    required this.minutes,
    required this.rating,
    required this.accentColor,
  });

  final String title;
  final String tag;
  final String author;
  final int minutes;
  final double rating;
  final Color accentColor;
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
