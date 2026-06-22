import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';

enum AppButtonVariant { filled, outlined, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
        onPressed: onPressed,
        style: _filledStyle(context),
        child: _content(),
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: onPressed,
        style: _outlinedStyle(context),
        child: _content(),
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: onPressed,
        style: _ghostStyle(context),
        child: _content(),
      ),
    };

    if (!isExpanded) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }

  Widget _content() {
    final text = Text(label, overflow: TextOverflow.ellipsis, softWrap: false);
    if (icon == null) {
      return text;
    }

    return Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: AppSpacing.xs),
        Flexible(child: text),
      ],
    );
  }

  ButtonStyle _filledStyle(BuildContext context) {
    final palette = context.palette;
    return FilledButton.styleFrom(
      backgroundColor: palette.primaryButtons,
      foregroundColor: Colors.white,
      disabledBackgroundColor: palette.primaryButtons.withValues(alpha: 0.35),
      overlayColor: palette.buttonHover.withValues(alpha: 0.22),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );
  }

  ButtonStyle _outlinedStyle(BuildContext context) {
    final palette = context.palette;
    return OutlinedButton.styleFrom(
      foregroundColor: palette.mainText,
      side: BorderSide(color: palette.borders),
      overlayColor: palette.buttonHover.withValues(alpha: 0.16),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );
  }

  ButtonStyle _ghostStyle(BuildContext context) {
    final palette = context.palette;
    return TextButton.styleFrom(
      foregroundColor: palette.mainText,
      overlayColor: palette.buttonHover.withValues(alpha: 0.16),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );
  }
}
