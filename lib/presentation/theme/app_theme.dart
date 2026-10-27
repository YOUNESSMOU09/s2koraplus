import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/app_typography.dart';

/// Builds the two themes from explicit tokens.
///
/// `ColorScheme` is written out field by field rather than seeded, so the exact
/// Pitch hex values survive into every Material component.
class AppTheme {
  const AppTheme._();

  static ThemeData build({
    required Brightness brightness,
    required Locale locale,
    bool highContrast = false,
  }) {
    MarmaColors c =
        brightness == Brightness.dark ? MarmaColors.dark : MarmaColors.light;
    if (highContrast) c = c.highContrast();
    final AppTypography type = AppTypography.forLocale(locale);
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? c.accent : c.ctaFill,
      onPrimary: isDark ? c.onAccent : c.onCta,
      secondary: c.live,
      onSecondary: c.bg,
      error: c.danger,
      onError: isDark ? c.bg : Colors.white,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerLowest: c.bg,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surfaceHigh,
      surfaceContainerHigh: c.surfaceHigh,
      surfaceContainerHighest: c.surfaceHighest,
      onSurfaceVariant: c.textSecondary,
      outline: c.outlineStrong,
      outlineVariant: c.outline,
      scrim: c.scrim,
      inverseSurface: c.textPrimary,
      onInverseSurface: c.bg,
      shadow: Colors.black,
    );

    final TextTheme textTheme = TextTheme(
      displayLarge: type.titleLarge,
      displayMedium: type.titleLarge,
      displaySmall: type.titleMedium,
      headlineLarge: type.titleLarge,
      headlineMedium: type.titleLarge,
      headlineSmall: type.titleMedium,
      titleLarge: type.titleLarge,
      titleMedium: type.titleMedium,
      titleSmall: type.sectionHeader,
      bodyLarge: type.bodyLarge,
      bodyMedium: type.bodyMedium,
      bodySmall: type.label,
      labelLarge: type.label,
      labelMedium: type.label,
      labelSmall: type.monoSmall,
    ).apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      // Depth comes from surface steps and 1 px hairlines — never shadows.
      shadowColor: Colors.transparent,
      dividerTheme: DividerThemeData(color: c.outline, space: 1, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: type.titleLarge.copyWith(color: c.textPrimary),
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        titleTextStyle: type.titleMedium.copyWith(color: c.textPrimary),
        contentTextStyle: type.bodyMedium.copyWith(color: c.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.blockRadius),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        textColor: c.textPrimary,
        titleTextStyle: type.bodyLarge.copyWith(color: c.textPrimary),
        subtitleTextStyle: type.bodyMedium.copyWith(color: c.textSecondary),
        minVerticalPadding: AppSpacing.md,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceHighest,
        hintStyle: type.bodyMedium.copyWith(color: c.textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: c.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: c.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: c.accent, width: 2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) =>
            s.contains(WidgetState.selected) ? c.onAccent : c.textSecondary),
        trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) =>
            s.contains(WidgetState.selected) ? c.accent : c.surfaceHighest),
        trackOutlineColor: WidgetStateProperty.all(c.outlineStrong),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) =>
            s.contains(WidgetState.selected) ? c.accent : c.outlineStrong),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) =>
            s.contains(WidgetState.selected) ? c.accent : Colors.transparent),
        checkColor: WidgetStateProperty.all(c.onAccent),
        side: BorderSide(color: c.outlineStrong, width: 1.5),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.surfaceHighest,
        circularTrackColor: c.surfaceHighest,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceHighest,
        contentTextStyle: type.bodyMedium.copyWith(color: c.textPrimary),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: type.label,
          minimumSize: const Size(48, 48),
        ),
      ),
      iconTheme: IconThemeData(color: c.textSecondary, size: 20),
      extensions: <ThemeExtension<dynamic>>[c, type],
    );
  }
}
