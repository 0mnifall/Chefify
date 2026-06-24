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

  CategoryModel copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    int? recipesCount,
    String? imageUrl,
    bool? isSaved,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      recipesCount: recipesCount ?? this.recipesCount,
      imageUrl: imageUrl ?? this.imageUrl,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class RecipeModel {
  const RecipeModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.author,
    required this.minutes,
    required this.rating,
    required this.accentColor,
    this.description = '',
    this.imageUrl,
    this.tags = const [],
    this.popularityScore = 0,
    this.isSaved = false,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final title = _stringValue(
      _jsonValue(json, 'title'),
      fallback: 'Untitled recipe',
    );
    final difficulty = _intValue(_jsonValue(json, 'difficulty'), fallback: 2);
    final normalizedDifficulty = difficulty.clamp(1, 5).toDouble();
    final categoryName = _categoryNameValue(json);
    final categoryId = _categoryIdValue(
      json,
      fallbackCategoryName: categoryName,
    );

    return RecipeModel(
      id: _stringValue(_jsonValue(json, 'id'), fallback: _slugFromTitle(title)),
      title: title,
      description: _stringValue(_jsonValue(json, 'description')),
      categoryId: categoryId,
      categoryName: categoryName,
      author: _authorValue(json),
      minutes: _intValue(
        _jsonValue(json, 'cookingTime') ?? _jsonValue(json, 'minutes'),
        fallback: 30,
      ),
      rating: _doubleValue(
        _jsonValue(json, 'rating'),
        fallback: 4.2 + (normalizedDifficulty * 0.12),
      ).clamp(0, 5).toDouble(),
      imageUrl: _stringValue(
        _jsonValue(json, 'imageUrl') ??
            _jsonValue(json, 'photoUrl') ??
            _jsonValue(json, 'pictureUrl'),
      ),
      tags: _tagsValue(json, categoryName: categoryName),
      popularityScore: _intValue(_jsonValue(json, 'popularityScore')),
      accentColor: _colorValue(
        _jsonValue(json, 'accentColor'),
        fallback: categoryName,
      ),
    );
  }

  final String id;
  final String title;
  final String categoryId;
  final String categoryName;
  final String author;
  final int minutes;
  final double rating;
  final Color accentColor;
  final String description;
  final String? imageUrl;
  final List<String> tags;
  final int popularityScore;
  final bool isSaved;

  String get tag => categoryName;

  static Object? _jsonValue(Map<String, dynamic> json, String key) {
    final pascalKey = key[0].toUpperCase() + key.substring(1);
    return json[key] ?? json[pascalKey];
  }

  static String _categoryNameValue(Map<String, dynamic> json) {
    final category = _jsonValue(json, 'category');
    if (category is Map) {
      final name = _stringValue(category['name'] ?? category['Name']);
      if (name.isNotEmpty) {
        return name;
      }
    }

    return _stringValue(
      _jsonValue(json, 'categoryName') ?? _jsonValue(json, 'tag'),
      fallback: 'Community',
    );
  }

  static String _categoryIdValue(
    Map<String, dynamic> json, {
    required String fallbackCategoryName,
  }) {
    final category = _jsonValue(json, 'category');
    if (category is Map) {
      final name = _stringValue(category['name'] ?? category['Name']);
      if (name.isNotEmpty) {
        return _slugFromTitle(name);
      }

      final id = _stringValue(category['id'] ?? category['Id']);
      if (id.isNotEmpty) {
        return id;
      }
    }

    final categoryName = _stringValue(_jsonValue(json, 'categoryName'));
    if (categoryName.isNotEmpty) {
      return _slugFromTitle(categoryName);
    }

    final categoryId = _stringValue(_jsonValue(json, 'categoryId'));
    if (categoryId.isNotEmpty) {
      return _slugFromTitle(categoryId);
    }

    return _slugFromTitle(fallbackCategoryName);
  }

  static List<String> _tagsValue(
    Map<String, dynamic> json, {
    required String categoryName,
  }) {
    final values = <String>[];
    final categorySlug = _slugFromTitle(categoryName);
    final tags = _jsonValue(json, 'tags');

    if (tags is String) {
      for (final tag in tags.split(',')) {
        _addTag(values, tag, categorySlug: categorySlug);
      }
    } else if (tags is Iterable) {
      for (final tag in tags) {
        _addTag(values, tag, categorySlug: categorySlug);
      }
    }

    return values.toList(growable: false);
  }

  static String _stringValue(Object? value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }

    final stringValue = value.toString().trim();
    return stringValue.isEmpty ? fallback : stringValue;
  }

  static int _intValue(Object? value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _doubleValue(Object? value, {double fallback = 0}) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static void _addTag(
    List<String> values,
    Object? tag, {
    required String categorySlug,
  }) {
    final value = _stringValue(tag);
    if (value.isEmpty) {
      return;
    }

    if (_slugFromTitle(value) == categorySlug) {
      return;
    }

    if (!values.contains(value)) {
      values.add(value);
    }
  }

  static String _authorValue(Map<String, dynamic> json) {
    final creator = _jsonValue(json, 'creator');
    if (creator is Map) {
      final username = _stringValue(creator['username'] ?? creator['Username']);
      if (username.isNotEmpty) {
        return username;
      }
    }

    return _stringValue(
      _jsonValue(json, 'creatorUsername') ??
          _jsonValue(json, 'author') ??
          creator,
      fallback: 'Chefify Kitchen',
    );
  }

  static Color _colorValue(Object? value, {required String fallback}) {
    final colorText = value?.toString().trim();
    if (colorText != null && colorText.isNotEmpty) {
      final normalized = colorText.replaceFirst('#', '');
      final parsed = int.tryParse(normalized, radix: 16);

      if (parsed != null) {
        return Color(0xFF000000 | parsed);
      }
    }

    final palette = [
      const Color(0xFF5F7C67),
      const Color(0xFFED7A3A),
      const Color(0xFF5E8B7E),
      const Color(0xFFB1784A),
      const Color(0xFFC89B3C),
      const Color(0xFF4F8E6B),
      const Color(0xFF9B5D45),
      const Color(0xFF7A4E68),
    ];
    return palette[fallback.hashCode.abs() % palette.length];
  }

  static String _slugFromTitle(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
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
