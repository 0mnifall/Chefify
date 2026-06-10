import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/localization/app_strings.dart';
import 'package:frontend/shared/bookmarks/bookmark_button.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final heroHeight = (width / 2.25).clamp(560.0, 680.0);

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: _HeroPhotoPlaceholder(
              recipe: recipe,
              isDarkTheme: isDarkTheme,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: _HeroSplitOverlay(isDarkTheme: isDarkTheme),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: _HeroTintOverlay(isDarkTheme: isDarkTheme),
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
                    onDarkBackground: isDarkTheme,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 8,
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: isDarkTheme
              ? const Color(0xFF1F140F)
              : const Color(0xFFF5E8DC),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: HeroTextBlock(
            title: title,
            subtitle: subtitle,
            compact: true,
            onDarkBackground: isDarkTheme,
          ),
        ),
        SizedBox(
          height: 280,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _HeroPhotoPlaceholder(recipe: recipe, isDarkTheme: isDarkTheme),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        isDarkTheme
                            ? const Color(0xCC1F140F)
                            : palette.pageBackground.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
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
    final strings = AppStrings.of(context);

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
            strings.trustedBy,
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
    final strings = AppStrings.of(context);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.play_arrow_rounded, size: 18),
          label: Text(strings.startFreeTrial),
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
          child: Text(strings.browseRecipes),
        ),
      ],
    );
  }
}

class _HeroPhotoPlaceholder extends StatelessWidget {
  const _HeroPhotoPlaceholder({
    required this.recipe,
    required this.isDarkTheme,
  });

  final RecipeModel recipe;
  final bool isDarkTheme;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final leadingColor = isDarkTheme
        ? recipe.accentColor.withValues(alpha: 0.96)
        : Color.lerp(recipe.accentColor, Colors.white, 0.28)!;
    final middleColor = isDarkTheme
        ? recipe.accentColor.withValues(alpha: 0.76)
        : Color.lerp(recipe.accentColor, const Color(0xFFEDE4D7), 0.4)!;
    final trailingColor = isDarkTheme
        ? const Color(0xFF2B332A)
        : const Color(0xFF8EA79A);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [leadingColor, middleColor, trailingColor],
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
                color: isDarkTheme
                    ? Colors.black.withValues(alpha: 0.24)
                    : Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isDarkTheme
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.78),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: isDarkTheme
                        ? Colors.white70
                        : const Color(0xFF6E655F),
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    strings.photoPlaceholder,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isDarkTheme
                          ? Colors.white.withValues(alpha: 0.88)
                          : const Color(0xFF544A43),
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
    final strings = AppStrings.of(context);
    final bookmarks = BookmarkScope.of(context);
    final isSaved = bookmarks.isRecipeSaved(recipe);
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
                    strings.recipeOfTheDay,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: palette.secondaryText,
                    ),
                  ),
                ),
                BookmarkButton(
                  isSaved: isSaved,
                  onPressed: () {
                    bookmarks.toggleRecipe(recipe);
                  },
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
                  label: '${recipe.minutes} ${strings.minutesShort}',
                  iconColor: palette.icons,
                ),
                _MetaChip(
                  icon: Icons.local_fire_department_rounded,
                  label: _difficulty(recipe.minutes, strings),
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

class _HeroSplitOverlay extends StatelessWidget {
  const _HeroSplitOverlay({required this.isDarkTheme});

  final bool isDarkTheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDarkTheme
              ? const [
                  Color(0xFF1F140F),
                  Color(0xF71F140F),
                  Color(0xD81F140F),
                  Color(0x8A1F140F),
                  Color(0x2D1F140F),
                  Colors.transparent,
                ]
              : const [
                  Color(0xFFF8EDE2),
                  Color(0xF4F5EBDD),
                  Color(0xDCEFE3D4),
                  Color(0x91EEE8DF),
                  Color(0x32FFFFFF),
                  Colors.transparent,
                ],
          stops: const [0.0, 0.34, 0.5, 0.64, 0.76, 0.94],
        ),
      ),
    );
  }
}

class _HeroTintOverlay extends StatelessWidget {
  const _HeroTintOverlay({required this.isDarkTheme});

  final bool isDarkTheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkTheme
              ? const [Color(0x4D2C1307), Colors.transparent, Color(0x332C1307)]
              : const [
                  Color(0x2DFFFFFF),
                  Colors.transparent,
                  Color(0x1FF2E9DD),
                ],
          stops: const [0.0, 0.56, 1.0],
        ),
      ),
    );
  }
}

String _difficulty(int minutes, AppStrings strings) {
  if (minutes <= 25) {
    return strings.easy;
  }
  if (minutes <= 45) {
    return strings.medium;
  }
  return strings.hard;
}

String _formatLikes(int likes) {
  if (likes >= 1000) {
    final formatted = likes / 1000;
    final decimals = formatted >= 10 ? 0 : 1;
    return '${formatted.toStringAsFixed(decimals)}k';
  }
  return likes.toString();
}
