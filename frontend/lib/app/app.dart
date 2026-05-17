import 'package:flutter/material.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';

class ChefifyApp extends StatefulWidget {
  const ChefifyApp({super.key});

  @override
  State<ChefifyApp> createState() => _ChefifyAppState();
}

class _ChefifyAppState extends State<ChefifyApp> {
  late final AppSettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _settingsController = AppSettingsController();
  }

  @override
  void dispose() {
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      controller: _settingsController,
      child: AnimatedBuilder(
        animation: _settingsController,
        builder: (context, _) {
          return MaterialApp(
            title: 'Chefify',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _settingsController.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
