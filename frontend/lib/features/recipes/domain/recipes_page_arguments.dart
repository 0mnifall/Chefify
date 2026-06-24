class RecipesPageArguments {
  const RecipesPageArguments({
    this.categoryIds = const [],
    this.tagIds = const [],
    this.authorIds = const [],
    this.query,
  });

  factory RecipesPageArguments.from(Object? arguments) {
    if (arguments is RecipesPageArguments) {
      return arguments;
    }

    if (arguments is String) {
      return RecipesPageArguments(categoryIds: [arguments]);
    }

    if (arguments is Iterable<String>) {
      return RecipesPageArguments(categoryIds: arguments.toList());
    }

    return const RecipesPageArguments();
  }

  final List<String> categoryIds;
  final List<String> tagIds;
  final List<String> authorIds;
  final String? query;
}
