import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/recipes/data/recipe_form_options.dart';
import 'package:frontend/features/recipes/presentation/image_upload/recipe_image_picker.dart';
import 'package:frontend/shared/models/home_models.dart';

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
      children: children ?? this.children,
    );
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
        const SizedBox(height: AppSpacing.lg),
        const _RecipeBodyEditor(),
      ],
    );
  }
}

class _RecipeBodyEditor extends StatefulWidget {
  const _RecipeBodyEditor();

  @override
  State<_RecipeBodyEditor> createState() => _RecipeBodyEditorState();
}

class _RecipeBodyEditorState extends State<_RecipeBodyEditor> {
  static const int _maxDepth = 4;

  final OverlayPortalController _overlayController = OverlayPortalController();
  int _nextId = 0;
  _RecipeEditorTab _activeTab = _RecipeEditorTab.templates;
  bool _paletteExpanded = false;
  bool _inspectorExpanded = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _overlayController.show();
      }
    });
  }

  @override
  void dispose() {
    _overlayController.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasPanel = _RecipeEditorCanvas(
      blocks: _blocks,
      selectedBlockId: _selectedBlockId,
      insertionHint: _insertionHint,
      onBlockSelected: _selectBlock,
      onBlockTitleChanged: _updateBlockTitle,
      onBlockBodyChanged: _updateBlockBody,
      onInsertParagraphAt: _insertParagraphAt,
      onMoveBlock: _moveRootBlock,
      onDuplicateBlock: _duplicateBlock,
      onDeleteBlock: _deleteBlock,
    );

    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) => _RecipeEditorOverlay(
        activeTab: _activeTab,
        paletteExpanded: _paletteExpanded,
        inspectorExpanded: _inspectorExpanded,
        templates: _templateDefinitions,
        blocks: _blockDefinitions,
        selectedBlock: _selectedBlock,
        onTabChanged: _setActiveTab,
        onPaletteExpandedChanged: (value) {
          setState(() => _paletteExpanded = value);
        },
        onInspectorExpandedChanged: (value) {
          setState(() => _inspectorExpanded = value);
        },
        onTemplateSelected: _insertTemplate,
        onBlockSelected: _insertBlock,
        onWidthChanged: _updateSelectedBlockWidth,
        onAlignmentChanged: _updateSelectedBlockAlignment,
        onSpacingChanged: _updateSelectedBlockSpacing,
        onVariantChanged: _updateSelectedBlockVariant,
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

  String get _insertionHint {
    final selected = _selectedBlock;
    if (selected == null) {
      return 'Palette inserts new content at the end of the recipe.';
    }

    final depth = _depthOfBlock(_blocks, selected.id) ?? 0;
    if (selected.canContainChildren && depth < _maxDepth) {
      return 'Palette inserts into ${selected.title.isEmpty ? selected.kind.label : selected.title}.';
    }

    return 'Selected block cannot contain more children. Palette inserts at root.';
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

  void _updateBlockTitle(String blockId, String title) {
    _updateBlock(blockId, (block) => block.copyWith(title: title));
  }

  void _updateBlockBody(String blockId, String body) {
    _updateBlock(blockId, (block) => block.copyWith(body: body));
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

  void _updateBlock(
    String blockId,
    _RecipeEditorBlock Function(_RecipeEditorBlock block) update,
  ) {
    setState(() {
      _blocks = _mapBlocks(_blocks, blockId, update);
    });
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
    _insertBlocksUsingSelection([_createBlock(block.kind)]);
  }

  void _insertParagraphAt(int index) {
    _insertBlockAt(index, _createBlock(_RecipeBlockKind.paragraph));
  }

  void _insertBlockAt(int index, _RecipeEditorBlock block) {
    setState(() {
      final targetIndex = index.clamp(0, _blocks.length).toInt();
      _blocks = [..._blocks]..insert(targetIndex, block);
      _selectedBlockId = block.id;
    });
  }

  void _moveRootBlock(String blockId, int targetIndex) {
    final currentIndex = _blocks.indexWhere((block) => block.id == blockId);
    if (currentIndex < 0) {
      return;
    }

    setState(() {
      final nextBlocks = [..._blocks];
      final block = nextBlocks.removeAt(currentIndex);
      final adjustedIndex = currentIndex < targetIndex
          ? targetIndex - 1
          : targetIndex;
      nextBlocks.insert(
        adjustedIndex.clamp(0, nextBlocks.length).toInt(),
        block,
      );
      _blocks = nextBlocks;
      _selectedBlockId = block.id;
    });
  }

  void _duplicateBlock(String blockId) {
    setState(() {
      _blocks = _duplicateBlockInList(_blocks, blockId);
    });
  }

  void _deleteBlock(String blockId) {
    setState(() {
      _blocks = _removeBlockFromList(_blocks, blockId);
      if (_selectedBlockId == blockId) {
        _selectedBlockId = _blocks.isEmpty ? null : _blocks.first.id;
      }
    });
  }

  List<_RecipeEditorBlock> _duplicateBlockInList(
    List<_RecipeEditorBlock> blocks,
    String blockId,
  ) {
    final result = <_RecipeEditorBlock>[];
    for (final block in blocks) {
      if (block.id == blockId) {
        final clone = _cloneBlock(block);
        result
          ..add(block)
          ..add(clone);
        _selectedBlockId = clone.id;
        continue;
      }

      result.add(
        block.copyWith(
          children: _duplicateBlockInList(block.children, blockId),
        ),
      );
    }
    return result;
  }

  _RecipeEditorBlock _cloneBlock(_RecipeEditorBlock block) {
    return block.copyWith(
      id: _newBlockId(block.kind.name),
      children: [for (final child in block.children) _cloneBlock(child)],
    );
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
  });

  final _RecipeEditorTab activeTab;
  final bool paletteExpanded;
  final bool inspectorExpanded;
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

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);
    final top = headerHeight + AppSpacing.sm;

    return Stack(
      children: [
        Positioned(
          top: top,
          bottom: AppSpacing.sm,
          left: AppSpacing.sm,
          child: _RecipePaletteDock(
            expanded: paletteExpanded,
            activeTab: activeTab,
            templates: templates,
            blocks: blocks,
            onExpandedChanged: onPaletteExpandedChanged,
            onTabChanged: onTabChanged,
            onTemplateSelected: onTemplateSelected,
            onBlockSelected: onBlockSelected,
          ),
        ),
        Positioned(
          top: top,
          bottom: AppSpacing.sm,
          right: AppSpacing.sm,
          child: _RecipeInspectorDock(
            expanded: inspectorExpanded,
            block: selectedBlock,
            onExpandedChanged: onInspectorExpandedChanged,
            onWidthChanged: onWidthChanged,
            onAlignmentChanged: onAlignmentChanged,
            onSpacingChanged: onSpacingChanged,
            onVariantChanged: onVariantChanged,
          ),
        ),
      ],
    );
  }
}

class _RecipePaletteDock extends StatelessWidget {
  const _RecipePaletteDock({
    required this.expanded,
    required this.activeTab,
    required this.templates,
    required this.blocks,
    required this.onExpandedChanged,
    required this.onTabChanged,
    required this.onTemplateSelected,
    required this.onBlockSelected,
  });

  final bool expanded;
  final _RecipeEditorTab activeTab;
  final List<_RecipeTemplateDefinition> templates;
  final List<_RecipeBlockDefinition> blocks;
  final ValueChanged<bool> onExpandedChanged;
  final ValueChanged<_RecipeEditorTab> onTabChanged;
  final ValueChanged<_RecipeTemplateDefinition> onTemplateSelected;
  final ValueChanged<_RecipeBlockDefinition> onBlockSelected;

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
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
      child: expanded
          ? Column(
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
                      activeTab: activeTab,
                      templates: templates,
                      blocks: blocks,
                      onTabChanged: onTabChanged,
                      onTemplateSelected: onTemplateSelected,
                      onBlockSelected: onBlockSelected,
                    ),
                  ),
                ),
              ],
            )
          : _RecipeCompactPalette(
              activeTab: activeTab,
              templates: templates,
              blocks: blocks,
              onTabChanged: onTabChanged,
              onExpanded: () => onExpandedChanged(true),
              onTemplateSelected: onTemplateSelected,
              onBlockSelected: onBlockSelected,
            ),
    );
  }
}

class _RecipeCompactPalette extends StatelessWidget {
  const _RecipeCompactPalette({
    required this.activeTab,
    required this.templates,
    required this.blocks,
    required this.onTabChanged,
    required this.onExpanded,
    required this.onTemplateSelected,
    required this.onBlockSelected,
  });

  final _RecipeEditorTab activeTab;
  final List<_RecipeTemplateDefinition> templates;
  final List<_RecipeBlockDefinition> blocks;
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
    required this.onSelected,
  });

  final List<_RecipeBlockDefinition> blocks;
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
    required this.onPressed,
  });

  final _RecipeBlockDefinition block;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Tooltip(
      message: block.kind.label,
      child: Material(
        color: palette.searchBarBackground.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: SizedBox(
            width: 43,
            height: 42,
            child: Icon(
              block.kind.icon,
              size: 20,
              color: palette.primaryButtons,
            ),
          ),
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
            child: Tooltip(
              message: template.title,
              preferBelow: false,
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
  });

  final bool expanded;
  final _RecipeEditorBlock? block;
  final ValueChanged<bool> onExpandedChanged;
  final ValueChanged<_RecipeBlockWidth> onWidthChanged;
  final ValueChanged<_RecipeBlockAlignment> onAlignmentChanged;
  final ValueChanged<_RecipeBlockSpacing> onSpacingChanged;
  final ValueChanged<_RecipeBlockVariant> onVariantChanged;

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
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
      child: expanded
          ? Column(
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
                      block: block,
                      onWidthChanged: onWidthChanged,
                      onAlignmentChanged: onAlignmentChanged,
                      onSpacingChanged: onSpacingChanged,
                      onVariantChanged: onVariantChanged,
                    ),
                  ),
                ),
              ],
            )
          : Align(
              alignment: Alignment.topCenter,
              child: IconButton(
                tooltip: 'Open block settings',
                onPressed: () => onExpandedChanged(true),
                icon: const Icon(Icons.tune_rounded),
              ),
            ),
    );
  }
}

class _RecipeEditorCanvas extends StatelessWidget {
  const _RecipeEditorCanvas({
    required this.blocks,
    required this.selectedBlockId,
    required this.insertionHint,
    required this.onBlockSelected,
    required this.onBlockTitleChanged,
    required this.onBlockBodyChanged,
    required this.onInsertParagraphAt,
    required this.onMoveBlock,
    required this.onDuplicateBlock,
    required this.onDeleteBlock,
  });

  final List<_RecipeEditorBlock> blocks;
  final String? selectedBlockId;
  final String insertionHint;
  final ValueChanged<String> onBlockSelected;
  final void Function(String blockId, String title) onBlockTitleChanged;
  final void Function(String blockId, String body) onBlockBodyChanged;
  final ValueChanged<int> onInsertParagraphAt;
  final void Function(String blockId, int targetIndex) onMoveBlock;
  final ValueChanged<String> onDuplicateBlock;
  final ValueChanged<String> onDeleteBlock;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.cardsSurface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _RecipeLockedAuthorBlock(),
          const SizedBox(height: AppSpacing.md),
          _RecipeCanvasHint(text: insertionHint),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index <= blocks.length; index++) ...[
            _RecipeBlockInsertZone(
              index: index,
              onPressed: () => onInsertParagraphAt(index),
              onMoveBlock: onMoveBlock,
            ),
            if (index < blocks.length) ...[
              const SizedBox(height: AppSpacing.xs),
              LongPressDraggable<String>(
                data: blocks[index].id,
                feedback: _RecipeBlockDragFeedback(block: blocks[index]),
                childWhenDragging: Opacity(
                  opacity: 0.38,
                  child: _RecipeEditorBlockCard(
                    block: blocks[index],
                    selectedBlockId: selectedBlockId,
                    depth: 0,
                    onBlockSelected: onBlockSelected,
                    onBlockTitleChanged: onBlockTitleChanged,
                    onBlockBodyChanged: onBlockBodyChanged,
                    onDuplicateBlock: onDuplicateBlock,
                    onDeleteBlock: onDeleteBlock,
                  ),
                ),
                child: _RecipeEditorBlockCard(
                  block: blocks[index],
                  selectedBlockId: selectedBlockId,
                  depth: 0,
                  onBlockSelected: onBlockSelected,
                  onBlockTitleChanged: onBlockTitleChanged,
                  onBlockBodyChanged: onBlockBodyChanged,
                  onDuplicateBlock: onDuplicateBlock,
                  onDeleteBlock: onDeleteBlock,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ],
      ),
    );
  }
}

class _RecipeCanvasHint extends StatelessWidget {
  const _RecipeCanvasHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.primaryButtons.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: palette.primaryButtons.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.alt_route_rounded,
            size: 18,
            color: palette.primaryButtons,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.mainText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeLockedAuthorBlock extends StatelessWidget {
  const _RecipeLockedAuthorBlock();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Transform.translate(
      offset: const Offset(0, -10),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: palette.searchBarBackground.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: palette.borders.withValues(alpha: 0.74)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: palette.primaryButtons.withValues(alpha: 0.2),
              child: Text(
                'CS',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: palette.primaryButtons,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chef Sofia',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: palette.mainText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Author block is locked and comes from the signed-in user.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.lock_rounded, color: palette.icons, size: 18),
          ],
        ),
      ),
    );
  }
}

class _RecipeBlockInsertZone extends StatelessWidget {
  const _RecipeBlockInsertZone({
    required this.index,
    required this.onPressed,
    required this.onMoveBlock,
  });

  final int index;
  final VoidCallback onPressed;
  final void Function(String blockId, int targetIndex) onMoveBlock;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data.isNotEmpty,
      onAcceptWithDetails: (details) => onMoveBlock(details.data, index),
      builder: (context, candidateData, rejectedData) {
        final active = candidateData.isNotEmpty;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: active ? 42 : 34,
              decoration: BoxDecoration(
                color: active
                    ? palette.primaryButtons.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: active
                      ? palette.primaryButtons
                      : palette.borders.withValues(alpha: 0.58),
                ),
              ),
              child: Center(
                child: Icon(
                  active
                      ? Icons.vertical_align_center_rounded
                      : Icons.add_rounded,
                  size: 20,
                  color: palette.primaryButtons,
                ),
              ),
            ),
          ),
        );
      },
    );
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

class _RecipeEditorBlockCard extends StatelessWidget {
  const _RecipeEditorBlockCard({
    required this.block,
    required this.selectedBlockId,
    required this.depth,
    required this.onBlockSelected,
    required this.onBlockTitleChanged,
    required this.onBlockBodyChanged,
    required this.onDuplicateBlock,
    required this.onDeleteBlock,
  });

  final _RecipeEditorBlock block;
  final String? selectedBlockId;
  final int depth;
  final ValueChanged<String> onBlockSelected;
  final void Function(String blockId, String title) onBlockTitleChanged;
  final void Function(String blockId, String body) onBlockBodyChanged;
  final ValueChanged<String> onDuplicateBlock;
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
        final alignment = switch (block.alignment) {
          _RecipeBlockAlignment.left => Alignment.centerLeft,
          _RecipeBlockAlignment.center => Alignment.center,
          _RecipeBlockAlignment.right => Alignment.centerRight,
        };

        return Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * effectiveWidthFactor,
            ),
            child: _RecipeEditorBlockSurface(
              block: block,
              selectedBlockId: selectedBlockId,
              depth: depth,
              onBlockSelected: onBlockSelected,
              onBlockTitleChanged: onBlockTitleChanged,
              onBlockBodyChanged: onBlockBodyChanged,
              onDuplicateBlock: onDuplicateBlock,
              onDeleteBlock: onDeleteBlock,
            ),
          ),
        );
      },
    );
  }
}

class _RecipeEditorBlockSurface extends StatelessWidget {
  const _RecipeEditorBlockSurface({
    required this.block,
    required this.selectedBlockId,
    required this.depth,
    required this.onBlockSelected,
    required this.onBlockTitleChanged,
    required this.onBlockBodyChanged,
    required this.onDuplicateBlock,
    required this.onDeleteBlock,
  });

  final _RecipeEditorBlock block;
  final String? selectedBlockId;
  final int depth;
  final ValueChanged<String> onBlockSelected;
  final void Function(String blockId, String title) onBlockTitleChanged;
  final void Function(String blockId, String body) onBlockBodyChanged;
  final ValueChanged<String> onDuplicateBlock;
  final ValueChanged<String> onDeleteBlock;

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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => onBlockSelected(block.id),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected
                  ? palette.primaryButtons
                  : palette.borders.withValues(alpha: 0.72),
            ),
            boxShadow: block.variant == _RecipeBlockVariant.cards
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    block.kind.icon,
                    size: 18,
                    color: palette.primaryButtons,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      block.kind.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: palette.categoryTags,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Duplicate block',
                    onPressed: () => onDuplicateBlock(block.id),
                    icon: const Icon(Icons.copy_rounded),
                    iconSize: 17,
                    visualDensity: VisualDensity.compact,
                    color: palette.icons,
                  ),
                  IconButton(
                    tooltip: 'Delete block',
                    onPressed: () => onDeleteBlock(block.id),
                    icon: const Icon(Icons.delete_outline_rounded),
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    color: palette.icons,
                  ),
                ],
              ),
              SizedBox(height: gap),
              if (block.kind == _RecipeBlockKind.divider)
                Divider(color: palette.borders.withValues(alpha: 0.8))
              else
                TextFormField(
                  key: ValueKey('${block.id}-title'),
                  initialValue: block.title,
                  maxLines: 1,
                  onTap: () => onBlockSelected(block.id),
                  onChanged: (value) => onBlockTitleChanged(block.id, value),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: palette.mainText,
                    fontWeight: FontWeight.w900,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Block title',
                    hintStyle: TextStyle(
                      color: palette.secondaryText.withValues(alpha: 0.66),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              if (block.kind != _RecipeBlockKind.divider) ...[
                SizedBox(height: gap / 2),
                TextFormField(
                  key: ValueKey('${block.id}-body'),
                  initialValue: block.body,
                  minLines: 1,
                  maxLines: block.kind == _RecipeBlockKind.heading ? 1 : 4,
                  onTap: () => onBlockSelected(block.id),
                  onChanged: (value) => onBlockBodyChanged(block.id, value),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.secondaryText,
                    height: 1.35,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Write content',
                    hintStyle: TextStyle(
                      color: palette.secondaryText.withValues(alpha: 0.66),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              if (block.children.isNotEmpty) ...[
                SizedBox(height: gap),
                _buildChildren(context, gap),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildren(BuildContext context, double gap) {
    final horizontalLayout =
        block.kind == _RecipeBlockKind.columns ||
        block.kind == _RecipeBlockKind.photoText;

    if (!horizontalLayout) {
      return Column(
        children: [
          for (final child in block.children) ...[
            _buildChildCard(child),
            if (child != block.children.last) SizedBox(height: gap),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        if (compact) {
          return Column(
            children: [
              for (final child in block.children) ...[
                _buildChildCard(child),
                if (child != block.children.last) SizedBox(height: gap),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final child in block.children) ...[
              Expanded(child: _buildChildCard(child)),
              if (child != block.children.last) SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }

  Widget _buildChildCard(_RecipeEditorBlock child) {
    return _RecipeEditorBlockCard(
      block: child,
      selectedBlockId: selectedBlockId,
      depth: depth + 1,
      onBlockSelected: onBlockSelected,
      onBlockTitleChanged: onBlockTitleChanged,
      onBlockBodyChanged: onBlockBodyChanged,
      onDuplicateBlock: onDuplicateBlock,
      onDeleteBlock: onDeleteBlock,
    );
  }
}

class _RecipeEditorInspector extends StatelessWidget {
  const _RecipeEditorInspector({
    required this.block,
    required this.onWidthChanged,
    required this.onAlignmentChanged,
    required this.onSpacingChanged,
    required this.onVariantChanged,
  });

  final _RecipeEditorBlock? block;
  final ValueChanged<_RecipeBlockWidth> onWidthChanged;
  final ValueChanged<_RecipeBlockAlignment> onAlignmentChanged;
  final ValueChanged<_RecipeBlockSpacing> onSpacingChanged;
  final ValueChanged<_RecipeBlockVariant> onVariantChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selectedBlock = block;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: palette.cardsSurface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
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
                const SizedBox(height: AppSpacing.md),
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
    required this.activeTab,
    required this.templates,
    required this.blocks,
    required this.onTabChanged,
    required this.onTemplateSelected,
    required this.onBlockSelected,
  });

  final _RecipeEditorTab activeTab;
  final List<_RecipeTemplateDefinition> templates;
  final List<_RecipeBlockDefinition> blocks;
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
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: palette.cardsSurface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
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
          _RecipePaletteItem(
            icon: template.icon,
            title: template.title,
            description: template.description,
            onPressed: () => onTemplateSelected(template),
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
              child: _RecipePaletteItem(
                icon: block.kind.icon,
                title: block.kind.label,
                description: block.description,
                onPressed: () => onBlockSelected(block),
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
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;

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
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
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
              if (isEditable)
                Positioned(
                  right: 0,
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
