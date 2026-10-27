import 'package:flutter/widgets.dart';

/// The whole app is laid out on this scale. Nothing outside it.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 48;

  /// Screen gutter.
  static const double gutter = 16;

  /// Horizontal inset of a grouped competition block.
  static const double blockInset = 12;
}

class AppRadius {
  const AppRadius._();

  static const double chip = 999;
  static const double badge = 8;
  static const double card = 16;
  static const double block = 16;
  static const double sheet = 24;
  static const double cta = 14;
  static const double input = 12;

  static const BorderRadius blockRadius = BorderRadius.all(Radius.circular(block));
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(chip));
  static const BorderRadius badgeRadius = BorderRadius.all(Radius.circular(badge));
  static const BorderRadius ctaRadius = BorderRadius.all(Radius.circular(cta));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(input));
}
