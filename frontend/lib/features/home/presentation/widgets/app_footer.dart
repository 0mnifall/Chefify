import 'package:flutter/material.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/localization/app_strings.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final strings = AppStrings.of(context);
    final settings = AppSettingsScope.of(context);
    final currentThemeMode = settings.themeMode;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.navbarBackground,
        border: Border(
          top: BorderSide(color: palette.borders.withValues(alpha: 0.46)),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding(context),
        vertical: AppSpacing.xxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.contentMaxWidth,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = !AppSpacing.useDesktopNavigationForContent(
                constraints.maxWidth,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!compact)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _FooterBrandAndLinks(strings: strings)),
                        const SizedBox(width: AppSpacing.xl),
                        SizedBox(
                          width: 360,
                          child: _FooterControls(
                            strings: strings,
                            settings: settings,
                            currentThemeMode: currentThemeMode,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _FooterBrandAndLinks(strings: strings),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: _FooterControls(
                        strings: strings,
                        settings: settings,
                        currentThemeMode: currentThemeMode,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    strings.copyright(DateTime.now().year),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.secondaryText,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FooterBrandAndLinks extends StatelessWidget {
  const _FooterBrandAndLinks({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: palette.primaryButtons,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.soup_kitchen_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Chefify',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: palette.mainText),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.sm,
          children: [
            _FooterLink(label: strings.recipes),
            _FooterLink(label: strings.mealPlans),
            _FooterLink(label: strings.pricing),
            _FooterLink(label: strings.blog),
            _FooterLink(label: strings.support),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          strings.followUs,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: const [
            _SocialButton(icon: Icons.camera_alt_outlined, label: 'Instagram'),
            _SocialButton(
              icon: Icons.play_circle_outline_rounded,
              label: 'YouTube',
            ),
            _SocialButton(icon: Icons.music_note_rounded, label: 'TikTok'),
            _SocialButton(
              icon: Icons.alternate_email_rounded,
              label: 'X / Twitter',
            ),
          ],
        ),
      ],
    );
  }
}

class _FooterControls extends StatelessWidget {
  const _FooterControls({
    required this.strings,
    required this.settings,
    required this.currentThemeMode,
  });

  final AppStrings strings;
  final AppSettingsController settings;
  final ThemeMode currentThemeMode;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.languageLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<AppLanguage>(
          initialValue: settings.language,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            filled: true,
            fillColor: palette.searchBarBackground.withValues(alpha: 0.62),
          ),
          items: [
            for (final language in AppLanguage.values)
              DropdownMenuItem(value: language, child: Text(language.label)),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }
            settings.setLanguage(value);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(strings.themeLabel, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        SegmentedButton<ThemeMode>(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return palette.primaryButtons.withValues(alpha: 0.18);
              }
              return palette.searchBarBackground.withValues(alpha: 0.42);
            }),
            foregroundColor: WidgetStateProperty.all(palette.mainText),
            side: WidgetStateProperty.all(
              BorderSide(color: palette.borders.withValues(alpha: 0.72)),
            ),
          ),
          segments: [
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text(strings.lightTheme, overflow: TextOverflow.ellipsis),
              icon: const Icon(Icons.light_mode_rounded, size: 18),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              label: Text(strings.darkTheme, overflow: TextOverflow.ellipsis),
              icon: const Icon(Icons.dark_mode_rounded, size: 18),
            ),
          ],
          selected: {currentThemeMode},
          onSelectionChanged: (selected) {
            if (selected.isEmpty) {
              return;
            }
            settings.setThemeMode(selected.first);
          },
          showSelectedIcon: false,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: palette.searchBarBackground.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.borders.withValues(alpha: 0.6)),
          ),
          child: Icon(icon, size: 18, color: palette.mainText),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: palette.secondaryText),
    );
  }
}
