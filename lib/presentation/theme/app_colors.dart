import 'package:flutter/material.dart';
import 'package:marma/presentation/theme/app_spacing.dart';

/// "Pitch" palette — a bright, modern sports scoreboard.
///
/// Light is the hero theme: white cards on a cool grey canvas, one strong
/// blue accent and a red live signal. Dark is deep navy with the same roles.
/// Text colours were chosen to pass WCAG AA against their backgrounds.
@immutable
class MarmaColors extends ThemeExtension<MarmaColors> {
  const MarmaColors({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.surfaceHigh,
    required this.surfaceHighest,
    required this.outline,
    required this.outlineStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.onAccent,
    required this.accentFill,
    required this.ctaFill,
    required this.onCta,
    required this.live,
    required this.liveSurface,
    required this.danger,
    required this.warning,
    required this.warningSurface,
    required this.scrim,
    required this.heroStart,
    required this.heroEnd,
  });

  final Brightness brightness;
  final Color bg;
  final Color surface;
  final Color surfaceHigh;
  final Color surfaceHighest;
  final Color outline;
  final Color outlineStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Accent used for text/icons. In light mode this is the deep amber that
  /// actually passes AA on paper — bright amber never carries small body text.
  final Color accent;
  final Color onAccent;

  /// Small amber fills (badges) — pair with [onAccent].
  final Color accentFill;
  final Color ctaFill;
  final Color onCta;
  final Color live;
  final Color liveSurface;
  final Color danger;
  final Color warning;
  final Color warningSurface;
  final Color scrim;

  /// Match-detail header gradient.
  final Color heroStart;
  final Color heroEnd;

  bool get isDark => brightness == Brightness.dark;

  /// The one card look: white fill, soft shadow in light, hairline in dark.
  BoxDecoration card({
    BorderRadius borderRadius = AppRadius.blockRadius,
    double hairline = 1,
  }) =>
      BoxDecoration(
        color: surfaceHigh,
        borderRadius: borderRadius,
        border: isDark ? Border.all(color: outline, width: hairline) : null,
        boxShadow: cardShadow,
      );

  static const MarmaColors dark = MarmaColors(
    brightness: Brightness.dark,
    bg: Color(0xFF0B1220),
    surface: Color(0xFF121A2B),
    surfaceHigh: Color(0xFF162036),
    surfaceHighest: Color(0xFF1F2A42),
    outline: Color(0xFF26314A),
    outlineStrong: Color(0xFF56627A),
    textPrimary: Color(0xFFF2F5FA),
    textSecondary: Color(0xFFA3ADBF),
    textTertiary: Color(0xFF8A94A8),
    accent: Color(0xFF6E9BFF),
    onAccent: Color(0xFF0B1220),
    accentFill: Color(0xFF6E9BFF),
    ctaFill: Color(0xFF6E9BFF),
    onCta: Color(0xFF0B1220),
    live: Color(0xFFFF5A61),
    liveSurface: Color(0xFF3A1822),
    danger: Color(0xFFFF7A6B),
    warning: Color(0xFFFFB547),
    warningSurface: Color(0xFF2E2414),
    scrim: Color(0x99000000),
    heroStart: Color(0xFF1B3A8C),
    heroEnd: Color(0xFF121A2B),
  );

  static const MarmaColors light = MarmaColors(
    brightness: Brightness.light,
    bg: Color(0xFFF1F4F9),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFFFFFFF),
    surfaceHighest: Color(0xFFE9EEF5),
    outline: Color(0xFFE3E8F0),
    outlineStrong: Color(0xFF98A2B3),
    textPrimary: Color(0xFF0B1424),
    textSecondary: Color(0xFF566173),
    textTertiary: Color(0xFF737E91),
    accent: Color(0xFF1A5CFF),
    onAccent: Color(0xFFFFFFFF),
    accentFill: Color(0xFF1A5CFF),
    ctaFill: Color(0xFF1A5CFF),
    onCta: Color(0xFFFFFFFF),
    live: Color(0xFFD92B32),
    liveSurface: Color(0xFFFDECEC),
    danger: Color(0xFFB42318),
    warning: Color(0xFFB54708),
    warningSurface: Color(0xFFFEF4E6),
    scrim: Color(0x660B1424),
    heroStart: Color(0xFF1A5CFF),
    heroEnd: Color(0xFF0A3BC2),
  );

  /// Positive confirmation (saved, complete, exact prediction) — kept apart
  /// from [live], which is red in this palette.
  Color get success => isDark ? const Color(0xFF3DD68C) : const Color(0xFF0E8A4F);

  /// Text and icons drawn on the [heroStart] -> [heroEnd] gradient.
  Color get onHero => const Color(0xFFFFFFFF);

  /// Soft lift under every card. Light mode leans on the shadow; dark mode
  /// cannot see a shadow, so it keeps the hairline border instead.
  List<BoxShadow> get cardShadow => isDark
      ? const <BoxShadow>[]
      : const <BoxShadow>[
          BoxShadow(color: Color(0x0F0B1424), blurRadius: 12, offset: Offset(0, 3)),
          BoxShadow(color: Color(0x0A0B1424), blurRadius: 2, offset: Offset(0, 1)),
        ];

  /// Increase-Contrast variants (§8.1).
  MarmaColors highContrast() => isDark
      ? copyWith(
          textSecondary: const Color(0xFFC9D1DF),
          outline: const Color(0xFF3A4762),
        )
      : copyWith(
          textSecondary: const Color(0xFF353E4D),
          outline: const Color(0xFFB8C1CF),
        );

  /// The single accessor used by every widget.
  static MarmaColors of(BuildContext context) =>
      Theme.of(context).extension<MarmaColors>() ?? dark;

  @override
  MarmaColors copyWith({
    Brightness? brightness,
    Color? bg,
    Color? surface,
    Color? surfaceHigh,
    Color? surfaceHighest,
    Color? outline,
    Color? outlineStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? onAccent,
    Color? accentFill,
    Color? ctaFill,
    Color? onCta,
    Color? live,
    Color? liveSurface,
    Color? danger,
    Color? warning,
    Color? warningSurface,
    Color? scrim,
    Color? heroStart,
    Color? heroEnd,
  }) =>
      MarmaColors(
        brightness: brightness ?? this.brightness,
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        surfaceHigh: surfaceHigh ?? this.surfaceHigh,
        surfaceHighest: surfaceHighest ?? this.surfaceHighest,
        outline: outline ?? this.outline,
        outlineStrong: outlineStrong ?? this.outlineStrong,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textTertiary: textTertiary ?? this.textTertiary,
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
        accentFill: accentFill ?? this.accentFill,
        ctaFill: ctaFill ?? this.ctaFill,
        onCta: onCta ?? this.onCta,
        live: live ?? this.live,
        liveSurface: liveSurface ?? this.liveSurface,
        danger: danger ?? this.danger,
        warning: warning ?? this.warning,
        warningSurface: warningSurface ?? this.warningSurface,
        scrim: scrim ?? this.scrim,
        heroStart: heroStart ?? this.heroStart,
        heroEnd: heroEnd ?? this.heroEnd,
      );

  @override
  MarmaColors lerp(ThemeExtension<MarmaColors>? other, double t) {
    if (other is! MarmaColors) return this;
    return MarmaColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      surfaceHighest: Color.lerp(surfaceHighest, other.surfaceHighest, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineStrong: Color.lerp(outlineStrong, other.outlineStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentFill: Color.lerp(accentFill, other.accentFill, t)!,
      ctaFill: Color.lerp(ctaFill, other.ctaFill, t)!,
      onCta: Color.lerp(onCta, other.onCta, t)!,
      live: Color.lerp(live, other.live, t)!,
      liveSurface: Color.lerp(liveSurface, other.liveSurface, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
    );
  }
}

/// 12 deterministic team hues (dark hue, light hue). Indexed by a hash of
/// `team.id`, so a team's colour is identical on every device and session.
class BadgePalette {
  const BadgePalette._();

  static const List<Color> darkHues = <Color>[
    Color(0xFF7FB3FF), Color(0xFFFF9E7A), Color(0xFF8FE08A), Color(0xFFFFD166),
    Color(0xFF9BC7A0), Color(0xFFC7B3FF), Color(0xFF6FD3C7), Color(0xFFE6A0FF),
    Color(0xFFFFB3C7), Color(0xFF9EA8FF), Color(0xFFFFC6A0), Color(0xFF8CCBE6),
  ];

  static const List<Color> lightHues = <Color>[
    Color(0xFF1D5FBF), Color(0xFFB24A21), Color(0xFF2C7A2C), Color(0xFF8A5A0A),
    Color(0xFF3A6B4A), Color(0xFF5B3FBF), Color(0xFF0F7268), Color(0xFF7B2FA6),
    Color(0xFFB02A50), Color(0xFF3C46B8), Color(0xFF8A5220), Color(0xFF15607E),
  ];

  static int get length => darkHues.length;

  static Color hue(int index, Brightness brightness) {
    final List<Color> hues =
        brightness == Brightness.dark ? darkHues : lightHues;
    return hues[index % hues.length];
  }
}
