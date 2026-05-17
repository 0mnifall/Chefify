import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/home/presentation/widgets/benefit_card.dart';
import 'package:frontend/shared/models/home_models.dart';

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key, required this.benefits});

  final List<BenefitModel> benefits;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, AppSpacing.sectionGap),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                eyebrow: 'WHY CHEFIFY',
                title: 'Everything you need in one kitchen flow',
                subtitle:
                    'From planning to plating, Chefify removes friction at every step.',
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth >= 960
                      ? (constraints.maxWidth - (AppSpacing.md * 2)) / 3
                      : constraints.maxWidth >= 640
                      ? (constraints.maxWidth - AppSpacing.md) / 2
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      for (final benefit in benefits)
                        SizedBox(
                          width: cardWidth,
                          child: BenefitCard(benefit: benefit),
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

