import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/create_event/bloc.dart';
import '../../../bloc/create_event/event.dart';
import '../../../bloc/create_event/state.dart';
import '../../../pages/pick_event_location_page.dart';
import '../../../utils/map_event_formatting.dart';
import '../../shared/map_event_chips.dart';
import '../create_event_chrome.dart';
import '../create_event_fields.dart';

/// Step 3 — the schedule and the pin.
///
/// There is no venue text field here any more. `location_name` is always the
/// address the map picker composed, so the address the organizer searched and
/// the pin they dropped can never drift apart — which is what the old free-text
/// field allowed.
class WhenWhereStep extends StatelessWidget {
  final CreateMapEventState state;

  const WhenWhereStep({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<CreateMapEventBloc>();

    String date(DateTime value) => MapEventFormat.dayAndMonth(context, value);
    String time(DateTime value) => MapEventFormat.time(context, value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateEventStepHeader(
          title: l10n.mapEventsStepWhenWhereTitle,
          subtitle: l10n.mapEventsStepWhenWhereSubtitle,
        ),
        MapEventSectionLabel(label: l10n.mapEventsFieldDateTime),
        const SizedBox(height: 8),
        EventDateTimeRow(
          label: l10n.mapEventsStartsLabel,
          value: state.startsAt,
          onChanged: (value) => bloc.add(ChangeEventStart(value)),
          formatDate: date,
          formatTime: time,
        ),
        const SizedBox(height: 8),
        EventDateTimeRow(
          label: l10n.mapEventsEndsLabel,
          value: state.endsAt,
          // The end can only be picked once there's a start to anchor it to,
          // and it can't land before that start.
          minimum: state.startsAt,
          enabled: state.startsAt != null,
          onChanged: (value) => bloc.add(ChangeEventEnd(value)),
          onClear: state.endsAt == null
              ? null
              : () => bloc.add(const ChangeEventEnd(null)),
          formatDate: date,
          formatTime: time,
        ),
        const SizedBox(height: 8),
        EventHint(l10n.mapEventsEndBlankHint),
        const SizedBox(height: 24),

        // The design labels the deadline OPTIONAL; the API requires it for car
        // meets, and the API wins — so the label says REQUIRED and the step
        // refuses to advance without it.
        Row(
          children: [
            Flexible(
              child: MapEventSectionLabel(label: l10n.mapEventsFieldDeadline),
            ),
            if (state.requiresDeadline) ...[
              const SizedBox(width: 8),
              CreateEventOptionalChip(label: l10n.mapEventsRequired),
            ],
          ],
        ),
        const SizedBox(height: 8),
        EventDateTimeRow(
          label: l10n.mapEventsFieldDeadline,
          value: state.registrationDeadline,
          // It must not land after the start; offering later dates at all just
          // means picking one and being told off for it.
          maximum: state.startsAt,
          onChanged: (value) => bloc.add(ChangeEventDeadline(value)),
          onClear: state.registrationDeadline == null || state.requiresDeadline
              ? null
              : () => bloc.add(const ChangeEventDeadline(null)),
          formatDate: date,
          formatTime: time,
        ),
        const SizedBox(height: 24),

        MapEventSectionLabel(label: l10n.mapEventsFieldLocation),
        const SizedBox(height: 10),
        _LocationSection(state: state),
      ],
    );
  }
}

class _LocationSection extends StatelessWidget {
  final CreateMapEventState state;

  const _LocationSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasPin = state.position != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasPin) ...[
          _PickedLocationCard(state: state),
          const SizedBox(height: 10),
        ],
        EventDashedButton(
          label: hasPin
              ? l10n.mapEventsLocationChangeCta
              : l10n.mapEventsLocationPickCta,
          icon: hasPin ? Icons.edit_location_alt_outlined : Icons.place_outlined,
          onTap: () => _pick(context),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final bloc = context.read<CreateMapEventBloc>();

    final picked = await showPickEventLocation(
      context,
      initial: state.position,
      // Seeds the picker's address form, so re-opening to nudge the pin doesn't
      // make the organizer retype the address they already searched.
      initialAddress: state.city.isEmpty && state.street.isEmpty
          ? null
          : PickedEventLocation(
              position: state.position!,
              city: state.city,
              street: state.street,
              number: state.number,
            ),
    );
    if (picked == null) return;

    bloc.add(ChangeEventLocation(picked));
  }
}

/// The address the picker came back with, read-only. The organizer types this
/// in the picker's own search form; nothing here is copied from the geocoder.
class _PickedLocationCard extends StatelessWidget {
  final CreateMapEventState state;

  const _PickedLocationCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final position = state.position!;

    // An event being edited has a saved `location_name` but no components —
    // it predates the picker returning them — so it shows as one line.
    final hasComponents = state.city.isNotEmpty || state.street.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(kCreateEventRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasComponents) ...[
            _Line(label: l10n.mapEventsLocationCardCity, value: state.city),
            if (state.street.isNotEmpty)
              _Line(label: l10n.mapEventsLocationCardStreet, value: state.street),
            if (state.number.isNotEmpty)
              _Line(label: l10n.mapEventsLocationCardNumber, value: state.number),
          ] else
            _Line(
              label: l10n.mapEventsFieldLocation,
              value: state.locationName,
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.place_rounded,
                size: 15,
                color: AppColors.accent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${l10n.mapEventsLocationCardPin} · '
                  '${position.lat.toStringAsFixed(5)}, '
                  '${position.lng.toStringAsFixed(5)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mute,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;

  const _Line({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.mute,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
