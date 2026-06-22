import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class BookmarkButton extends StatelessWidget {
  const BookmarkButton({
    super.key,
    required this.isSaved,
    required this.onPressed,
  });

  final bool isSaved;
  final VoidCallback onPressed;

  static const saveTooltip = 'Save to bookmarks';
  static const removeTooltip = 'Remove from bookmarks';

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final savedColor = palette.activeElements;
    final backgroundColor = isSaved
        ? savedColor
        : palette.cardsSurface.withValues(alpha: 0.94);
    final foregroundColor = isSaved ? Colors.white : palette.mainText;
    final borderColor = isSaved
        ? savedColor.withValues(alpha: 0.62)
        : palette.borders.withValues(alpha: 0.72);

    return Semantics(
      button: true,
      toggled: isSaved,
      label: isSaved ? removeTooltip : saveTooltip,
      child: Tooltip(
        message: isSaved ? removeTooltip : saveTooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
                boxShadow: isSaved
                    ? [
                        BoxShadow(
                          color: savedColor.withValues(alpha: 0.24),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 140),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  key: ValueKey<bool>(isSaved),
                  size: 24,
                  color: foregroundColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
