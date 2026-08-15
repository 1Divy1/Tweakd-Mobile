import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/map_event.dart';
import '../../bloc/event_detail/bloc.dart';
import '../../bloc/event_detail/event.dart';
import '../../bloc/event_detail/state.dart';
import '../../utils/map_event_formatting.dart';
import '../shared/event_car_picker_sheet.dart';
import '../shared/map_event_attendee_stack.dart';
import '../shared/map_event_chips.dart';
import '../shared/map_event_organizer_row.dart';
import '../shared/map_event_participation_strip.dart';

/// Everything under the Overview tab, in the order the design lays it out:
/// when & where, the viewer's own entry status, the description, the
/// organizers, their rules, the contests placeholder and the attendee row.
class MapEventOverviewTab extends StatelessWidget {
  final MapEventDetailState state;
  final VoidCallback onSeeAllCars;

  const MapEventOverviewTab({
    super.key,
    required this.state,
    required this.onSeeAllCars,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final event = state.event!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WhenCard(event: event),
        const SizedBox(height: 14),
        MapEventParticipationStrip(
          state: state,
          onTryAnotherCar: () => _register(context),
          onCancelRequest: (carId) => context
              .read<MapEventDetailBloc>()
              .add(CancelPendingCarRegistration(carId)),
        ),
        if (event.description.isNotEmpty) ...[
          const SizedBox(height: 20),
          MapEventSectionLabel(label: l10n.mapEventsSectionAbout),
          const SizedBox(height: 8),
          _Card(
            child: Text(
              event.description,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.45,
                color: AppColors.ink2,
              ),
            ),
          ),
        ],
        if (event.organizers.isNotEmpty) ...[
          const SizedBox(height: 20),
          MapEventSectionLabel(label: l10n.mapEventsSectionOrganizers),
          const SizedBox(height: 8),
          for (final organizer in event.organizers) ...[
            MapEventOrganizerRow(organizer: organizer),
            const SizedBox(height: 8),
          ],
        ],
        if (event.rules.isNotEmpty) ...[
          const SizedBox(height: 12),
          MapEventSectionLabel(label: l10n.mapEventsSectionRules),
          const SizedBox(height: 8),
          _RulesCard(event: event),
        ],
        const SizedBox(height: 20),
        MapEventSectionLabel(label: l10n.mapEventsSectionContests),
        const SizedBox(height: 8),
        const _ContestsPlaceholder(),
        const SizedBox(height: 20),
        _AttendeesSection(state: state),
        const SizedBox(height: 14),
        _SeeAllCarsButton(count: event.attendingCarsCount, onTap: onSeeAllCars),
      ],
    );
  }

  Future<void> _register(BuildContext context) async {
    final bloc = context.read<MapEventDetailBloc>();
    final carIds = await showEventCarPickerSheet(
      context,
      remainingSpots: state.event!.remainingCapacity,
      excludedCarIds: state.activeParticipationCarIds,
    );
    if (carIds != null && carIds.isNotEmpty) {
      bloc.add(RegisterCarsForEvent(carIds));
    }
  }
}

/// The date card: a calendar tile, the date/time range, the full address, and —
/// for a car meet — the registration deadline.
class _WhenCard extends StatelessWidget {
  final MapEventEntity event;

  const _WhenCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deadline = event.carMeet?.registrationDeadline;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CalendarTile(date: event.startsAt),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      MapEventFormat.dateRange(
                        context,
                        event.startsAt,
                        event.endsAt,
                      ),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.locationName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.mute,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (deadline != null) ...[
            const SizedBox(height: 14),
            const Divider(color: AppColors.line2, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.hourglass_empty_rounded,
                  size: 15,
                  // Once the deadline has gone the line stops being a prompt
                  // and starts being an explanation, so it loses the accent.
                  color: event.carMeet!.hasPassed
                      ? AppColors.mute
                      : AppColors.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.carMeet!.hasPassed
                        ? l10n.mapEventsRegistrationClosed
                        : l10n.mapEventsRegisterBefore(
                            MapEventFormat.deadline(context, deadline),
                          ),
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.ink2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CalendarTile extends StatelessWidget {
  final DateTime date;

  const _CalendarTile({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            MapEventFormat.monthShort(context, date),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            MapEventFormat.dayNumber(context, date),
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  final MapEventEntity event;

  const _RulesCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < event.rules.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The backend owns the order, so the number is the position in
                // the list it sent — not `sort_order`, which is an internal
                // value and can have gaps.
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mute,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    event.rules[i].rule,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.ink2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A UI-only stub, exactly as the design shows it: there is no contests
/// endpoint, no state and nothing to tap. It exists to set the expectation.
class _ContestsPlaceholder extends StatelessWidget {
  const _ContestsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.emoji_events_outlined,
              size: 17,
              color: AppColors.muteSoft,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.mapEventsContestsTitle,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const MapEventSoonChip(),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.mapEventsContestsBody,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: AppColors.mute,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendeesSection extends StatelessWidget {
  final MapEventDetailState state;

  const _AttendeesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final event = state.event!;
    final hasAttendees =
        event.attendeesCount > 0 || state.attendeePreview.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MapEventSectionLabel(label: l10n.mapEventsSectionAttendees),
            if (hasAttendees)
              TextButton(
                onPressed: () =>
                    context.push('/map-events/${event.id}/attendees'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                child: Text(l10n.mapEventsSeeAll),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (!hasAttendees)
          _Card(
            child: Text(
              l10n.mapEventsAttendeesEmpty,
              style: const TextStyle(fontSize: 13.5, color: AppColors.mute),
            ),
          )
        else ...[
          MapEventAttendeeStack(
            attendees: state.attendeePreview,
            total: event.attendeesCount,
            maxAvatars: 6,
            size: 34,
          ),
          const SizedBox(height: 12),
          _WideButton(
            label: l10n.mapEventsSeeAllAttendees,
            onTap: () => context.push('/map-events/${event.id}/attendees'),
          ),
        ],
      ],
    );
  }
}

class _SeeAllCarsButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _SeeAllCarsButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _WideButton(
      label: l10n.mapEventsSeeAllCars(count),
      icon: Icons.directions_car_rounded,
      trailingIcon: Icons.chevron_right_rounded,
      onTap: onTap,
    );
  }
}

class _WideButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback onTap;

  const _WideButton({
    required this.label,
    this.icon,
    this.trailingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.ink),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 18, color: AppColors.ink),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
