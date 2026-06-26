import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/recipes/data/recipe_form_options.dart';
import 'package:frontend/features/recipes/presentation/image_upload/recipe_image_picker.dart';

@immutable
class _RecipeDurationValue {
  const _RecipeDurationValue({
    required this.days,
    required this.hours,
    required this.minutes,
  });

  final int days;
  final int hours;
  final int minutes;

  String get label {
    final parts = <String>[];
    if (days > 0) {
      parts.add('${days}d');
    }
    if (hours > 0) {
      parts.add('${hours}h');
    }
    if (minutes > 0 || parts.isEmpty) {
      parts.add('$minutes min');
    }
    return parts.join(' ');
  }
}

class RecipeCreatePage extends StatefulWidget {
  const RecipeCreatePage({super.key});

  @override
  State<RecipeCreatePage> createState() => _RecipeCreatePageState();
}

class _RecipeCreatePageState extends State<RecipeCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _tagFocusNode = FocusNode();
  final List<String> _tags = [];
  final _RecipeDurationValue _duration = const _RecipeDurationValue(
    days: 0,
    hours: 0,
    minutes: 20,
  );
  bool _isAddingTag = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _tagFocusNode.addListener(_handleTagFocusChange);
    _tagController.addListener(_handleTagTextChange);
  }

  @override
  void dispose() {
    _tagFocusNode.removeListener(_handleTagFocusChange);
    _tagController.removeListener(_handleTagTextChange);
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _tagFocusNode.dispose();
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
                          tags: _tags,
                          isAddingTag: _isAddingTag,
                          tagController: _tagController,
                          tagFocusNode: _tagFocusNode,
                          tagSuggestions: _tagSuggestions,
                          duration: _duration,
                          onEditDuration: _editDuration,
                          onSubmitTag: _submitTag,
                          onRemoveTag: _removeTag,
                          onAddTagPressed: _startAddingTag,
                          onCancelTagInput: _cancelTagInput,
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

  void _handleTagFocusChange() {
    if (!_tagFocusNode.hasFocus && _isAddingTag) {
      _submitTag(_tagController.text);
    }
  }

  void _handleTagTextChange() {
    if (_isAddingTag) {
      setState(() {});
    }
  }

  void _startAddingTag() {
    if (_tags.length >= 10) {
      return;
    }

    setState(() {
      _isAddingTag = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _tagFocusNode.requestFocus();
      }
    });
  }

  void _submitTag(String value) {
    final slug = RecipeFormOptions.slug(value);
    if (slug.isEmpty) {
      _cancelTagInput();
      return;
    }

    setState(() {
      if (!_tags.contains(slug) && _tags.length < 10) {
        _tags.add(slug);
      }
      _isAddingTag = false;
    });
    _tagController.clear();
  }

  void _cancelTagInput() {
    setState(() {
      _isAddingTag = false;
    });
    _tagController.clear();
  }

  void _editDuration() {}

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  List<String> get _tagSuggestions {
    if (!_isAddingTag) {
      return const [];
    }

    final query = RecipeFormOptions.slug(_tagController.text);
    final suggestions = RecipeFormOptions.availableTags
        .where((tag) {
          if (_tags.contains(tag)) {
            return false;
          }

          if (query.isEmpty) {
            return true;
          }

          final label = RecipeFormOptions.readableTagLabel(tag).toLowerCase();
          return tag.contains(query) ||
              label.contains(query.replaceAll('-', ' '));
        })
        .take(6);

    return suggestions.toList(growable: false);
  }
}

class _RecipeCreateContent extends StatelessWidget {
  const _RecipeCreateContent({
    required this.imageUrl,
    required this.titleController,
    required this.descriptionController,
    required this.tags,
    required this.isAddingTag,
    required this.tagController,
    required this.tagFocusNode,
    required this.tagSuggestions,
    required this.duration,
    required this.onEditDuration,
    required this.onSubmitTag,
    required this.onRemoveTag,
    required this.onAddTagPressed,
    required this.onCancelTagInput,
    required this.onPickImage,
  });

  final String? imageUrl;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<String> tags;
  final bool isAddingTag;
  final TextEditingController tagController;
  final FocusNode tagFocusNode;
  final List<String> tagSuggestions;
  final _RecipeDurationValue duration;
  final VoidCallback onEditDuration;
  final ValueChanged<String> onSubmitTag;
  final ValueChanged<String> onRemoveTag;
  final VoidCallback onAddTagPressed;
  final VoidCallback onCancelTagInput;
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
          tags: tags,
          isAddingTag: isAddingTag,
          tagController: tagController,
          tagFocusNode: tagFocusNode,
          tagSuggestions: tagSuggestions,
          duration: duration,
          onEditDuration: onEditDuration,
          onSubmitTag: onSubmitTag,
          onRemoveTag: onRemoveTag,
          onAddTagPressed: onAddTagPressed,
          onCancelTagInput: onCancelTagInput,
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
    required this.tags,
    required this.isAddingTag,
    required this.tagController,
    required this.tagFocusNode,
    required this.tagSuggestions,
    required this.duration,
    required this.onEditDuration,
    required this.onSubmitTag,
    required this.onRemoveTag,
    required this.onAddTagPressed,
    required this.onCancelTagInput,
    required this.onPickImage,
  });

  static const double _desktopHeight = 400;
  static const double _compactHeight = 720;

  final String? imageUrl;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<String> tags;
  final bool isAddingTag;
  final TextEditingController tagController;
  final FocusNode tagFocusNode;
  final List<String> tagSuggestions;
  final _RecipeDurationValue duration;
  final VoidCallback onEditDuration;
  final ValueChanged<String> onSubmitTag;
  final ValueChanged<String> onRemoveTag;
  final VoidCallback onAddTagPressed;
  final VoidCallback onCancelTagInput;
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
                        tags: tags,
                        isAddingTag: isAddingTag,
                        tagController: tagController,
                        tagFocusNode: tagFocusNode,
                        tagSuggestions: tagSuggestions,
                        duration: duration,
                        onEditDuration: onEditDuration,
                        onSubmitTag: onSubmitTag,
                        onRemoveTag: onRemoveTag,
                        onAddTagPressed: onAddTagPressed,
                        onCancelTagInput: onCancelTagInput,
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
    required this.tags,
    required this.isAddingTag,
    required this.tagController,
    required this.tagFocusNode,
    required this.tagSuggestions,
    required this.duration,
    required this.onEditDuration,
    required this.onSubmitTag,
    required this.onRemoveTag,
    required this.onAddTagPressed,
    required this.onCancelTagInput,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<String> tags;
  final bool isAddingTag;
  final TextEditingController tagController;
  final FocusNode tagFocusNode;
  final List<String> tagSuggestions;
  final _RecipeDurationValue duration;
  final VoidCallback onEditDuration;
  final ValueChanged<String> onSubmitTag;
  final ValueChanged<String> onRemoveTag;
  final VoidCallback onAddTagPressed;
  final VoidCallback onCancelTagInput;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final editorWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth * 0.54).clamp(440.0, 640.0).toDouble();

        return Stack(
          children: [
            Align(
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
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(fontSize: compact ? 34 : 46),
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
            ),
            Positioned(
              left: 0,
              bottom: compact ? 156 : 0,
              right: compact ? 0 : null,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: editorWidth),
                child: _RecipeCreateTagRow(
                  tags: tags,
                  isAddingTag: isAddingTag,
                  tagController: tagController,
                  tagFocusNode: tagFocusNode,
                  tagSuggestions: tagSuggestions,
                  onSubmitTag: onSubmitTag,
                  onRemoveTag: onRemoveTag,
                  onAddTagPressed: onAddTagPressed,
                  onCancelTagInput: onCancelTagInput,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: _RecipeCreateMetaPanel(
                duration: duration,
                onEditDuration: onEditDuration,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecipeCreateMetaPanel extends StatelessWidget {
  const _RecipeCreateMetaPanel({
    required this.duration,
    required this.onEditDuration,
  });

  final _RecipeDurationValue duration;
  final VoidCallback onEditDuration;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Row(
        children: [
          Expanded(
            child: _RecipeCreateMetaChip(
              icon: Icons.schedule_rounded,
              label: duration.label,
              onPressed: onEditDuration,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCreateMetaChip extends StatelessWidget {
  const _RecipeCreateMetaChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: palette.searchBarBackground.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: palette.icons),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.mainText,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeCreateTagRow extends StatelessWidget {
  const _RecipeCreateTagRow({
    required this.tags,
    required this.isAddingTag,
    required this.tagController,
    required this.tagFocusNode,
    required this.tagSuggestions,
    required this.onSubmitTag,
    required this.onRemoveTag,
    required this.onAddTagPressed,
    required this.onCancelTagInput,
  });

  final List<String> tags;
  final bool isAddingTag;
  final TextEditingController tagController;
  final FocusNode tagFocusNode;
  final List<String> tagSuggestions;
  final ValueChanged<String> onSubmitTag;
  final ValueChanged<String> onRemoveTag;
  final VoidCallback onAddTagPressed;
  final VoidCallback onCancelTagInput;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final tag in tags)
              _RecipeCreateTagChip(tag: tag, onRemove: () => onRemoveTag(tag)),
            if (isAddingTag)
              _RecipeCreateTagInputChip(
                controller: tagController,
                focusNode: tagFocusNode,
                onSubmitted: onSubmitTag,
                onCancel: onCancelTagInput,
              )
            else if (tags.length < 10)
              _RecipeCreateAddTagChip(onPressed: onAddTagPressed),
          ],
        ),
        if (tagSuggestions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          _RecipeCreateTagSuggestions(
            tags: tagSuggestions,
            onSelected: onSubmitTag,
          ),
        ],
      ],
    );
  }
}

class _RecipeCreateTagChip extends StatelessWidget {
  const _RecipeCreateTagChip({required this.tag, required this.onRemove});

  final String tag;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            RecipeFormOptions.readableTagLabel(tag),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.mainText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          InkResponse(
            onTap: onRemove,
            radius: 14,
            child: Icon(Icons.remove_rounded, size: 16, color: palette.icons),
          ),
        ],
      ),
    );
  }
}

class _RecipeCreateTagSuggestions extends StatelessWidget {
  const _RecipeCreateTagSuggestions({
    required this.tags,
    required this.onSelected,
  });

  final List<String> tags;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: palette.navbarBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: palette.borders.withValues(alpha: 0.62)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final tag in tags)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTapDown: (_) => onSelected(tag),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    RecipeFormOptions.readableTagLabel(tag),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.mainText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecipeCreateTagInputChip extends StatelessWidget {
  const _RecipeCreateTagInputChip({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: 220,
      padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.xs),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: palette.primaryButtons.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('recipe-create-tag-input'),
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 1,
              textInputAction: TextInputAction.done,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.mainText,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Tag',
                hintStyle: TextStyle(color: palette.secondaryText),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          IconButton(
            tooltip: 'Cancel tag',
            onPressed: onCancel,
            icon: const Icon(Icons.remove_rounded),
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          ),
        ],
      ),
    );
  }
}

class _RecipeCreateAddTagChip extends StatelessWidget {
  const _RecipeCreateAddTagChip({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ActionChip(
      key: const ValueKey('recipe-create-add-tag-chip'),
      onPressed: onPressed,
      avatar: Icon(Icons.add_rounded, size: 20, color: palette.mainText),
      label: const Text('Tag'),
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: palette.mainText,
        fontWeight: FontWeight.w800,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      backgroundColor: palette.primaryButtons.withValues(alpha: 0.18),
      shape: StadiumBorder(
        side: BorderSide(color: palette.primaryButtons.withValues(alpha: 0.48)),
      ),
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
