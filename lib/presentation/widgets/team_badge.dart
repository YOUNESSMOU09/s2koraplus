import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marma/app/app_env.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/crest_url.dart';
import 'package:marma/core/utils/monogram.dart';
import 'package:marma/presentation/theme/app_colors.dart';

enum TeamBadgeSize { sm, md, lg, xl }

extension on TeamBadgeSize {
  double get dimension => switch (this) {
        TeamBadgeSize.sm => 24,
        TeamBadgeSize.md => 30,
        TeamBadgeSize.lg => 40,
        TeamBadgeSize.xl => 60,
      };
}

/// Swappable backing for team identity.
///
/// v1 shipped `MonogramBadgeRenderer` alone and documented `CrestBadgeRenderer`
/// as the one-line override to make "if and only if licensing is secured". That
/// call has now been made by the app's owner, so [TeamBadge.renderer] points at
/// the crest renderer — and the monogram is still what draws while the image
/// loads and whenever it fails, so no surface has ever depended on the network
/// to show who is playing.
abstract class TeamBadgeRenderer {
  const TeamBadgeRenderer();
  Widget build(BuildContext context, {required String teamId, required String teamName, required double size});
}

class MonogramBadgeRenderer extends TeamBadgeRenderer {
  const MonogramBadgeRenderer();

  @override
  Widget build(BuildContext context,
      {required String teamId, required String teamName, required double size}) {
    final MarmaColors colors = context.colors;
    final int index = teamPaletteIndex(teamId, paletteLength: BadgePalette.length);
    final Color hue = BadgePalette.hue(index, colors.brightness);
    final double fillAlpha = colors.isDark ? 0.18 : 0.14;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: hue.withValues(alpha: fillAlpha),
        // A soft squircle, deliberately NOT a circle, so it never reads as a
        // crest lockup.
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Text(
        teamMonogram(teamName),
        textAlign: TextAlign.center,
        textScaler: TextScaler.noScaling,
        style: context.type.sectionHeader.copyWith(
          color: hue,
          fontSize: size * 0.40,
          height: 1.0,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

/// Draws the real crest, with the monogram underneath it.
///
/// The monogram is not a spinner: it is the FINAL state whenever the crest is
/// missing, still downloading, or on a device that is offline and has never
/// cached this club. Every badge therefore renders something identifying in one
/// frame, with no layout shift when the image arrives — the box is the same
/// size either way.
class CrestBadgeRenderer extends TeamBadgeRenderer {
  const CrestBadgeRenderer();

  @override
  Widget build(BuildContext context,
      {required String teamId, required String teamName, required double size}) {
    final String? url = teamCrestUrl(teamId);
    final Widget monogram = const MonogramBadgeRenderer()
        .build(context, teamId: teamId, teamName: teamName, size: size);

    // Headless tests must never reach the network; `CachedNetworkImage` would
    // otherwise leave an HTTP client pending at teardown.
    if (url == null || AppEnv.isTest) return monogram;

    return SizedBox(
      width: size,
      height: size,
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        // Crests are small and square; asking the decoder for the display size
        // keeps ~1200 badges on a scoreboard out of full-resolution memory.
        memCacheWidth: (size * 3).round(),
        fadeInDuration: const Duration(milliseconds: 160),
        placeholder: (BuildContext context, String _) => monogram,
        errorWidget: (BuildContext context, String _, Object _) => monogram,
      ),
    );
  }
}

/// The single point of team identity in the entire app.
class TeamBadge extends StatelessWidget {
  const TeamBadge({
    required this.teamId,
    required this.teamName,
    this.size = TeamBadgeSize.md,
    super.key,
  });

  /// The one place identity backing is chosen. Swap this line to go back to
  /// monograms everywhere.
  static const TeamBadgeRenderer renderer = CrestBadgeRenderer();

  final String teamId;
  final String teamName;
  final TeamBadgeSize size;

  @override
  Widget build(BuildContext context) {
    // Decorative: the team name is always adjacent in text.
    return ExcludeSemantics(
      child: renderer.build(
          context, teamId: teamId, teamName: teamName, size: size.dimension),
    );
  }
}
