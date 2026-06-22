import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/core/widgets/responsive_wrap_grid.dart';
import 'package:frontend/features/home/presentation/widgets/category_card.dart';
import 'package:frontend/shared/models/home_models.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key, required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.sectionInsets(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.contentMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: 'DISCOVER',
                title: 'Browse by category',
                subtitle:
                    'Pick a mood and we will find recipes that fit your day.',
                action: AppButton(
                  label: 'See all',
                  variant: AppButtonVariant.ghost,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.categories);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ResponsiveWrapGrid<CategoryModel>(
                items: categories,
                minItemWidth: 250,
                maxColumns: 4,
                itemHeightBuilder: (width, columns) {
                  if (columns >= 4) {
                    return 248;
                  }
                  if (columns == 2) {
                    return 232;
                  }
                  return width < 360 ? 224 : 218;
                },
                itemBuilder: (context, category) {
                  return CategoryCard(
                    category: category,
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(AppRouter.recipes, arguments: category.id);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
