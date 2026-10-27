import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/presentation/screens/common/state_views.dart';
import 'package:marma/presentation/widgets/content_width.dart';

/// `GoRouter.errorBuilder`. A bad deep link must land somewhere designed.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colors.bg,
        appBar: AppBar(),
        body: ContentWidth(
          child: MarmaStateView(
            title: context.l10n.routeNotFoundTitle,
            body: context.l10n.routeNotFoundBody,
            actionLabel: context.l10n.actionGoToToday,
            onAction: () => context.go('/matches?day=today'),
          ),
        ),
      );
}
