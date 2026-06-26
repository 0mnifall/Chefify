import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/recipes/presentation/image_upload/recipe_image_picker.dart';

class RecipeCreatePage extends StatefulWidget {
  const RecipeCreatePage({super.key});

  @override
  State<RecipeCreatePage> createState() => _RecipeCreatePageState();
}

class _RecipeCreatePageState extends State<RecipeCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _imageUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
                        child: _RecipeCreateContent(
                          imageUrl: _imageUrl,
                          titleController: _titleController,
                          descriptionController: _descriptionController,
                          onPickImage: _pickImage,
                        ),
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

  Future<void> _pickImage() async {
    final imageUrl = await pickRecipeHeroImageUrl();
    if (!mounted || imageUrl == null) {
      return;
    }

    setState(() {
      _imageUrl = imageUrl;
    });
  }
}

class _RecipeCreateContent extends StatelessWidget {
  const _RecipeCreateContent({
    required this.imageUrl,
    required this.titleController,
    required this.descriptionController,
    required this.onPickImage,
  });

  final String? imageUrl;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecipeCreateHeroPanel(
          imageUrl: imageUrl,
          titleController: titleController,
          descriptionController: descriptionController,
          onPickImage: onPickImage,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _RecipeCreateHeroPanel extends StatelessWidget {
  const _RecipeCreateHeroPanel({
    required this.imageUrl,
    required this.titleController,
    required this.descriptionController,
    required this.onPickImage,
  });

  static const double _desktopHeight = 400;
  static const double _compactHeight = 720;

  final String? imageUrl;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final VoidCallback onPickImage;

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
                  _RecipeCreateImageDropZone(
                    imageUrl: imageUrl,
                    onPressed: onPickImage,
                  ),
                  _RecipeCreateHeroGradientOverlay(compact: compact),
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(
                        compact ? AppSpacing.lg : AppSpacing.xl,
                      ),
                      child: _RecipeCreateHeroEditor(
                        titleController: titleController,
                        descriptionController: descriptionController,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecipeCreateHeroEditor extends StatelessWidget {
  const _RecipeCreateHeroEditor({
    required this.titleController,
    required this.descriptionController,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final editorWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth * 0.54).clamp(440.0, 640.0).toDouble();

        return Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: editorWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _RecipeHeroTextField(
                  key: const ValueKey('recipe-create-title-field'),
                  controller: titleController,
                  hintText: 'Title',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: compact ? 34 : 46,
                  ),
                  minLines: 1,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.sm),
                _RecipeHeroTextField(
                  key: const ValueKey('recipe-create-description-field'),
                  controller: descriptionController,
                  hintText: 'Description',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: compact ? 16 : 18,
                    height: 1.45,
                  ),
                  minLines: 2,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecipeHeroTextField extends StatelessWidget {
  const _RecipeHeroTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.style,
    required this.minLines,
    required this.maxLines,
  });

  final TextEditingController controller;
  final String hintText;
  final TextStyle? style;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: style,
      cursorColor: palette.primaryButtons,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: style?.copyWith(
          color: palette.mainText.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: palette.searchBarBackground.withValues(alpha: 0.42),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: palette.borders.withValues(alpha: 0.36),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: palette.borders.withValues(alpha: 0.36),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: palette.primaryButtons.withValues(alpha: 0.72),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}

class _RecipeCreateImageDropZone extends StatelessWidget {
  const _RecipeCreateImageDropZone({
    required this.imageUrl,
    required this.onPressed,
  });

  final String? imageUrl;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selectedImageUrl = imageUrl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (selectedImageUrl == null)
              DecoratedBox(
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
              )
            else
              Image.network(selectedImageUrl, fit: BoxFit.cover),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: selectedImageUrl == null
                      ? palette.primaryButtons.withValues(alpha: 0.15)
                      : palette.navbarBackground.withValues(alpha: 0.72),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: palette.primaryButtons.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(
                  selectedImageUrl == null
                      ? Icons.add_rounded
                      : Icons.image_rounded,
                  size: 52,
                  color: palette.mainText,
                ),
              ),
            ),
          ],
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
