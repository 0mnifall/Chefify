import 'package:flutter/widgets.dart';
import 'package:frontend/app/app_settings.dart';

class AppStrings {
  const AppStrings._(this.language);

  final AppLanguage language;

  static AppStrings of(BuildContext context) {
    return AppStrings._(AppSettingsScope.of(context).language);
  }

  String _value({required String en, required String uk, required String es}) {
    return switch (language) {
      AppLanguage.en => en,
      AppLanguage.uk => uk,
      AppLanguage.es => es,
    };
  }

  String get recipes => _value(en: 'Recipes', uk: 'Рецепти', es: 'Recetas');
  String get mealPlans =>
      _value(en: 'Meal plans', uk: 'Плани харчування', es: 'Planes');
  String get pricing => _value(en: 'Pricing', uk: 'Ціни', es: 'Precios');
  String get community =>
      _value(en: 'Community', uk: 'Спільнота', es: 'Comunidad');
  String get blog => _value(en: 'Blog', uk: 'Блог', es: 'Blog');
  String get support => _value(en: 'Support', uk: 'Підтримка', es: 'Soporte');
  String get logIn => _value(en: 'Log in', uk: 'Увійти', es: 'Ingresar');
  String get getStarted =>
      _value(en: 'Get started', uk: 'Почати', es: 'Comenzar');

  String get trustedBy => _value(
    en: 'Trusted by 120K+ home cooks',
    uk: 'Нам довіряють 120K+ кухарів',
    es: 'Más de 120K cocineros confían',
  );

  String get heroTitle => _value(
    en: 'Cook with confidence.\nServe with style.',
    uk: 'Готуй впевнено.\nПодавай стильно.',
    es: 'Cocina con confianza.\nSirve con estilo.',
  );

  String get heroSubtitle => _value(
    en: 'Chefify helps you discover recipes, manage meal plans, and cook faster without sacrificing flavor.',
    uk: 'Chefify допомагає відкривати нові рецепти, планувати харчування та готувати швидше без компромісів у смаку.',
    es: 'Chefify te ayuda a descubrir recetas, planificar comidas y cocinar más rápido sin perder sabor.',
  );

  String get startFreeTrial => _value(
    en: 'Start free trial',
    uk: 'Почати безкоштовно',
    es: 'Probar gratis',
  );

  String get browseRecipes => _value(
    en: 'Browse recipes',
    uk: 'Переглянути рецепти',
    es: 'Ver recetas',
  );

  String get recipeOfTheDay =>
      _value(en: 'Recipe of the day', uk: 'Рецепт дня', es: 'Receta del día');

  String get photoPlaceholder => _value(
    en: 'Photo placeholder',
    uk: 'Місце для фото',
    es: 'Espacio para foto',
  );

  String get minutesShort => _value(en: 'min', uk: 'хв', es: 'min');
  String get easy => _value(en: 'Easy', uk: 'Легко', es: 'Fácil');
  String get medium => _value(en: 'Medium', uk: 'Середньо', es: 'Medio');
  String get hard => _value(en: 'Hard', uk: 'Складно', es: 'Difícil');

  String get followUs =>
      _value(en: 'Follow us', uk: 'Ми в соцмережах', es: 'Síguenos');

  String get languageLabel =>
      _value(en: 'Interface language', uk: 'Мова інтерфейсу', es: 'Idioma');

  String get themeLabel => _value(en: 'Theme', uk: 'Тема', es: 'Tema');
  String get lightTheme => _value(en: 'Light', uk: 'Світла', es: 'Claro');
  String get darkTheme => _value(en: 'Dark', uk: 'Темна', es: 'Oscuro');

  String copyright(int year) {
    return _value(
      en: '(c) $year Chefify. All rights reserved.',
      uk: '(c) $year Chefify. Усі права захищені.',
      es: '(c) $year Chefify. Todos los derechos reservados.',
    );
  }
}
