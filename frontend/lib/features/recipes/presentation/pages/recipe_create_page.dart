import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';

class RecipeCreatePage extends StatefulWidget {
  const RecipeCreatePage({super.key});

  @override
  State<RecipeCreatePage> createState() => _RecipeCreatePageState();
}

class _RecipeCreatePageState extends State<RecipeCreatePage> {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.pageBackground, palette.cardsSurface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.horizontalPaddingForWidth(viewportWidth),
                    headerHeight + AppSpacing.xl,
                    AppSpacing.horizontalPaddingForWidth(viewportWidth),
                    AppSpacing.sectionGapForWidth(viewportWidth),
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSpacing.contentMaxWidth,
                        ),
                        child: const _RecipeCreateContent(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _RecipeCreateHeaderShell(
              height: headerHeight,
              child: const AppHeader(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCreateContent extends StatelessWidget {
  const _RecipeCreateContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_RecipeCreateHeroPanel()],
    );
  }
}

class _RecipeCreateHeroPanel extends StatelessWidget {
  const _RecipeCreateHeroPanel();

  static const double _desktopHeight = 400;
  static const double _compactHeight = 720;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      padding: EdgeInsets.zero,
      radius: AppSpacing.radiusLg,
      backgroundColor: palette.navbarBackground,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;

            return SizedBox(
              height: compact ? _compactHeight : _desktopHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const _RecipeCreateImageDropZone(),
                  _RecipeCreateHeroGradientOverlay(compact: compact),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecipeCreateImageDropZone extends StatelessWidget {
  const _RecipeCreateImageDropZone();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.searchBarBackground.withValues(alpha: 0.9),
            palette.cardsSurface.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: palette.primaryButtons.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: palette.primaryButtons.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(Icons.add_rounded, size: 52, color: palette.mainText),
        ),
      ),
    );
  }
}

class _RecipeCreateHeroGradientOverlay extends StatelessWidget {
  const _RecipeCreateHeroGradientOverlay({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: compact ? Alignment.topCenter : Alignment.centerLeft,
          end: compact ? Alignment.bottomCenter : Alignment.centerRight,
          colors: [
            Colors.black.withValues(alpha: compact ? 0.16 : 0.1),
            palette.navbarBackground.withValues(alpha: compact ? 0.66 : 0.48),
            palette.navbarBackground.withValues(alpha: compact ? 0.96 : 0.9),
          ],
          stops: compact ? const [0, 0.46, 1] : const [0, 0.55, 1],
        ),
      ),
    );
  }
}

class _RecipeCreateHeaderShell extends StatelessWidget {
  const _RecipeCreateHeaderShell({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.navbarBackground.withValues(alpha: 0.94),
          border: Border(
            bottom: BorderSide(color: palette.borders.withValues(alpha: 0.5)),
          ),
        ),
        child: child,
      ),
    );
  }
}
