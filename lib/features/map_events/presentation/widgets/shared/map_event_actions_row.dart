import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/map_event_enums.dart';
import '../../bloc/event_detail/state.dart';
import 'map_event_action_button.dart';

/// The Attending / Interested toggle pair.
///
/// They behave as one control: whichever is active is filled black, and tapping
/// the active one clears the RSVP rather than doing nothing. Both go inert when
/// the backend says the viewer can't RSVP at all (a finished or canceled
/// event).
class MapEventRsvpButtons extends StatelessWidget {
  final MapEventDetailState state;
  final ValueChanged<MapEventAttendance> onToggle;

  /// The map popup runs these at a smaller size than the detail page.
  final bool isCompact;

  const MapEventRsvpButtons({
    super.key,
    required this.state,
    required this.onToggle,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final event = state.event;
    if (event == null) return const SizedBox.shrink();

    final canRsvp = event.viewer.canRsvp && !state.isBusy;
    final busy = state.action == MapEventAction.rsvp;

    Widget button(MapEventAttendance status, String label, IconData icon) {
      final isActive = event.viewer.attendanceStatus == status;
      return MapEventActionButton(
        label: label,
        icon: isActive ? Icons.check_rounded : icon,
        tone: isActive ? MapEventButtonTone.active : MapEventButtonTone.idle,
        isCompact: isCompact,
        isBusy: busy && isActive,
        onTap: canRsvp ? () => onToggle(status) : null,
      );
    }

    return Row(
      children: [
        Expanded(
          child: button(
            MapEventAttendance.attending,
            l10n.mapEventsAttending,
            Icons.event_available_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: button(
            MapEventAttendance.interested,
            l10n.mapEventsInterested,
            Icons.star_outline_rounded,
          ),
        ),
      ],
    );
  }
}

/// The participation control, which is really a small state machine:
///
/// ```
///  nothing registered ──► "PARTICIPATE?"   (opens the garage picker)
///  awaiting organizer ──► "PENDING"        (inert, accent-soft)
///  accepted           ──► "PARTICIPATING"  + a separate WITHDRAW button
///  withdrawal sent    ──► "PENDING"        (inert — withdrawal is one-way)
/// ```
///
/// It disappears entirely when the viewer can't register cars at all, and greys
/// out when the entry list is full or the deadline has passed — the reason is
/// spelled out next to it rather than left to a dead button.
class MapEventParticipationButtons extends StatelessWidget {
  final MapEventDetailState state;
  final VoidCallback onRegister;
  final VoidCallback onWithdraw;
  final bool isCompact;

  const MapEventParticipationButtons({
    super.key,
    required this.state,
    required this.onRegister,
    required this.onWithdraw,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final event = state.event;
    if (event == null || !event.viewer.canRegisterCars) {
      return const SizedBox.shrink();
    }

    // Accepted: a done pill plus the way out.
    if (state.myAcceptedEntry != null) {
      return Row(
        children: [
          Expanded(
            child: MapEventActionButton(
              label: l10n.mapEventsParticipating,
              icon: Icons.check_rounded,
              tone: MapEventButtonTone.done,
              isCompact: isCompact,
              onTap: null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: MapEventActionButton(
              label: l10n.mapEventsWithdrawAction,
              tone: MapEventButtonTone.idle,
              isCompact: isCompact,
              isBusy: state.action == MapEventAction.withdraw,
              onTap: state.isBusy ? null : onWithdraw,
            ),
          ),
        ],
      );
    }

    // A pending entry or a pending withdrawal — both "waiting on the
    // organizers", both inert.
    if (state.myPendingEntry != null || state.myWithdrawnEntry != null) {
      return MapEventActionButton(
        label: l10n.mapEventsParticipationPending,
        icon: Icons.hourglass_empty_rounded,
        tone: MapEventButtonTone.accentSoft,
        isCompact: isCompact,
        onTap: null,
      );
    }

    final blocked = event.isRegistrationClosed || event.isAtCapacity;

    return MapEventActionButton(
      label: isCompact
          ? l10n.mapEventsWantToParticipate
          : l10n.mapEventsParticipateShort,
      icon: Icons.directions_car_rounded,
      tone: MapEventButtonTone.idle,
      isCompact: isCompact,
      isBusy: state.action == MapEventAction.register,
      onTap: (blocked || state.isBusy) ? null : onRegister,
    );
  }
}
