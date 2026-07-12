import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/recipes/data/recipe_form_options.dart';
import 'package:frontend/features/recipes/presentation/image_upload/recipe_image_picker.dart';
import 'package:frontend/shared/models/home_models.dart';

const double _recipeAuthorCardExtent = 224;
const double _recipeAuthorCardOffset = -60;
const double _recipeAuthorCardAngle = -0.2;

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

  _RecipeDurationValue copyWith({int? days, int? hours, int? minutes}) {
    return _RecipeDurationValue(
      days: days ?? this.days,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
    );
  }

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

enum _RecipeEditorTab { templates, blocks }

enum _RecipeBlockGroup { content, recipe, widgets, layout }

enum _RecipeBlockKind {
  section,
  columns,
  column,
  card,
  photoText,
  heading,
  paragraph,
  quote,
  image,
  video,
  note,
  divider,
  ingredients,
  steps,
  equipment,
  substitutions,
  nutrition,
  timer,
  servings,
  checklist,
}

enum _RecipeBlockWidth { narrow, normal, wide, full }

enum _RecipeBlockAlignment { left, center, right }

enum _RecipeBlockSpacing { compact, normal, spacious }

enum _RecipeBlockVariant { simple, cards, timeline }

enum _RecipeTextAlignment { left, center, right, justify }

enum _RecipeTextSize { extraSmall, small, medium, large, extraLarge }

enum _RecipeInspectorTab { block, content }

enum _RecipeQuoteLineSide { left, right }

extension _RecipeBlockKindDetails on _RecipeBlockKind {
  String get label {
    return switch (this) {
      _RecipeBlockKind.section => 'Section',
      _RecipeBlockKind.columns => 'Columns',
      _RecipeBlockKind.column => 'Column',
      _RecipeBlockKind.card => 'Card',
      _RecipeBlockKind.photoText => 'Photo + text',
      _RecipeBlockKind.heading => 'Heading',
      _RecipeBlockKind.paragraph => 'Paragraph',
      _RecipeBlockKind.quote => 'Quote',
      _RecipeBlockKind.image => 'Photo',
      _RecipeBlockKind.video => 'Video',
      _RecipeBlockKind.note => 'Note',
      _RecipeBlockKind.divider => 'Divider',
      _RecipeBlockKind.ingredients => 'Ingredients',
      _RecipeBlockKind.steps => 'Steps',
      _RecipeBlockKind.equipment => 'Equipment',
      _RecipeBlockKind.substitutions => 'Substitutions',
      _RecipeBlockKind.nutrition => 'Nutrition',
      _RecipeBlockKind.timer => 'Timer',
      _RecipeBlockKind.servings => 'Serving calculator',
      _RecipeBlockKind.checklist => 'Checklist',
    };
  }

  IconData get icon {
    return switch (this) {
      _RecipeBlockKind.section => Icons.view_agenda_rounded,
      _RecipeBlockKind.columns => Icons.view_column_rounded,
      _RecipeBlockKind.column => Icons.view_stream_rounded,
      _RecipeBlockKind.card => Icons.crop_square_rounded,
      _RecipeBlockKind.photoText => Icons.view_week_rounded,
      _RecipeBlockKind.heading => Icons.title_rounded,
      _RecipeBlockKind.paragraph => Icons.notes_rounded,
      _RecipeBlockKind.quote => Icons.format_quote_rounded,
      _RecipeBlockKind.image => Icons.image_rounded,
      _RecipeBlockKind.video => Icons.smart_display_rounded,
      _RecipeBlockKind.note => Icons.sticky_note_2_rounded,
      _RecipeBlockKind.divider => Icons.horizontal_rule_rounded,
      _RecipeBlockKind.ingredients => Icons.local_dining_rounded,
      _RecipeBlockKind.steps => Icons.format_list_numbered_rounded,
      _RecipeBlockKind.equipment => Icons.soup_kitchen_rounded,
      _RecipeBlockKind.substitutions => Icons.sync_alt_rounded,
      _RecipeBlockKind.nutrition => Icons.monitor_heart_rounded,
      _RecipeBlockKind.timer => Icons.timer_rounded,
      _RecipeBlockKind.servings => Icons.calculate_rounded,
      _RecipeBlockKind.checklist => Icons.checklist_rounded,
    };
  }

  _RecipeBlockGroup get group {
    return switch (this) {
      _RecipeBlockKind.heading ||
      _RecipeBlockKind.paragraph ||
      _RecipeBlockKind.quote ||
      _RecipeBlockKind.image ||
      _RecipeBlockKind.video ||
      _RecipeBlockKind.note ||
      _RecipeBlockKind.divider => _RecipeBlockGroup.content,
      _RecipeBlockKind.ingredients ||
      _RecipeBlockKind.steps ||
      _RecipeBlockKind.equipment ||
      _RecipeBlockKind.substitutions ||
      _RecipeBlockKind.nutrition => _RecipeBlockGroup.recipe,
      _RecipeBlockKind.timer ||
      _RecipeBlockKind.servings ||
      _RecipeBlockKind.checklist => _RecipeBlockGroup.widgets,
      _RecipeBlockKind.section ||
      _RecipeBlockKind.columns ||
      _RecipeBlockKind.column ||
      _RecipeBlockKind.card ||
      _RecipeBlockKind.photoText => _RecipeBlockGroup.layout,
    };
  }

  bool get canContainChildren {
    return switch (this) {
      _RecipeBlockKind.section ||
      _RecipeBlockKind.columns ||
      _RecipeBlockKind.column ||
      _RecipeBlockKind.card => true,
      _ => false,
    };
  }

  bool get supportsTextSettings {
    return this == _RecipeBlockKind.heading ||
        this == _RecipeBlockKind.paragraph ||
        this == _RecipeBlockKind.quote;
  }

  bool get supportsJustifiedText {
    return this == _RecipeBlockKind.paragraph || this == _RecipeBlockKind.quote;
  }
}

@immutable
class _RecipeEditorBlock {
  const _RecipeEditorBlock({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.width = _RecipeBlockWidth.normal,
    this.alignment = _RecipeBlockAlignment.left,
    this.spacing = _RecipeBlockSpacing.normal,
    this.variant = _RecipeBlockVariant.simple,
    this.textAlignment = _RecipeTextAlignment.left,
    this.textSize = _RecipeTextSize.medium,
    this.quoteAuthor = '',
    this.quoteLineSide = _RecipeQuoteLineSide.left,
    this.editorHeight,
    this.children = const [],
  });

  final String id;
  final _RecipeBlockKind kind;
  final String title;
  final String body;
  final _RecipeBlockWidth width;
  final _RecipeBlockAlignment alignment;
  final _RecipeBlockSpacing spacing;
  final _RecipeBlockVariant variant;
  final _RecipeTextAlignment textAlignment;
  final _RecipeTextSize textSize;
  final String quoteAuthor;
  final _RecipeQuoteLineSide quoteLineSide;
  final double? editorHeight;
  final List<_RecipeEditorBlock> children;

  bool get canContainChildren => kind.canContainChildren;

  _RecipeEditorBlock copyWith({
    String? id,
    _RecipeBlockKind? kind,
    String? title,
    String? body,
    _RecipeBlockWidth? width,
    _RecipeBlockAlignment? alignment,
    _RecipeBlockSpacing? spacing,
    _RecipeBlockVariant? variant,
    _RecipeTextAlignment? textAlignment,
    _RecipeTextSize? textSize,
    String? quoteAuthor,
    _RecipeQuoteLineSide? quoteLineSide,
    double? editorHeight,
    List<_RecipeEditorBlock>? children,
  }) {
    return _RecipeEditorBlock(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      width: width ?? this.width,
      alignment: alignment ?? this.alignment,
      spacing: spacing ?? this.spacing,
      variant: variant ?? this.variant,
      textAlignment: textAlignment ?? this.textAlignment,
      textSize: textSize ?? this.textSize,
      quoteAuthor: quoteAuthor ?? this.quoteAuthor,
      quoteLineSide: quoteLineSide ?? this.quoteLineSide,
      editorHeight: editorHeight ?? this.editorHeight,
      children: children ?? this.children,
    );
  }
}

@immutable
abstract class _RecipeEditorDragData {
  const _RecipeEditorDragData();
}

@immutable
class _RecipeBlockDragData extends _RecipeEditorDragData {
  const _RecipeBlockDragData({
    required this.blockId,
    required this.sourceParentId,
    required this.sourceIndex,
    required this.sourceDepth,
  }) : super();

  final String blockId;
  final String? sourceParentId;
  final int sourceIndex;
  final int sourceDepth;
}

@immutable
class _RecipePaletteBlockDragData extends _RecipeEditorDragData {
  const _RecipePaletteBlockDragData(this.block);

  final _RecipeBlockDefinition block;
}

@immutable
class _RecipeBlockDropTarget {
  const _RecipeBlockDropTarget({
    required this.parentId,
    required this.index,
    required this.depth,
  });

  final String? parentId;
  final int index;
  final int depth;
}

@immutable
class _RecipeBlockLocation {
  const _RecipeBlockLocation({
    required this.block,
    required this.parentId,
    required this.index,
    required this.depth,
  });

  final _RecipeEditorBlock block;
  final String? parentId;
  final int index;
  final int depth;
}

@immutable
class _RecipeBlockExtraction {
  const _RecipeBlockExtraction({required this.blocks, this.block});

  final List<_RecipeEditorBlock> blocks;
  final _RecipeEditorBlock? block;
}

class _RecipeBlockHoverController {
  final Map<String, ValueNotifier<bool>> _blockStates = {};
  String? _activeBlockId;

  ValueNotifier<bool> listenableFor(String blockId) {
    return _blockStates.putIfAbsent(blockId, () => ValueNotifier(false));
  }

  void activate(String? blockId) {
    if (_activeBlockId == blockId) {
      return;
    }

    final previousId = _activeBlockId;
    _activeBlockId = blockId;
    if (previousId != null) {
      _blockStates[previousId]?.value = false;
    }
    if (blockId != null) {
      listenableFor(blockId).value = true;
    }
  }

  void dispose() {
    for (final state in _blockStates.values) {
      state.dispose();
    }
    _blockStates.clear();
  }
}

@immutable
class _RecipeBlockDefinition {
  const _RecipeBlockDefinition({required this.kind, required this.description});

  final _RecipeBlockKind kind;
  final String description;
}

@immutable
class _RecipeTemplateDefinition {
  const _RecipeTemplateDefinition({
    required this.title,
    required this.description,
    required this.icon,
    required this.createBlocks,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<_RecipeEditorBlock> Function(String Function(String prefix))
  createBlocks;
}

class RecipeCreatePage extends StatefulWidget {
  const RecipeCreatePage({super.key});

  @override
  State<RecipeCreatePage> createState() => _RecipeCreatePageState();
}

class _RecipeCreatePageState extends State<RecipeCreatePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _tagFocusNode = FocusNode();
  final List<String> _tags = [];
  _RecipeDurationValue _duration = const _RecipeDurationValue(
    days: 0,
    hours: 0,
    minutes: 20,
  );
  String _difficulty = 'Easy';
  CategoryModel? _category;
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);

    return Scaffold(
      key: const ValueKey('recipe-create-page'),
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
              controller: _scrollController,
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
                          scrollController: _scrollController,
                          imageUrl: _imageUrl,
                          titleController: _titleController,
                          descriptionController: _descriptionController,
                          tags: _tags,
                          isAddingTag: _isAddingTag,
                          tagController: _tagController,
                          tagFocusNode: _tagFocusNode,
                          tagSuggestions: _tagSuggestions,
                          duration: _duration,
                          difficulty: _difficulty,
                          category: _category,
                          onEditDuration: _editDuration,
                          onEditDifficulty: _editDifficulty,
                          onEditCategory: _editCategory,
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

  Future<void> _editDuration() async {
    final value = await showDialog<_RecipeDurationValue>(
      context: context,
      builder: (context) => _RecipeDurationPickerDialog(initial: _duration),
    );
    if (!mounted || value == null) {
      return;
    }

    setState(() {
      _duration = value;
    });
  }

  Future<void> _editDifficulty() async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => _RecipeDifficultyDialog(selected: _difficulty),
    );
    if (!mounted || value == null) {
      return;
    }

    setState(() {
      _difficulty = value;
    });
  }

  Future<void> _editCategory() async {
    final value = await showDialog<CategoryModel>(
      context: context,
      builder: (context) => _RecipeCategoryDialog(selected: _category),
    );
    if (!mounted || value == null) {
      return;
    }

    setState(() {
      _category = value;
    });
  }

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
    required this.scrollController,
    required this.imageUrl,
    required this.titleController,
    required this.descriptionController,
    required this.tags,
    required this.isAddingTag,
    required this.tagController,
    required this.tagFocusNode,
    required this.tagSuggestions,
    required this.duration,
    required this.difficulty,
    required this.category,
    required this.onEditDuration,
    required this.onEditDifficulty,
    required this.onEditCategory,
    required this.onSubmitTag,
    required this.onRemoveTag,
    required this.onAddTagPressed,
    required this.onCancelTagInput,
    required this.onPickImage,
  });

  final ScrollController scrollController;
  final String? imageUrl;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<String> tags;
  final bool isAddingTag;
  final TextEditingController tagController;
  final FocusNode tagFocusNode;
  final List<String> tagSuggestions;
  final _RecipeDurationValue duration;
  final String difficulty;
  final CategoryModel? category;
  final VoidCallback onEditDuration;
  final VoidCallback onEditDifficulty;
  final VoidCallback onEditCategory;
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
          difficulty: difficulty,
          category: category,
          onEditDuration: onEditDuration,
          onEditDifficulty: onEditDifficulty,
          onEditCategory: onEditCategory,
          onSubmitTag: onSubmitTag,
          onRemoveTag: onRemoveTag,
          onAddTagPressed: onAddTagPressed,
          onCancelTagInput: onCancelTagInput,
          onPickImage: onPickImage,
        ),
        const SizedBox(height: AppSpacing.xl),
        _RecipeBodyEditor(scrollController: scrollController),
      ],
    );
  }
}

class _RecipeBodyEditor extends StatefulWidget {
  const _RecipeBodyEditor({required this.scrollController});

  final ScrollController scrollController;

  @override
  State<_RecipeBodyEditor> createState() => _RecipeBodyEditorState();
}

class _RecipeBodyEditorState extends State<_RecipeBodyEditor> {
  static const int _maxDepth = 4;

  final OverlayPortalController _overlayController = OverlayPortalController();
  final _RecipeBlockHoverController _hoveredBlockId =
      _RecipeBlockHoverController();
  int _nextId = 0;
  _RecipeEditorTab _activeTab = _RecipeEditorTab.templates;
  bool _paletteExpanded = false;
  bool _inspectorExpanded = false;
  bool _appendNextBlock = false;
  int _blockPaletteCue = 0;
  String? _selectedBlockId;
  late List<_RecipeEditorBlock> _blocks = _initialBlocks();

  late final List<_RecipeBlockDefinition> _blockDefinitions = [
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.heading,
      description: 'Section title with strong hierarchy.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.paragraph,
      description: 'Body copy for preparation details.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.quote,
      description: 'Call out a chef note or personal tip.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.image,
      description: 'Add a supporting process photo.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.video,
      description: 'Embed a short cooking clip.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.note,
      description: 'Highlight timing, texture, or storage advice.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.divider,
      description: 'Separate two parts of the recipe.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.ingredients,
      description: 'Structured ingredient checklist.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.steps,
      description: 'Ordered cooking instructions.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.equipment,
      description: 'Tools and cookware required.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.substitutions,
      description: 'Alternative ingredients or swaps.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.nutrition,
      description: 'Nutrition facts summary.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.timer,
      description: 'Inline timer for a cooking step.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.servings,
      description: 'Scale ingredient amounts by servings.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.checklist,
      description: 'Track prep tasks before cooking.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.section,
      description: 'Vertical container for related blocks.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.columns,
      description: 'Two-column responsive layout.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.card,
      description: 'Framed group for compact content.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.photoText,
      description: 'Photo beside explanatory text.',
    ),
  ];

  late final List<_RecipeTemplateDefinition> _templateDefinitions = [
    _RecipeTemplateDefinition(
      title: 'Classic method',
      description: 'Ingredients beside numbered steps.',
      icon: Icons.menu_book_rounded,
      createBlocks: (id) => [
        _RecipeEditorBlock(
          id: id('section'),
          kind: _RecipeBlockKind.section,
          title: 'Method',
          body: 'Keep the core flow compact and easy to scan.',
          width: _RecipeBlockWidth.wide,
          children: [
            _RecipeEditorBlock(
              id: id('ingredients'),
              kind: _RecipeBlockKind.ingredients,
              title: 'Ingredients',
              body: '1 onion\n2 garlic cloves\n400 g tomatoes',
              variant: _RecipeBlockVariant.cards,
            ),
            _RecipeEditorBlock(
              id: id('steps'),
              kind: _RecipeBlockKind.steps,
              title: 'Steps',
              body: 'Prep the ingredients.\nCook the base.\nFinish and serve.',
              variant: _RecipeBlockVariant.timeline,
            ),
          ],
        ),
      ],
    ),
    _RecipeTemplateDefinition(
      title: 'Story with photo',
      description: 'Intro, image, and a chef note.',
      icon: Icons.auto_stories_rounded,
      createBlocks: (id) => [
        _RecipeEditorBlock(
          id: id('section'),
          kind: _RecipeBlockKind.section,
          title: 'Before you start',
          body: 'Set context before the actual method.',
          children: [
            _RecipeEditorBlock(
              id: id('paragraph'),
              kind: _RecipeBlockKind.paragraph,
              title: 'Why this works',
              body:
                  'Short, practical context that helps the cook understand the recipe.',
            ),
            _RecipeEditorBlock(
              id: id('image'),
              kind: _RecipeBlockKind.image,
              title: 'Process photo',
              body: 'Show the key texture or color.',
              width: _RecipeBlockWidth.wide,
            ),
            _RecipeEditorBlock(
              id: id('note'),
              kind: _RecipeBlockKind.note,
              title: 'Chef note',
              body: 'A small adjustment that makes the result more reliable.',
            ),
          ],
        ),
      ],
    ),
    _RecipeTemplateDefinition(
      title: 'Prep checklist',
      description: 'Equipment, prep tasks, and timer.',
      icon: Icons.task_alt_rounded,
      createBlocks: (id) => [
        _RecipeEditorBlock(
          id: id('section'),
          kind: _RecipeBlockKind.section,
          title: 'Prep station',
          body: 'Get everything ready before heat hits the pan.',
          variant: _RecipeBlockVariant.cards,
          children: [
            _RecipeEditorBlock(
              id: id('equipment'),
              kind: _RecipeBlockKind.equipment,
              title: 'Equipment',
              body: 'Large skillet\nMixing bowl\nSharp knife',
            ),
            _RecipeEditorBlock(
              id: id('checklist'),
              kind: _RecipeBlockKind.checklist,
              title: 'Prep checklist',
              body: 'Wash produce\nMeasure spices\nPreheat oven',
            ),
            _RecipeEditorBlock(
              id: id('timer'),
              kind: _RecipeBlockKind.timer,
              title: 'Resting timer',
              body: '10 minutes',
            ),
          ],
        ),
      ],
    ),
  ];

  List<_RecipeEditorBlock> _initialBlocks() {
    final sectionId = _newBlockId('section');
    final ingredientsId = _newBlockId('ingredients');
    final stepsId = _newBlockId('steps');

    _selectedBlockId = sectionId;

    return [
      _RecipeEditorBlock(
        id: sectionId,
        kind: _RecipeBlockKind.section,
        title: 'Cooking flow',
        body: 'Build the main preparation story here.',
        width: _RecipeBlockWidth.wide,
        children: [
          _RecipeEditorBlock(
            id: ingredientsId,
            kind: _RecipeBlockKind.ingredients,
            title: 'Ingredients',
            body: '2 cups flour\n1 tsp salt\n1 cup warm water',
            variant: _RecipeBlockVariant.cards,
          ),
          _RecipeEditorBlock(
            id: stepsId,
            kind: _RecipeBlockKind.steps,
            title: 'Steps',
            body:
                'Mix the dry ingredients.\nFold in the wet ingredients.\nBake until golden.',
            variant: _RecipeBlockVariant.timeline,
          ),
        ],
      ),
    ];
  }

  String _newBlockId(String prefix) {
    _nextId += 1;
    return '$prefix-$_nextId';
  }

  _RecipeEditorBlock _createBlock(_RecipeBlockKind kind) {
    if (kind == _RecipeBlockKind.columns) {
      return _RecipeEditorBlock(
        id: _newBlockId(kind.name),
        kind: kind,
        title: kind.label,
        body: _defaultBodyForKind(kind),
        width: _RecipeBlockWidth.full,
        children: [
          _RecipeEditorBlock(
            id: _newBlockId('column'),
            kind: _RecipeBlockKind.column,
            title: 'Column',
            body: 'Drop blocks here.',
            width: _RecipeBlockWidth.full,
          ),
          _RecipeEditorBlock(
            id: _newBlockId('column'),
            kind: _RecipeBlockKind.column,
            title: 'Column',
            body: 'Drop blocks here.',
            width: _RecipeBlockWidth.full,
          ),
        ],
      );
    }

    if (kind == _RecipeBlockKind.photoText) {
      return _RecipeEditorBlock(
        id: _newBlockId(kind.name),
        kind: kind,
        title: kind.label,
        body: _defaultBodyForKind(kind),
        width: _RecipeBlockWidth.full,
        children: [
          _RecipeEditorBlock(
            id: _newBlockId('image'),
            kind: _RecipeBlockKind.image,
            title: 'Photo',
            body: 'Process image placeholder',
            width: _RecipeBlockWidth.full,
          ),
          _RecipeEditorBlock(
            id: _newBlockId('paragraph'),
            kind: _RecipeBlockKind.paragraph,
            title: 'Caption',
            body: 'Explain what the cook should look for here.',
            width: _RecipeBlockWidth.full,
          ),
        ],
      );
    }

    return _RecipeEditorBlock(
      id: _newBlockId(kind.name),
      kind: kind,
      title: kind.label,
      body: _defaultBodyForKind(kind),
      width: kind.group == _RecipeBlockGroup.layout
          ? _RecipeBlockWidth.wide
          : _RecipeBlockWidth.normal,
      variant: kind == _RecipeBlockKind.steps
          ? _RecipeBlockVariant.timeline
          : _RecipeBlockVariant.simple,
    );
  }

  String _defaultBodyForKind(_RecipeBlockKind kind) {
    return switch (kind) {
      _RecipeBlockKind.heading => 'New section',
      _RecipeBlockKind.paragraph =>
        'Write the cooking detail directly in the page preview.',
      _RecipeBlockKind.quote => 'A useful note from the cook.',
      _RecipeBlockKind.image => 'Image placeholder',
      _RecipeBlockKind.video => 'Video URL or embed placeholder',
      _RecipeBlockKind.note => 'Keep this tip short and practical.',
      _RecipeBlockKind.divider => '',
      _RecipeBlockKind.ingredients => 'Ingredient one\nIngredient two',
      _RecipeBlockKind.steps => 'First step\nSecond step',
      _RecipeBlockKind.equipment => 'Skillet\nKnife\nMixing bowl',
      _RecipeBlockKind.substitutions => 'Swap butter for olive oil.',
      _RecipeBlockKind.nutrition => 'Calories, protein, carbs, and fat.',
      _RecipeBlockKind.timer => '15 minutes',
      _RecipeBlockKind.servings => 'Serves 4',
      _RecipeBlockKind.checklist => 'Prep vegetables\nHeat pan',
      _RecipeBlockKind.section => 'Group related content here.',
      _RecipeBlockKind.columns => 'Responsive column group.',
      _RecipeBlockKind.column => 'Column content.',
      _RecipeBlockKind.card => 'Framed content group.',
      _RecipeBlockKind.photoText => 'Pair a photo with a short instruction.',
    };
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_syncOverlayVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncOverlayVisibility();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _RecipeBodyEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController == widget.scrollController) {
      return;
    }
    oldWidget.scrollController.removeListener(_syncOverlayVisibility);
    widget.scrollController.addListener(_syncOverlayVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncOverlayVisibility();
      }
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_syncOverlayVisibility);
    _hoveredBlockId.dispose();
    super.dispose();
  }

  void _syncOverlayVisibility() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final viewportHeight = MediaQuery.sizeOf(context).height;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);
    final top = renderObject.localToGlobal(Offset.zero).dy;
    final bottom = top + renderObject.size.height;
    final visible = bottom > headerHeight && top < viewportHeight - 80;

    if (visible && !_overlayController.isShowing) {
      _overlayController.show();
    } else if (!visible && _overlayController.isShowing) {
      _overlayController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasPanel = _RecipeEditorCanvas(
      blocks: _blocks,
      selectedBlockId: _selectedBlockId,
      hoveredBlockId: _hoveredBlockId,
      onBlockSelected: _selectBlock,
      onSelectionCleared: _clearBlockSelection,
      onBlockTitleChanged: _updateBlockTitle,
      onBlockBodyChanged: _updateBlockBody,
      onBlockQuoteAuthorChanged: _updateBlockQuoteAuthor,
      onBlockHeightChanged: _updateBlockHeight,
      onAppendBlockRequested: _prepareAppendBlock,
      canDropBlock: _canDropBlock,
      onDropBlock: _dropBlock,
      onDeleteBlock: _deleteBlock,
    );

    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) => _RecipeEditorOverlay(
        activeTab: _activeTab,
        paletteExpanded: _paletteExpanded,
        inspectorExpanded: _inspectorExpanded,
        blockPaletteCue: _blockPaletteCue,
        templates: _templateDefinitions,
        blocks: _blockDefinitions,
        selectedBlock: _selectedBlock,
        onTabChanged: _setActiveTab,
        onPaletteExpandedChanged: (value) {
          setState(() {
            _paletteExpanded = value;
            if (value) {
              _inspectorExpanded = false;
            }
          });
        },
        onInspectorExpandedChanged: (value) {
          setState(() {
            _inspectorExpanded = value;
            if (value) {
              _paletteExpanded = false;
            }
          });
        },
        onTemplateSelected: _insertTemplate,
        onBlockSelected: _insertBlock,
        onWidthChanged: _updateSelectedBlockWidth,
        onAlignmentChanged: _updateSelectedBlockAlignment,
        onSpacingChanged: _updateSelectedBlockSpacing,
        onVariantChanged: _updateSelectedBlockVariant,
        onTextAlignmentChanged: _updateSelectedBlockTextAlignment,
        onTextSizeChanged: _updateSelectedBlockTextSize,
        onBlockChanged: _replaceBlock,
      ),
      child: canvasPanel,
    );
  }

  _RecipeEditorBlock? get _selectedBlock {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return null;
    }
    return _findBlock(_blocks, blockId);
  }

  _RecipeEditorBlock? _findBlock(
    List<_RecipeEditorBlock> blocks,
    String blockId,
  ) {
    for (final block in blocks) {
      if (block.id == blockId) {
        return block;
      }
      final child = _findBlock(block.children, blockId);
      if (child != null) {
        return child;
      }
    }
    return null;
  }

  void _setActiveTab(_RecipeEditorTab tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  void _selectBlock(String blockId) {
    setState(() {
      _selectedBlockId = blockId;
    });
  }

  void _clearBlockSelection() {
    if (_selectedBlockId == null) {
      return;
    }
    setState(() {
      _selectedBlockId = null;
    });
  }

  void _updateBlockTitle(String blockId, String title) {
    _updateBlock(blockId, (block) => block.copyWith(title: title));
  }

  void _updateBlockBody(String blockId, String body) {
    _updateBlock(blockId, (block) => block.copyWith(body: body));
  }

  void _updateBlockQuoteAuthor(String blockId, String author) {
    _updateBlock(blockId, (block) => block.copyWith(quoteAuthor: author));
  }

  void _updateBlockHeight(String blockId, double height) {
    _updateBlock(blockId, (block) => block.copyWith(editorHeight: height));
  }

  void _updateSelectedBlockWidth(_RecipeBlockWidth width) {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return;
    }
    _updateBlock(blockId, (block) => block.copyWith(width: width));
  }

  void _updateSelectedBlockAlignment(_RecipeBlockAlignment alignment) {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return;
    }
    _updateBlock(blockId, (block) => block.copyWith(alignment: alignment));
  }

  void _updateSelectedBlockSpacing(_RecipeBlockSpacing spacing) {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return;
    }
    _updateBlock(blockId, (block) => block.copyWith(spacing: spacing));
  }

  void _updateSelectedBlockVariant(_RecipeBlockVariant variant) {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return;
    }
    _updateBlock(blockId, (block) => block.copyWith(variant: variant));
  }

  void _updateSelectedBlockTextAlignment(_RecipeTextAlignment alignment) {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return;
    }
    _updateBlock(blockId, (block) => block.copyWith(textAlignment: alignment));
  }

  void _updateSelectedBlockTextSize(_RecipeTextSize size) {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return;
    }
    _updateBlock(blockId, (block) => block.copyWith(textSize: size));
  }

  void _updateBlock(
    String blockId,
    _RecipeEditorBlock Function(_RecipeEditorBlock block) update,
  ) {
    setState(() {
      _blocks = _mapBlocks(_blocks, blockId, update);
    });
  }

  void _replaceBlock(_RecipeEditorBlock block) {
    _updateBlock(block.id, (_) => block);
  }

  List<_RecipeEditorBlock> _mapBlocks(
    List<_RecipeEditorBlock> blocks,
    String blockId,
    _RecipeEditorBlock Function(_RecipeEditorBlock block) update,
  ) {
    return [
      for (final block in blocks)
        if (block.id == blockId)
          update(block)
        else
          block.copyWith(children: _mapBlocks(block.children, blockId, update)),
    ];
  }

  void _insertTemplate(_RecipeTemplateDefinition template) {
    final blocks = template.createBlocks(_newBlockId);
    _insertBlocksUsingSelection(blocks);
  }

  void _insertBlock(_RecipeBlockDefinition block) {
    final target = _appendNextBlock
        ? _RecipeBlockDropTarget(
            parentId: null,
            index: _blocks.length,
            depth: 0,
          )
        : _insertionTargetAfterSelection(block.kind);
    _insertPaletteBlock(block, target);
  }

  void _prepareAppendBlock() {
    setState(() {
      _activeTab = _RecipeEditorTab.blocks;
      _appendNextBlock = true;
      _blockPaletteCue += 1;
    });
  }

  _RecipeBlockDropTarget _insertionTargetAfterSelection(_RecipeBlockKind kind) {
    var selectedId = _selectedBlockId;
    while (selectedId != null) {
      final location = _findBlockLocation(_blocks, selectedId);
      if (location == null) {
        break;
      }

      final target = _RecipeBlockDropTarget(
        parentId: location.parentId,
        index: location.index + 1,
        depth: location.depth,
      );
      if (_canInsertPaletteBlock(kind, target)) {
        return target;
      }
      selectedId = location.parentId;
    }

    return _RecipeBlockDropTarget(
      parentId: null,
      index: _blocks.length,
      depth: 0,
    );
  }

  void _insertPaletteBlock(
    _RecipeBlockDefinition definition,
    _RecipeBlockDropTarget target,
  ) {
    if (!_canInsertPaletteBlock(definition.kind, target)) {
      return;
    }

    final block = _createBlock(definition.kind);
    setState(() {
      _blocks = _insertMovedBlock(
        _blocks,
        target.parentId,
        target.index,
        block,
      );
      _selectedBlockId = block.id;
      _appendNextBlock = false;
    });
  }

  bool _canInsertPaletteBlock(
    _RecipeBlockKind kind,
    _RecipeBlockDropTarget target,
  ) {
    if (target.parentId != null) {
      final parent = _findBlock(_blocks, target.parentId!);
      if (parent == null || !parent.canContainChildren) {
        return false;
      }
    }

    final insertedTreeHeight = switch (kind) {
      _RecipeBlockKind.columns || _RecipeBlockKind.photoText => 2,
      _ => 1,
    };
    return target.depth + insertedTreeHeight - 1 <= _maxDepth;
  }

  bool _canMoveBlock(_RecipeBlockDragData data, _RecipeBlockDropTarget target) {
    final source = _findBlockLocation(_blocks, data.blockId);
    if (source == null) {
      return false;
    }

    if (source.parentId == target.parentId &&
        (target.index == source.index || target.index == source.index + 1)) {
      return false;
    }

    if (target.parentId == source.block.id ||
        _blockContains(source.block, target.parentId)) {
      return false;
    }

    if (target.parentId != null) {
      final parent = _findBlock(_blocks, target.parentId!);
      if (parent == null || !parent.canContainChildren) {
        return false;
      }
    }

    final movedTreeHeight = _blockTreeHeight(source.block);
    return target.depth + movedTreeHeight - 1 <= _maxDepth;
  }

  bool _canDropBlock(
    _RecipeEditorDragData data,
    _RecipeBlockDropTarget target,
  ) {
    return switch (data) {
      _RecipeBlockDragData() => _canMoveBlock(data, target),
      _RecipePaletteBlockDragData() => _canInsertPaletteBlock(
        data.block.kind,
        target,
      ),
      _ => false,
    };
  }

  void _dropBlock(_RecipeEditorDragData data, _RecipeBlockDropTarget target) {
    switch (data) {
      case _RecipeBlockDragData():
        _moveBlock(data, target);
        return;
      case _RecipePaletteBlockDragData():
        _insertPaletteBlock(data.block, target);
        return;
      default:
        return;
    }
  }

  void _moveBlock(_RecipeBlockDragData data, _RecipeBlockDropTarget target) {
    if (!_canMoveBlock(data, target)) {
      return;
    }

    setState(() {
      final source = _findBlockLocation(_blocks, data.blockId)!;
      final extraction = _extractBlock(_blocks, data.blockId);
      final movedBlock = extraction.block;
      if (movedBlock == null) {
        return;
      }

      var targetIndex = target.index;
      if (source.parentId == target.parentId && source.index < targetIndex) {
        targetIndex -= 1;
      }

      _blocks = _insertMovedBlock(
        extraction.blocks,
        target.parentId,
        targetIndex,
        movedBlock,
      );
      _selectedBlockId = movedBlock.id;
    });
  }

  _RecipeBlockLocation? _findBlockLocation(
    List<_RecipeEditorBlock> blocks,
    String blockId, {
    String? parentId,
    int depth = 0,
  }) {
    for (var index = 0; index < blocks.length; index++) {
      final block = blocks[index];
      if (block.id == blockId) {
        return _RecipeBlockLocation(
          block: block,
          parentId: parentId,
          index: index,
          depth: depth,
        );
      }

      final childLocation = _findBlockLocation(
        block.children,
        blockId,
        parentId: block.id,
        depth: depth + 1,
      );
      if (childLocation != null) {
        return childLocation;
      }
    }
    return null;
  }

  bool _blockContains(_RecipeEditorBlock block, String? blockId) {
    if (blockId == null) {
      return false;
    }
    for (final child in block.children) {
      if (child.id == blockId || _blockContains(child, blockId)) {
        return true;
      }
    }
    return false;
  }

  _RecipeBlockExtraction _extractBlock(
    List<_RecipeEditorBlock> blocks,
    String blockId,
  ) {
    for (var index = 0; index < blocks.length; index++) {
      final block = blocks[index];
      if (block.id == blockId) {
        return _RecipeBlockExtraction(
          blocks: [...blocks]..removeAt(index),
          block: block,
        );
      }

      final childExtraction = _extractBlock(block.children, blockId);
      if (childExtraction.block != null) {
        final nextBlocks = [...blocks];
        nextBlocks[index] = block.copyWith(children: childExtraction.blocks);
        return _RecipeBlockExtraction(
          blocks: nextBlocks,
          block: childExtraction.block,
        );
      }
    }
    return _RecipeBlockExtraction(blocks: blocks);
  }

  List<_RecipeEditorBlock> _insertMovedBlock(
    List<_RecipeEditorBlock> blocks,
    String? parentId,
    int index,
    _RecipeEditorBlock movedBlock,
  ) {
    if (parentId == null) {
      final targetIndex = index.clamp(0, blocks.length).toInt();
      return [...blocks]..insert(targetIndex, movedBlock);
    }

    return [
      for (final block in blocks)
        if (block.id == parentId)
          block.copyWith(
            children: [...block.children]
              ..insert(
                index.clamp(0, block.children.length).toInt(),
                movedBlock,
              ),
          )
        else
          block.copyWith(
            children: _insertMovedBlock(
              block.children,
              parentId,
              index,
              movedBlock,
            ),
          ),
    ];
  }

  void _deleteBlock(String blockId) {
    setState(() {
      _blocks = _removeBlockFromList(_blocks, blockId);
      if (_selectedBlockId == blockId) {
        _selectedBlockId = _blocks.isEmpty ? null : _blocks.first.id;
      }
    });
  }

  List<_RecipeEditorBlock> _removeBlockFromList(
    List<_RecipeEditorBlock> blocks,
    String blockId,
  ) {
    return [
      for (final block in blocks)
        if (block.id != blockId)
          block.copyWith(
            children: _removeBlockFromList(block.children, blockId),
          ),
    ];
  }

  void _insertRootBlocks(List<_RecipeEditorBlock> blocks) {
    if (blocks.isEmpty) {
      return;
    }

    setState(() {
      _blocks = [..._blocks, ...blocks];
      _selectedBlockId = blocks.last.id;
    });
  }

  void _insertBlocksUsingSelection(List<_RecipeEditorBlock> blocks) {
    if (blocks.isEmpty) {
      return;
    }

    final selected = _selectedBlock;
    final selectedId = selected?.id;
    if (selected == null ||
        selectedId == null ||
        !_canInsertBlocksInto(selectedId, selected, blocks)) {
      _insertRootBlocks(blocks);
      return;
    }

    setState(() {
      _blocks = _insertChildrenInto(_blocks, selectedId, blocks);
      _selectedBlockId = blocks.last.id;
    });
  }

  bool _canInsertBlocksInto(
    String parentId,
    _RecipeEditorBlock parent,
    List<_RecipeEditorBlock> blocks,
  ) {
    if (!parent.canContainChildren) {
      return false;
    }

    final parentDepth = _depthOfBlock(_blocks, parentId);
    if (parentDepth == null) {
      return false;
    }

    final insertedHeight = blocks.fold<int>(1, (height, block) {
      final blockHeight = _blockTreeHeight(block);
      return blockHeight > height ? blockHeight : height;
    });

    return parentDepth + insertedHeight <= _maxDepth;
  }

  int? _depthOfBlock(
    List<_RecipeEditorBlock> blocks,
    String blockId, [
    int depth = 0,
  ]) {
    for (final block in blocks) {
      if (block.id == blockId) {
        return depth;
      }
      final childDepth = _depthOfBlock(block.children, blockId, depth + 1);
      if (childDepth != null) {
        return childDepth;
      }
    }
    return null;
  }

  int _blockTreeHeight(_RecipeEditorBlock block) {
    if (block.children.isEmpty) {
      return 1;
    }

    return 1 +
        block.children.fold<int>(0, (height, child) {
          final childHeight = _blockTreeHeight(child);
          return childHeight > height ? childHeight : height;
        });
  }

  List<_RecipeEditorBlock> _insertChildrenInto(
    List<_RecipeEditorBlock> blocks,
    String parentId,
    List<_RecipeEditorBlock> children,
  ) {
    return [
      for (final block in blocks)
        if (block.id == parentId)
          block.copyWith(children: [...block.children, ...children])
        else
          block.copyWith(
            children: _insertChildrenInto(block.children, parentId, children),
          ),
    ];
  }
}

class _RecipeEditorOverlay extends StatelessWidget {
  const _RecipeEditorOverlay({
    required this.activeTab,
    required this.paletteExpanded,
    required this.inspectorExpanded,
    required this.blockPaletteCue,
    required this.templates,
    required this.blocks,
    required this.selectedBlock,
    required this.onTabChanged,
    required this.onPaletteExpandedChanged,
    required this.onInspectorExpandedChanged,
    required this.onTemplateSelected,
    required this.onBlockSelected,
    required this.onWidthChanged,
    required this.onAlignmentChanged,
    required this.onSpacingChanged,
    required this.onVariantChanged,
    required this.onTextAlignmentChanged,
    required this.onTextSizeChanged,
    required this.onBlockChanged,
  });

  final _RecipeEditorTab activeTab;
  final bool paletteExpanded;
  final bool inspectorExpanded;
  final int blockPaletteCue;
  final List<_RecipeTemplateDefinition> templates;
  final List<_RecipeBlockDefinition> blocks;
  final _RecipeEditorBlock? selectedBlock;
  final ValueChanged<_RecipeEditorTab> onTabChanged;
  final ValueChanged<bool> onPaletteExpandedChanged;
  final ValueChanged<bool> onInspectorExpandedChanged;
  final ValueChanged<_RecipeTemplateDefinition> onTemplateSelected;
  final ValueChanged<_RecipeBlockDefinition> onBlockSelected;
  final ValueChanged<_RecipeBlockWidth> onWidthChanged;
  final ValueChanged<_RecipeBlockAlignment> onAlignmentChanged;
  final ValueChanged<_RecipeBlockSpacing> onSpacingChanged;
  final ValueChanged<_RecipeBlockVariant> onVariantChanged;
  final ValueChanged<_RecipeTextAlignment> onTextAlignmentChanged;
  final ValueChanged<_RecipeTextSize> onTextSizeChanged;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);
    final top = headerHeight + AppSpacing.sm;

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          top: top,
          bottom: AppSpacing.sm,
          left: paletteExpanded ? AppSpacing.sm : 0,
          child: _RecipePaletteDock(
            expanded: paletteExpanded,
            activeTab: activeTab,
            blockPaletteCue: blockPaletteCue,
            templates: templates,
            blocks: blocks,
            onExpandedChanged: onPaletteExpandedChanged,
            onTabChanged: onTabChanged,
            onTemplateSelected: onTemplateSelected,
            onBlockSelected: onBlockSelected,
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          top: top,
          height: inspectorExpanded
              ? MediaQuery.sizeOf(context).height - top - AppSpacing.sm
              : 52,
          right: inspectorExpanded ? AppSpacing.sm : 0,
          child: _RecipeInspectorDock(
            expanded: inspectorExpanded,
            block: selectedBlock,
            onExpandedChanged: onInspectorExpandedChanged,
            onWidthChanged: onWidthChanged,
            onAlignmentChanged: onAlignmentChanged,
            onSpacingChanged: onSpacingChanged,
            onVariantChanged: onVariantChanged,
            onTextAlignmentChanged: onTextAlignmentChanged,
            onTextSizeChanged: onTextSizeChanged,
            onBlockChanged: onBlockChanged,
          ),
        ),
      ],
    );
  }
}

class _RecipePaletteDock extends StatefulWidget {
  const _RecipePaletteDock({
    required this.expanded,
    required this.activeTab,
    required this.blockPaletteCue,
    required this.templates,
    required this.blocks,
    required this.onExpandedChanged,
    required this.onTabChanged,
    required this.onTemplateSelected,
    required this.onBlockSelected,
  });

  final bool expanded;
  final _RecipeEditorTab activeTab;
  final int blockPaletteCue;
  final List<_RecipeTemplateDefinition> templates;
  final List<_RecipeBlockDefinition> blocks;
  final ValueChanged<bool> onExpandedChanged;
  final ValueChanged<_RecipeEditorTab> onTabChanged;
  final ValueChanged<_RecipeTemplateDefinition> onTemplateSelected;
  final ValueChanged<_RecipeBlockDefinition> onBlockSelected;

  @override
  State<_RecipePaletteDock> createState() => _RecipePaletteDockState();
}

class _RecipePaletteDockState extends State<_RecipePaletteDock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cueController;
  late final Animation<double> _blockCueAnimation;

  bool get expanded => widget.expanded;
  _RecipeEditorTab get activeTab => widget.activeTab;
  List<_RecipeTemplateDefinition> get templates => widget.templates;
  List<_RecipeBlockDefinition> get blocks => widget.blocks;
  ValueChanged<bool> get onExpandedChanged => widget.onExpandedChanged;
  ValueChanged<_RecipeEditorTab> get onTabChanged => widget.onTabChanged;
  ValueChanged<_RecipeTemplateDefinition> get onTemplateSelected =>
      widget.onTemplateSelected;
  ValueChanged<_RecipeBlockDefinition> get onBlockSelected =>
      widget.onBlockSelected;

  @override
  void initState() {
    super.initState();
    _cueController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      value: 1,
    );
    _blockCueAnimation = TweenSequence<double>([
      for (var index = 0; index < 3; index++) ...[
        TweenSequenceItem(
          tween: Tween(
            begin: 1.0,
            end: 0.28,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 0.28,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeIn)),
          weight: 1,
        ),
      ],
    ]).animate(_cueController);
  }

  @override
  void didUpdateWidget(covariant _RecipePaletteDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.blockPaletteCue != widget.blockPaletteCue) {
      _cueController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _cueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: expanded ? 292 : 112,
      decoration: BoxDecoration(
        color: palette.navbarBackground.withValues(
          alpha: expanded ? 0.9 : 0.96,
        ),
        borderRadius: expanded
            ? BorderRadius.circular(AppSpacing.radiusMd)
            : const BorderRadius.horizontal(
                right: Radius.circular(AppSpacing.radiusMd),
              ),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showExpandedContent = expanded && constraints.maxWidth >= 270;
          if (!showExpandedContent) {
            return _RecipeCompactPalette(
              activeTab: activeTab,
              templates: templates,
              blocks: blocks,
              blockCueAnimation: _blockCueAnimation,
              onTabChanged: onTabChanged,
              onExpanded: () => onExpandedChanged(true),
              onTemplateSelected: onTemplateSelected,
              onBlockSelected: onBlockSelected,
            );
          }

          return Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Collapse block palette',
                  onPressed: () => onExpandedChanged(false),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    0,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: _RecipeEditorPalette(
                    embedded: true,
                    activeTab: activeTab,
                    templates: templates,
                    blocks: blocks,
                    blockCueAnimation: _blockCueAnimation,
                    onTabChanged: onTabChanged,
                    onTemplateSelected: onTemplateSelected,
                    onBlockSelected: onBlockSelected,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecipeCompactPalette extends StatelessWidget {
  const _RecipeCompactPalette({
    required this.activeTab,
    required this.templates,
    required this.blocks,
    required this.blockCueAnimation,
    required this.onTabChanged,
    required this.onExpanded,
    required this.onTemplateSelected,
    required this.onBlockSelected,
  });

  final _RecipeEditorTab activeTab;
  final List<_RecipeTemplateDefinition> templates;
  final List<_RecipeBlockDefinition> blocks;
  final Animation<double> blockCueAnimation;
  final ValueChanged<_RecipeEditorTab> onTabChanged;
  final VoidCallback onExpanded;
  final ValueChanged<_RecipeTemplateDefinition> onTemplateSelected;
  final ValueChanged<_RecipeBlockDefinition> onBlockSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RecipeCompactTabButton(
                tooltip: 'Templates',
                icon: Icons.dashboard_customize_rounded,
                selected: activeTab == _RecipeEditorTab.templates,
                onPressed: () => onTabChanged(_RecipeEditorTab.templates),
              ),
              _RecipeCompactTabButton(
                tooltip: 'Blocks',
                icon: Icons.widgets_rounded,
                selected: activeTab == _RecipeEditorTab.blocks,
                onPressed: () => onTabChanged(_RecipeEditorTab.blocks),
              ),
              _RecipeCompactTabButton(
                tooltip: 'Expand block palette',
                icon: Icons.chevron_right_rounded,
                selected: false,
                onPressed: onExpanded,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: activeTab == _RecipeEditorTab.templates
                ? _RecipeCompactTemplateList(
                    templates: templates,
                    onSelected: onTemplateSelected,
                  )
                : _RecipeCompactBlockList(
                    blocks: blocks,
                    cueAnimation: blockCueAnimation,
                    onSelected: onBlockSelected,
                  ),
          ),
        ),
      ],
    );
  }
}

class _RecipeCompactBlockList extends StatelessWidget {
  const _RecipeCompactBlockList({
    required this.blocks,
    required this.cueAnimation,
    required this.onSelected,
  });

  final List<_RecipeBlockDefinition> blocks;
  final Animation<double> cueAnimation;
  final ValueChanged<_RecipeBlockDefinition> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      children: [
        for (final group in _RecipeBlockGroup.values) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 6,
            ),
            child: Divider(
              height: 1,
              color: palette.borders.withValues(alpha: 0.72),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final block in blocks.where(
                  (block) => block.kind.group == group,
                ))
                  _RecipeCompactBlockButton(
                    block: block,
                    cueAnimation: cueAnimation,
                    onPressed: () => onSelected(block),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RecipeCompactBlockButton extends StatelessWidget {
  const _RecipeCompactBlockButton({
    required this.block,
    required this.cueAnimation,
    required this.onPressed,
  });

  final _RecipeBlockDefinition block;
  final Animation<double> cueAnimation;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Tooltip(
      message: block.kind.label,
      child: _RecipePaletteBlockDragSource(
        block: block,
        child: Material(
          color: palette.searchBarBackground.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: SizedBox(
              width: 43,
              height: 42,
              child: FadeTransition(
                key: ValueKey('recipe-palette-cue-${block.kind.name}'),
                opacity: cueAnimation,
                child: Icon(
                  block.kind.icon,
                  size: 20,
                  color: palette.primaryButtons,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipePaletteBlockDragSource extends StatelessWidget {
  const _RecipePaletteBlockDragSource({
    required this.block,
    required this.child,
  });

  final _RecipeBlockDefinition block;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Draggable<_RecipeEditorDragData>(
        key: ValueKey('recipe-palette-drag-${block.kind.name}'),
        data: _RecipePaletteBlockDragData(block),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        rootOverlay: true,
        feedback: _RecipePaletteBlockDragFeedback(block: block),
        childWhenDragging: Opacity(opacity: 0.42, child: child),
        child: child,
      ),
    );
  }
}

class _RecipePaletteBlockDragFeedback extends StatelessWidget {
  const _RecipePaletteBlockDragFeedback({required this.block});

  final _RecipeBlockDefinition block;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 236,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: palette.navbarBackground.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: palette.primaryButtons),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.26),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(block.kind.icon, size: 20, color: palette.primaryButtons),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                block.kind.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.mainText,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCompactTemplateList extends StatelessWidget {
  const _RecipeCompactTemplateList({
    required this.templates,
    required this.onSelected,
  });

  final List<_RecipeTemplateDefinition> templates;
  final ValueChanged<_RecipeTemplateDefinition> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      children: [
        for (final template in templates)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 4,
            ),
            child: _RecipeTemplatePreviewTarget(
              key: ValueKey('compact-template-${template.title}'),
              template: template,
              child: Material(
                color: palette.searchBarBackground.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: InkWell(
                  onTap: () => onSelected(template),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: SizedBox(
                    width: 80,
                    height: 68,
                    child: Icon(
                      template.icon,
                      size: 28,
                      color: palette.primaryButtons,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RecipeTemplatePreviewTarget extends StatefulWidget {
  const _RecipeTemplatePreviewTarget({
    super.key,
    required this.template,
    required this.child,
  });

  final _RecipeTemplateDefinition template;
  final Widget child;

  @override
  State<_RecipeTemplatePreviewTarget> createState() =>
      _RecipeTemplatePreviewTargetState();
}

class _RecipeTemplatePreviewTargetState
    extends State<_RecipeTemplatePreviewTarget> {
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _controller = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) => Positioned(
        top: 0,
        left: 0,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.centerRight,
          followerAnchor: Alignment.centerLeft,
          offset: const Offset(AppSpacing.sm, 0),
          child: _RecipeTemplatePreview(template: widget.template),
        ),
      ),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: MouseRegion(
          onEnter: (_) => _controller.show(),
          onExit: (_) {
            if (_controller.isShowing) {
              _controller.hide();
            }
          },
          child: Semantics(
            label: '${widget.template.title} template',
            button: true,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _RecipeTemplatePreview extends StatelessWidget {
  const _RecipeTemplatePreview({required this.template});

  final _RecipeTemplateDefinition template;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final previewBlocks = template.createBlocks((prefix) => 'preview-$prefix');

    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 286,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: palette.navbarBackground.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: palette.primaryButtons.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(template.icon, size: 22, color: palette.primaryButtons),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      template.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: palette.mainText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                template.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Divider(color: palette.borders.withValues(alpha: 0.7)),
              const SizedBox(height: AppSpacing.xs),
              for (final block in previewBlocks)
                _RecipeTemplatePreviewBlock(block: block),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeTemplatePreviewBlock extends StatelessWidget {
  const _RecipeTemplatePreviewBlock({required this.block, this.depth = 0});

  final _RecipeEditorBlock block;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: EdgeInsets.only(left: depth * 14, bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(block.kind.icon, size: 16, color: palette.icons),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  block.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.mainText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          for (final child in block.children)
            _RecipeTemplatePreviewBlock(block: child, depth: depth + 1),
        ],
      ),
    );
  }
}

class _RecipeCompactTabButton extends StatelessWidget {
  const _RecipeCompactTabButton({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: selected
            ? palette.primaryButtons.withValues(alpha: 0.22)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: SizedBox(
            width: 32,
            height: 34,
            child: Icon(
              icon,
              size: 19,
              color: selected ? palette.primaryButtons : palette.icons,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeInspectorDock extends StatelessWidget {
  const _RecipeInspectorDock({
    required this.expanded,
    required this.block,
    required this.onExpandedChanged,
    required this.onWidthChanged,
    required this.onAlignmentChanged,
    required this.onSpacingChanged,
    required this.onVariantChanged,
    required this.onTextAlignmentChanged,
    required this.onTextSizeChanged,
    required this.onBlockChanged,
  });

  final bool expanded;
  final _RecipeEditorBlock? block;
  final ValueChanged<bool> onExpandedChanged;
  final ValueChanged<_RecipeBlockWidth> onWidthChanged;
  final ValueChanged<_RecipeBlockAlignment> onAlignmentChanged;
  final ValueChanged<_RecipeBlockSpacing> onSpacingChanged;
  final ValueChanged<_RecipeBlockVariant> onVariantChanged;
  final ValueChanged<_RecipeTextAlignment> onTextAlignmentChanged;
  final ValueChanged<_RecipeTextSize> onTextSizeChanged;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: expanded ? 292 : 52,
      decoration: BoxDecoration(
        color: palette.navbarBackground.withValues(
          alpha: expanded ? 0.9 : 0.96,
        ),
        borderRadius: expanded
            ? BorderRadius.circular(AppSpacing.radiusMd)
            : const BorderRadius.horizontal(
                left: Radius.circular(AppSpacing.radiusMd),
              ),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showExpandedContent = expanded && constraints.maxWidth >= 270;
          if (!showExpandedContent) {
            return Center(
              child: IconButton(
                tooltip: 'Open block settings',
                onPressed: () => onExpandedChanged(true),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
                icon: const Icon(Icons.tune_rounded),
              ),
            );
          }

          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Collapse block settings',
                  onPressed: () => onExpandedChanged(false),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    0,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: _RecipeEditorInspector(
                    embedded: true,
                    block: block,
                    onWidthChanged: onWidthChanged,
                    onAlignmentChanged: onAlignmentChanged,
                    onSpacingChanged: onSpacingChanged,
                    onVariantChanged: onVariantChanged,
                    onTextAlignmentChanged: onTextAlignmentChanged,
                    onTextSizeChanged: onTextSizeChanged,
                    onBlockChanged: onBlockChanged,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecipeEditorCanvas extends StatelessWidget {
  const _RecipeEditorCanvas({
    required this.blocks,
    required this.selectedBlockId,
    required this.hoveredBlockId,
    required this.onBlockSelected,
    required this.onSelectionCleared,
    required this.onBlockTitleChanged,
    required this.onBlockBodyChanged,
    required this.onBlockQuoteAuthorChanged,
    required this.onBlockHeightChanged,
    required this.onAppendBlockRequested,
    required this.canDropBlock,
    required this.onDropBlock,
    required this.onDeleteBlock,
  });

  final List<_RecipeEditorBlock> blocks;
  final String? selectedBlockId;
  final _RecipeBlockHoverController hoveredBlockId;
  final ValueChanged<String> onBlockSelected;
  final VoidCallback onSelectionCleared;
  final void Function(String blockId, String title) onBlockTitleChanged;
  final void Function(String blockId, String body) onBlockBodyChanged;
  final void Function(String blockId, String author) onBlockQuoteAuthorChanged;
  final void Function(String blockId, double height) onBlockHeightChanged;
  final VoidCallback onAppendBlockRequested;
  final bool Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  canDropBlock;
  final void Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  onDropBlock;
  final ValueChanged<String> onDeleteBlock;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: 52),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            key: const ValueKey('recipe-editor-canvas'),
            behavior: HitTestBehavior.opaque,
            onTap: onSelectionCleared,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: palette.cardsSurface.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: palette.borders.withValues(alpha: 0.72),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < blocks.length; index++) ...[
                    _RecipeBlockDropZone(
                      target: _RecipeBlockDropTarget(
                        parentId: null,
                        index: index,
                        depth: 0,
                      ),
                      canDropBlock: canDropBlock,
                      onDropBlock: onDropBlock,
                    ),
                    _RecipeEditorBlockCard(
                      dragData: _RecipeBlockDragData(
                        blockId: blocks[index].id,
                        sourceParentId: null,
                        sourceIndex: index,
                        sourceDepth: 0,
                      ),
                      block: blocks[index],
                      selectedBlockId: selectedBlockId,
                      hoveredBlockId: hoveredBlockId,
                      parentBlockId: null,
                      depth: 0,
                      avoidAuthorOverlay: index == 0,
                      canDropBlock: canDropBlock,
                      onDropBlock: onDropBlock,
                      onBlockSelected: onBlockSelected,
                      onBlockTitleChanged: onBlockTitleChanged,
                      onBlockBodyChanged: onBlockBodyChanged,
                      onBlockQuoteAuthorChanged: onBlockQuoteAuthorChanged,
                      onBlockHeightChanged: onBlockHeightChanged,
                      onDeleteBlock: onDeleteBlock,
                    ),
                  ],
                  _RecipeBlockInsertZone(
                    target: _RecipeBlockDropTarget(
                      parentId: null,
                      index: blocks.length,
                      depth: 0,
                    ),
                    onPressed: onAppendBlockRequested,
                    canDropBlock: canDropBlock,
                    onDropBlock: onDropBlock,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: _recipeAuthorCardOffset,
            right: _recipeAuthorCardOffset,
            child: Transform.rotate(
              angle: _recipeAuthorCardAngle,
              child: const _RecipeLockedAuthorBlock(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeLockedAuthorBlock extends StatefulWidget {
  const _RecipeLockedAuthorBlock();

  @override
  State<_RecipeLockedAuthorBlock> createState() =>
      _RecipeLockedAuthorBlockState();
}

class _RecipeLockedAuthorBlockState extends State<_RecipeLockedAuthorBlock> {
  static const _avatarUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=320&q=82';

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: _recipeAuthorCardExtent,
        height: _recipeAuthorCardExtent,
        decoration: BoxDecoration(
          color: palette.navbarBackground.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: _hovered
                ? palette.primaryButtons.withValues(alpha: 0.74)
                : palette.borders.withValues(alpha: 0.74),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.3 : 0.2),
              blurRadius: _hovered ? 28 : 20,
              offset: Offset(0, _hovered ? 14 : 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    ClipOval(
                      child: SizedBox.square(
                        dimension: 78,
                        child: Image.network(
                          _avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              ColoredBox(
                                color: palette.primaryButtons.withValues(
                                  alpha: 0.2,
                                ),
                                child: Center(
                                  child: Text(
                                    'CS',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: palette.primaryButtons,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Chef Sofia',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: palette.mainText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '24 recipes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.secondaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _RecipeAuthorMoreButton(),
          ],
        ),
      ),
    );
  }
}

class _RecipeAuthorMoreButton extends StatefulWidget {
  const _RecipeAuthorMoreButton();

  @override
  State<_RecipeAuthorMoreButton> createState() =>
      _RecipeAuthorMoreButtonState();
}

class _RecipeAuthorMoreButtonState extends State<_RecipeAuthorMoreButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 46,
        color: _hovered
            ? palette.primaryButtons.withValues(alpha: 0.28)
            : palette.searchBarBackground.withValues(alpha: 0.82),
        alignment: Alignment.center,
        child: Text(
          'More recipes',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: _hovered ? palette.primaryButtons : palette.mainText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

enum _RecipeDropZoneAxis { vertical, horizontal }

class _RecipeBlockDropZone extends StatefulWidget {
  const _RecipeBlockDropZone({
    required this.target,
    required this.canDropBlock,
    required this.onDropBlock,
    this.axis = _RecipeDropZoneAxis.vertical,
  });

  final _RecipeBlockDropTarget target;
  final bool Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  canDropBlock;
  final void Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  onDropBlock;
  final _RecipeDropZoneAxis axis;

  @override
  State<_RecipeBlockDropZone> createState() => _RecipeBlockDropZoneState();
}

class _RecipeBlockDropZoneState extends State<_RecipeBlockDropZone> {
  bool _escapeReady = true;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final target = widget.target;

    return DragTarget<_RecipeEditorDragData>(
      onWillAcceptWithDetails: _handleWillAccept,
      onMove: _handleMove,
      onLeave: (_) => _setEscapeReady(true),
      onAcceptWithDetails: (details) {
        if (_escapeReady && widget.canDropBlock(details.data, target)) {
          widget.onDropBlock(details.data, target);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final hasCandidate = candidateData.isNotEmpty;
        final active = hasCandidate && _escapeReady;
        final invalid =
            (hasCandidate && !_escapeReady) ||
            (!hasCandidate && rejectedData.isNotEmpty);
        final color = invalid
            ? Theme.of(context).colorScheme.error
            : palette.primaryButtons;
        final lineAlpha = active
            ? 0.95
            : invalid
            ? 0.5
            : 0.0;

        if (widget.axis == _RecipeDropZoneAxis.horizontal) {
          return AnimatedContainer(
            key: ValueKey(
              'recipe-drop-zone-${target.parentId ?? 'root'}-${target.index}',
            ),
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOutCubic,
            width: active || invalid ? 22 : 7,
            height: 72,
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              width: active || invalid ? 4 : 0,
              height: active || invalid ? 62 : 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0),
                    color.withValues(alpha: lineAlpha),
                    color.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          );
        }

        return AnimatedContainer(
          key: ValueKey(
            'recipe-drop-zone-${target.parentId ?? 'root'}-${target.index}',
          ),
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutCubic,
          height: active || invalid ? 24 : 8,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            width: double.infinity,
            height: active || invalid ? 4 : 0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0),
                  color.withValues(alpha: lineAlpha),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _handleWillAccept(DragTargetDetails<_RecipeEditorDragData> details) {
    final valid = widget.canDropBlock(details.data, widget.target);
    _setEscapeReady(valid && _isEscapeReady(details.data, details.offset));
    return valid;
  }

  void _handleMove(DragTargetDetails<_RecipeEditorDragData> details) {
    _setEscapeReady(_isEscapeReady(details.data, details.offset));
  }

  bool _isEscapeReady(_RecipeEditorDragData data, Offset globalOffset) {
    if (data is! _RecipeBlockDragData) {
      return true;
    }
    final levelsOut = data.sourceDepth - widget.target.depth;
    if (levelsOut <= 0) {
      return true;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return false;
    }
    final localOffset = renderObject.globalToLocal(globalOffset);
    final acceptedFraction = (0.68 - ((levelsOut - 1) * 0.1)).clamp(0.48, 0.68);
    final threshold = renderObject.size.width * acceptedFraction;
    return localOffset.dx <= threshold;
  }

  void _setEscapeReady(bool value) {
    if (_escapeReady == value || !mounted) {
      return;
    }
    setState(() => _escapeReady = value);
  }
}

class _RecipeBlockInsertZone extends StatefulWidget {
  const _RecipeBlockInsertZone({
    required this.target,
    required this.onPressed,
    required this.canDropBlock,
    required this.onDropBlock,
  });

  final _RecipeBlockDropTarget target;
  final VoidCallback onPressed;
  final bool Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  canDropBlock;
  final void Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  onDropBlock;

  @override
  State<_RecipeBlockInsertZone> createState() => _RecipeBlockInsertZoneState();
}

class _RecipeBlockInsertZoneState extends State<_RecipeBlockInsertZone> {
  bool _escapeReady = true;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DragTarget<_RecipeEditorDragData>(
      onWillAcceptWithDetails: (details) {
        final valid = widget.canDropBlock(details.data, widget.target);
        _setEscapeReady(valid && _isEscapeReady(details.data, details.offset));
        return valid;
      },
      onMove: (details) =>
          _setEscapeReady(_isEscapeReady(details.data, details.offset)),
      onLeave: (_) => _setEscapeReady(true),
      onAcceptWithDetails: (details) {
        if (_escapeReady && widget.canDropBlock(details.data, widget.target)) {
          widget.onDropBlock(details.data, widget.target);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final hasCandidate = candidateData.isNotEmpty;
        final active = hasCandidate && _escapeReady;
        final invalid =
            (hasCandidate && !_escapeReady) ||
            (!hasCandidate && rejectedData.isNotEmpty);
        final activeColor = invalid
            ? Theme.of(context).colorScheme.error
            : palette.primaryButtons;

        return Material(
          key: ValueKey(
            'recipe-block-insert-zone-${widget.target.parentId ?? 'root'}-${widget.target.index}',
          ),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: active || invalid ? 96 : 84,
              decoration: BoxDecoration(
                color: active || invalid
                    ? activeColor.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: active || invalid
                      ? activeColor
                      : palette.borders.withValues(alpha: 0.58),
                ),
              ),
              child: Center(
                child: Icon(
                  active
                      ? Icons.vertical_align_center_rounded
                      : Icons.add_rounded,
                  size: active || invalid ? 34 : 32,
                  color: activeColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isEscapeReady(_RecipeEditorDragData data, Offset globalOffset) {
    if (data is! _RecipeBlockDragData) {
      return true;
    }
    final levelsOut = data.sourceDepth - widget.target.depth;
    if (levelsOut <= 0) {
      return true;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return false;
    }
    final localOffset = renderObject.globalToLocal(globalOffset);
    final acceptedFraction = (0.68 - ((levelsOut - 1) * 0.1)).clamp(0.48, 0.68);
    final threshold = renderObject.size.width * acceptedFraction;
    return localOffset.dx <= threshold;
  }

  void _setEscapeReady(bool value) {
    if (_escapeReady == value || !mounted) {
      return;
    }
    setState(() => _escapeReady = value);
  }
}

class _RecipeBlockDragFeedback extends StatelessWidget {
  const _RecipeBlockDragFeedback({required this.block});

  final _RecipeEditorBlock block;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: palette.navbarBackground.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: palette.primaryButtons),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(block.kind.icon, size: 18, color: palette.primaryButtons),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                block.title.isEmpty ? block.kind.label : block.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.mainText,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeBlockDragHandle extends StatelessWidget {
  const _RecipeBlockDragHandle({
    required this.data,
    required this.block,
    required this.hoveredBlockId,
    required this.child,
  });

  final _RecipeBlockDragData data;
  final _RecipeEditorBlock block;
  final _RecipeBlockHoverController hoveredBlockId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Draggable<_RecipeBlockDragData>(
        data: data,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        rootOverlay: true,
        onDragStarted: () => hoveredBlockId.activate(null),
        onDragCompleted: () => hoveredBlockId.activate(null),
        onDraggableCanceled: (_, _) => hoveredBlockId.activate(null),
        feedback: RepaintBoundary(
          child: _RecipeBlockDragFeedback(block: block),
        ),
        childWhenDragging: Opacity(opacity: 0.34, child: child),
        child: child,
      ),
    );
  }
}

class _RecipeActiveBlockTabPortal extends StatefulWidget {
  const _RecipeActiveBlockTabPortal({
    required this.data,
    required this.block,
    required this.hoveredBlockId,
    required this.offset,
  });

  final _RecipeBlockDragData data;
  final _RecipeEditorBlock block;
  final _RecipeBlockHoverController hoveredBlockId;
  final Offset offset;

  @override
  State<_RecipeActiveBlockTabPortal> createState() =>
      _RecipeActiveBlockTabPortalState();
}

class _RecipeActiveBlockTabPortalState
    extends State<_RecipeActiveBlockTabPortal> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();

  @override
  void initState() {
    super.initState();
    _controller.show();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        final viewportWidth = MediaQuery.sizeOf(context).width;
        final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);

        return Positioned(
          left: 0,
          top: headerHeight,
          right: 0,
          bottom: 0,
          child: ClipRect(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  width: 220,
                  height: 40,
                  child: CompositedTransformFollower(
                    link: _link,
                    showWhenUnlinked: false,
                    targetAnchor: Alignment.topLeft,
                    followerAnchor: Alignment.bottomLeft,
                    offset: widget.offset,
                    child: _RecipeBlockDragHandle(
                      data: widget.data,
                      block: widget.block,
                      hoveredBlockId: widget.hoveredBlockId,
                      child: _RecipeActiveBlockTab(block: widget.block),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: _link,
        child: const SizedBox.shrink(),
      ),
    );
  }
}

class _RecipeActiveBlockTab extends StatelessWidget {
  const _RecipeActiveBlockTab({required this.block});

  final _RecipeEditorBlock block;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      key: ValueKey('recipe-editor-block-handle-${block.id}'),
      constraints: const BoxConstraints(minWidth: 132, maxWidth: 220),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: palette.navbarBackground.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusSm),
          topRight: Radius.circular(AppSpacing.radiusSm),
          bottomRight: Radius.circular(AppSpacing.xs),
        ),
        border: Border.all(
          color: palette.primaryButtons.withValues(alpha: 0.54),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(block.kind.icon, size: 17, color: palette.primaryButtons),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              block.kind.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: palette.categoryTags,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeEditorBlockCard extends StatelessWidget {
  const _RecipeEditorBlockCard({
    required this.dragData,
    required this.block,
    required this.selectedBlockId,
    required this.hoveredBlockId,
    required this.parentBlockId,
    required this.depth,
    this.avoidAuthorOverlay = false,
    required this.canDropBlock,
    required this.onDropBlock,
    required this.onBlockSelected,
    required this.onBlockTitleChanged,
    required this.onBlockBodyChanged,
    required this.onBlockQuoteAuthorChanged,
    required this.onBlockHeightChanged,
    required this.onDeleteBlock,
  });

  final _RecipeBlockDragData dragData;
  final _RecipeEditorBlock block;
  final String? selectedBlockId;
  final _RecipeBlockHoverController hoveredBlockId;
  final String? parentBlockId;
  final int depth;
  final bool avoidAuthorOverlay;
  final bool Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  canDropBlock;
  final void Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  onDropBlock;
  final ValueChanged<String> onBlockSelected;
  final void Function(String blockId, String title) onBlockTitleChanged;
  final void Function(String blockId, String body) onBlockBodyChanged;
  final void Function(String blockId, String author) onBlockQuoteAuthorChanged;
  final void Function(String blockId, double height) onBlockHeightChanged;
  final ValueChanged<String> onDeleteBlock;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthFactor = switch (block.width) {
          _RecipeBlockWidth.narrow => 0.56,
          _RecipeBlockWidth.normal => 0.78,
          _RecipeBlockWidth.wide => 0.92,
          _RecipeBlockWidth.full => 1.0,
        };
        final effectiveWidthFactor = constraints.maxWidth < 420
            ? 1.0
            : widthFactor;
        final blockWidth = constraints.maxWidth * effectiveWidthFactor;
        final blockLeft = switch (block.alignment) {
          _RecipeBlockAlignment.left => 0.0,
          _RecipeBlockAlignment.center =>
            (constraints.maxWidth - blockWidth) / 2,
          _RecipeBlockAlignment.right => constraints.maxWidth - blockWidth,
        };
        final blockRight = blockLeft + blockWidth;
        final authorCenterX =
            constraints.maxWidth -
            _recipeAuthorCardOffset -
            (_recipeAuthorCardExtent / 2);
        final authorRotatedHalfWidth =
            (_recipeAuthorCardExtent / 2) *
            (math.cos(_recipeAuthorCardAngle).abs() +
                math.sin(_recipeAuthorCardAngle).abs());
        final authorLeft = authorCenterX - authorRotatedHalfWidth;
        final overlapInset = blockRight - authorLeft + AppSpacing.sm;
        final deleteButtonInset =
            avoidAuthorOverlay &&
                constraints.maxWidth >= 600 &&
                overlapInset > 0
            ? overlapInset.clamp(0.0, math.max(0.0, blockWidth - 80)).toDouble()
            : 0.0;
        final alignment = switch (block.alignment) {
          _RecipeBlockAlignment.left => Alignment.centerLeft,
          _RecipeBlockAlignment.center => Alignment.center,
          _RecipeBlockAlignment.right => Alignment.centerRight,
        };

        return Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: blockWidth),
            child: _RecipeEditorBlockSurface(
              dragData: dragData,
              block: block,
              selectedBlockId: selectedBlockId,
              hoveredBlockId: hoveredBlockId,
              parentBlockId: parentBlockId,
              depth: depth,
              deleteButtonInset: deleteButtonInset,
              canDropBlock: canDropBlock,
              onDropBlock: onDropBlock,
              onBlockSelected: onBlockSelected,
              onBlockTitleChanged: onBlockTitleChanged,
              onBlockBodyChanged: onBlockBodyChanged,
              onBlockQuoteAuthorChanged: onBlockQuoteAuthorChanged,
              onBlockHeightChanged: onBlockHeightChanged,
              onDeleteBlock: onDeleteBlock,
            ),
          ),
        );
      },
    );
  }
}

class _RecipeEditorBlockSurface extends StatefulWidget {
  const _RecipeEditorBlockSurface({
    required this.dragData,
    required this.block,
    required this.selectedBlockId,
    required this.hoveredBlockId,
    required this.parentBlockId,
    required this.depth,
    required this.deleteButtonInset,
    required this.canDropBlock,
    required this.onDropBlock,
    required this.onBlockSelected,
    required this.onBlockTitleChanged,
    required this.onBlockBodyChanged,
    required this.onBlockQuoteAuthorChanged,
    required this.onBlockHeightChanged,
    required this.onDeleteBlock,
  });

  final _RecipeBlockDragData dragData;
  final _RecipeEditorBlock block;
  final String? selectedBlockId;
  final _RecipeBlockHoverController hoveredBlockId;
  final String? parentBlockId;
  final int depth;
  final double deleteButtonInset;
  final bool Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  canDropBlock;
  final void Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  onDropBlock;
  final ValueChanged<String> onBlockSelected;
  final void Function(String blockId, String title) onBlockTitleChanged;
  final void Function(String blockId, String body) onBlockBodyChanged;
  final void Function(String blockId, String author) onBlockQuoteAuthorChanged;
  final void Function(String blockId, double height) onBlockHeightChanged;
  final ValueChanged<String> onDeleteBlock;

  @override
  State<_RecipeEditorBlockSurface> createState() =>
      _RecipeEditorBlockSurfaceState();
}

class _RecipeEditorBlockSurfaceState extends State<_RecipeEditorBlockSurface> {
  static const double _minimumEditorHeight = 72;

  final GlobalKey _surfaceKey = GlobalKey();
  double? _dragHeight;

  _RecipeBlockDragData get dragData => widget.dragData;
  _RecipeEditorBlock get block => widget.block;
  String? get selectedBlockId => widget.selectedBlockId;
  _RecipeBlockHoverController get hoveredBlockId => widget.hoveredBlockId;
  String? get parentBlockId => widget.parentBlockId;
  int get depth => widget.depth;
  double get deleteButtonInset => widget.deleteButtonInset;
  bool Function(_RecipeEditorDragData, _RecipeBlockDropTarget)
  get canDropBlock => widget.canDropBlock;
  void Function(_RecipeEditorDragData, _RecipeBlockDropTarget)
  get onDropBlock => widget.onDropBlock;
  ValueChanged<String> get onBlockSelected => widget.onBlockSelected;
  void Function(String, String) get onBlockTitleChanged =>
      widget.onBlockTitleChanged;
  void Function(String, String) get onBlockBodyChanged =>
      widget.onBlockBodyChanged;
  void Function(String, String) get onBlockQuoteAuthorChanged =>
      widget.onBlockQuoteAuthorChanged;
  void Function(String, double) get onBlockHeightChanged =>
      widget.onBlockHeightChanged;
  ValueChanged<String> get onDeleteBlock => widget.onDeleteBlock;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selected = selectedBlockId == block.id;
    final padding = switch (block.spacing) {
      _RecipeBlockSpacing.compact => AppSpacing.sm,
      _RecipeBlockSpacing.normal => depth == 0 ? AppSpacing.md : AppSpacing.sm,
      _RecipeBlockSpacing.spacious => AppSpacing.lg,
    };
    final gap = switch (block.spacing) {
      _RecipeBlockSpacing.compact => AppSpacing.xs,
      _RecipeBlockSpacing.normal => AppSpacing.sm,
      _RecipeBlockSpacing.spacious => AppSpacing.md,
    };
    final background = switch (block.variant) {
      _RecipeBlockVariant.simple => palette.recipeCardBackground.withValues(
        alpha: 0.72,
      ),
      _RecipeBlockVariant.cards => palette.searchBarBackground.withValues(
        alpha: 0.76,
      ),
      _RecipeBlockVariant.timeline => palette.recipeCardBackground.withValues(
        alpha: 0.64,
      ),
    };

    return ConstrainedBox(
      key: _surfaceKey,
      constraints: BoxConstraints(minHeight: block.editorHeight ?? 0),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          MouseRegion(
            key: ValueKey('recipe-editor-block-${block.id}'),
            onEnter: (_) => _setHoveredBlock(block.id),
            onExit: (_) => _setHoveredBlock(parentBlockId),
            child: ValueListenableBuilder<bool>(
              valueListenable: hoveredBlockId.listenableFor(block.id),
              builder: (context, hovered, child) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(end: hovered ? 1 : 0),
                  duration: const Duration(milliseconds: 190),
                  curve: Curves.easeOutCubic,
                  builder: (context, hoverProgress, child) {
                    final hoverBackground = Color.alphaBlend(
                      palette.primaryButtons.withValues(alpha: 0.04),
                      background,
                    );
                    final animatedBackground = Color.lerp(
                      background,
                      hoverBackground,
                      hoverProgress,
                    )!;
                    final restingBorder = selected
                        ? palette.primaryButtons
                        : palette.borders.withValues(alpha: 0.72);
                    final hoverBorder = selected
                        ? palette.primaryButtons
                        : palette.primaryButtons.withValues(alpha: 0.48);
                    final animatedBorder = Color.lerp(
                      restingBorder,
                      hoverBorder,
                      hoverProgress,
                    )!;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onBlockSelected(block.id),
                      child: CustomPaint(
                        foregroundPainter: _RecipeBlockEdgeBorderPainter(
                          color: animatedBorder,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(padding),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                animatedBackground.withValues(alpha: 0),
                                animatedBackground,
                                animatedBackground,
                                animatedBackground.withValues(alpha: 0),
                              ],
                              stops: const [0, 0.18, 0.82, 1],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildPrimaryContent(
                                          context,
                                          palette,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: deleteButtonInset,
                                        ),
                                        child: IconButton(
                                          tooltip: 'Delete block',
                                          onPressed: () =>
                                              onDeleteBlock(block.id),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                          ),
                                          iconSize: 18,
                                          visualDensity: VisualDensity.compact,
                                          color: palette.icons,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (selected)
                                    _RecipeActiveBlockTabPortal(
                                      data: dragData,
                                      block: block,
                                      hoveredBlockId: hoveredBlockId,
                                      offset: Offset(
                                        -padding + AppSpacing.sm,
                                        6,
                                      ),
                                    ),
                                ],
                              ),
                              if (_usesSecondaryBody) ...[
                                SizedBox(height: gap / 2),
                                _buildGenericBody(context, palette),
                              ],
                              if (block.canContainChildren) ...[
                                SizedBox(height: gap),
                                _buildChildren(context, gap),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (selected)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 12,
              child: _RecipeBlockResizeHandle(
                blockId: block.id,
                onResizeStart: _startResize,
                onResize: _resizeBy,
                onResizeEnd: _endResize,
              ),
            ),
        ],
      ),
    );
  }

  void _startResize() {
    final renderObject = _surfaceKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      _dragHeight = renderObject.size.height;
    }
  }

  void _resizeBy(double delta) {
    final currentHeight = _dragHeight;
    if (currentHeight == null) {
      return;
    }
    final nextHeight = math.max(_minimumEditorHeight, currentHeight + delta);
    _dragHeight = nextHeight;
    onBlockHeightChanged(block.id, nextHeight);
  }

  void _endResize() {
    _dragHeight = null;
  }

  bool get _usesSecondaryBody {
    return block.kind != _RecipeBlockKind.divider &&
        !block.kind.supportsTextSettings;
  }

  Widget _buildPrimaryContent(BuildContext context, AppPalette palette) {
    return switch (block.kind) {
      _RecipeBlockKind.divider => Divider(
        color: palette.borders.withValues(alpha: 0.8),
      ),
      _RecipeBlockKind.heading => _buildTextContentField(
        context,
        palette,
        hintText: 'Write a heading',
        style: TextStyle(
          color: palette.mainText,
          fontSize: _textFontSize,
          fontWeight: FontWeight.w900,
          height: 1.12,
        ),
      ),
      _RecipeBlockKind.paragraph => _buildTextContentField(
        context,
        palette,
        hintText: 'Write a paragraph',
        style: TextStyle(
          color: palette.mainText.withValues(alpha: 0.9),
          fontSize: _textFontSize,
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),
      ),
      _RecipeBlockKind.quote => _buildQuoteContent(context, palette),
      _ => _buildGenericTitle(context, palette),
    };
  }

  Widget _buildGenericTitle(BuildContext context, AppPalette palette) {
    return TextFormField(
      key: ValueKey('${block.id}-title'),
      initialValue: block.title,
      maxLines: 1,
      onTap: () => onBlockSelected(block.id),
      onChanged: (value) => onBlockTitleChanged(block.id, value),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: palette.mainText,
        fontWeight: FontWeight.w900,
      ),
      decoration: _textFieldDecoration(
        palette,
        'Add ${block.kind.label.toLowerCase()} title',
      ),
    );
  }

  Widget _buildGenericBody(BuildContext context, AppPalette palette) {
    return TextFormField(
      key: ValueKey('${block.id}-body'),
      initialValue: block.body,
      minLines: 1,
      maxLines: 4,
      onTap: () => onBlockSelected(block.id),
      onChanged: (value) => onBlockBodyChanged(block.id, value),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: palette.secondaryText,
        height: 1.35,
      ),
      decoration: _textFieldDecoration(
        palette,
        'Write ${block.kind.label.toLowerCase()} content',
      ),
    );
  }

  Widget _buildTextContentField(
    BuildContext context,
    AppPalette palette, {
    required String hintText,
    required TextStyle style,
  }) {
    return TextFormField(
      key: ValueKey('${block.id}-body'),
      initialValue: block.body,
      minLines: 1,
      maxLines: null,
      textAlign: _textAlign,
      onTap: () => onBlockSelected(block.id),
      onChanged: (value) => onBlockBodyChanged(block.id, value),
      style: style,
      decoration: _textFieldDecoration(palette, hintText),
    );
  }

  Widget _buildQuoteContent(BuildContext context, AppPalette palette) {
    final lineOnLeft = block.quoteLineSide == _RecipeQuoteLineSide.left;
    return Container(
      key: ValueKey('${block.id}-quote-surface'),
      padding: EdgeInsets.only(
        left: lineOnLeft ? AppSpacing.md : 0,
        right: lineOnLeft ? 0 : AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: lineOnLeft
              ? BorderSide(color: palette.primaryButtons, width: 3)
              : BorderSide.none,
          right: lineOnLeft
              ? BorderSide.none
              : BorderSide(color: palette.primaryButtons, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextContentField(
            context,
            palette,
            hintText: 'Write a quote',
            style: TextStyle(
              color: palette.mainText,
              fontSize: _textFontSize,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            key: ValueKey('${block.id}-quote-author'),
            initialValue: block.quoteAuthor,
            maxLines: 1,
            textAlign: TextAlign.right,
            onTap: () => onBlockSelected(block.id),
            onChanged: (value) => onBlockQuoteAuthorChanged(block.id, value),
            style: TextStyle(
              color: palette.secondaryText,
              fontSize: math.max(12, _textFontSize * 0.72),
              fontWeight: FontWeight.w700,
            ),
            decoration: _textFieldDecoration(
              palette,
              'Quote author (optional)',
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _textFieldDecoration(AppPalette palette, String hintText) {
    return InputDecoration(
      isCollapsed: true,
      filled: false,
      fillColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      hintText: hintText,
      hintStyle: TextStyle(
        color: palette.secondaryText.withValues(alpha: 0.66),
      ),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    );
  }

  TextAlign get _textAlign {
    return switch (block.textAlignment) {
      _RecipeTextAlignment.left => TextAlign.left,
      _RecipeTextAlignment.center => TextAlign.center,
      _RecipeTextAlignment.right => TextAlign.right,
      _RecipeTextAlignment.justify => TextAlign.justify,
    };
  }

  double get _textFontSize {
    if (block.kind == _RecipeBlockKind.heading) {
      return switch (block.textSize) {
        _RecipeTextSize.extraSmall => 18,
        _RecipeTextSize.small => 23,
        _RecipeTextSize.medium => 30,
        _RecipeTextSize.large => 38,
        _RecipeTextSize.extraLarge => 48,
      };
    }

    return switch (block.textSize) {
      _RecipeTextSize.extraSmall => 12,
      _RecipeTextSize.small => 14,
      _RecipeTextSize.medium => 16,
      _RecipeTextSize.large => 19,
      _RecipeTextSize.extraLarge => 23,
    };
  }

  void _setHoveredBlock(String? blockId) {
    hoveredBlockId.activate(blockId);
  }

  Widget _buildChildren(BuildContext context, double gap) {
    final horizontalLayout =
        block.kind == _RecipeBlockKind.columns ||
        block.kind == _RecipeBlockKind.photoText;

    if (!horizontalLayout) {
      return _buildVerticalChildren();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        if (compact) {
          return _buildVerticalChildren();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index <= block.children.length; index++) ...[
              _buildChildDropZone(index, axis: _RecipeDropZoneAxis.horizontal),
              if (index < block.children.length)
                Expanded(child: _buildChildCard(block.children[index], index)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildVerticalChildren() {
    return Column(
      children: [
        for (var index = 0; index <= block.children.length; index++) ...[
          _buildChildDropZone(index),
          if (index < block.children.length)
            _buildChildCard(block.children[index], index),
        ],
      ],
    );
  }

  Widget _buildChildDropZone(
    int index, {
    _RecipeDropZoneAxis axis = _RecipeDropZoneAxis.vertical,
  }) {
    return _RecipeBlockDropZone(
      target: _RecipeBlockDropTarget(
        parentId: block.id,
        index: index,
        depth: depth + 1,
      ),
      canDropBlock: canDropBlock,
      onDropBlock: onDropBlock,
      axis: axis,
    );
  }

  Widget _buildChildCard(_RecipeEditorBlock child, int index) {
    return _RecipeEditorBlockCard(
      dragData: _RecipeBlockDragData(
        blockId: child.id,
        sourceParentId: block.id,
        sourceIndex: index,
        sourceDepth: depth + 1,
      ),
      block: child,
      selectedBlockId: selectedBlockId,
      hoveredBlockId: hoveredBlockId,
      parentBlockId: block.id,
      depth: depth + 1,
      avoidAuthorOverlay: false,
      canDropBlock: canDropBlock,
      onDropBlock: onDropBlock,
      onBlockSelected: onBlockSelected,
      onBlockTitleChanged: onBlockTitleChanged,
      onBlockBodyChanged: onBlockBodyChanged,
      onBlockQuoteAuthorChanged: onBlockQuoteAuthorChanged,
      onBlockHeightChanged: onBlockHeightChanged,
      onDeleteBlock: onDeleteBlock,
    );
  }
}

class _RecipeBlockResizeHandle extends StatefulWidget {
  const _RecipeBlockResizeHandle({
    required this.blockId,
    required this.onResizeStart,
    required this.onResize,
    required this.onResizeEnd,
  });

  final String blockId;
  final VoidCallback onResizeStart;
  final ValueChanged<double> onResize;
  final VoidCallback onResizeEnd;

  @override
  State<_RecipeBlockResizeHandle> createState() =>
      _RecipeBlockResizeHandleState();
}

class _RecipeBlockResizeHandleState extends State<_RecipeBlockResizeHandle> {
  bool _hovered = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final active = _hovered || _dragging;

    return MouseRegion(
      key: ValueKey('recipe-editor-block-resize-${widget.blockId}'),
      cursor: SystemMouseCursors.resizeUpDown,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onVerticalDragStart: (_) {
          setState(() => _dragging = true);
          widget.onResizeStart();
        },
        onVerticalDragUpdate: (details) => widget.onResize(details.delta.dy),
        onVerticalDragEnd: (_) => _finishDrag(),
        onVerticalDragCancel: _finishDrag,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            width: active ? 72 : 42,
            height: 2,
            color: palette.primaryButtons.withValues(alpha: active ? 0.72 : 0),
          ),
        ),
      ),
    );
  }

  void _finishDrag() {
    if (_dragging) {
      setState(() => _dragging = false);
    }
    widget.onResizeEnd();
  }
}

class _RecipeBlockEdgeBorderPainter extends CustomPainter {
  const _RecipeBlockEdgeBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.18),
          color,
          color.withValues(alpha: 0.18),
        ],
      ).createShader(Offset.zero & size);
    final halfWidth = size.width / 2;

    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 0.55)
      ..quadraticBezierTo(halfWidth, 3.1, 0, 0.55)
      ..close();
    final bottomPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - 0.55)
      ..quadraticBezierTo(halfWidth, size.height - 3.1, 0, size.height - 0.55)
      ..close();

    canvas
      ..drawPath(topPath, paint)
      ..drawPath(bottomPath, paint);
  }

  @override
  bool shouldRepaint(covariant _RecipeBlockEdgeBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _RecipeEditorInspector extends StatefulWidget {
  const _RecipeEditorInspector({
    this.embedded = false,
    required this.block,
    required this.onWidthChanged,
    required this.onAlignmentChanged,
    required this.onSpacingChanged,
    required this.onVariantChanged,
    required this.onTextAlignmentChanged,
    required this.onTextSizeChanged,
    required this.onBlockChanged,
  });

  final bool embedded;
  final _RecipeEditorBlock? block;
  final ValueChanged<_RecipeBlockWidth> onWidthChanged;
  final ValueChanged<_RecipeBlockAlignment> onAlignmentChanged;
  final ValueChanged<_RecipeBlockSpacing> onSpacingChanged;
  final ValueChanged<_RecipeBlockVariant> onVariantChanged;
  final ValueChanged<_RecipeTextAlignment> onTextAlignmentChanged;
  final ValueChanged<_RecipeTextSize> onTextSizeChanged;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;

  @override
  State<_RecipeEditorInspector> createState() => _RecipeEditorInspectorState();
}

class _RecipeEditorInspectorState extends State<_RecipeEditorInspector> {
  _RecipeInspectorTab _activeTab = _RecipeInspectorTab.block;

  bool get embedded => widget.embedded;
  _RecipeEditorBlock? get block => widget.block;
  ValueChanged<_RecipeBlockWidth> get onWidthChanged => widget.onWidthChanged;
  ValueChanged<_RecipeBlockAlignment> get onAlignmentChanged =>
      widget.onAlignmentChanged;
  ValueChanged<_RecipeBlockSpacing> get onSpacingChanged =>
      widget.onSpacingChanged;
  ValueChanged<_RecipeBlockVariant> get onVariantChanged =>
      widget.onVariantChanged;
  ValueChanged<_RecipeTextAlignment> get onTextAlignmentChanged =>
      widget.onTextAlignmentChanged;
  ValueChanged<_RecipeTextSize> get onTextSizeChanged =>
      widget.onTextSizeChanged;
  ValueChanged<_RecipeEditorBlock> get onBlockChanged => widget.onBlockChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selectedBlock = block;

    return Container(
      key: ValueKey('recipe-inspector-block-${selectedBlock?.id ?? 'none'}'),
      width: double.infinity,
      padding: embedded ? EdgeInsets.zero : const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: embedded
            ? Colors.transparent
            : palette.cardsSurface.withValues(alpha: 0.72),
        borderRadius: embedded
            ? BorderRadius.zero
            : BorderRadius.circular(AppSpacing.radiusMd),
        border: embedded
            ? null
            : Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: selectedBlock == null
          ? _RecipeInspectorEmptyState(palette: palette)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      selectedBlock.kind.icon,
                      color: palette.primaryButtons,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        selectedBlock.kind.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: palette.mainText,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _RecipeInspectorTabs(
                  selected: _activeTab,
                  onSelected: (tab) => setState(() => _activeTab = tab),
                ),
                const SizedBox(height: AppSpacing.md),
                if (_activeTab == _RecipeInspectorTab.block) ...[
                  _RecipePresetSelector<_RecipeBlockWidth>(
                    label: 'Width',
                    values: _RecipeBlockWidth.values,
                    selected: selectedBlock.width,
                    labelForValue: _widthLabel,
                    onSelected: onWidthChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _RecipePresetSelector<_RecipeBlockAlignment>(
                    label: 'Alignment',
                    values: _RecipeBlockAlignment.values,
                    selected: selectedBlock.alignment,
                    labelForValue: _alignmentLabel,
                    onSelected: onAlignmentChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _RecipePresetSelector<_RecipeBlockSpacing>(
                    label: 'Spacing',
                    values: _RecipeBlockSpacing.values,
                    selected: selectedBlock.spacing,
                    labelForValue: _spacingLabel,
                    onSelected: onSpacingChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _RecipePresetSelector<_RecipeBlockVariant>(
                    label: 'Variant',
                    values: _RecipeBlockVariant.values,
                    selected: selectedBlock.variant,
                    labelForValue: _variantLabel,
                    onSelected: onVariantChanged,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _RecipeInspectorRuleNote(block: selectedBlock),
                ] else
                  _RecipeTextContentInspector(
                    block: selectedBlock,
                    onAlignmentChanged: onTextAlignmentChanged,
                    onSizeChanged: onTextSizeChanged,
                    onBlockChanged: onBlockChanged,
                  ),
              ],
            ),
    );
  }

  String _widthLabel(_RecipeBlockWidth width) {
    return switch (width) {
      _RecipeBlockWidth.narrow => 'Narrow',
      _RecipeBlockWidth.normal => 'Normal',
      _RecipeBlockWidth.wide => 'Wide',
      _RecipeBlockWidth.full => 'Full',
    };
  }

  String _alignmentLabel(_RecipeBlockAlignment alignment) {
    return switch (alignment) {
      _RecipeBlockAlignment.left => 'Left',
      _RecipeBlockAlignment.center => 'Center',
      _RecipeBlockAlignment.right => 'Right',
    };
  }

  String _spacingLabel(_RecipeBlockSpacing spacing) {
    return switch (spacing) {
      _RecipeBlockSpacing.compact => 'Compact',
      _RecipeBlockSpacing.normal => 'Normal',
      _RecipeBlockSpacing.spacious => 'Spacious',
    };
  }

  String _variantLabel(_RecipeBlockVariant variant) {
    return switch (variant) {
      _RecipeBlockVariant.simple => 'Simple',
      _RecipeBlockVariant.cards => 'Cards',
      _RecipeBlockVariant.timeline => 'Timeline',
    };
  }
}

class _RecipeInspectorTabs extends StatelessWidget {
  const _RecipeInspectorTabs({
    required this.selected,
    required this.onSelected,
  });

  final _RecipeInspectorTab selected;
  final ValueChanged<_RecipeInspectorTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RecipeInspectorTabButton(
            label: 'Block',
            icon: Icons.crop_free_rounded,
            selected: selected == _RecipeInspectorTab.block,
            onPressed: () => onSelected(_RecipeInspectorTab.block),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _RecipeInspectorTabButton(
            label: 'Content',
            icon: Icons.text_fields_rounded,
            selected: selected == _RecipeInspectorTab.content,
            onPressed: () => onSelected(_RecipeInspectorTab.content),
          ),
        ),
      ],
    );
  }
}

class _RecipeInspectorTabButton extends StatelessWidget {
  const _RecipeInspectorTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      key: ValueKey('recipe-inspector-tab-${label.toLowerCase()}'),
      color: selected
          ? palette.primaryButtons.withValues(alpha: 0.22)
          : palette.searchBarBackground.withValues(alpha: 0.62),
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? palette.primaryButtons : palette.icons,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? palette.mainText : palette.secondaryText,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeTextContentInspector extends StatelessWidget {
  const _RecipeTextContentInspector({
    required this.block,
    required this.onAlignmentChanged,
    required this.onSizeChanged,
    required this.onBlockChanged,
  });

  final _RecipeEditorBlock block;
  final ValueChanged<_RecipeTextAlignment> onAlignmentChanged;
  final ValueChanged<_RecipeTextSize> onSizeChanged;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (!block.kind.supportsTextSettings) {
      return Text(
        'This block has no content presets yet.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
      );
    }

    final alignments = block.kind.supportsJustifiedText
        ? _RecipeTextAlignment.values
        : _RecipeTextAlignment.values
              .where((value) => value != _RecipeTextAlignment.justify)
              .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text alignment',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.categoryTags,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            for (var index = 0; index < alignments.length; index++) ...[
              Expanded(
                child: _RecipeTextAlignmentButton(
                  alignment: alignments[index],
                  selected: block.textAlignment == alignments[index],
                  onPressed: () => onAlignmentChanged(alignments[index]),
                ),
              ),
              if (index < alignments.length - 1)
                const SizedBox(width: AppSpacing.xs),
            ],
          ],
        ),
        if (block.kind == _RecipeBlockKind.quote) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Quote line',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: palette.categoryTags,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (final side in _RecipeQuoteLineSide.values) ...[
                Expanded(
                  child: _RecipeQuoteLineSideButton(
                    side: side,
                    selected: block.quoteLineSide == side,
                    onPressed: () =>
                        onBlockChanged(block.copyWith(quoteLineSide: side)),
                  ),
                ),
                if (side != _RecipeQuoteLineSide.values.last)
                  const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          'Text size',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.categoryTags,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<_RecipeTextSize>(
          key: ValueKey('recipe-text-size-${block.id}-${block.textSize.name}'),
          initialValue: block.textSize,
          isExpanded: true,
          dropdownColor: palette.navbarBackground,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: palette.searchBarBackground.withValues(alpha: 0.72),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              borderSide: BorderSide(
                color: palette.borders.withValues(alpha: 0.72),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              borderSide: BorderSide(
                color: palette.borders.withValues(alpha: 0.72),
              ),
            ),
          ),
          items: [
            for (final size in _RecipeTextSize.values)
              DropdownMenuItem(value: size, child: Text(_textSizeLabel(size))),
          ],
          onChanged: (value) {
            if (value != null) {
              onSizeChanged(value);
            }
          },
        ),
      ],
    );
  }

  String _textSizeLabel(_RecipeTextSize size) {
    return switch (size) {
      _RecipeTextSize.extraSmall => 'Extra small',
      _RecipeTextSize.small => 'Small',
      _RecipeTextSize.medium => 'Medium',
      _RecipeTextSize.large => 'Large',
      _RecipeTextSize.extraLarge => 'Extra large',
    };
  }
}

class _RecipeQuoteLineSideButton extends StatelessWidget {
  const _RecipeQuoteLineSideButton({
    required this.side,
    required this.selected,
    required this.onPressed,
  });

  final _RecipeQuoteLineSide side;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final left = side == _RecipeQuoteLineSide.left;

    return Tooltip(
      message: left ? 'Line on left' : 'Line on right',
      child: Material(
        key: ValueKey('recipe-quote-line-${side.name}'),
        color: selected
            ? palette.primaryButtons.withValues(alpha: 0.24)
            : palette.searchBarBackground.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: SizedBox(
            height: 40,
            child: Icon(
              left ? Icons.border_left_rounded : Icons.border_right_rounded,
              size: 20,
              color: selected ? palette.primaryButtons : palette.icons,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeTextAlignmentButton extends StatelessWidget {
  const _RecipeTextAlignmentButton({
    required this.alignment,
    required this.selected,
    required this.onPressed,
  });

  final _RecipeTextAlignment alignment;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (icon, tooltip) = switch (alignment) {
      _RecipeTextAlignment.left => (Icons.format_align_left_rounded, 'Left'),
      _RecipeTextAlignment.center => (
        Icons.format_align_center_rounded,
        'Center',
      ),
      _RecipeTextAlignment.right => (Icons.format_align_right_rounded, 'Right'),
      _RecipeTextAlignment.justify => (
        Icons.format_align_justify_rounded,
        'Justify',
      ),
    };

    return Tooltip(
      message: tooltip,
      child: Material(
        key: ValueKey('recipe-text-align-${alignment.name}'),
        color: selected
            ? palette.primaryButtons.withValues(alpha: 0.24)
            : palette.searchBarBackground.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: SizedBox(
            height: 40,
            child: Icon(
              icon,
              size: 19,
              color: selected ? palette.primaryButtons : palette.icons,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeInspectorEmptyState extends StatelessWidget {
  const _RecipeInspectorEmptyState({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Select a block to edit presets.',
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
    );
  }
}

class _RecipeInspectorRuleNote extends StatelessWidget {
  const _RecipeInspectorRuleNote({required this.block});

  final _RecipeEditorBlock block;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = block.canContainChildren
        ? 'This layout block can contain child blocks.'
        : 'Content blocks cannot contain nested blocks.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: palette.borders.withValues(alpha: 0.58)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: palette.icons),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.secondaryText,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipePresetSelector<T extends Object> extends StatelessWidget {
  const _RecipePresetSelector({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelForValue,
    required this.onSelected,
  });

  final String label;
  final List<T> values;
  final T selected;
  final String Function(T value) labelForValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.categoryTags,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final value in values)
              ChoiceChip(
                label: Text(labelForValue(value)),
                selected: value == selected,
                onSelected: (_) => onSelected(value),
                labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: value == selected
                      ? palette.mainText
                      : palette.secondaryText,
                  fontWeight: FontWeight.w800,
                ),
                selectedColor: palette.primaryButtons.withValues(alpha: 0.24),
                backgroundColor: palette.searchBarBackground.withValues(
                  alpha: 0.62,
                ),
                side: BorderSide(
                  color: value == selected
                      ? palette.primaryButtons
                      : palette.borders.withValues(alpha: 0.58),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RecipeEditorPalette extends StatelessWidget {
  const _RecipeEditorPalette({
    this.embedded = false,
    required this.activeTab,
    required this.templates,
    required this.blocks,
    required this.blockCueAnimation,
    required this.onTabChanged,
    required this.onTemplateSelected,
    required this.onBlockSelected,
  });

  final bool embedded;
  final _RecipeEditorTab activeTab;
  final List<_RecipeTemplateDefinition> templates;
  final List<_RecipeBlockDefinition> blocks;
  final Animation<double> blockCueAnimation;
  final ValueChanged<_RecipeEditorTab> onTabChanged;
  final ValueChanged<_RecipeTemplateDefinition> onTemplateSelected;
  final ValueChanged<_RecipeBlockDefinition> onBlockSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final content = activeTab == _RecipeEditorTab.templates
        ? _buildTemplateList(context)
        : _buildBlockList(context);

    return Container(
      padding: embedded ? EdgeInsets.zero : const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: embedded
            ? Colors.transparent
            : palette.cardsSurface.withValues(alpha: 0.72),
        borderRadius: embedded
            ? BorderRadius.zero
            : BorderRadius.circular(AppSpacing.radiusMd),
        border: embedded
            ? null
            : Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _RecipeEditorTabButton(
                  label: 'Templates',
                  selected: activeTab == _RecipeEditorTab.templates,
                  onPressed: () => onTabChanged(_RecipeEditorTab.templates),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _RecipeEditorTabButton(
                  label: 'Blocks',
                  selected: activeTab == _RecipeEditorTab.blocks,
                  onPressed: () => onTabChanged(_RecipeEditorTab.blocks),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          content,
        ],
      ),
    );
  }

  Widget _buildTemplateList(BuildContext context) {
    return Column(
      children: [
        for (final template in templates) ...[
          _RecipeTemplatePreviewTarget(
            key: ValueKey('expanded-template-${template.title}'),
            template: template,
            child: _RecipePaletteItem(
              icon: template.icon,
              title: template.title,
              description: template.description,
              onPressed: () => onTemplateSelected(template),
            ),
          ),
          if (template != templates.last) const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }

  Widget _buildBlockList(BuildContext context) {
    final groups = _RecipeBlockGroup.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          _RecipePaletteGroupTitle(group: group),
          const SizedBox(height: AppSpacing.xs),
          for (final block in blocks.where(
            (block) => block.kind.group == group,
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: _RecipePaletteBlockDragSource(
                block: block,
                child: _RecipePaletteItem(
                  icon: block.kind.icon,
                  title: block.kind.label,
                  description: block.description,
                  iconOpacity: blockCueAnimation,
                  onPressed: () => onBlockSelected(block),
                ),
              ),
            ),
          if (group != groups.last) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _RecipeEditorTabButton extends StatelessWidget {
  const _RecipeEditorTabButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: selected
          ? palette.primaryButtons.withValues(alpha: 0.22)
          : palette.searchBarBackground.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected ? palette.primaryButtons : palette.mainText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipePaletteGroupTitle extends StatelessWidget {
  const _RecipePaletteGroupTitle({required this.group});

  final _RecipeBlockGroup group;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = switch (group) {
      _RecipeBlockGroup.content => 'Content',
      _RecipeBlockGroup.recipe => 'Recipe',
      _RecipeBlockGroup.widgets => 'Widgets',
      _RecipeBlockGroup.layout => 'Layout',
    };

    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: palette.categoryTags,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class _RecipePaletteItem extends StatelessWidget {
  const _RecipePaletteItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
    this.iconOpacity,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;
  final Animation<double>? iconOpacity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.searchBarBackground.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (iconOpacity case final animation?)
                FadeTransition(
                  opacity: animation,
                  child: Icon(icon, color: palette.primaryButtons, size: 20),
                )
              else
                Icon(icon, color: palette.primaryButtons, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.mainText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.secondaryText,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeCreateHeroPanel extends StatefulWidget {
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
    required this.difficulty,
    required this.category,
    required this.onEditDuration,
    required this.onEditDifficulty,
    required this.onEditCategory,
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
  final String difficulty;
  final CategoryModel? category;
  final VoidCallback onEditDuration;
  final VoidCallback onEditDifficulty;
  final VoidCallback onEditCategory;
  final ValueChanged<String> onSubmitTag;
  final ValueChanged<String> onRemoveTag;
  final VoidCallback onAddTagPressed;
  final VoidCallback onCancelTagInput;
  final VoidCallback onPickImage;

  @override
  State<_RecipeCreateHeroPanel> createState() => _RecipeCreateHeroPanelState();
}

class _RecipeCreateHeroPanelState extends State<_RecipeCreateHeroPanel> {
  Timer? _imageHoverTimer;
  bool _isImageHovered = false;

  @override
  void dispose() {
    _imageHoverTimer?.cancel();
    super.dispose();
  }

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
              height: compact
                  ? _RecipeCreateHeroPanel._compactHeight
                  : _RecipeCreateHeroPanel._desktopHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => _setImageHovered(true),
                    onExit: (_) => _setImageHovered(false),
                    child: _RecipeCreateImageDropZone(
                      imageUrl: widget.imageUrl,
                      onPressed: widget.onPickImage,
                    ),
                  ),
                  IgnorePointer(
                    child: _RecipeCreateHeroGradientOverlay(compact: compact),
                  ),
                  IgnorePointer(
                    child: _RecipeCreateUploadHint(
                      imageUrl: widget.imageUrl,
                      isImageHovered: _isImageHovered,
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(
                        compact ? AppSpacing.lg : AppSpacing.xl,
                      ),
                      child: _RecipeCreateHeroEditor(
                        titleController: widget.titleController,
                        descriptionController: widget.descriptionController,
                        tags: widget.tags,
                        isAddingTag: widget.isAddingTag,
                        tagController: widget.tagController,
                        tagFocusNode: widget.tagFocusNode,
                        tagSuggestions: widget.tagSuggestions,
                        duration: widget.duration,
                        difficulty: widget.difficulty,
                        category: widget.category,
                        onEditDuration: widget.onEditDuration,
                        onEditDifficulty: widget.onEditDifficulty,
                        onEditCategory: widget.onEditCategory,
                        onSubmitTag: widget.onSubmitTag,
                        onRemoveTag: widget.onRemoveTag,
                        onAddTagPressed: widget.onAddTagPressed,
                        onCancelTagInput: widget.onCancelTagInput,
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

  void _setImageHovered(bool isHovered) {
    _imageHoverTimer?.cancel();

    if (isHovered) {
      _imageHoverTimer = Timer(const Duration(milliseconds: 180), () {
        if (!mounted || _isImageHovered) {
          return;
        }

        setState(() {
          _isImageHovered = true;
        });
      });
    } else if (_isImageHovered) {
      setState(() {
        _isImageHovered = false;
      });
    }
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
    required this.difficulty,
    required this.category,
    required this.onEditDuration,
    required this.onEditDifficulty,
    required this.onEditCategory,
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
  final String difficulty;
  final CategoryModel? category;
  final VoidCallback onEditDuration;
  final VoidCallback onEditDifficulty;
  final VoidCallback onEditCategory;
  final ValueChanged<String> onSubmitTag;
  final ValueChanged<String> onRemoveTag;
  final VoidCallback onAddTagPressed;
  final VoidCallback onCancelTagInput;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
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
                difficulty: difficulty,
                category: category,
                onEditDuration: onEditDuration,
                onEditDifficulty: onEditDifficulty,
                onEditCategory: onEditCategory,
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
    required this.difficulty,
    required this.category,
    required this.onEditDuration,
    required this.onEditDifficulty,
    required this.onEditCategory,
  });

  final _RecipeDurationValue duration;
  final String difficulty;
  final CategoryModel? category;
  final VoidCallback onEditDuration;
  final VoidCallback onEditDifficulty;
  final VoidCallback onEditCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _RecipeCreateMetaChip(
                  icon: Icons.schedule_rounded,
                  label: duration.label,
                  onPressed: onEditDuration,
                  isEditable: true,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _RecipeCreateMetaChip(
                  icon: Icons.local_fire_department_rounded,
                  label: difficulty,
                  onPressed: onEditDifficulty,
                  isEditable: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: double.infinity,
            child: _RecipeCreateMetaChip(
              icon: category?.icon ?? Icons.restaurant_menu_rounded,
              label: category?.title ?? 'Category',
              onPressed: onEditCategory,
              isEditable: true,
              isHighlighted: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _RecipeCreateMetaChip(
                  icon: Icons.favorite_rounded,
                  label: '0',
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _RecipeCreateMetaChip(
                  icon: Icons.star_rounded,
                  label: '0.0',
                ),
              ),
            ],
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
    this.onPressed,
    this.isEditable = false,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isEditable;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foregroundColor = isHighlighted
        ? palette.primaryButtons
        : palette.icons;

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
            color: isHighlighted
                ? palette.primaryButtons.withValues(alpha: 0.14)
                : palette.searchBarBackground.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isHighlighted
                  ? palette.primaryButtons.withValues(alpha: 0.42)
                  : palette.borders.withValues(alpha: 0.72),
            ),
          ),
          child: Row(
            children: [
              if (isEditable) const SizedBox(width: 17),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 16, color: foregroundColor),
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
              if (isEditable)
                SizedBox(
                  width: 17,
                  child: Icon(
                    Icons.edit_rounded,
                    size: 13,
                    color: palette.secondaryText.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeCategoryDialog extends StatefulWidget {
  const _RecipeCategoryDialog({required this.selected});

  final CategoryModel? selected;

  @override
  State<_RecipeCategoryDialog> createState() => _RecipeCategoryDialogState();
}

class _RecipeCategoryDialogState extends State<_RecipeCategoryDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final query = RecipeFormOptions.slug(_controller.text);
    final categories = RecipeFormOptions.categories
        .where((category) {
          if (query.isEmpty) {
            return true;
          }

          return category.id.contains(query) ||
              category.title.toLowerCase().contains(query.replaceAll('-', ' '));
        })
        .toList(growable: false);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          backgroundColor: palette.cardsSurface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: const ValueKey('recipe-create-category-search'),
                controller: _controller,
                decoration: const InputDecoration(hintText: 'Search category'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final category in categories)
                        _RecipeCategoryOption(
                          category: category,
                          selected: widget.selected?.id == category.id,
                          onSelected: () => Navigator.of(context).pop(category),
                        ),
                    ],
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

class _RecipeCategoryOption extends StatelessWidget {
  const _RecipeCategoryOption({
    required this.category,
    required this.selected,
    required this.onSelected,
  });

  final CategoryModel category;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: selected
            ? palette.primaryButtons.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          leading: Icon(
            category.icon,
            color: selected ? palette.primaryButtons : palette.icons,
          ),
          title: Text(category.title),
          subtitle: Text(category.description),
          trailing: selected ? const Icon(Icons.check_rounded) : null,
          onTap: onSelected,
        ),
      ),
    );
  }
}

class _RecipeDifficultyDialog extends StatelessWidget {
  const _RecipeDifficultyDialog({required this.selected});

  static const List<String> _options = ['Easy', 'Medium', 'Hard'];

  final String selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          backgroundColor: palette.cardsSurface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Difficulty', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              for (final option in _options)
                _RecipeDifficultyOption(
                  label: option,
                  selected: selected == option,
                  onSelected: () => Navigator.of(context).pop(option),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeDifficultyOption extends StatelessWidget {
  const _RecipeDifficultyOption({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: selected
            ? palette.primaryButtons.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          leading: Icon(
            Icons.local_fire_department_rounded,
            color: selected ? palette.primaryButtons : palette.icons,
          ),
          title: Text(label),
          trailing: selected ? const Icon(Icons.check_rounded) : null,
          onTap: onSelected,
        ),
      ),
    );
  }
}

class _RecipeDurationPickerDialog extends StatefulWidget {
  const _RecipeDurationPickerDialog({required this.initial});

  final _RecipeDurationValue initial;

  @override
  State<_RecipeDurationPickerDialog> createState() =>
      _RecipeDurationPickerDialogState();
}

class _RecipeDurationPickerDialogState
    extends State<_RecipeDurationPickerDialog> {
  late _RecipeDurationValue _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          backgroundColor: palette.cardsSurface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set cooking time',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 380;
                  final steppers = [
                    _RecipeDurationStepper(
                      label: 'Days',
                      value: _value.days,
                      onIncrement: () =>
                          _setDays(_nextCyclic(_value.days, 0, 30)),
                      onDecrement: () =>
                          _setDays(_previousCyclic(_value.days, 0, 30)),
                    ),
                    _RecipeDurationStepper(
                      label: 'Hours',
                      value: _value.hours,
                      onIncrement: () =>
                          _setHours(_nextCyclic(_value.hours, 0, 23)),
                      onDecrement: () =>
                          _setHours(_previousCyclic(_value.hours, 0, 23)),
                    ),
                    _RecipeDurationStepper(
                      label: 'Minutes',
                      value: _value.minutes,
                      onIncrement: () => _setMinutes(
                        _nextCyclic(_value.minutes, 0, 55, step: 5),
                      ),
                      onDecrement: () => _setMinutes(
                        _previousCyclic(_value.minutes, 0, 55, step: 5),
                      ),
                    ),
                  ];

                  if (stacked) {
                    return Column(
                      children: [
                        for (
                          var index = 0;
                          index < steppers.length;
                          index++
                        ) ...[
                          if (index > 0) const SizedBox(height: AppSpacing.sm),
                          steppers[index],
                        ],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      for (var index = 0; index < steppers.length; index++) ...[
                        if (index > 0) const SizedBox(width: AppSpacing.sm),
                        Expanded(child: steppers[index]),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(_value),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setDays(int days) {
    setState(() {
      _value = _value.copyWith(days: days);
    });
  }

  void _setHours(int hours) {
    setState(() {
      _value = _value.copyWith(hours: hours);
    });
  }

  void _setMinutes(int minutes) {
    setState(() {
      _value = _value.copyWith(minutes: minutes);
    });
  }

  int _nextCyclic(int value, int min, int max, {int step = 1}) {
    final next = value + step;
    return next > max ? min : next;
  }

  int _previousCyclic(int value, int min, int max, {int step = 1}) {
    final previous = value - step;
    return previous < min ? max : previous;
  }
}

class _RecipeDurationStepper extends StatelessWidget {
  const _RecipeDurationStepper({
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: palette.borders.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Decrease $label',
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_rounded),
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 30,
                  height: 30,
                ),
                visualDensity: VisualDensity.compact,
              ),
              SizedBox(
                width: 38,
                child: Text(
                  value.toString().padLeft(2, '0'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Increase $label',
                onPressed: onIncrement,
                icon: const Icon(Icons.add_rounded),
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 30,
                  height: 30,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecipeCreateTagRow extends StatefulWidget {
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
  State<_RecipeCreateTagRow> createState() => _RecipeCreateTagRowState();
}

class _RecipeCreateTagRowState extends State<_RecipeCreateTagRow> {
  final GlobalKey _tagInputAnchorKey = GlobalKey();
  OverlayEntry? _suggestionsOverlay;

  @override
  void didUpdateWidget(covariant _RecipeCreateTagRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleSuggestionsOverlaySync();
  }

  @override
  void dispose() {
    _removeSuggestionsOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleSuggestionsOverlaySync();

    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = _buildRows(context, constraints.maxWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (
                    var itemIndex = 0;
                    itemIndex < rows[rowIndex].length;
                    itemIndex++
                  ) ...[
                    if (itemIndex > 0) const SizedBox(width: AppSpacing.xs),
                    SizedBox(
                      width: rows[rowIndex][itemIndex].width,
                      child: _buildTagItem(rows[rowIndex][itemIndex].item),
                    ),
                  ],
                ],
              ),
              if (rowIndex < rows.length - 1)
                const SizedBox(height: AppSpacing.xxs),
            ],
          ],
        );
      },
    );
  }

  List<List<_RecipeCreateTagLayout>> _buildRows(
    BuildContext context,
    double maxWidth,
  ) {
    final safeWidth = maxWidth.isFinite && maxWidth > 0
        ? maxWidth
        : AppSpacing.contentMaxWidth;
    final seeds = _buildSeeds(context, safeWidth);
    final rows = <List<_RecipeCreateTagSeed>>[];
    var currentRow = <_RecipeCreateTagSeed>[];
    var currentWidth = 0.0;

    for (final seed in seeds) {
      final nextWidth =
          currentWidth + (currentRow.isEmpty ? 0 : AppSpacing.xs) + seed.width;

      if (currentRow.isNotEmpty && nextWidth > safeWidth) {
        rows.add(currentRow);
        currentRow = [seed];
        currentWidth = seed.width;
      } else {
        currentRow.add(seed);
        currentWidth = nextWidth;
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    if (rows.isEmpty) {
      return const [];
    }

    final targetWidth = rows
        .map(_rowWidth)
        .fold<double>(0, (largest, width) => width > largest ? width : largest)
        .clamp(0, safeWidth)
        .toDouble();

    return [for (final row in rows) _justifyRow(row, targetWidth)];
  }

  List<_RecipeCreateTagSeed> _buildSeeds(
    BuildContext context,
    double maxWidth,
  ) {
    return [
      for (final tag in widget.tags)
        _RecipeCreateTagSeed(
          _RecipeCreateTagItem.tag(tag),
          _measureTagChipWidth(context, tag, maxWidth),
        ),
      if (widget.isAddingTag)
        const _RecipeCreateTagSeed(
          _RecipeCreateTagItem.input(),
          _RecipeCreateTagInputChip.width,
        )
      else if (widget.tags.length < 10)
        _RecipeCreateTagSeed(
          const _RecipeCreateTagItem.add(),
          _measureAddTagChipWidth(context, maxWidth),
        ),
    ];
  }

  List<_RecipeCreateTagLayout> _justifyRow(
    List<_RecipeCreateTagSeed> row,
    double targetWidth,
  ) {
    final spacing = AppSpacing.xs * (row.length - 1);
    final baseWidth = row.fold<double>(0, (sum, seed) => sum + seed.width);
    final extra = (targetWidth - spacing - baseWidth).clamp(0, double.infinity);
    final extraPerChip = row.isEmpty ? 0.0 : extra / row.length;

    return [
      for (final seed in row)
        _RecipeCreateTagLayout(seed.item, seed.width + extraPerChip),
    ];
  }

  Widget _buildTagItem(_RecipeCreateTagItem item) {
    return switch (item.type) {
      _RecipeCreateTagItemType.tag => _RecipeCreateTagChip(
        tag: item.tag!,
        onRemove: () => widget.onRemoveTag(item.tag!),
      ),
      _RecipeCreateTagItemType.input => KeyedSubtree(
        key: _tagInputAnchorKey,
        child: _RecipeCreateTagInputChip(
          controller: widget.tagController,
          focusNode: widget.tagFocusNode,
          onSubmitted: widget.onSubmitTag,
          onCancel: widget.onCancelTagInput,
        ),
      ),
      _RecipeCreateTagItemType.add => _RecipeCreateAddTagChip(
        onPressed: widget.onAddTagPressed,
      ),
    };
  }

  double _rowWidth(List<_RecipeCreateTagSeed> row) {
    final spacing = AppSpacing.xs * (row.length - 1);
    return row.fold<double>(spacing, (sum, seed) => sum + seed.width);
  }

  double _measureTagChipWidth(
    BuildContext context,
    String tag,
    double maxWidth,
  ) {
    final textStyle =
        Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700) ??
        DefaultTextStyle.of(context).style;
    final textPainter = TextPainter(
      text: TextSpan(
        text: RecipeFormOptions.readableTagLabel(tag),
        style: textStyle,
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    return (textPainter.width + 24 + AppSpacing.xs + (AppSpacing.sm * 2))
        .clamp(58, maxWidth)
        .toDouble();
  }

  double _measureAddTagChipWidth(BuildContext context, double maxWidth) {
    final textStyle =
        Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800) ??
        DefaultTextStyle.of(context).style;
    final textPainter = TextPainter(
      text: TextSpan(text: 'Tag', style: textStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    return (textPainter.width + 22 + AppSpacing.xxs + (AppSpacing.sm * 2))
        .clamp(58, maxWidth)
        .toDouble();
  }

  void _scheduleSuggestionsOverlaySync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncSuggestionsOverlay();
      }
    });
  }

  void _syncSuggestionsOverlay() {
    final shouldShow = widget.isAddingTag && widget.tagSuggestions.isNotEmpty;

    if (!shouldShow) {
      _removeSuggestionsOverlay();
      return;
    }

    if (_suggestionsOverlay == null) {
      _suggestionsOverlay = OverlayEntry(
        builder: (context) {
          final anchorRect = _tagInputRect;
          if (anchorRect == null) {
            return const SizedBox.shrink();
          }

          return Positioned(
            left: anchorRect.left,
            top: anchorRect.bottom + AppSpacing.xs,
            child: _RecipeCreateTagSuggestions(
              tags: widget.tagSuggestions,
              onSelected: widget.onSubmitTag,
            ),
          );
        },
      );
      Overlay.of(context, rootOverlay: true).insert(_suggestionsOverlay!);
      return;
    }

    _suggestionsOverlay?.markNeedsBuild();
  }

  Rect? get _tagInputRect {
    final renderObject = _tagInputAnchorKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }

    final offset = renderObject.localToGlobal(Offset.zero);
    return offset & renderObject.size;
  }

  void _removeSuggestionsOverlay() {
    _suggestionsOverlay?.remove();
    _suggestionsOverlay = null;
  }
}

enum _RecipeCreateTagItemType { tag, input, add }

class _RecipeCreateTagItem {
  const _RecipeCreateTagItem.tag(this.tag)
    : type = _RecipeCreateTagItemType.tag;

  const _RecipeCreateTagItem.input()
    : type = _RecipeCreateTagItemType.input,
      tag = null;

  const _RecipeCreateTagItem.add()
    : type = _RecipeCreateTagItemType.add,
      tag = null;

  final _RecipeCreateTagItemType type;
  final String? tag;
}

class _RecipeCreateTagSeed {
  const _RecipeCreateTagSeed(this.item, this.width);

  final _RecipeCreateTagItem item;
  final double width;
}

class _RecipeCreateTagLayout {
  const _RecipeCreateTagLayout(this.item, this.width);

  final _RecipeCreateTagItem item;
  final double width;
}

class _RecipeCreateTagChip extends StatelessWidget {
  const _RecipeCreateTagChip({required this.tag, required this.onRemove});

  final String tag;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              RecipeFormOptions.readableTagLabel(tag),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.mainText,
                fontWeight: FontWeight.w700,
              ),
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

  static const double width = 180;

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      alignment: Alignment.center,
      width: width,
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('recipe-create-add-tag-chip'),
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: palette.primaryButtons.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: palette.primaryButtons.withValues(alpha: 0.48),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 18, color: palette.mainText),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                'Tag',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.mainText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeHeroTextField extends StatefulWidget {
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
  State<_RecipeHeroTextField> createState() => _RecipeHeroTextFieldState();
}

class _RecipeHeroTextFieldState extends State<_RecipeHeroTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFieldStateChange);
    widget.controller.addListener(_handleFieldStateChange);
  }

  @override
  void didUpdateWidget(covariant _RecipeHeroTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleFieldStateChange);
      widget.controller.addListener(_handleFieldStateChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleFieldStateChange);
    _focusNode.removeListener(_handleFieldStateChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasText = widget.controller.text.trim().isNotEmpty;
    final isPlainText = hasText && !_focusNode.hasFocus;

    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      style: widget.style,
      cursorColor: palette.primaryButtons,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: widget.style?.copyWith(
          color: palette.mainText.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: isPlainText
            ? Colors.transparent
            : palette.searchBarBackground.withValues(alpha: 0.42),
        border: _fieldBorder(palette, isPlainText: isPlainText),
        enabledBorder: _fieldBorder(palette, isPlainText: isPlainText),
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

  void _handleFieldStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  OutlineInputBorder _fieldBorder(
    AppPalette palette, {
    required bool isPlainText,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(
        color: isPlainText
            ? Colors.transparent
            : palette.borders.withValues(alpha: 0.36),
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
          ],
        ),
      ),
    );
  }
}

class _RecipeCreateUploadHint extends StatelessWidget {
  const _RecipeCreateUploadHint({
    required this.imageUrl,
    required this.isImageHovered,
  });

  final String? imageUrl;
  final bool isImageHovered;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasImage = imageUrl != null;
    final isVisible = !hasImage || isImageHovered;

    return AnimatedOpacity(
      opacity: isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: Center(
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: hasImage
                ? palette.navbarBackground.withValues(alpha: 0.72)
                : palette.primaryButtons.withValues(alpha: 0.15),
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
