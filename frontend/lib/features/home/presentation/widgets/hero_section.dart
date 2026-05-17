import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/shared/models/home_models.dart';

const double _heroMaxWidth = 1520;

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.featuredRecipe,
  });

  final String title;
  final String subtitle;
  final RecipeModel featuredRecipe;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, AppSpacing.sectionGap),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _heroMaxWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 960;

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg + 6),
                  border: Border.all(
                    color: palette.borders.withValues(alpha: 0.28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: stacked
                    ? _MobileHeroLayout(
                        title: title,
                        subtitle: subtitle,
                        recipe: featuredRecipe,
                      )
                    : _DesktopHeroLayout(
                        title: title,
                        subtitle: subtitle,
                        recipe: featuredRecipe,
                        width: constraints.maxWidth,
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DesktopHeroLayout extends StatelessWidget {
  const _DesktopHeroLayout({
    required this.title,
    required this.subtitle,
    required this.recipe,
    required this.width,
  });

  final String title;
  final String subtitle;
  final RecipeModel recipe;
  final double width;

  @override
  Widget build(BuildContext context) {
    final heroHeight = (width / 2.25).clamp(560.0, 680.0);

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          Positioned.fill(child: _HeroPhotoPlaceholder(recipe: recipe)),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF1F140F),
                      Color(0xF71F140F),
                      Color(0xD81F140F),
                      Color(0x8A1F140F),
                      Color(0x2D1F140F),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.34, 0.5, 0.64, 0.76, 0.94],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0x4D2C1307),
                      Colors.transparent,
                      const Color(0x332C1307),
                    ],
                    stops: const [0.0, 0.56, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(52, 52, 58, 52),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: HeroTextBlock(
                    title: title,
                    subtitle: subtitle,
                    onDarkBackground: true,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 54,
            right: 36,
            child: _TiltedRecipeCard(recipe: recipe),
          ),
        ],
      ),
    );
  }
}

class _MobileHeroLayout extends StatelessWidget {
  const _MobileHeroLayout({
    required this.title,
    required this.subtitle,
    required this.recipe,
  });

  final String title;
  final String subtitle;
  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: const Color(0xFF1F140F),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: HeroTextBlock(
            title: title,
            subtitle: subtitle,
            compact: true,
            onDarkBackground: true,
          ),
        ),
        SizedBox(
          height: 280,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _HeroPhotoPlaceholder(recipe: recipe),
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xCC1F140F), Colors.transparent],
                      stops: [0.0, 0.64],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  child: _TiltedRecipeCard(recipe: recipe, compact: true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HeroTextBlock extends StatelessWidget {
  const HeroTextBlock({
    super.key,
    required this.title,
    required this.subtitle,
    this.compact = false,
    this.onDarkBackground = false,
  });

  final String title;
  final String subtitle;
  final bool compact;
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    final titleStyle = compact
        ? Theme.of(context).textTheme.displayMedium
        : Theme.of(context).textTheme.displayLarge;
    final subtitleStyle = Theme.of(context).textTheme.bodyLarge;
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: onDarkBackground
                ? Colors.white.withValues(alpha: 0.12)
                : palette.searchBarBackground,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: onDarkBackground
                  ? Colors.white.withValues(alpha: 0.15)
                  : palette.borders,
            ),
          ),
          child: Text(
            'Trusted by 120K+ home cooks',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: onDarkBackground
                  ? const Color(0xFFE8C7A7)
                  : palette.categoryTags,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: titleStyle?.copyWith(
            color: onDarkBackground ? Colors.white : null,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: compact ? 500 : 620),
          child: Text(
            subtitle,
            style: subtitleStyle?.copyWith(
              color: onDarkBackground
                  ? Colors.white.withValues(alpha: 0.8)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        HeroActions(onDarkBackground: onDarkBackground),
      ],
    );
  }
}

class HeroActions extends StatelessWidget {
  const HeroActions({super.key, this.onDarkBackground = false});

  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.play_arrow_rounded, size: 18),
          label: const Text('Start free trial'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE18D59),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: onDarkBackground ? Colors.white : palette.mainText,
            side: BorderSide(
              color: onDarkBackground
                  ? Colors.white.withValues(alpha: 0.28)
                  : palette.borders,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Browse recipes'),
        ),
      ],
    );
  }
}

class _HeroPhotoPlaceholder extends StatelessWidget {
  const _HeroPhotoPlaceholder({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            recipe.accentColor.withValues(alpha: 0.96),
            recipe.accentColor.withValues(alpha: 0.76),
            const Color(0xFF2B332A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.6, -0.8),
                radius: 1.3,
                colors: [
                  Colors.white.withValues(alpha: 0.28),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.image_outlined,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Photo placeholder',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TiltedRecipeCard extends StatelessWidget {
  const _TiltedRecipeCard({required this.recipe, this.compact = false});

  final RecipeModel recipe;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final likes = _formatLikes((recipe.rating * 390).round() + 610);

    return Transform.rotate(
      angle: compact ? 0.025 : 0.055,
      child: Container(
        width: compact ? 268 : 292,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          color: palette.recipeCardBackground.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.borders.withValues(alpha: 0.82)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Recipe of the day',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: palette.secondaryText,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_add_rounded, size: 20),
                  style: IconButton.styleFrom(
                    foregroundColor: palette.mainText,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(32, 32),
                    backgroundColor: palette.cardsSurface.withValues(
                      alpha: 0.9,
                    ),
                    side: BorderSide(
                      color: palette.borders.withValues(alpha: 0.72),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              recipe.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(height: 1.2),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _MetaChip(
                  icon: Icons.star_rounded,
                  label: recipe.rating.toStringAsFixed(1),
                  iconColor: const Color(0xFFE5A03C),
                ),
                _MetaChip(
                  icon: Icons.schedule_rounded,
                  label: '${recipe.minutes} min',
                  iconColor: palette.icons,
                ),
                _MetaChip(
                  icon: Icons.local_fire_department_rounded,
                  label: _difficulty(recipe.minutes),
                  iconColor: recipe.accentColor,
                ),
                _MetaChip(
                  icon: Icons.favorite_rounded,
                  label: likes,
                  iconColor: const Color(0xFFD56E5A),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borders.withValues(alpha: 0.65)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.mainText,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

String _difficulty(int minutes) {
  if (minutes <= 25) {
    return 'Easy';
  }
  if (minutes <= 45) {
    return 'Medium';
  }
  return 'Hard';
}

String _formatLikes(int likes) {
  if (likes >= 1000) {
    final formatted = likes / 1000;
    final decimals = formatted >= 10 ? 0 : 1;
    return '${formatted.toStringAsFixed(decimals)}k';
  }
  return likes.toString();
}
