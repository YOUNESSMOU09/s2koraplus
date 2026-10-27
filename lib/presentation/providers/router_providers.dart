import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the in-app splash gate has lifted. A plain bool, flipped once.
class SplashGate extends Notifier<bool> {
  @override
  bool build() => false;

  void complete() {
    if (!state) state = true;
  }
}

final NotifierProvider<SplashGate, bool> splashGateProvider =
    NotifierProvider<SplashGate, bool>(SplashGate.new);
