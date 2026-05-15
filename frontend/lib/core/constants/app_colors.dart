import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.pageBackground,
    required this.cardsSurface,
    required this.primaryButtons,
    required this.categoryTags,
    required this.mainText,
    required this.secondaryText,
    required this.borders,
    required this.navbarBackground,
    required this.buttonHover,
    required this.searchBarBackground,
    required this.recipeCardBackground,
    required this.activeElements,
    required this.icons,
  });

  final Color pageBackground;
  final Color cardsSurface;
  final Color primaryButtons;
  final Color categoryTags;
  final Color mainText;
  final Color secondaryText;
  final Color borders;
  final Color navbarBackground;
  final Color buttonHover;
  final Color searchBarBackground;
  final Color recipeCardBackground;
  final Color activeElements;
  final Color icons;

  @override
  AppPalette copyWith({
    Color? pageBackground,
    Color? cardsSurface,
    Color? primaryButtons,
    Color? categoryTags,
    Color? mainText,
    Color? secondaryText,
    Color? borders,
    Color? navbarBackground,
    Color? buttonHover,
    Color? searchBarBackground,
    Color? recipeCardBackground,
    Color? activeElements,
    Color? icons,
  }) {
    return AppPalette(
      pageBackground: pageBackground ?? this.pageBackground,
      cardsSurface: cardsSurface ?? this.cardsSurface,
      primaryButtons: primaryButtons ?? this.primaryButtons,
      categoryTags: categoryTags ?? this.categoryTags,
      mainText: mainText ?? this.mainText,
      secondaryText: secondaryText ?? this.secondaryText,
      borders: borders ?? this.borders,
      navbarBackground: navbarBackground ?? this.navbarBackground,
      buttonHover: buttonHover ?? this.buttonHover,
      searchBarBackground: searchBarBackground ?? this.searchBarBackground,
      recipeCardBackground: recipeCardBackground ?? this.recipeCardBackground,
      activeElements: activeElements ?? this.activeElements,
      icons: icons ?? this.icons,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }
    return AppPalette(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      cardsSurface: Color.lerp(cardsSurface, other.cardsSurface, t)!,
      primaryButtons: Color.lerp(primaryButtons, other.primaryButtons, t)!,
      categoryTags: Color.lerp(categoryTags, other.categoryTags, t)!,
      mainText: Color.lerp(mainText, other.mainText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      borders: Color.lerp(borders, other.borders, t)!,
      navbarBackground: Color.lerp(navbarBackground, other.navbarBackground, t)!,
      buttonHover: Color.lerp(buttonHover, other.buttonHover, t)!,
      searchBarBackground:
          Color.lerp(searchBarBackground, other.searchBarBackground, t)!,
      recipeCardBackground:
          Color.lerp(recipeCardBackground, other.recipeCardBackground, t)!,
      activeElements: Color.lerp(activeElements, other.activeElements, t)!,
      icons: Color.lerp(icons, other.icons, t)!,
    );
  }
}

class AppPalettes {
  AppPalettes._();

  static const AppPalette light = AppPalette(
    pageBackground: Color(0xFFF7F3EE),
    cardsSurface: Color(0xFFFFFDF9),
    primaryButtons: Color(0xFFC96B3B),
    categoryTags: Color(0xFF8A9A5B),
    mainText: Color(0xFF2B2623),
    secondaryText: Color(0xFF6E655F),
    borders: Color(0xFFE7DED6),
    navbarBackground: Color(0xFFF1E7DC),
    buttonHover: Color(0xFFD97745),
    searchBarBackground: Color(0xFFEFE4D8),
    recipeCardBackground: Color(0xFFFFFFFF),
    activeElements: Color(0xFFB85C38),
    icons: Color(0xFFA06B4E),
  );

  static const AppPalette dark = AppPalette(
    pageBackground: Color(0xFF1C1816),
    cardsSurface: Color(0xFF2A2421),
    primaryButtons: Color(0xFFE08A57),
    categoryTags: Color(0xFFA7B97A),
    mainText: Color(0xFFF5EEE8),
    secondaryText: Color(0xFFB8ADA4),
    borders: Color(0xFF3A322E),
    navbarBackground: Color(0xFF241F1C),
    buttonHover: Color(0xFFF09A66),
    searchBarBackground: Color(0xFF332C28),
    recipeCardBackground: Color(0xFF2F2926),
    activeElements: Color(0xFFD9784A),
    icons: Color(0xFFC28A68),
  );
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette {
    return Theme.of(this).extension<AppPalette>() ?? AppPalettes.light;
  }
}
