import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/home/data/home_mock_data.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/home/presentation/widgets/app_footer.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/home/presentation/widgets/benefit_card.dart';
import 'package:frontend/features/home/presentation/widgets/benefits_section.dart';
import 'package:frontend/features/home/presentation/widgets/category_card.dart';
import 'package:frontend/features/home/presentation/widgets/category_section.dart';
import 'package:frontend/features/home/presentation/widgets/featured_recipe_section.dart';
import 'package:frontend/features/home/presentation/widgets/hero_section.dart';
import 'package:frontend/features/home/presentation/widgets/mobile_app_promo_section.dart';
import 'package:frontend/features/home/presentation/widgets/newsletter_section.dart';
import 'package:frontend/features/home/presentation/widgets/recipe_card.dart';
import 'package:frontend/features/home/presentation/widgets/stats_banner.dart';
import 'package:frontend/features/home/presentation/widgets/testimonials_section.dart';
import 'package:frontend/features/home/presentation/widgets/trending_recipes_section.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

const _previewSurfacePadding = EdgeInsets.all(16);

PreviewThemeData chefifyPreviewTheme() => PreviewThemeData(
  materialLight: AppTheme.lightTheme,
  materialDark: AppTheme.darkTheme,
);

Widget chefifyPreviewWrapper(Widget child) {
  return _PreviewScope(child: child);
}

class _PreviewScope extends StatefulWidget {
  const _PreviewScope({required this.child});

  final Widget child;

  @override
  State<_PreviewScope> createState() => _PreviewScopeState();
}

class _PreviewScopeState extends State<_PreviewScope> {
  late final AppSettingsController _settingsController;
  late final BookmarkStore _bookmarkStore;

  @override
  void initState() {
    super.initState();
    _settingsController = AppSettingsController(
      initialThemeMode: ThemeMode.dark,
    );
    _bookmarkStore = BookmarkStore.memory(
      const BookmarkSnapshot(
        categoryIds: <String>{'quick-meals'},
        recipeIds: <String>{'citrus-herb-chicken-quinoa'},
      ),
    );
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
        child: Builder(
          builder: (context) {
            return Material(
              color: context.palette.pageBackground,
              child: Padding(
                padding: _previewSurfacePadding,
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}

final _mock = HomeMockData.content;

@Preview(
  name: 'Home Page',
  group: 'Page',
  size: Size(1500, 2100),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewHomePage() => const HomePage();

@Preview(
  name: 'App Header',
  group: 'Shell',
  size: Size(1400, 120),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewAppHeader() => const AppHeader();

@Preview(
  name: 'App Footer',
  group: 'Shell',
  size: Size(1400, 460),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewAppFooter() => const AppFooter();

@Preview(
  name: 'Hero Section',
  group: 'Sections',
  size: Size(1500, 760),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewHeroSection() => HeroSection(
  title: 'Cook with confidence.\nServe with style.',
  subtitle:
      'Chefify helps you discover recipes, manage meal plans, and cook faster without sacrificing flavor.',
  featuredRecipe: _mock.featuredRecipe,
);

@Preview(
  name: 'Category Section',
  group: 'Sections',
  size: Size(1500, 540),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewCategorySection() =>
    CategorySection(categories: _mock.categories);

@Preview(
  name: 'Trending Recipes Section',
  group: 'Sections',
  size: Size(1500, 560),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewTrendingRecipesSection() =>
    TrendingRecipesSection(recipes: _mock.trendingRecipes);

@Preview(
  name: 'Benefits Section',
  group: 'Sections',
  size: Size(1500, 520),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewBenefitsSection() => BenefitsSection(benefits: _mock.benefits);

@Preview(
  name: 'Featured Recipe Section',
  group: 'Sections',
  size: Size(1500, 540),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewFeaturedRecipeSection() =>
    FeaturedRecipeSection(recipe: _mock.featuredRecipe);

@Preview(
  name: 'Stats Banner',
  group: 'Sections',
  size: Size(1500, 300),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewStatsBanner() => StatsBanner(stats: _mock.stats);

@Preview(
  name: 'Testimonials Section',
  group: 'Sections',
  size: Size(1500, 520),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewTestimonialsSection() =>
    TestimonialsSection(testimonials: _mock.testimonials);

@Preview(
  name: 'Mobile App Promo Section',
  group: 'Sections',
  size: Size(1500, 460),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewMobilePromoSection() => const MobileAppPromoSection();

@Preview(
  name: 'Newsletter Section',
  group: 'Sections',
  size: Size(1500, 340),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewNewsletterSection() => const NewsletterSection();

@Preview(
  name: 'Category Card',
  group: 'Cards',
  size: Size(380, 280),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewCategoryCard() => SizedBox(
  width: 340,
  height: 248,
  child: CategoryCard(category: _mock.categories.first),
);

@Preview(
  name: 'Recipe Card',
  group: 'Cards',
  size: Size(360, 330),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewRecipeCard() => SizedBox(
  width: 320,
  child: RecipeCard(recipe: _mock.trendingRecipes.first),
);

@Preview(
  name: 'Benefit Card',
  group: 'Cards',
  size: Size(420, 300),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewBenefitCard() =>
    SizedBox(width: 360, child: BenefitCard(benefit: _mock.benefits.first));

@Preview(
  name: 'Testimonial Card',
  group: 'Cards',
  size: Size(440, 320),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewTestimonialCard() => SizedBox(
  width: 360,
  child: TestimonialCard(testimonial: _mock.testimonials.first),
);

@Preview(
  name: 'Stat Item',
  group: 'Cards',
  size: Size(300, 240),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewStatItem() => const SizedBox(
  width: 220,
  child: StatItem(
    item: StatItemModel(label: 'Active users', value: '120K+'),
  ),
);

@Preview(
  name: 'App Button Variants',
  group: 'Core Widgets',
  size: Size(740, 220),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewAppButtons() => Wrap(
  spacing: AppSpacing.sm,
  runSpacing: AppSpacing.sm,
  children: const [
    AppButton(label: 'Filled'),
    AppButton(label: 'Outlined', variant: AppButtonVariant.outlined),
    AppButton(label: 'Ghost', variant: AppButtonVariant.ghost),
    AppButton(label: 'With icon', icon: Icons.arrow_forward_rounded),
  ],
);

@Preview(
  name: 'App Card',
  group: 'Core Widgets',
  size: Size(520, 280),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewAppCard() => SizedBox(
  width: 420,
  child: AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text('Card title'),
        SizedBox(height: AppSpacing.xs),
        Text('Reusable card wrapper preview.'),
      ],
    ),
  ),
);

@Preview(
  name: 'Section Header',
  group: 'Core Widgets',
  size: Size(960, 230),
  theme: chefifyPreviewTheme,
  wrapper: chefifyPreviewWrapper,
)
Widget previewSectionHeader() => SectionHeader(
  eyebrow: 'DISCOVER',
  title: 'Browse by category',
  subtitle: 'Pick a mood and we will find recipes that fit your day.',
  action: AppButton(
    label: 'See all',
    variant: AppButtonVariant.ghost,
    onPressed: () {},
  ),
);
