import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../bloc/event_detail/state.dart';

/// The status cards the viewer sees about *their own* entries — the design's
/// "⏳ Request pending · Nissan Skyline" and "✕ Entry declined · Mazda RX-7"
/// strips, both fed by `GET /{id}/cars/mine`.
///
/// One car per accepted entry doesn't get a strip here — that's what the
/// "PARTICIPATING (N)" button says. Everything else the viewer has a live or
/// recent opinion about (pending, rejected, withdrawn) gets its own strip,
/// since with multi-car registration more than one can be true at once — a
/// declined Mazda and a still-pending Skyline, say.
///
/// Renders nothing when there's nothing to say. Each declined strip quotes the
/// organizer's reason and carries the **TRY ANOTHER CAR** action (which
/// reopens the same multi-select picker); each pending one carries a way to
/// take that one request back (`DELETE /cars/{car_id}` works on pending rows
/// only). The withdrawn variant carries no action at all — withdrawal is
/// one-way, and an undo button would be a lie.
class MapEventParticipationStrip extends StatelessWidget {
  final MapEventDetailState state;
  final VoidCallback onTryAnotherCar;
  final ValueChanged<String> onCancelRequest;

  const MapEventParticipationStrip({
    super.key,
    required this.state,
    required this.onTryAnotherCar,
    required this.onCancelRequest,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final strips = <Widget>[
      for (final pending in state.myPendingEntries)
        _Strip(
          icon: Icons.hourglass_empty_rounded,
          title: l10n.mapEventsStripPendingTitle,
          subject: '${pending.car.brand} ${pending.car.model}',
          body: l10n.mapEventsStripPendingBody,
          actionLabel: l10n.mapEventsCancelRequest,
          onAction:
              state.isBusy ? null : () => onCancelRequest(pending.car.id),
        ),
      for (final rejected in state.myRejectedEntries)
        _Strip(
          icon: Icons.close_rounded,
          title: l10n.mapEventsStripDeclinedTitle,
          subject: '${rejected.car.brand} ${rejected.car.model}',
          body: l10n.mapEventsStripDeclinedBody,
          // The organizer has to give a reason to decline, so this is
          // normally present — but a row from before that rule still has
          // none.
          quote: rejected.rejectionReason,
          actionLabel: l10n.mapEventsTryAnotherCar,
          onAction: state.isBusy ? null : onTryAnotherCar,
        ),
      for (final withdrawn in state.myWithdrawnEntries)
        _Strip(
          icon: Icons.logout_rounded,
          title: l10n.mapEventsStripWithdrawnTitle,
          subject: '${withdrawn.car.brand} ${withdrawn.car.model}',
          body: l10n.mapEventsStripWithdrawnBody,
          actionLabel: null,
          onAction: null,
        ),
    ];

    if (strips.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (var i = 0; i < strips.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          strips[i],
        ],
      ],
    );
  }
}

class _Strip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subject;
  final String body;

  /// The organizer's own words, set apart from the app's copy so it's clear
  /// whose sentence it is.
  final String? quote;

  final String? actionLabel;
  final VoidCallback? onAction;

  const _Strip({
    required this.icon,
    required this.title,
    required this.subject,
    required this.body,
    this.quote,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quote = this.quote;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 16, color: AppColors.mute),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The car name is a muted continuation of the title rather
                    // than its own line — that's what makes "Request pending ·
                    // Nissan Skyline R34 GT-R" read as one sentence.
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                        children: [
                          TextSpan(text: title),
                          if (subject != null)
                            TextSpan(
                              text: ' · $subject',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.mute,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.ink2,
                      ),
                    ),
                    if (quote != null && quote.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.mapEventsDeclineReasonHeading,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.mute,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              quote,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: AppColors.ink2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.bg,
                  foregroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
