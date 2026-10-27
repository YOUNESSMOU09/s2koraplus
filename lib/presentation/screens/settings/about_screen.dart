import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/presentation/providers/fixture_providers.dart';
import 'package:marma/presentation/providers/infra_providers.dart';
import 'package:marma/presentation/screens/settings/settings_screen.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/content_width.dart';
import 'package:marma/presentation/widgets/brand_mark.dart';
import 'package:marma/presentation/widgets/worth_watching_info_sheet.dart';

final FutureProvider<PackageInfo> packageInfoProvider =
    FutureProvider<PackageInfo>((Ref ref) => PackageInfo.fromPlatform());

final FutureProviderFamily<int, int> cacheSizeProvider =
    FutureProvider.family<int, int>(
        (Ref ref, int nonce) => ref.read(fixtureRepositoryProvider).cacheSizeBytes());

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  int _nonce = 0;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final AsyncValue<PackageInfo> info = ref.watch(packageInfoProvider);
    final AsyncValue<Health> health = ref.watch(healthProvider(_nonce));
    final AsyncValue<int> cacheBytes = ref.watch(cacheSizeProvider(_nonce));

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: Text(context.l10n.screenAbout)),
      body: ContentWidth(
          child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.giant),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: Column(
              children: <Widget>[
                const BrandMark(size: 84),
                const SizedBox(height: AppSpacing.lg),
                Text(context.l10n.appName,
                    style: context.type.titleLarge.copyWith(color: colors.textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  info.maybeWhen(
                    data: (PackageInfo p) =>
                        context.l10n.aboutVersion(p.version, p.buildNumber),
                    orElse: () => '',
                  ),
                  style: context.type.monoSmall.copyWith(color: colors.textTertiary),
                ),
              ],
            ),
          ),
          _Paragraph(text: context.l10n.aboutPrivacyPosture),
          // A stable, citable location for the "Worth watching" explanation:
          // Settings -> About -> How "Worth watching" is ordered. The App
          // Review notes name this exact path, so it must not move.
          SettingsGroup(
            children: <Widget>[
              SettingsTile(
                icon: MarmaIcons.info,
                title: context.l10n.worthHowAction,
                onTap: () => showWorthWatchingInfoSheet(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _Paragraph(text: context.l10n.aboutAttribution, emphasis: true),
          _Paragraph(text: context.l10n.aboutDisclaimer),
          SettingsSectionHeader(text: context.l10n.aboutBackendStatus),
          SettingsGroup(
            children: <Widget>[
              SettingsTile(
                icon: MarmaIcons.health,
                title: health.when(
                  data: (Health h) => h.isHealthy
                      ? context.l10n.aboutBackendHealthy
                      : context.l10n.aboutBackendUnhealthy,
                  error: (_, _) => context.l10n.aboutBackendUnhealthy,
                  loading: () => context.l10n.aboutBackendChecking,
                ),
                value: health.maybeWhen(
                  data: (Health h) => h.lastUpdated == null
                      ? null
                      : context.l10n.aboutBackendUpdated(
                          DateTime.now().difference(h.lastUpdated!).inMinutes.abs()),
                  orElse: () => null,
                ),
                trailing: const SizedBox.shrink(),
                onTap: () => setState(() => _nonce++),
              ),
              SettingsTile(
                icon: MarmaIcons.clearCache,
                title: context.l10n.aboutClearCache,
                value: cacheBytes.maybeWhen(
                  data: (int bytes) =>
                      context.l10n.aboutClearCacheSubtitle((bytes / 1024).round()),
                  orElse: () => null,
                ),
                onTap: () async {
                  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
                  final String message = context.l10n.aboutCacheCleared;
                  await ref.read(fixtureRepositoryProvider).clearCache();
                  if (!mounted) return;
                  setState(() => _nonce++);
                  messenger.showSnackBar(SnackBar(content: Text(message)));
                },
              ),
            ],
          ),
        ],
      )),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.text, this.emphasis = false});

  final String text;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
      child: Text(
        text,
        style: context.type.bodyMedium.copyWith(
          color: emphasis ? colors.textSecondary : colors.textTertiary,
        ),
      ),
    );
  }
}
