import 'package:flutter/material.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/failures.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/brand_mark.dart';
import 'package:marma/presentation/widgets/marma_button.dart';

/// Every empty and error state in the app is this one designed composition:
/// the soft brand mark, a `titleLarge` line, a `bodyMedium` line, at most one
/// CTA. Never a bare `Text('Error')`, never a lone spinner.
class MarmaStateView extends StatelessWidget {
  const MarmaStateView({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.actionIcon,
    super.key,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  /// Optional glyph on the CTA. Left null for navigational actions — a refresh
  /// arrow on "Add favourites" would be a lie.
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            BrandMark(size: 88, soft: true, icon: icon),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.type.titleLarge.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              textAlign: TextAlign.center,
              style: context.type.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xxl),
              MarmaButton.secondary(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
                icon: actionIcon == null ? null : Icon(actionIcon),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Maps an [AppFailure] onto the designed copy from §11.2.
class FailureView extends StatelessWidget {
  const FailureView({
    required this.failure,
    required this.onRetry,
    this.minutesAgo = 0,
    this.hasCachedData = false,
    super.key,
  });

  final Object failure;
  final VoidCallback onRetry;
  final int minutesAgo;
  final bool hasCachedData;

  @override
  Widget build(BuildContext context) {
    final AppFailure f = asAppFailure(failure);
    final String title;
    final String body;
    switch (f.kind) {
      case FailureKind.noConnection:
        title = context.l10n.errorOfflineTitle;
        body = hasCachedData
            ? context.l10n.errorOfflineBody(minutesAgo)
            : context.l10n.errorOfflineBodyNoCache;
      case FailureKind.timeout:
        title = context.l10n.errorTimeoutTitle;
        body = context.l10n.errorTimeoutBody;
      case FailureKind.server:
        title = context.l10n.errorServerTitle;
        body = context.l10n.errorServerBody;
      case FailureKind.badResponse:
        title = context.l10n.errorBadResponseTitle;
        body = context.l10n.errorBadResponseBody;
      case FailureKind.notFound:
        title = context.l10n.notFoundTitle;
        body = context.l10n.notFoundBody;
      case FailureKind.rateLimited:
        title = context.l10n.errorQuotaTitle;
        body = context.l10n.errorQuotaBody;
      case FailureKind.emptyDay:
        title = context.l10n.emptyDayTitle;
        body = context.l10n.emptyDayBody;
      case FailureKind.cancelled:
      case FailureKind.unknown:
        title = context.l10n.errorUnknownTitle;
        body = context.l10n.errorUnknownBody;
    }
    return MarmaStateView(
      title: title,
      body: body,
      actionLabel: context.l10n.actionRetry,
      onAction: onRetry,
      actionIcon: MarmaIcons.retry,
    );
  }
}
