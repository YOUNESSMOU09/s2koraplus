import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/presentation/providers/infra_providers.dart';
import 'package:marma/service/ad_policy.dart';
import 'package:marma/service/interstitial_gate.dart';

/// The ad-free window bought by a rewarded view.
///
/// Two sources of truth would be one too many, so this notifier owns the value
/// and pushes it into [AdPolicy] — the gate is a plain static because it is
/// called from widget callbacks that have no `ref`.
class AdFreeNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() {
    final DateTime? until = ref.watch(prefsStoreProvider).readAdFreeUntil();
    AdPolicy.adFreeUntil = until;
    return until;
  }

  /// Grants the window. Called from the rewarded ad's own reward callback, so
  /// it cannot run unless the user actually watched.
  Future<void> grant([Duration duration = AdPolicy.adFreeReward]) async {
    // Extends rather than replaces: watching a second ad while a window is
    // running must not shorten it.
    final DateTime base = AdPolicy.isAdFree ? state! : DateTime.now();
    final DateTime until = base.add(duration);
    state = until;
    AdPolicy.adFreeUntil = until;
    await ref.read(prefsStoreProvider).writeAdFreeUntil(until);
  }

  /// Drops an expired window so the UI stops offering to show its countdown.
  Future<void> clearIfExpired() async {
    if (state == null || AdPolicy.isAdFree) return;
    state = null;
    AdPolicy.adFreeUntil = null;
    await ref.read(prefsStoreProvider).writeAdFreeUntil(null);
  }
}

final NotifierProvider<AdFreeNotifier, DateTime?> adFreeProvider =
    NotifierProvider<AdFreeNotifier, DateTime?>(AdFreeNotifier.new);

/// Whether a rewarded ad can be offered right now.
final Provider<bool> rewardedAvailableProvider =
    Provider<bool>((Ref ref) => RewardedGate.isAvailable);
