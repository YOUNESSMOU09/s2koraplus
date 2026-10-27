import 'package:flutter/material.dart';
import 'package:marma/l10n/app_localizations.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_typography.dart';

/// Terse accessors used by every widget: `context.l10n`, `context.colors`,
/// `context.type`.
extension MarmaContextX on BuildContext {
  AppL10n get l10n => AppL10n.of(this);
  MarmaColors get colors => MarmaColors.of(this);
  AppTypography get type => AppTypography.of(this);

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
  String get languageCode => Localizations.localeOf(this).languageCode;

  /// Hairline width — exactly one physical pixel.
  double get hairline => 1 / MediaQuery.devicePixelRatioOf(this);
}
