import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/features/categories/presentation/pages/categories_page.dart';
import 'package:frontend/features/home/presentation/widgets/category_card.dart';
import 'package:frontend/features/home/presentation/widgets/hero_section.dart';
import 'package:frontend/features/home/presentation/widgets/recipe_card.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/features/recipes/presentation/pages/recipes_page.dart';
import 'package:frontend/shared/bookmarks/bookmark_button.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

const _featuredRecipe = RecipeModel(
  id: 'citrus-herb-chicken-quinoa',
  title: 'Citrus Herb Chicken with Warm Quinoa',
  categoryId: 'healthy',
  categoryName: 'Healthy',
  author: 'Chef Luna',
  minutes: 40,
  rating: 4.9,
  accentColor: Color(0xFF5F7C67),
  tags: ['chef-pick', 'chicken', 'high-protein'],
);

const _category = CategoryModel(
  id: 'quick-meals',
  title: 'Quick Meals',
  description: '30-minute dishes for busy days.',
  icon: Icons.flash_on_rounded,
  recipesCount: 124,
);

void main() {
  testWidgets('renders chefify home sections', (tester) async {
    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(
      ChefifyApp(
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chefify'), findsWidgets);
    expect(find.text('Browse by category'), findsOneWidget);
    expect(find.text('Recipes everyone is saving'), findsOneWidget);
    expect(find.text('Weekly recipes in your inbox'), findsOneWidget);
  });

  testWidgets('home and recipes pages fit common viewport widths', (
    tester,
  ) async {
    final sizes = [
      const Size(320, 1200),
      const Size(390, 1200),
      const Size(768, 1200),
      const Size(1024, 1200),
      const Size(1440, 1200),
    ];

    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in sizes) {
      tester.view.physicalSize = size;

      await tester.pumpWidget(
        const _PageTestApp(
          child: HomePage(recipeRepository: MockRecipeRepository()),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Home overflow at ${size.width}px',
      );

      await tester.pumpWidget(
        const _PageTestApp(
          child: RecipesPage(recipeRepository: MockRecipeRepository()),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Recipes overflow at ${size.width}px',
      );

      await tester.pumpWidget(
        const _PageTestApp(
          child: CategoriesPage(recipeRepository: MockRecipeRepository()),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Categories overflow at ${size.width}px',
      );
    }
  });

  testWidgets('opens recipes page and filters recipe catalog', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(
      ChefifyApp(
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Recipes').first);
    await tester.pumpAndSettle();

    expect(find.text('Find your next cook'), findsOneWidget);
    expect(find.text('Roasted Tomato Pasta'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'salmon',
    );
    await tester.pumpAndSettle();

    expect(find.text('Miso Glazed Salmon'), findsOneWidget);
    expect(find.text('Roasted Tomato Pasta'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'high protein',
    );
    await tester.pumpAndSettle();

    expect(find.text('Miso Glazed Salmon'), findsOneWidget);
    expect(find.text('Roasted Tomato Pasta'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('recipes-category-chip-breakfast')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lemon Ricotta Pancakes'), findsOneWidget);
    expect(find.text('Miso Glazed Salmon'), findsNothing);
  });

  testWidgets('opens recipe details from recipe card', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(
      ChefifyApp(
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Recipes').first);
    await tester.pumpAndSettle();

    final recipeCard = find.byKey(
      const ValueKey('recipes-card-roasted-tomato-pasta'),
    );

    await tester.scrollUntilVisible(
      recipeCard,
      360,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(recipeCard);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-details-page-roasted-tomato-pasta')),
      findsOneWidget,
    );
    expect(find.text('Cook profile'), findsOneWidget);
  });

  testWidgets('opens author profile from recipe card author chip', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(
      ChefifyApp(
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Recipes').first);
    await tester.pumpAndSettle();

    final recipeCard = find.byKey(
      const ValueKey('recipes-card-roasted-tomato-pasta'),
    );
    await tester.scrollUntilVisible(
      recipeCard,
      360,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 180));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('recipe-author-chip-roasted-tomato-pasta')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('author-profile-page-chef-aria')),
      findsOneWidget,
    );
    expect(find.text('Chef Aria'), findsWidgets);
  });

  testWidgets('opens categories page from category see all action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(
      ChefifyApp(
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -620),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('See all').first);
    await tester.pumpAndSettle();

    expect(find.text('Explore every category'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('categories-search-field')),
      findsOneWidget,
    );
  });

  testWidgets('opens recipes page from trending see all action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(
      ChefifyApp(
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('See all').last);
    await tester.pumpAndSettle();

    expect(find.text('Find your next cook'), findsOneWidget);
    expect(find.byKey(const ValueKey('recipes-search-field')), findsOneWidget);
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

    expect(find.byTooltip(BookmarkButton.removeTooltip), findsOneWidget);
    expect(find.byTooltip(BookmarkButton.saveTooltip), findsNothing);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsNothing);

    await tester.tap(find.byTooltip(BookmarkButton.removeTooltip));
    await tester.pumpAndSettle();

    expect(find.byTooltip(BookmarkButton.removeTooltip), findsNothing);
    expect(find.byTooltip(BookmarkButton.saveTooltip), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_rounded), findsNothing);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
  });

  testWidgets('toggles category bookmark icon', (tester) async {
    await tester.pumpWidget(
      const _TestApp(
        child: SizedBox(
          width: 340,
          height: 248,
          child: CategoryCard(category: _category),
        ),
      ),
    );

    expect(find.byTooltip(BookmarkButton.saveTooltip), findsOneWidget);
    expect(find.byTooltip(BookmarkButton.removeTooltip), findsNothing);

    await tester.tap(find.byTooltip(BookmarkButton.saveTooltip));
    await tester.pumpAndSettle();

    expect(find.byTooltip(BookmarkButton.saveTooltip), findsNothing);
    expect(find.byTooltip(BookmarkButton.removeTooltip), findsOneWidget);
  });

  testWidgets('toggles trending recipe card bookmark icon', (tester) async {
    await tester.pumpWidget(
      const _TestApp(
        child: SizedBox(width: 320, child: RecipeCard(recipe: _featuredRecipe)),
      ),
    );

    expect(find.byTooltip(BookmarkButton.saveTooltip), findsOneWidget);
    expect(find.byTooltip(BookmarkButton.removeTooltip), findsNothing);

    await tester.tap(find.byTooltip(BookmarkButton.saveTooltip));
    await tester.pumpAndSettle();

    expect(find.byTooltip(BookmarkButton.saveTooltip), findsNothing);
    expect(find.byTooltip(BookmarkButton.removeTooltip), findsOneWidget);
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

class _PageTestApp extends StatefulWidget {
  const _PageTestApp({required this.child});

  final Widget child;

  @override
  State<_PageTestApp> createState() => _PageTestAppState();
}

class _PageTestAppState extends State<_PageTestApp> {
  late final AppSettingsController _settingsController;
  late final BookmarkStore _bookmarkStore;

  @override
  void initState() {
    super.initState();
    _settingsController = AppSettingsController();
    _bookmarkStore = BookmarkStore.memory();
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
          home: widget.child,
        ),
      ),
    );
  }
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
