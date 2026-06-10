import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/features/home/presentation/widgets/hero_section.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

const _featuredRecipe = RecipeModel(
  id: 'citrus-herb-chicken-quinoa',
  title: 'Citrus Herb Chicken with Warm Quinoa',
  tag: 'Chef Pick',
  author: 'Chef Luna',
  minutes: 40,
  rating: 4.9,
  accentColor: Color(0xFF5F7C67),
);

void main() {
  testWidgets('renders chefify home sections', (tester) async {
    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(ChefifyApp(bookmarkStore: bookmarks));
    await tester.pumpAndSettle();

    expect(find.text('Chefify'), findsWidgets);
    expect(find.text('Browse by category'), findsOneWidget);
    expect(find.text('Recipes everyone is saving'), findsOneWidget);
    expect(find.text('Weekly recipes in your inbox'), findsOneWidget);
  });

  testWidgets('toggles featured recipe bookmark icon', (tester) async {
    await tester.pumpWidget(
      const _TestApp(
        initialBookmarks: BookmarkSnapshot(
          recipeIds: <String>{'citrus-herb-chicken-quinoa'},
        ),
        child: HeroSection(
          title: 'Cook with confidence.',
          subtitle: 'Save recipes you want to cook later.',
          featuredRecipe: _featuredRecipe,
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

  testWidgets('persists recipe bookmarks to storage', (tester) async {
    final storage = MemoryBookmarkStorage();
    final bookmarks = BookmarkStore(storage: storage);
    addTearDown(bookmarks.dispose);

    await bookmarks.load();

    expect(bookmarks.isRecipeSaved(_featuredRecipe), isFalse);

    await bookmarks.toggleRecipe(_featuredRecipe);

    expect(bookmarks.isRecipeSaved(_featuredRecipe), isTrue);
    expect(storage.snapshot.recipeIds, contains('citrus-herb-chicken-quinoa'));

    await bookmarks.toggleRecipe(_featuredRecipe);

    expect(bookmarks.isRecipeSaved(_featuredRecipe), isFalse);
    expect(
      storage.snapshot.recipeIds,
      isNot(contains('citrus-herb-chicken-quinoa')),
    );
  });
}

class _TestApp extends StatefulWidget {
  const _TestApp({
    required this.child,
    this.initialBookmarks = const BookmarkSnapshot(),
  });

  final Widget child;
  final BookmarkSnapshot initialBookmarks;

  @override
  State<_TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<_TestApp> {
  late final AppSettingsController _settingsController;
  late final BookmarkStore _bookmarkStore;

  @override
  void initState() {
    super.initState();
    _settingsController = AppSettingsController();
    _bookmarkStore = BookmarkStore.memory(widget.initialBookmarks);
  }

  @override
  void dispose() {
    _settingsController.dispose();
    _bookmarkStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BookmarkScope(
      store: _bookmarkStore,
      child: AppSettingsScope(
        controller: _settingsController,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _settingsController.themeMode,
          home: Scaffold(body: SingleChildScrollView(child: widget.child)),
        ),
      ),
    );
  }
}
