/// What the splash is currently waiting on, in the order the user sees it.
enum SplashStep { config, matches, ready }

/// The splash gate's decision, as a pure value: no timers, no Flutter.
///
/// The gate lifts once the remote config has booted (non-negotiable — the ad
/// globals are `late` until then), the brand has been on screen for the
/// minimum hold, and today's matches are ready to paint. The data wait is
/// bounded: past [maxHoldElapsed] the app opens anyway and the screen behind
/// shows its own loading state.
class SplashReadiness {
  const SplashReadiness({
    this.booted = false,
    this.dataReady = false,
    this.minHoldElapsed = false,
    this.maxHoldElapsed = false,
  });

  final bool booted;
  final bool dataReady;
  final bool minHoldElapsed;
  final bool maxHoldElapsed;

  bool get canLift => booted && minHoldElapsed && (dataReady || maxHoldElapsed);

  SplashStep get step => !booted
      ? SplashStep.config
      : (dataReady || maxHoldElapsed ? SplashStep.ready : SplashStep.matches);

  /// 0…1 for the progress bar: config is the first half, data the second.
  double get progress => switch (step) {
        SplashStep.config => 0.25,
        SplashStep.matches => 0.65,
        SplashStep.ready => 1.0,
      };

  SplashReadiness copyWith({
    bool? booted,
    bool? dataReady,
    bool? minHoldElapsed,
    bool? maxHoldElapsed,
  }) =>
      SplashReadiness(
        booted: booted ?? this.booted,
        dataReady: dataReady ?? this.dataReady,
        minHoldElapsed: minHoldElapsed ?? this.minHoldElapsed,
        maxHoldElapsed: maxHoldElapsed ?? this.maxHoldElapsed,
      );
}
