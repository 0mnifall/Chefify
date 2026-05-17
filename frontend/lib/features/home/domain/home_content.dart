import 'package:frontend/shared/models/home_models.dart';

class HomeContent {
  const HomeContent({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.categories,
    required this.trendingRecipes,
    required this.benefits,
    required this.featuredRecipe,
    required this.stats,
    required this.testimonials,
  });

  final String heroTitle;
  final String heroSubtitle;
  final List<CategoryModel> categories;
  final List<RecipeModel> trendingRecipes;
  final List<BenefitModel> benefits;
  final RecipeModel featuredRecipe;
  final List<StatItemModel> stats;
  final List<TestimonialModel> testimonials;
}
