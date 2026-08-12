import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/features/map/domain/entities/geo_position.dart';
import 'package:car_social_media_app/features/map/presentation/widgets/navigation/navigation_app_sheet.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/map_event_pin.dart';
import '../../bloc/event_detail/bloc.dart';
import '../../bloc/event_detail/event.dart';
import '../../bloc/event_detail/state.dart';
import '../../utils/map_event_error_mapper.dart';
import '../../utils/map_event_formatting.dart';
import '../shared/event_car_picker_sheet.dart';
import '../shared/map_event_action_button.dart';
import '../shared/map_event_actions_row.dart';
import '../shared/map_event_attendee_stack.dart';
import '../shared/map_event_chips.dart';
import '../shared/map_event_cover.dart';
import '../shared/map_event_organizer_row.dart';
import '../shared/map_event_stat_tiles.dart';
import '../shared/withdraw_event_dialog.dart';

/// The floating card that opens over the map when an event pin is tapped.
///
/// Same shape as the business popup — not a modal sheet, so the map stays
/// visible and pannable behind it and the tapped pin keeps its highlight — but
/// with a cover-image header and the full RSVP/participation controls, because
/// the design lets you act on an event without ever opening its page.
///
/// The pin's own data ([pin]) renders immediately; everything that needs
/// `GET /map-events/{id}` fills in when [MapEventDetailBloc] lands.
class MapEventPopup extends StatelessWidget {
  final MapEventPinEntity? pin;

  /// Where the map fetched from — the distance tile is computed against it,
  /// since the backend stopped sending one.
  final GeoPosition? fetchCentre;

  final VoidCallback onClose;

  const MapEventPopup({
    super.key,
    required this.pin,
    required this.fetchCentre,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return BlocBuilder<MapEventDetailBloc, MapEventDetailState>(
      builder: (context, state) {
        final event = state.event;
        final destination = event?.position ?? pin?.position;

        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 28,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: switch (state.status) {
                    MapEventDetailStatus.failure when event == null =>
                      _PopupError(state: state),
                    _ => _PopupBody(
                        state: state,
                        pin: pin,
                        fetchCentre: fetchCentre,
                        onClose: onClose,
                      ),
                  },
                ),
              ),
              // Pinned below the scroll area so a long description can never
              // push the two main actions off the card.
              if (destination != null && event != null)
                _PopupFooter(
                  eventId: event.id,
                  destination: destination,
                  label: event.title,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PopupBody extends StatelessWidget {
  final MapEventDetailState state;
  final MapEventPinEntity? pin;
  final GeoPosition? fetchCentre;
  final VoidCallback onClose;

  const _PopupBody({
    required this.state,
    required this.pin,
    required this.fetchCentre,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final event = state.event;

    // Prefer the pin for the header: it's already on screen, so the card opens
    // filled in rather than as a skeleton that fills in a beat later.
    final title = pin?.title ?? event?.title ?? '';
    final coverUrl = pin?.coverImageUrl ?? event?.coverImageUrl;
    final status = pin?.status ?? event?.status;
    final position = pin?.position ?? event?.position;
    final centre = fetchCentre;
    final distanceKm = (centre != null && position != null)
        ? centre.distanceKmTo(position)
        : null;

    final attendees = event?.attendeesCount ?? pin?.attendeesCount ?? 0;
    final cars = event?.attendingCarsCount ?? pin?.attendingCarsCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            MapEventCover(imageUrl: coverUrl, height: 132, withScrim: false),
            if (status != null)
              Positioned(
                top: 10,
                left: 12,
                child: MapEventStatusChip(status: status),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: _RoundIconButton(
                icon: Icons.close_rounded,
                semanticLabel: l10n.mapEventsClose,
                onTap: onClose,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              if (event != null && event.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  event.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.35,
                    color: AppColors.ink2,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _MetaRow(
                icon: Icons.place_outlined,
                text: pin?.locationName ?? event?.locationName ?? '',
                isStrong: true,
              ),
              if (pin != null || event != null) ...[
                const SizedBox(height: 6),
                _MetaRow(
                  icon: Icons.schedule_rounded,
                  text: MapEventFormat.dateRange(
                    context,
                    pin?.startsAt ?? event!.startsAt,
                    pin?.endsAt ?? event?.endsAt,
                  ),
                  isStrong: true,
                ),
              ],
              const SizedBox(height: 14),
              MapEventStatRow(
                tiles: [
                  MapEventStatTile(
                    icon: Icons.people_alt_rounded,
                    value: '$attendees',
                    label: l10n.mapEventsStatAttendees,
                  ),
                  MapEventStatTile(
                    icon: Icons.directions_car_rounded,
                    value: '$cars',
                    label: l10n.mapEventsStatCars,
                    isHighlighted: state.myAcceptedEntry != null,
                  ),
                  MapEventStatTile(
                    icon: Icons.near_me_outlined,
                    value: distanceKm == null
                        ? '—'
                        : MapEventFormat.distance(l10n, distanceKm),
                    label: l10n.mapEventsStatAway,
                  ),
                ],
              ),
              if (event == null) ...[
                const SizedBox(height: 18),
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.muteSoft,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ] else ...[
                if (state.attendeePreview.isNotEmpty || attendees > 0) ...[
                  const SizedBox(height: 12),
                  MapEventAttendeeStack(
                    attendees: state.attendeePreview,
                    total: attendees,
                  ),
                ],
                if (event.organizers.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (final organizer in event.organizers) ...[
                    MapEventOrganizerRow(organizer: organizer),
                    const SizedBox(height: 6),
                  ],
                ],
                const SizedBox(height: 6),
                MapEventRsvpButtons(
                  state: state,
                  isCompact: true,
                  onToggle: (status) => context
                      .read<MapEventDetailBloc>()
                      .add(ToggleMapEventRsvp(status)),
                ),
                const SizedBox(height: 8),
                _ParticipationLine(state: state),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The popup's participation strip: either the invitation to register, or a
/// one-line statement of where the viewer's car stands.
class _ParticipationLine extends StatelessWidget {
  final MapEventDetailState state;

  const _ParticipationLine({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accepted = state.myAcceptedEntry;

    if (accepted != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          l10n.mapEventsCarOnEntryList(
            '${accepted.car.brand} ${accepted.car.model}',
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12.5, color: AppColors.ink2),
        ),
      );
    }

    return MapEventParticipationButtons(
      state: state,
      isCompact: true,
      onRegister: () => _register(context),
      onWithdraw: () => _withdraw(context),
    );
  }

  Future<void> _register(BuildContext context) async {
    final bloc = context.read<MapEventDetailBloc>();
    final carId = await showEventCarPickerSheet(context);
    if (carId != null) bloc.add(RegisterCarForEvent(carId));
  }

  Future<void> _withdraw(BuildContext context) async {
    final bloc = context.read<MapEventDetailBloc>();
    final note = await showWithdrawEventDialog(context);
    if (note != null) bloc.add(SubmitEventWithdrawal(note.isEmpty ? null : note));
  }
}

/// The pinned bar: navigate, and the way into the full page.
class _PopupFooter extends StatelessWidget {
  final String eventId;
  final GeoPosition destination;
  final String label;

  const _PopupFooter({
    required this.eventId,
    required this.destination,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line2)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          // Square icon button rather than the shared full-width NavigateButton:
          // here it shares the bar with the primary CTA.
          Material(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => showNavigationAppSheet(
                context,
                lat: destination.lat,
                lng: destination.lng,
                destinationLabel: label,
              ),
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 46,
                height: 46,
                child: Semantics(
                  button: true,
                  label: l10n.mapNavigate,
                  child: const Icon(
                    Icons.near_me_rounded,
                    size: 19,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: MapEventActionButton(
              label: l10n.mapEventsViewEvent,
              icon: Icons.chevron_right_rounded,
              tone: MapEventButtonTone.accent,
              onTap: () async {
                final bloc = context.read<MapEventDetailBloc>();
                await context.push('/map-events/$eventId');
                // The page runs its own bloc instance, so anything done there —
                // an RSVP, a car registered — is invisible to this one. Force a
                // reload rather than leaving the popup contradicting the page
                // the user just came back from.
                bloc.add(LoadMapEvent(eventId, force: true));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isStrong;

  const _MetaRow({
    required this.icon,
    required this.text,
    this.isStrong = false,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.mute),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isStrong ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, size: 17, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _PopupError extends StatelessWidget {
  final MapEventDetailState state;

  const _PopupError({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = state.error ?? const MapEventError(MapEventErrorCode.generic);
    // A gone event answers 404 by design; retrying it would only fail again.
    final canRetry = error.code != MapEventErrorCode.notFound;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 28,
            color: AppColors.muteSoft,
          ),
          const SizedBox(height: 12),
          Text(
            mapEventErrorMessage(l10n, error),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.ink2),
          ),
          if (canRetry) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  context.read<MapEventDetailBloc>().add(const RefreshMapEvent()),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(l10n.mapEventsRetry),
            ),
          ],
        ],
      ),
    );
  }
}
