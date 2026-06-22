import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_card.dart';

class NewsletterSection extends StatelessWidget {
  const NewsletterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: AppSpacing.sectionInsets(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.contentMaxWidth,
          ),
          child: AppCard(
            backgroundColor: palette.cardsSurface,
            padding: EdgeInsets.all(
              AppSpacing.panelPaddingForWidth(viewportWidth),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 760;
                if (stacked) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NewsletterTextBlock(),
                      SizedBox(height: AppSpacing.lg),
                      _NewsletterForm(width: double.infinity),
                    ],
                  );
                }

                final formWidth = constraints.maxWidth < 960 ? 340.0 : 380.0;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _NewsletterTextBlock()),
                    const SizedBox(width: AppSpacing.lg),
                    _NewsletterForm(width: formWidth),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsletterTextBlock extends StatelessWidget {
  const _NewsletterTextBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly recipes in your inbox',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'No spam. Just fresh ideas and practical kitchen tips every Thursday.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _NewsletterForm extends StatelessWidget {
  const _NewsletterForm({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: width,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter your email',
              filled: true,
              fillColor: palette.searchBarBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                borderSide: BorderSide(color: palette.borders),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                borderSide: BorderSide(color: palette.borders),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(label: 'Subscribe', isExpanded: true, onPressed: () {}),
        ],
      ),
    );
  }
}
