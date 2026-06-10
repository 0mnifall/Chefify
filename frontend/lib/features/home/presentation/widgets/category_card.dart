import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/shared/models/home_models.dart';

class CategoryCard extends StatefulWidget {
  const CategoryCard({super.key, required this.category});

  final CategoryModel category;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.category.isSaved;
  }

  @override
  void didUpdateWidget(covariant CategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _isSaved = widget.category.isSaved;
    }
  }

  void _toggleSaved() {
    setState(() {
      _isSaved = !_isSaved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _CategoryBackground(imageUrl: widget.category.imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x521A1714),
                    Color(0x7F1A1714),
                    Color(0xB21A1714),
                    Color(0xD91A1714),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: Colors.white.withValues(alpha: 0.75),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.66),
                          ),
                        ),
                        child: Icon(
                          widget.category.icon,
                          color: const Color(0xFF7B4D32),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        isSelected: _isSaved,
                        onPressed: _toggleSaved,
                        selectedIcon: const Icon(
                          Icons.bookmark_rounded,
                          size: 20,
                        ),
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
                  const Spacer(),
                  Text(
                    widget.category.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.category.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${widget.category.recipesCount} recipes',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBackground extends StatelessWidget {
  const _CategoryBackground({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8F684A), Color(0xFF4B5F52)],
          ),
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8F684A), Color(0xFF4B5F52)],
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8F684A), Color(0xFF4B5F52)],
            ),
          ),
        );
      },
    );
  }
}
