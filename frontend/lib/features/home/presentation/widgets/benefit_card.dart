import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/shared/models/home_models.dart';

class BenefitCard extends StatelessWidget {
  const BenefitCard({super.key, required this.benefit});

  final BenefitModel benefit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      backgroundColor: palette.recipeCardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: palette.searchBarBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(benefit.icon, color: palette.icons),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(benefit.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(benefit.description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

