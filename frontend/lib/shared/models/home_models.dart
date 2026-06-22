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
    required this.tag,
    required this.author,
    required this.minutes,
    required this.rating,
    required this.accentColor,
    this.description = '',
    this.imageUrl,
    this.categoryIds = const [],
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
    final categoryName = _stringValue(_jsonValue(json, 'categoryName'));
    final tag = _stringValue(
      _jsonValue(json, 'tag') ??
          (categoryName.isEmpty ? null : categoryName) ??
          _firstTag(json),
      fallback: 'Community',
    );

    return RecipeModel(
      id: _stringValue(_jsonValue(json, 'id'), fallback: _slugFromTitle(title)),
      title: title,
      description: _stringValue(_jsonValue(json, 'description')),
      tag: tag,
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
      categoryIds: _categoryIdsValue(json, fallbackTag: tag),
      popularityScore: _intValue(_jsonValue(json, 'popularityScore')),
      accentColor: _colorValue(_jsonValue(json, 'accentColor'), fallback: tag),
    );
  }

  final String id;
  final String title;
  final String tag;
  final String author;
  final int minutes;
  final double rating;
  final Color accentColor;
  final String description;
  final String? imageUrl;
  final List<String> categoryIds;
  final int popularityScore;
  final bool isSaved;

  static Object? _jsonValue(Map<String, dynamic> json, String key) {
    final pascalKey = key[0].toUpperCase() + key.substring(1);
    return json[key] ?? json[pascalKey];
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

  static String? _firstTag(Map<String, dynamic> json) {
    final tags = _jsonValue(json, 'tags');
    if (tags is Iterable) {
      for (final tag in tags) {
        final value = _stringValue(tag);
        if (value.isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }

  static List<String> _categoryIdsValue(
    Map<String, dynamic> json, {
    required String fallbackTag,
  }) {
    final values = <String>{};
    final categoryIds = _jsonValue(json, 'categoryIds');

    if (categoryIds is Iterable) {
      for (final categoryId in categoryIds) {
        final value = _stringValue(categoryId);
        if (value.isNotEmpty) {
          values.add(_slugFromTitle(value));
        }
      }
    }

    for (final key in ['categoryId', 'categoryName', 'category']) {
      final value = _stringValue(_jsonValue(json, key));
      if (value.isNotEmpty) {
        values.add(_slugFromTitle(value));
      }
    }

    if (values.isEmpty && fallbackTag.isNotEmpty) {
      values.add(_slugFromTitle(fallbackTag));
    }

    return values.toList(growable: false);
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
