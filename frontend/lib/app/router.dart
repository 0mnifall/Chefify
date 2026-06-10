import 'package:flutter/material.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/recipes/presentation/pages/recipes_page.dart';

class AppRouter {
  static const String home = '/';
  static const String recipes = '/recipes';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case recipes:
        return MaterialPageRoute<void>(
          builder: (_) => const RecipesPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
    }
  }
}
