import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/home/data/home_mock_data.dart';
import 'package:frontend/features/home/presentation/widgets/app_footer.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/home/presentation/widgets/benefits_section.dart';
import 'package:frontend/features/home/presentation/widgets/category_section.dart';
import 'package:frontend/features/home/presentation/widgets/featured_recipe_section.dart';
import 'package:frontend/features/home/presentation/widgets/hero_section.dart';
import 'package:frontend/features/home/presentation/widgets/mobile_app_promo_section.dart';
import 'package:frontend/features/home/presentation/widgets/newsletter_section.dart';
import 'package:frontend/features/home/presentation/widgets/stats_banner.dart';
import 'package:frontend/features/home/presentation/widgets/testimonials_section.dart';
import 'package:frontend/features/home/presentation/widgets/trending_recipes_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = HomeMockData.content;
    final palette = context.palette;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.pageBackground, palette.cardsSurface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AppHeader(),
              HeroSection(
                title: content.heroTitle,
                subtitle: content.heroSubtitle,
                featuredRecipe: content.featuredRecipe,
              ),
              CategorySection(categories: content.categories),
              TrendingRecipesSection(recipes: content.trendingRecipes),
              BenefitsSection(benefits: content.benefits),
              FeaturedRecipeSection(recipe: content.featuredRecipe),
              StatsBanner(stats: content.stats),
              TestimonialsSection(testimonials: content.testimonials),
              const MobileAppPromoSection(),
              const NewsletterSection(),
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
