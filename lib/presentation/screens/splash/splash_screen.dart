import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/app/app_env.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/dev_log.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/domain/services/splash_readiness.dart';
import 'package:marma/presentation/providers/app_providers.dart';
import 'package:marma/presentation/providers/fixture_providers.dart';
import 'package:marma/presentation/providers/router_providers.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/service/ads_bootstrap.dart';
import 'package:marma/service/app_tracking_service.dart';

/// The in-app branded gate, shown after the native splash.
///
/// It lifts as soon as the app is genuinely ready — see [SplashReadiness]:
/// the remote config has booted, the brand has shown for
/// [AppEnv.splashMinHold], and today's matches can paint (from cache or
/// network), never waiting on data past [AppEnv.splashHold]. A returning user
/// with a warm cache is through in about a second and a half.
///
/// [AdsBootstrap] runs here because the remote config publishes the `late`
/// globals in `const.dart`: the gate must not lift until it has succeeded. If
/// it fails, the splash shows an offline state that retries by itself — on
/// reconnect, and on a backoff timer for a server that is merely down.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  SplashReadiness _ready = const SplashReadiness();
  final List<Timer> _timers = <Timer>[];
  Timer? _retryTimer;

  /// Non-null once the config fetch has failed: the gate is parked and the
  /// offline state is on screen until a retry succeeds.
  Object? _failure;
  bool _retrying = false;
  int _attempt = 0;

  /// How long the gate will wait on the ATT sheet before giving up on it.
  static const Duration _attWait = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    if (AppEnv.isTest) {
      // Headless tests never touch the network or leave a timer pending.
      _ready = const SplashReadiness(
          booted: true, dataReady: true, minHoldElapsed: true, maxHoldElapsed: true);
      scheduleMicrotask(_liftIfReady);
      return;
    }
    _warmUp();
    _timers
      ..add(Timer(AppEnv.splashMinHold, () => _update(_ready.copyWith(minHoldElapsed: true))))
      ..add(Timer(AppEnv.splashHold, () => _update(_ready.copyWith(maxHoldElapsed: true))));

    // Today's bucket is what the first screen paints; an error counts as
    // "ready" too, because that screen has its own designed error state.
    ref.listenManual<AsyncValue<DayBucket>>(
      dayBucketProvider(DayKey.today),
      (_, AsyncValue<DayBucket> next) {
        if (next.hasValue || next.hasError) _update(_ready.copyWith(dataReady: true));
      },
      fireImmediately: true,
    );

    // Back online while parked on the offline state: try again at once.
    ref.listenManual<bool>(isOnlineProvider, (bool? was, bool now) {
      if (_failure != null && now && was == false) _retry();
    });

    _boot();
  }

  /// Fetches the remote ad config, initialises the networks, then asks for
  /// tracking authorisation.
  Future<void> _boot() async {
    try {
      await AdsBootstrap.run();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _failure = error;
        _retrying = false;
      });
      _scheduleRetry();
      return;
    }

    // ATT is asked for AFTER the config lands, so the prompt is never spent on
    // a launch that then fails into the offline state. Bounded, because iOS
    // DEFERS the prompt when the app is not frontmost and a deferred request
    // never resolves — a late prompt over Matches beats a stuck splash.
    await AppTrackingService()
        .initializeTracking()
        .timeout(_attWait, onTimeout: () => devLog('att', 'no response in $_attWait'));

    if (!mounted) return;
    _update(_ready.copyWith(booted: true));
  }

  /// 4 s, 8 s, 16 s… capped at 30 s, for a server that is down while the
  /// device is online (no connectivity event will ever fire for that).
  void _scheduleRetry() {
    _retryTimer?.cancel();
    final int seconds = math.min(30, 4 * (1 << math.min(_attempt, 3)));
    _attempt++;
    _retryTimer = Timer(Duration(seconds: seconds), _retry);
  }

  void _retry() {
    if (!mounted || _retrying) return;
    _retryTimer?.cancel();
    setState(() => _retrying = true);
    _boot();
  }

  /// Kicks today's bucket and the live snapshot so the first screen paints
  /// instantly when the gate lifts. Yesterday and tomorrow are NOT warmed:
  /// each is 4–12 GOAL requests, so they load when their tab is opened.
  void _warmUp() {
    ref.read(dayBucketProvider(DayKey.today));
    ref.read(liveFeedProvider);
  }

  void _update(SplashReadiness next) {
    if (!mounted) return;
    setState(() {
      _ready = next;
      if (next.booted) {
        _failure = null;
        _retrying = false;
      }
    });
    _liftIfReady();
  }

  void _liftIfReady() {
    if (!mounted || !_ready.canLift) return;
    ref.read(splashGateProvider.notifier).complete();
  }

  @override
  void dispose() {
    for (final Timer t in _timers) {
      t.cancel();
    }
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    // Counts are a bonus on a real launch; tests never warm the providers.
    final int? today = AppEnv.isTest
        ? null
        : ref.watch(dayBucketProvider(DayKey.today)).valueOrNull?.fixtureCount;
    final int live = AppEnv.isTest ? 0 : ref.watch(liveCountProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.heroEnd,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[colors.heroStart, colors.heroEnd],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: _failure != null
                        ? _OfflinePanel(retrying: _retrying, onRetry: _retry)
                        : const _Brand(),
                  ),
                ),
                if (_failure == null)
                  _StatusFooter(readiness: _ready, today: today, live: live),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// App tile with pulsing rings, wordmark and tagline.
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final bool motion = AppMotion.enabled(context);

    Widget tile = Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Icon(MarmaIcons.matches, size: 58, color: colors.heroStart, fill: 1),
    );
    Widget words = Column(
      children: <Widget>[
        Text(
          context.l10n.appName,
          style: context.type.titleLarge.copyWith(
            color: colors.onHero,
            fontSize: 38,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
          child: Text(
            context.l10n.appTagline,
            textAlign: TextAlign.center,
            style: context.type.bodyLarge.copyWith(color: colors.onHero.withValues(alpha: 0.82)),
          ),
        ),
      ],
    );

    if (motion) {
      tile = tile
          .animate()
          .scaleXY(begin: 0.6, end: 1, duration: AppMotion.bloom, curve: Curves.easeOutBack)
          .fadeIn(duration: AppMotion.slow);
      words = words
          .animate(delay: const Duration(milliseconds: 280))
          .fadeIn(duration: AppMotion.slow)
          .moveY(begin: 12, end: 0, curve: AppMotion.emphasis);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if (motion) ...<Widget>[
                _Ring(color: colors.onHero, delay: Duration.zero),
                _Ring(color: colors.onHero, delay: const Duration(milliseconds: 900)),
              ],
              tile,
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        words,
      ],
    );
  }
}

/// A soft ring that grows out from the tile and fades, on a loop. Only built
/// when motion is enabled, so tests never see a repeating controller.
class _Ring extends StatelessWidget {
  const _Ring({required this.color, required this.delay});

  final Color color;
  final Duration delay;

  @override
  Widget build(BuildContext context) => Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.35), width: 2),
        ),
      )
          .animate(onPlay: (AnimationController c) => c.repeat(), delay: delay)
          .scaleXY(begin: 1, end: 2, duration: const Duration(milliseconds: 1800), curve: Curves.easeOut)
          .fadeOut(duration: const Duration(milliseconds: 1800), curve: Curves.easeOut);
}

/// Real progress along the bottom: the current step, a bar that follows it,
/// and today's numbers as soon as they are known.
class _StatusFooter extends StatelessWidget {
  const _StatusFooter({required this.readiness, required this.today, required this.live});

  final SplashReadiness readiness;
  final int? today;
  final int live;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final String step = switch (readiness.step) {
      SplashStep.config => context.l10n.splashStepConfig,
      SplashStep.matches => context.l10n.splashStepMatches,
      SplashStep.ready => context.l10n.splashStepReady,
    };
    final String counts = <String>[
      if (today != null && today! > 0) context.l10n.splashToday(today!),
      if (live > 0) context.l10n.splashLive(live),
    ].join(' · ');
    final Duration motion = AppMotion.enabled(context) ? AppMotion.slow : Duration.zero;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.huge, 0, AppSpacing.huge, AppSpacing.xxl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedSwitcher(
              duration: motion,
              child: Text(
                step,
                key: ValueKey<SplashStep>(readiness.step),
                style: context.type.label.copyWith(
                  color: colors.onHero,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: AppRadius.chipRadius,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: readiness.progress),
                duration: motion * 2,
                curve: AppMotion.emphasis,
                builder: (BuildContext context, double v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 4,
                  color: colors.onHero,
                  backgroundColor: colors.onHero.withValues(alpha: 0.2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Fixed height so the column never jumps when the counts arrive.
            SizedBox(
              height: 18,
              child: AnimatedOpacity(
                opacity: counts.isEmpty ? 0 : 1,
                duration: motion,
                child: Text(
                  counts,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.label.copyWith(color: colors.onHero.withValues(alpha: 0.75)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Offline on first launch: the config is required, so the gate waits — but
/// it says so plainly and retries on its own.
class _OfflinePanel extends StatelessWidget {
  const _OfflinePanel({required this.retrying, required this.onRetry});

  final bool retrying;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: colors.onHero.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off_rounded, size: 40, color: colors.onHero),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.errorOfflineTitle,
            textAlign: TextAlign.center,
            style: context.type.titleLarge.copyWith(color: colors.onHero),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.splashAutoRetry,
            textAlign: TextAlign.center,
            style: context.type.bodyLarge.copyWith(color: colors.onHero.withValues(alpha: 0.82)),
          ),
          const SizedBox(height: AppSpacing.xxl),
          FilledButton.icon(
            onPressed: retrying ? null : onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colors.heroStart,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.6),
              disabledForegroundColor: colors.heroStart,
              minimumSize: const Size(200, 50),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.chipRadius),
              textStyle: context.type.label.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            icon: retrying
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colors.heroStart),
                  )
                : const Icon(MarmaIcons.retry, size: 18),
            label: Text(retrying ? context.l10n.splashReconnecting : context.l10n.actionRetry),
          ),
        ],
      ),
    );
  }
}
