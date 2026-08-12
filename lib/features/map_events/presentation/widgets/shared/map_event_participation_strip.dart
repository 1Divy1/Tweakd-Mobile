import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../bloc/event_detail/state.dart';

/// The status card the viewer sees about *their own* entry — the design's
/// "⏳ Request pending · Nissan Skyline" and "✕ Entry declined · Mazda RX-7"
/// strips.
///
/// Renders nothing when there's nothing to say. The declined variant carries
/// the **TRY ANOTHER CAR** action; the pending one carries a way to take the
/// request back (`DELETE /cars/{car_id}` works on pending rows only). The
/// withdrawn variant carries no action at all — withdrawal is one-way, and an
/// undo button would be a lie.
class MapEventParticipationStrip extends StatelessWidget {
  final MapEventDetailState state;
  final VoidCallback onTryAnotherCar;
  final VoidCallback onCancelRequest;

  const MapEventParticipationStrip({
    super.key,
    required this.state,
    required this.onTryAnotherCar,
    required this.onCancelRequest,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pending = state.myPendingEntry;
    if (pending != null) {
      return _Strip(
        icon: Icons.hourglass_empty_rounded,
        title: l10n.mapEventsStripPendingTitle,
        subject: '${pending.car.brand} ${pending.car.model}',
        body: l10n.mapEventsStripPendingBody,
        actionLabel: l10n.mapEventsCancelRequest,
        onAction: state.isBusy ? null : onCancelRequest,
      );
    }

    final rejected = state.myRejectedEntry;
    if (rejected != null) {
      return _Strip(
        icon: Icons.close_rounded,
        title: l10n.mapEventsStripDeclinedTitle,
        subject: '${rejected.car.brand} ${rejected.car.model}',
        // The backend sends no rejection reason on a participant row, so the
        // design's quoted organizer note can't be shown — see
        // `MAP_EVENTS_NOTES.md` §1.3.
        body: l10n.mapEventsStripDeclinedBody,
        actionLabel: l10n.mapEventsTryAnotherCar,
        onAction: state.isBusy ? null : onTryAnotherCar,
      );
    }

    final withdrawn = state.myWithdrawnEntry;
    if (withdrawn != null) {
      return _Strip(
        icon: Icons.logout_rounded,
        title: l10n.mapEventsStripWithdrawnTitle,
        subject: '${withdrawn.car.brand} ${withdrawn.car.model}',
        body: l10n.mapEventsStripWithdrawnBody,
        actionLabel: null,
        onAction: null,
      );
    }

    // A registration the backend won't describe to this viewer: their own
    // pending or rejected row, which only organizers may list. Saying "in
    // progress" is honest; guessing at a status wouldn't be.
    if (state.hasUnresolvedRegistration) {
      return _Strip(
        icon: Icons.hourglass_empty_rounded,
        title: l10n.mapEventsStripUnknownTitle,
        subject: null,
        body: l10n.mapEventsStripUnknownBody,
        actionLabel: null,
        onAction: null,
      );
    }

    return const SizedBox.shrink();
  }
}

class _Strip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subject;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Strip({
    required this.icon,
    required this.title,
    required this.subject,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                        children: [
                          TextSpan(text: title),
                          if (subject != null)
                            TextSpan(
                              text: ' · $subject',
                              style: const TextStyle(
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
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.ink2,
                      ),
                    ),
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
