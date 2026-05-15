import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_button.dart';

class MobileAppPromoSection extends StatelessWidget {
  const MobileAppPromoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, AppSpacing.sectionGap),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              gradient: LinearGradient(
                colors: [palette.activeElements, palette.primaryButtons],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 900;
                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PromoContent(),
                      const SizedBox(height: AppSpacing.lg),
                      _PromoPhoneMock(width: constraints.maxWidth),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _PromoContent()),
                    SizedBox(width: AppSpacing.xl),
                    const _PromoPhoneMock(width: 250),
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

class _PromoContent extends StatelessWidget {
  const _PromoContent();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Take Chefify wherever you cook',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: palette.mainText,
            fontSize: 34,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Sync shopping lists, watch guided steps, and track your progress from phone to desktop.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(
              label: 'Download on App Store',
              icon: Icons.apple,
              onPressed: () {},
            ),
            AppButton(
              label: 'Get it on Google Play',
              icon: Icons.play_arrow_rounded,
              variant: AppButtonVariant.outlined,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _PromoPhoneMock extends StatelessWidget {
  const _PromoPhoneMock({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: width,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        color: palette.searchBarBackground,
        border: Border.all(color: palette.borders),
      ),
      child: Icon(
        Icons.phone_android_rounded,
        size: 86,
        color: palette.icons,
      ),
    );
  }
}
