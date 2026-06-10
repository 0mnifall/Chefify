import 'package:flutter/material.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';

class ChefifyApp extends StatefulWidget {
  const ChefifyApp({super.key, this.bookmarkStore});

  final BookmarkStore? bookmarkStore;

  @override
  State<ChefifyApp> createState() => _ChefifyAppState();
}

class _ChefifyAppState extends State<ChefifyApp> {
  late final AppSettingsController _settingsController;
  late final BookmarkStore _bookmarkStore;
  late final bool _ownsBookmarkStore;

  @override
  void initState() {
    super.initState();
    _settingsController = AppSettingsController();
    _ownsBookmarkStore = widget.bookmarkStore == null;
    _bookmarkStore = widget.bookmarkStore ?? BookmarkStore();
    _bookmarkStore.load();
  }

  @override
  void dispose() {
    _settingsController.dispose();
    if (_ownsBookmarkStore) {
      _bookmarkStore.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BookmarkScope(
      store: _bookmarkStore,
      child: AppSettingsScope(
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
              onGenerateRoute: AppRouter.onGenerateRoute,
            );
          },
        ),
      ),
    );
  }
}
