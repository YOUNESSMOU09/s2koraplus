import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marma/app/app_env.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/country_flag.dart';
import 'package:marma/core/utils/crest_url.dart';
import 'package:marma/presentation/theme/app_colors.dart';

/// The competition mark, with the country's emoji flag underneath it.
///
/// The flag is the FINAL fallback, not a placeholder: it is what every
/// competition header showed before crests, it needs no network, and it still
/// identifies the competition's country while the crest loads or when it never
/// arrives. Country flags themselves are never fetched — the API publishes them
/// as SVG, which Flutter cannot decode.
class LeagueCrest extends StatelessWidget {
  const LeagueCrest({
    required this.leagueId,
    required this.country,
    this.size = 20,
    super.key,
  });

  final String leagueId;

  /// The RAW hyphenated API country value — the emoji lookup key.
  final String country;

  final double size;

  @override
  Widget build(BuildContext context) {
    final Widget flag = Text(
      countryFlagEmoji(country),
      style: TextStyle(fontSize: size * 0.8),
      textScaler: TextScaler.noScaling,
    );

    final String? url = leagueCrestUrl(leagueId);
    if (url == null || AppEnv.isTest) {
      return ExcludeSemantics(child: SizedBox(width: size, child: Center(child: flag)));
    }

    final MarmaColors colors = context.colors;

    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.contain,
          memCacheWidth: (size * 3).round(),
          fadeInDuration: const Duration(milliseconds: 160),
          // Many league marks are dark line art on transparency, which
          // disappears against the dark theme; a light plate keeps them legible
          // in both palettes without touching the mark itself.
          imageBuilder: (BuildContext context, ImageProvider<Object> image) => Container(
            padding: EdgeInsets.all(size * 0.08),
            decoration: BoxDecoration(
              color: colors.isDark ? Colors.white.withValues(alpha: 0.92) : null,
              borderRadius: BorderRadius.circular(size * 0.24),
            ),
            child: Image(image: image, fit: BoxFit.contain),
          ),
          placeholder: (BuildContext context, String _) => Center(child: flag),
          errorWidget: (BuildContext context, String _, Object _) =>
              Center(child: flag),
        ),
      ),
    );
  }
}
