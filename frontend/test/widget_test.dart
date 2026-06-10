import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/features/home/presentation/widgets/hero_section.dart';
import 'package:frontend/shared/models/home_models.dart';

void main() {
  testWidgets('renders chefify home sections', (tester) async {
    await tester.pumpWidget(const ChefifyApp());
    await tester.pumpAndSettle();

    expect(find.text('Chefify'), findsWidgets);
    expect(find.text('Browse by category'), findsOneWidget);
    expect(find.text('Recipes everyone is saving'), findsOneWidget);
    expect(find.text('Weekly recipes in your inbox'), findsOneWidget);
  });

  testWidgets('toggles featured recipe bookmark icon', (tester) async {
    await tester.pumpWidget(
      const _TestApp(
        child: HeroSection(
          title: 'Cook with confidence.',
          subtitle: 'Save recipes you want to cook later.',
          featuredRecipe: RecipeModel(
            title: 'Citrus Herb Chicken with Warm Quinoa',
            tag: 'Chef Pick',
            author: 'Chef Luna',
            minutes: 40,
            rating: 4.9,
            accentColor: Color(0xFF5F7C67),
            isSaved: true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_add_rounded), findsNothing);

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(find.byIcon(Icons.bookmark_rounded), findsNothing);
    expect(find.byIcon(Icons.bookmark_add_rounded), findsOneWidget);
  });
}

class _TestApp extends StatefulWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  State<_TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<_TestApp> {
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
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _settingsController.themeMode,
        home: Scaffold(body: SingleChildScrollView(child: widget.child)),
      ),
    );
  }
}
