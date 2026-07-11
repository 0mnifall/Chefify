import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/features/categories/presentation/pages/categories_page.dart';
import 'package:frontend/features/home/presentation/widgets/category_card.dart';
import 'package:frontend/features/home/presentation/widgets/hero_section.dart';
import 'package:frontend/features/home/presentation/widgets/recipe_card.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/features/recipes/presentation/pages/recipe_create_page.dart';
import 'package:frontend/features/recipes/presentation/pages/recipe_details_page.dart';
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

  testWidgets('main app pages fit common viewport widths', (tester) async {
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

      await tester.pumpWidget(
        const _PageTestApp(
          child: RecipeDetailsPage(
            recipeId: 'citrus-herb-chicken-quinoa',
            initialRecipe: _featuredRecipe,
            recipeRepository: MockRecipeRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Recipe details overflow at ${size.width}px',
      );

      await tester.pumpWidget(const _PageTestApp(child: RecipeCreatePage()));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Recipe create overflow at ${size.width}px',
      );
    }
  });

  testWidgets('opens recipe creation page from direct route', (tester) async {
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

    Navigator.of(
      tester.element(find.byType(HomePage)),
    ).pushNamed(AppRouter.recipeCreate);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('recipe-create-page')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('recipe-create-title-field')),
      findsOneWidget,
    );
    expect(find.text('Chef Sofia'), findsOneWidget);
    expect(find.byTooltip('Templates'), findsOneWidget);
    expect(find.byTooltip('Open block settings'), findsOneWidget);
  });

  testWidgets('adds recipe body blocks from create editor palette', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const _PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Blocks'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Paragraph'));
    await tester.pumpAndSettle();

    expect(
      find.text('Write the cooking detail directly in the page preview.'),
      findsOneWidget,
    );
  });

  testWidgets('expands recipe editor docks without resizing canvas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const _PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Expand block palette'), findsOneWidget);
    expect(find.byTooltip('Open block settings'), findsOneWidget);

    await tester.tap(find.byTooltip('Expand block palette'));
    await tester.pumpAndSettle();
    expect(find.text('Classic method'), findsOneWidget);
    expect(find.byTooltip('Collapse block palette'), findsOneWidget);

    await tester.tap(find.byTooltip('Open block settings'));
    await tester.pumpAndSettle();
    expect(find.text('Width'), findsOneWidget);
    expect(find.byTooltip('Collapse block settings'), findsOneWidget);
    expect(find.byTooltip('Expand block palette'), findsOneWidget);
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
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'salmon',
    );
    await tester.pumpAndSettle();

    expect(find.text('Miso Glazed Salmon'), findsWidgets);
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsNothing,
    );

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'high protein',
    );
    await tester.pumpAndSettle();

    expect(find.text('Miso Glazed Salmon'), findsWidgets);
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsNothing,
    );

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('recipes-category-chip-breakfast')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipes-card-lemon-ricotta-pancakes')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-miso-glazed-salmon')),
      findsNothing,
    );
  });

  testWidgets('opens recipe tag filters from recipe cards', (tester) async {
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

    final pastaTag = find.byKey(
      const ValueKey('recipe-card-tag-roasted-tomato-pasta-pasta'),
    );
    await tester.scrollUntilVisible(
      pastaTag,
      360,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 220));
    await tester.pumpAndSettle();

    await tester.tap(pastaTag);
    await tester.pumpAndSettle();

    expect(find.text('Find your next cook'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('recipe-search-tag-token-pasta')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-miso-glazed-salmon')),
      findsNothing,
    );
  });

  testWidgets('selects tag suggestions as search tokens', (tester) async {
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

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'high',
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('recipe-search-suggestion-tag-high-protein')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-search-tag-token-high-protein')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-miso-glazed-salmon')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsNothing,
    );
  });

  testWidgets('selects author suggestions as search tokens', (tester) async {
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

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'aria',
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('recipe-search-suggestion-author-chef-aria')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-search-author-token-chef-aria')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-miso-glazed-salmon')),
      findsNothing,
    );
  });

  testWidgets('clear search removes text tag and author tokens', (
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

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'high',
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('recipe-search-suggestion-tag-high-protein')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'aria',
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('recipe-search-suggestion-author-chef-aria')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-search-tag-token-high-protein')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipe-search-author-token-chef-aria')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-search-tag-token-high-protein')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('recipe-search-author-token-chef-aria')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsOneWidget,
    );
  });

  testWidgets('autocompletes recipe title suggestions', (tester) async {
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

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'miso',
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey('recipe-search-suggestion-recipe-miso-glazed-salmon'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipes-card-miso-glazed-salmon')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsNothing,
    );
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

  testWidgets('creates recipe reviews and paginates review list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const _PageTestApp(
        child: RecipeDetailsPage(
          recipeId: 'citrus-herb-chicken-quinoa',
          initialRecipe: _featuredRecipe,
          recipeRepository: MockRecipeRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('recipe-review-comment-field')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('recipe-review-comment-field')),
      'Loved the balance and timing.',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('recipe-review-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Loved the balance and timing.'), findsOneWidget);
    expect(find.textContaining('Showing 1-20'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byTooltip('Next review page'),
      800,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next review page'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Showing 21-40'), findsOneWidget);
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
