import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/presentation/providers/ad_providers.dart';
import 'package:marma/service/ad_policy.dart';
import 'package:marma/service/interstitial_gate.dart';

/// Opening a match from a card, with whatever ad that card is configured to
/// carry.
///
/// One function, so the two ad shapes can never diverge across the four
/// surfaces that show a match card.
///
/// NAVIGATION ALWAYS HAPPENS. The push is issued before the ad is asked for, so
/// the card still works when the SDK has nothing loaded, when the config never
/// landed, and offline — a tap that silently does nothing is a broken app, not
/// a monetised one.
void openMatchFromCard(
  BuildContext context,
  WidgetRef ref,
  Fixture fixture, {
  required bool rewarded,
}) {
  context.push('/match/${fixture.id}', extra: fixture);

  if (rewarded && RewardedGate.isAvailable && AdPolicy.shouldShowInterstitial()) {
    // A rewarded ad has to pay: the same ad-free window the Settings offer
    // grants. Without a reward this is just an interstitial wearing a rewarded
    // ad's format, which is the specific thing AdMob suspends accounts for.
    RewardedGate.show(
      onRewarded: () => ref.read(adFreeProvider.notifier).grant(),
    );
    return;
  }

  InterstitialGate.onAction('match_open');
}
