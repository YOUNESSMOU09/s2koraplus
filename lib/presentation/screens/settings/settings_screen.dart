import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/app/app_env.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/presentation/providers/journal_providers.dart';
import 'package:marma/presentation/providers/settings_providers.dart';
import 'package:marma/presentation/screens/settings/about_screen.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/core/utils/app_format.dart';
import 'package:marma/presentation/providers/ad_providers.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/service/ad_policy.dart';
import 'package:marma/presentation/widgets/content_width.dart';
import 'package:marma/presentation/widgets/directional_icon.dart';
import 'package:marma/service/interstitial_gate.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings: a summary card of what you follow and have written, the theme
/// and language chosen in place (no detour through a sub-screen), then the
/// usual rows. A plain scrolling column rather than a lazy list — the page is
/// short, and every row should exist for accessibility and tests alike.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarmaColors colors = context.colors;
    final AppSettings settings = ref.watch(settingsProvider);
    final Favourites favourites = ref.watch(favouritesProvider);
    final int journals = ref.watch(allJournalsProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: Text(context.l10n.screenSettings)),
      body: ContentWidth(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.giant),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _ProfileCard(
                teams: favourites.teams.length,
                competitions: favourites.leagues.length,
                journals: journals,
              ),
              SettingsSectionHeader(text: context.l10n.settingsAppearance),
              _ThemePicker(
                selected: settings.theme,
                onSelect: (AppThemeChoice c) => ref.read(settingsProvider.notifier).setTheme(c),
              ),
              SettingsSectionHeader(text: context.l10n.settingsLanguage),
              _LanguagePicker(
                selected: settings.locale,
                onSelect: (AppLocaleChoice c) => ref.read(settingsProvider.notifier).setLocale(c),
              ),
              SettingsSectionHeader(text: context.l10n.settingsSectionYourFootball),
              SettingsGroup(
                children: <Widget>[
                  SettingsTile(
                    icon: MarmaIcons.navFollowing,
                    tint: colors.live,
                    title: context.l10n.settingsFollowing,
                    subtitle: favourites.isEmpty
                        ? null
                        : context.l10n.settingsFollowingSummary(
                            favourites.teams.length, favourites.leagues.length),
                    onTap: () => context.go('/following'),
                  ),
                  SettingsTile(
                    icon: MarmaIcons.navJournal,
                    tint: colors.accent,
                    title: context.l10n.navJournal,
                    subtitle: context.l10n.journalIndexSubtitle(journals),
                    onTap: () => context.go('/journals'),
                  ),
                ],
              ),
              const _SupportSection(),
              SettingsSectionHeader(text: context.l10n.settingsSectionLegal),
              SettingsGroup(
                children: <Widget>[
                  SettingsTile(
                    icon: MarmaIcons.privacy,
                    tint: colors.success,
                    title: context.l10n.settingsPrivacy,
                    external: true,
                    onTap: () => _open(AppEnv.privacyUrl),
                  ),
                  SettingsTile(
                    icon: MarmaIcons.terms,
                    tint: colors.textSecondary,
                    title: context.l10n.settingsTerms,
                    external: true,
                    onTap: () => _open(AppEnv.termsUrl),
                  ),
                  SettingsTile(
                    icon: MarmaIcons.support,
                    tint: colors.warning,
                    title: context.l10n.settingsSupport,
                    external: true,
                    onTap: () => _open(AppEnv.supportUrl),
                  ),
                  SettingsTile(
                    icon: MarmaIcons.info,
                    tint: colors.accent,
                    title: context.l10n.settingsAbout,
                    onTap: () {
                      InterstitialGate.onAction('settings_about');
                      context.push('/settings/about');
                    },
                  ),
                ],
              ),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Bold label above each group. Kept in its own casing: Arabic has none, and
/// the string a screen reader announces should be the one that was written.
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.sm),
        child: Text(
          text,
          style: context.type.label.copyWith(
            color: context.colors.textTertiary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
      );
}

/// A rounded card of rows separated by inset hairlines.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.blockInset),
      decoration: colors.card(hairline: context.hairline),
      clipBehavior: Clip.antiAlias,
      // The fill lives on a Material, not the DecoratedBox: a ListTile paints
      // its background and press state onto the nearest Material ancestor, and
      // a coloured box in between would swallow them.
      child: Material(
        color: colors.surfaceHigh,
        child: Column(
          children: <Widget>[
            for (int i = 0; i < children.length; i++) ...<Widget>[
              if (i > 0)
                Padding(
                  // Aligned with the row text, past the icon tile.
                  padding: const EdgeInsetsDirectional.only(start: 64),
                  child: Divider(height: 1, thickness: 1, color: colors.outline),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// One row: a tinted icon tile, a title (and optional subtitle), an optional
/// value, and a chevron — or an external-link mark for rows that leave the app.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.external = false,
    this.trailing,
    this.tint,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool external;
  final Widget? trailing;

  /// The icon tile's colour; the accent when null.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final Color c = tint ?? colors.accent;
    return ListTile(
      minTileHeight: 60,
      contentPadding: const EdgeInsetsDirectional.only(start: AppSpacing.md, end: AppSpacing.lg),
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.withValues(alpha: colors.isDark ? 0.18 : 0.11),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: c, fill: 1),
      ),
      title: Text(
        title,
        style: context.type.bodyLarge.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: context.type.label.copyWith(color: colors.textTertiary)),
      trailing: trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (value != null)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.38),
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: context.type.bodyMedium.copyWith(color: colors.textTertiary),
                  ),
                ),
              if (onTap != null) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  external ? MarmaIcons.external : DirectionalIcon.disclosure(context),
                  size: 16,
                  color: colors.textTertiary,
                ),
              ],
            ],
          ),
      onTap: onTap,
    );
  }
}

/// The gradient header: the app, its version, and three counts that double as
/// shortcuts to Following and the Journal.
class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({required this.teams, required this.competitions, required this.journals});

  final int teams;
  final int competitions;
  final int journals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarmaColors colors = context.colors;
    final String version = ref.watch(packageInfoProvider).maybeWhen(
          data: (PackageInfo p) => context.l10n.aboutVersion(p.version, p.buildNumber),
          orElse: () => '',
        );
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.blockInset, AppSpacing.sm, AppSpacing.blockInset, 0),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[colors.heroStart, colors.heroEnd],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sheet)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.heroStart.withValues(alpha: colors.isDark ? 0 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(MarmaIcons.matches, size: 32, color: colors.heroStart, fill: 1),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.l10n.appName,
                      style: context.type.titleLarge.copyWith(color: colors.onHero),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      version.isEmpty ? context.l10n.appTagline : version,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.type.label.copyWith(color: colors.onHero.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              _Stat(value: teams, label: context.l10n.labelTeams, onTap: () => context.go('/following')),
              const SizedBox(width: AppSpacing.sm),
              _Stat(
                value: competitions,
                label: context.l10n.labelCompetitions,
                onTap: () => context.go('/following'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _Stat(
                value: journals,
                label: context.l10n.journalStatJournals,
                onTap: () => context.go('/journals'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.onTap});

  final int value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Expanded(
      child: Semantics(
        button: true,
        label: '$value $label',
        excludeSemantics: true,
        child: Material(
          color: colors.onHero.withValues(alpha: 0.14),
          borderRadius: AppRadius.cardRadius,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.cardRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
              child: Column(
                children: <Widget>[
                  Text(
                    AppFormat.integer(value),
                    textDirection: TextDirection.ltr,
                    style: context.type.scoreLarge.copyWith(color: colors.onHero),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.label.copyWith(
                      color: colors.onHero.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// System / Light / Dark as three preview cards, applied on tap.
class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.selected, required this.onSelect});

  final AppThemeChoice selected;
  final ValueChanged<AppThemeChoice> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.blockInset),
      child: Row(
        children: <Widget>[
          for (final AppThemeChoice c in AppThemeChoice.values) ...<Widget>[
            if (c != AppThemeChoice.values.first) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ThemeCard(
                choice: c,
                selected: c == selected,
                onTap: () {
                  if (c == selected) return;
                  unawaited(HapticFeedback.selectionClick());
                  onSelect(c);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.choice, required this.selected, required this.onTap});

  final AppThemeChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final String label = switch (choice) {
      AppThemeChoice.system => context.l10n.themeSystem,
      AppThemeChoice.light => context.l10n.themeLight,
      AppThemeChoice.dark => context.l10n.themeDark,
    };
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.enabled(context) ? AppMotion.quick : Duration.zero,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.surfaceHigh,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: selected ? colors.accent : colors.outline,
              width: selected ? 2 : 1,
            ),
            boxShadow: colors.cardShadow,
          ),
          child: Column(
            children: <Widget>[
              AspectRatio(aspectRatio: 1.25, child: _ThemePreview(choice: choice)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (selected) ...<Widget>[
                    Icon(Icons.check_circle_rounded, size: 16, color: colors.accent),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.type.label.copyWith(
                        color: selected ? colors.accent : colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A miniature screen in that theme's real colours; System is split
/// diagonally between the two.
class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.choice});

  final AppThemeChoice choice;

  @override
  Widget build(BuildContext context) {
    Widget screen(MarmaColors c) => Container(
          color: c.bg,
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: 8,
                decoration: BoxDecoration(color: c.accentFill, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 5),
              for (int i = 0; i < 2; i++) ...<Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.surfaceHigh,
                      borderRadius: BorderRadius.circular(4),
                      border: c.isDark ? Border.all(color: c.outline, width: 0.5) : null,
                    ),
                  ),
                ),
                if (i == 0) const SizedBox(height: 4),
              ],
            ],
          ),
        );
    final Widget body = switch (choice) {
      AppThemeChoice.light => screen(MarmaColors.light),
      AppThemeChoice.dark => screen(MarmaColors.dark),
      AppThemeChoice.system => Stack(
          fit: StackFit.expand,
          children: <Widget>[
            screen(MarmaColors.light),
            ClipPath(clipper: _DiagonalClipper(), child: screen(MarmaColors.dark)),
          ],
        ),
    };
    return ClipRRect(borderRadius: BorderRadius.circular(8), child: body);
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => false;
}

/// System / English / العربية as one segmented switch.
class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.selected, required this.onSelect});

  final AppLocaleChoice selected;
  final ValueChanged<AppLocaleChoice> onSelect;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.blockInset),
      padding: const EdgeInsets.all(4),
      decoration: colors.card(borderRadius: AppRadius.chipRadius, hairline: context.hairline),
      child: Row(
        children: <Widget>[
          for (final AppLocaleChoice c in AppLocaleChoice.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: c == selected,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (c == selected) return;
                    unawaited(HapticFeedback.selectionClick());
                    onSelect(c);
                  },
                  child: AnimatedContainer(
                    duration: AppMotion.enabled(context) ? AppMotion.quick : Duration.zero,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c == selected ? colors.accentFill : Colors.transparent,
                      borderRadius: AppRadius.chipRadius,
                    ),
                    child: Text(
                      switch (c) {
                        AppLocaleChoice.system => context.l10n.languageSystem,
                        AppLocaleChoice.en => context.l10n.languageEnglish,
                        AppLocaleChoice.ar => context.l10n.languageArabic,
                      },
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.type.label.copyWith(
                        color: c == selected ? colors.onAccent : colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
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

/// The data credit at the foot of the page.
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, 0),
        child: Text(
          context.l10n.aboutAttribution,
          textAlign: TextAlign.center,
          style: context.type.label.copyWith(color: context.colors.textTertiary),
        ),
      );
}

/// The rewarded ad — the one full-screen ad in the app the user chooses to see.
///
/// It appears only when the REMOTE config allows it (`config.allowReward`), so
/// the whole feature can be switched off without shipping a build. While a
/// window is running the card becomes its countdown instead of an offer.
class _SupportSection extends ConsumerWidget {
  const _SupportSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarmaColors colors = context.colors;
    final DateTime? adFreeUntil = ref.watch(adFreeProvider);
    final bool available = ref.watch(rewardedAvailableProvider);
    final bool active = AdPolicy.isAdFree;

    if (!available && !active) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsSectionHeader(text: context.l10n.settingsSectionSupport),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.blockInset),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.warning.withValues(alpha: colors.isDark ? 0.14 : 0.08),
            borderRadius: AppRadius.blockRadius,
            border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(active ? MarmaIcons.adFree : MarmaIcons.rewardAd,
                    color: colors.warning, fill: 1),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      active
                          ? context.l10n.settingsAdFreeActive(AdPolicy.adFreeRemaining.inMinutes + 1)
                          : context.l10n.settingsRewardTitle,
                      style: context.type.titleMedium.copyWith(color: colors.textPrimary, fontSize: 15),
                    ),
                    if (!active || adFreeUntil != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        active
                            ? AppFormat.kickoffTime(adFreeUntil!.toLocal())
                            : context.l10n.settingsRewardBody(AdPolicy.adFreeReward.inMinutes),
                        style: context.type.label.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              if (!active) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: () => _watch(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.warning,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.chipRadius),
                    textStyle: context.type.label.copyWith(fontWeight: FontWeight.w700),
                  ),
                  child: Text(context.l10n.settingsRewardAction),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _watch(BuildContext context, WidgetRef ref) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String thanks = context.l10n.settingsAdFreeThanks;
    final String unavailable = context.l10n.settingsRewardUnavailable;

    if (!RewardedGate.isAvailable) {
      messenger.showSnackBar(SnackBar(content: Text(unavailable)));
      return;
    }

    RewardedGate.show(
      onRewarded: () async {
        // The SDK calls this only if the video was actually watched.
        await ref.read(adFreeProvider.notifier).grant();
        messenger.showSnackBar(SnackBar(content: Text(thanks)));
      },
    );
  }
}
