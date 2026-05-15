import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/shared/models/home_models.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key, required this.testimonials});

  final List<TestimonialModel> testimonials;

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
                eyebrow: 'SOCIAL PROOF',
                title: 'Loved by cooks around the world',
                subtitle: 'Real stories from people who upgraded their daily kitchen routine.',
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
                      for (final testimonial in testimonials)
                        SizedBox(
                          width: cardWidth,
                          child: TestimonialCard(testimonial: testimonial),
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

class TestimonialCard extends StatelessWidget {
  const TestimonialCard({super.key, required this.testimonial});

  final TestimonialModel testimonial;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, size: 28, color: palette.activeElements),
          const SizedBox(height: AppSpacing.sm),
          Text(
            testimonial.message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: palette.mainText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(testimonial.name, style: Theme.of(context).textTheme.titleMedium),
          Text(
            testimonial.role,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

