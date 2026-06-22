import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_spacing.dart';
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
              const SectionHeader(
                eyebrow: 'DISCOVER',
                title: 'Browse by category',
                subtitle:
                    'Pick a mood and we will find recipes that fit your day.',
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
                  return CategoryCard(category: category);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
