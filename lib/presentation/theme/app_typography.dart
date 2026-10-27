import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sora × IBM Plex. Three faces, each with exactly one job.
///
/// All three are BUNDLED as `.ttf` under `assets/google_fonts/` and
/// `GoogleFonts.config.allowRuntimeFetching` is `false`, so the app never makes
/// a network request for a font (offline-first, and no runtime licence or
/// privacy surface).
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.displayScore,
    required this.scoreLarge,
    required this.rowScore,
    required this.mono,
    required this.monoSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.sectionHeader,
    required this.teamName,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.label,
  });

  /// Match-detail scoreline.
  final TextStyle displayScore;

  /// Detail secondary lines (FT / PEN).
  final TextStyle scoreLarge;

  /// List-row score.
  final TextStyle rowScore;

  /// Live badge, kickoff time, event minutes.
  final TextStyle mono;

  /// Tab count badge, freshness chip.
  final TextStyle monoSmall;

  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle sectionHeader;
  final TextStyle teamName;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle label;

  static const List<FontFeature> _tabular = <FontFeature>[FontFeature.tabularFigures()];

  /// Every aligning numeral uses IBM Plex Mono, which is monospaced by
  /// construction — relying on `tabularFigures()` against a proportional face
  /// silently no-ops when the face lacks `tnum`, and scores then jitter on
  /// every poll.
  static TextStyle _mono(double size, FontWeight weight, double height, double tracking) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: tracking,
        fontFeatures: _tabular,
      );

  /// Sora has no Arabic glyphs, so display styles fall back to IBM Plex Sans
  /// Arabic in `ar` — implemented once, here, never per widget.
  static AppTypography forLocale(Locale locale) {
    final bool isArabic = locale.languageCode == 'ar';

    TextStyle display(double size, FontWeight weight, double height, double tracking) {
      if (isArabic) {
        return GoogleFonts.ibmPlexSansArabic(
          fontSize: size,
          fontWeight: weight == FontWeight.w700 ? FontWeight.w700 : FontWeight.w600,
          height: height + 0.1,
          letterSpacing: 0,
        );
      }
      return GoogleFonts.sora(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: tracking,
      );
    }

    TextStyle body(double size, FontWeight weight, double height, double tracking) =>
        GoogleFonts.ibmPlexSansArabic(
          fontSize: size,
          fontWeight: weight,
          height: height + (isArabic ? 0.1 : 0),
          letterSpacing: tracking,
          fontFeatures: _tabular,
        );

    return AppTypography(
      displayScore: _mono(44, FontWeight.w600, 1.00, -0.5),
      scoreLarge: _mono(22, FontWeight.w600, 1.05, -0.2),
      rowScore: _mono(19, FontWeight.w600, 1.10, 0),
      mono: _mono(12, FontWeight.w600, 1.00, 0.2),
      monoSmall: _mono(10, FontWeight.w600, 1.00, 0.4),
      titleLarge: display(22, FontWeight.w700, 1.20, -0.2),
      titleMedium: display(17, FontWeight.w600, 1.25, -0.1),
      sectionHeader: display(13, FontWeight.w600, 1.20, 0.3),
      teamName: body(15, FontWeight.w500, 1.20, 0),
      bodyLarge: body(16, FontWeight.w400, 1.45, 0),
      bodyMedium: body(14, FontWeight.w400, 1.45, 0),
      label: body(12, FontWeight.w500, 1.30, 0.1),
    );
  }

  static AppTypography of(BuildContext context) =>
      Theme.of(context).extension<AppTypography>() ?? forLocale(const Locale('en'));

  @override
  AppTypography copyWith({
    TextStyle? displayScore,
    TextStyle? scoreLarge,
    TextStyle? rowScore,
    TextStyle? mono,
    TextStyle? monoSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? sectionHeader,
    TextStyle? teamName,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? label,
  }) =>
      AppTypography(
        displayScore: displayScore ?? this.displayScore,
        scoreLarge: scoreLarge ?? this.scoreLarge,
        rowScore: rowScore ?? this.rowScore,
        mono: mono ?? this.mono,
        monoSmall: monoSmall ?? this.monoSmall,
        titleLarge: titleLarge ?? this.titleLarge,
        titleMedium: titleMedium ?? this.titleMedium,
        sectionHeader: sectionHeader ?? this.sectionHeader,
        teamName: teamName ?? this.teamName,
        bodyLarge: bodyLarge ?? this.bodyLarge,
        bodyMedium: bodyMedium ?? this.bodyMedium,
        label: label ?? this.label,
      );

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return t < 0.5 ? this : other;
  }
}
