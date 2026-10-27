import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/presentation/providers/settings_providers.dart';
import 'package:marma/presentation/screens/settings/settings_screen.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/content_width.dart';

class _ChoiceTile<T> extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelected,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final T value;
  final T groupValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final bool selected = value == groupValue;
    return ListTile(
      minTileHeight: 52,
      title: Text(label, style: context.type.bodyLarge.copyWith(color: colors.textPrimary)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: context.type.label.copyWith(color: colors.textTertiary)),
      trailing: selected
          ? Icon(MarmaIcons.check, size: 18, color: colors.accent)
          : null,
      selected: selected,
      onTap: () => onSelected(value),
    );
  }
}

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeChoice current =
        ref.watch(settingsProvider.select((AppSettings s) => s.theme));
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(title: Text(context.l10n.screenAppearance)),
      // Reached from the (clamped) Settings list; without the same clamp the
      // hierarchy would jump from a 700 pt column to a 1024 pt one mid-flow.
      body: ContentWidth(
          child: ListView(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        children: <Widget>[
          SettingsGroup(
            children: <Widget>[
              for (final AppThemeChoice choice in AppThemeChoice.values)
                _ChoiceTile<AppThemeChoice>(
                  label: switch (choice) {
                    AppThemeChoice.system => context.l10n.themeSystem,
                    AppThemeChoice.light => context.l10n.themeLight,
                    AppThemeChoice.dark => context.l10n.themeDark,
                  },
                  value: choice,
                  groupValue: current,
                  onSelected: (AppThemeChoice v) =>
                      ref.read(settingsProvider.notifier).setTheme(v),
                ),
            ],
          ),
        ],
      )),
    );
  }
}

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocaleChoice current =
        ref.watch(settingsProvider.select((AppSettings s) => s.locale));
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(title: Text(context.l10n.screenLanguage)),
      body: ContentWidth(
          child: ListView(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        children: <Widget>[
          SettingsGroup(
            children: <Widget>[
              for (final AppLocaleChoice choice in AppLocaleChoice.values)
                _ChoiceTile<AppLocaleChoice>(
                  label: switch (choice) {
                    AppLocaleChoice.system => context.l10n.languageSystem,
                    AppLocaleChoice.en => context.l10n.languageEnglish,
                    AppLocaleChoice.ar => context.l10n.languageArabic,
                  },
                  value: choice,
                  groupValue: current,
                  onSelected: (AppLocaleChoice v) =>
                      ref.read(settingsProvider.notifier).setLocale(v),
                ),
            ],
          ),
        ],
      )),
    );
  }
}
