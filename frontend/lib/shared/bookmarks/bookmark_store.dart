import 'package:flutter/widgets.dart';
import 'package:frontend/shared/models/home_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _recipeIdsKey = 'chefify.bookmarks.recipeIds';
const _categoryIdsKey = 'chefify.bookmarks.categoryIds';

class BookmarkSnapshot {
  const BookmarkSnapshot({
    this.recipeIds = const <String>{},
    this.categoryIds = const <String>{},
  });

  final Set<String> recipeIds;
  final Set<String> categoryIds;

  BookmarkSnapshot copy() {
    return BookmarkSnapshot(
      recipeIds: Set<String>.of(recipeIds),
      categoryIds: Set<String>.of(categoryIds),
    );
  }
}

abstract class BookmarkStorage {
  Future<BookmarkSnapshot> load();

  Future<void> save(BookmarkSnapshot snapshot);
}

class SharedPreferencesBookmarkStorage implements BookmarkStorage {
  SharedPreferencesBookmarkStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<BookmarkSnapshot> load() async {
    final recipeIds = await _preferences.getStringList(_recipeIdsKey);
    final categoryIds = await _preferences.getStringList(_categoryIdsKey);

    return BookmarkSnapshot(
      recipeIds: recipeIds?.toSet() ?? const <String>{},
      categoryIds: categoryIds?.toSet() ?? const <String>{},
    );
  }

  @override
  Future<void> save(BookmarkSnapshot snapshot) async {
    await Future.wait(<Future<void>>[
      _preferences.setStringList(_recipeIdsKey, _sorted(snapshot.recipeIds)),
      _preferences.setStringList(
        _categoryIdsKey,
        _sorted(snapshot.categoryIds),
      ),
    ]);
  }
}

class MemoryBookmarkStorage implements BookmarkStorage {
  MemoryBookmarkStorage([BookmarkSnapshot initial = const BookmarkSnapshot()])
    : _snapshot = initial.copy();

  BookmarkSnapshot _snapshot;

  BookmarkSnapshot get snapshot => _snapshot.copy();

  @override
  Future<BookmarkSnapshot> load() async {
    return _snapshot.copy();
  }

  @override
  Future<void> save(BookmarkSnapshot snapshot) async {
    _snapshot = snapshot.copy();
  }
}

class BookmarkStore extends ChangeNotifier {
  BookmarkStore({BookmarkStorage? storage})
    : _storage = storage ?? SharedPreferencesBookmarkStorage();

  BookmarkStore.memory([BookmarkSnapshot initial = const BookmarkSnapshot()])
    : _storage = MemoryBookmarkStorage(initial) {
    _applySnapshot(initial);
    _isLoaded = true;
  }

  final BookmarkStorage _storage;
  final Set<String> _recipeIds = <String>{};
  final Set<String> _categoryIds = <String>{};

  bool _isLoaded = false;
  bool _isDirty = false;
  Future<void>? _loadFuture;

  bool get isLoaded => _isLoaded;

  Future<void> load() {
    if (_isLoaded) {
      return Future<void>.value();
    }
    return _loadFuture ??= _load();
  }

  bool isRecipeSaved(RecipeModel recipe) {
    return _isSaved(ids: _recipeIds, id: recipe.id, fallback: recipe.isSaved);
  }

  bool isCategorySaved(CategoryModel category) {
    return _isSaved(
      ids: _categoryIds,
      id: category.id,
      fallback: category.isSaved,
    );
  }

  Future<void> toggleRecipe(RecipeModel recipe) {
    return setRecipeSaved(recipe, !isRecipeSaved(recipe));
  }

  Future<void> toggleCategory(CategoryModel category) {
    return setCategorySaved(category, !isCategorySaved(category));
  }

  Future<void> setRecipeSaved(RecipeModel recipe, bool isSaved) async {
    if (isRecipeSaved(recipe) == isSaved) {
      return;
    }
    _setSaved(_recipeIds, recipe.id, isSaved);
    await _persist();
  }

  Future<void> setCategorySaved(CategoryModel category, bool isSaved) async {
    if (isCategorySaved(category) == isSaved) {
      return;
    }
    _setSaved(_categoryIds, category.id, isSaved);
    await _persist();
  }

  Future<void> _load() async {
    final snapshot = await _storage.load();
    if (!_isDirty) {
      _applySnapshot(snapshot);
    }
    _isLoaded = true;
    notifyListeners();
  }

  bool _isSaved({
    required Set<String> ids,
    required String id,
    required bool fallback,
  }) {
    if (_isLoaded || _isDirty) {
      return ids.contains(id);
    }
    return fallback;
  }

  void _setSaved(Set<String> ids, String id, bool isSaved) {
    if (isSaved) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    _isDirty = true;
    notifyListeners();
  }

  Future<void> _persist() {
    return _storage.save(
      BookmarkSnapshot(
        recipeIds: Set<String>.of(_recipeIds),
        categoryIds: Set<String>.of(_categoryIds),
      ),
    );
  }

  void _applySnapshot(BookmarkSnapshot snapshot) {
    _recipeIds
      ..clear()
      ..addAll(snapshot.recipeIds);
    _categoryIds
      ..clear()
      ..addAll(snapshot.categoryIds);
  }
}

class BookmarkScope extends InheritedNotifier<BookmarkStore> {
  const BookmarkScope({
    super.key,
    required BookmarkStore store,
    required super.child,
  }) : super(notifier: store);

  static BookmarkStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BookmarkScope>();
    assert(scope != null, 'BookmarkScope is missing in widget tree.');
    return scope!.notifier!;
  }
}

List<String> _sorted(Set<String> ids) {
  return ids.toList()..sort();
}
