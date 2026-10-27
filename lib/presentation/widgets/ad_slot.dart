import 'package:flutter/widgets.dart';

/// The single reserved advertising position (§14.4).
///
/// v1 renders nothing. Step 6 may fill exactly this one slot — pinned below the
/// `/matches` list — and nowhere else: not on `/live`, not on `/match/:id`, not
/// on `/following`, and never as an interstitial. Gambling, alcohol and dating
/// categories must be excluded when it is wired.
class AdSlot extends StatelessWidget {
  const AdSlot({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
