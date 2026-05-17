import 'package:flutter/material.dart';

enum AppLanguage { en, uk, es }

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
    AppLanguage.en => 'en',
    AppLanguage.uk => 'uk',
    AppLanguage.es => 'es',
  };

  String get label => switch (this) {
    AppLanguage.en => 'English',
    AppLanguage.uk => 'Українська',
    AppLanguage.es => 'Español',
  };
}

class AppSettingsController extends ChangeNotifier {
  AppSettingsController({
    ThemeMode initialThemeMode = ThemeMode.dark,
    AppLanguage initialLanguage = AppLanguage.en,
  }) : _themeMode = initialThemeMode,
       _language = initialLanguage;

  ThemeMode _themeMode;
  AppLanguage _language;

  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;

  void setThemeMode(ThemeMode themeMode) {
    if (themeMode != ThemeMode.light && themeMode != ThemeMode.dark) {
      return;
    }
    if (_themeMode == themeMode) {
      return;
    }
    _themeMode = themeMode;
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    if (_language == language) {
      return;
    }
    _language = language;
    notifyListeners();
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    super.key,
    required AppSettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppSettingsController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope is missing in widget tree.');
    return scope!.notifier!;
  }
}
