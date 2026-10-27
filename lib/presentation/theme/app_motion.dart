import 'package:flutter/material.dart';
import 'package:marma/app/app_env.dart';

/// The single motion guard used by every animated widget.
///
/// Infinite animations (`onPlay: (c) => c.repeat()`) are the specific hazard:
/// under a headless widget test they leave a controller pending and the suite
/// times out with "A Timer is still pending". `AppEnv.isTest` closes that.
class AppMotion {
  const AppMotion._();

  static bool enabled(BuildContext context) =>
      !AppEnv.isTest && !MediaQuery.of(context).disableAnimations;

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration quick = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 280);
  static const Duration pulse = Duration(milliseconds: 1400);
  static const Duration bloom = Duration(milliseconds: 900);
  static const Duration stagger = Duration(milliseconds: 30);

  static const Curve emphasis = Curves.easeOutCubic;
  static const Curve gentle = Curves.easeInOut;
}
