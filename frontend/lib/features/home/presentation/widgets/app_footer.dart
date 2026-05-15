import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: double.infinity,
      color: palette.navbarBackground,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: AppSpacing.xxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: palette.primaryButtons,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.soup_kitchen_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Chefify',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: palette.mainText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.sm,
                children: const [
                  _FooterLink(label: 'Recipes'),
                  _FooterLink(label: 'Meal plans'),
                  _FooterLink(label: 'Pricing'),
                  _FooterLink(label: 'Blog'),
                  _FooterLink(label: 'Support'),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '(c) 2026 Chefify. All rights reserved.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: palette.secondaryText,
      ),
    );
  }
}
