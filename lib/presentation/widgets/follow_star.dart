import 'package:flutter/material.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/presentation/theme/app_colors.dart';

/// Follow toggle. 48 dp target, semantic `toggled` state, amber when followed.
class FollowStar extends StatelessWidget {
  const FollowStar({
    required this.followed,
    required this.onPressed,
    required this.label,
    this.size = 24,
    super.key,
  });

  final bool followed;
  final VoidCallback onPressed;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Semantics(
      // `container: true` is load-bearing: without it these annotations are
      // merged into the enclosing ListTile/row node, and VoiceOver exposes the
      // whole tile as one button instead of a separately focusable toggle.
      container: true,
      button: true,
      toggled: followed,
      label: label,
      child: InkResponse(
        onTap: onPressed,
        radius: 24,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            MarmaIcons.following,
            size: size,
            fill: followed ? 1 : 0,
            color: followed ? colors.accent : colors.textTertiary,
          ),
        ),
      ),
    );
  }
}
