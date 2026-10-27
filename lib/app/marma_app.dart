import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/app/router.dart';
import 'package:marma/l10n/app_localizations.dart';
import 'package:marma/presentation/providers/settings_providers.dart';
import 'package:marma/presentation/theme/app_theme.dart';

class MarmaApp extends ConsumerWidget {
  const MarmaApp({super.key});

  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ar')];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final Locale? locale = ref.watch(localeProvider);

    // The theme's typography depends on the resolved locale (Sora has no Arabic
    // glyphs), so resolve it once here rather than per widget.
    final Locale effective = locale ??
        _resolve(WidgetsBinding.instance.platformDispatcher.locales);

    return MaterialApp.router(
      title: 'Marma',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      themeMode: themeMode,
      theme: AppTheme.build(brightness: Brightness.light, locale: effective),
      darkTheme: AppTheme.build(brightness: Brightness.dark, locale: effective),
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (BuildContext context, Widget? child) {
        // Dynamic Type up to 1.6x — every row height in the app is a minimum,
        // never a fixed height.
        return MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.6,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  static Locale _resolve(List<Locale> device) {
    for (final Locale locale in device) {
      for (final Locale supported in supportedLocales) {
        if (supported.languageCode == locale.languageCode) return supported;
      }
    }
    return const Locale('en');
  }
}
