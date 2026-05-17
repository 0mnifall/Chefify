import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/localization/app_strings.dart';
import 'package:frontend/core/widgets/app_button.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final strings = AppStrings.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.contentMaxWidth,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 920;

              return Row(
                children: [
                  const _Logo(),
                  const Spacer(),
                  if (!compact) ...[
                    const _MainNavigation(),
                    const SizedBox(width: AppSpacing.lg),
                    AppButton(
                      label: strings.logIn,
                      variant: AppButtonVariant.ghost,
                      onPressed: () {},
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton(label: strings.getStarted, onPressed: () {}),
                  ] else ...[
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search_rounded),
                      color: palette.icons,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.menu_rounded),
                      color: palette.icons,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [palette.primaryButtons, palette.activeElements],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.soup_kitchen_rounded, color: Colors.white),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Chefify',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _MainNavigation extends StatelessWidget {
  const _MainNavigation();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final items = [
      strings.recipes,
      strings.mealPlans,
      strings.pricing,
      strings.community,
    ];
    return Row(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: TextButton(onPressed: () {}, child: Text(item)),
          ),
      ],
    );
  }
}
