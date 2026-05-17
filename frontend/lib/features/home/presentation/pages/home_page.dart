import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/localization/app_strings.dart';
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
    final strings = AppStrings.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.pageBackground, palette.cardsSurface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 920;
            final headerHeight = compact ? 92.0 : 98.0;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: headerHeight),
                      HeroSection(
                        title: strings.heroTitle,
                        subtitle: strings.heroSubtitle,
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
                _StickyHeaderShell(
                  height: headerHeight,
                  child: const AppHeader(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StickyHeaderShell extends StatelessWidget {
  const _StickyHeaderShell({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: palette.navbarBackground.withValues(alpha: 0.84),
              border: Border(
                bottom: BorderSide(
                  color: palette.borders.withValues(alpha: 0.55),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
