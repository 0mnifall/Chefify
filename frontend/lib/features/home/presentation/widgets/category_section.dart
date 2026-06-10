import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/home/presentation/widgets/category_card.dart';
import 'package:frontend/shared/models/home_models.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key, required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, AppSpacing.sectionGap),
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth >= 960
                      ? (constraints.maxWidth - (AppSpacing.md * 3)) / 4
                      : constraints.maxWidth >= 640
                      ? (constraints.maxWidth - AppSpacing.md) / 2
                      : constraints.maxWidth;
                  final cardHeight = constraints.maxWidth >= 960
                      ? 248.0
                      : constraints.maxWidth >= 640
                      ? 232.0
                      : 218.0;

                  return Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      for (final category in categories)
                        SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: CategoryCard(category: category),
                        ),
                    ],
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
