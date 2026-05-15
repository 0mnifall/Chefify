import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/app/theme.dart';

class ChefifyApp extends StatelessWidget {
  const ChefifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chefify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
