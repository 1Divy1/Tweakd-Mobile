import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/event_detail/bloc.dart';
import '../bloc/event_detail/event.dart';
import '../bloc/event_detail/state.dart';
import '../utils/map_event_error_mapper.dart';
import '../utils/map_event_formatting.dart';
import '../widgets/detail/map_event_cars_tab.dart';
import '../widgets/detail/map_event_hero.dart';
import '../widgets/detail/map_event_overview_tab.dart';
import '../widgets/detail/map_event_tabs.dart';
import '../widgets/shared/event_car_picker_sheet.dart';
import '../widgets/shared/map_event_actions_row.dart';
import '../widgets/shared/map_event_stat_tiles.dart';
import '../widgets/shared/withdraw_event_dialog.dart';

/// The full event page: hero, stat tiles, the action row, and the
/// Overview / Cars segmented content.
///
/// Shares [MapEventDetailBloc] with the map's popup — same data, same actions,
/// two presentations — so nothing about RSVP or participation is implemented
/// twice.
class MapEventDetailPage extends StatefulWidget {
  final String eventId;

  const MapEventDetailPage({super.key, required this.eventId});

  @override
  State<MapEventDetailPage> createState() => _MapEventDetailPageState();
}

class _MapEventDetailPageState extends State<MapEventDetailPage> {
  MapEventTab _tab = MapEventTab.overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocConsumer<MapEventDetailBloc, MapEventDetailState>(
        // Action failures are one-shot: a snackbar, then cleared, so they never
        // stack up or reappear on a later rebuild.
        listenWhen: (a, b) => a.actionError != b.actionError,
        listener: (context, state) {
          final error = state.actionError;
          if (error == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mapEventErrorMessage(l10n, error)),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context
              .read<MapEventDetailBloc>()
              .add(const ClearMapEventActionError());
        },
        builder: (context, state) {
          if (state.event == null) {
            return switch (state.status) {
              MapEventDetailStatus.failure => _DetailError(state: state),
              _ => const Center(child: CircularProgressIndicator()),
            };
          }
          return _DetailContent(
            state: state,
            tab: _tab,
            onTabChanged: (tab) => setState(() => _tab = tab),
          );
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final MapEventDetailState state;
  final MapEventTab tab;
  final ValueChanged<MapEventTab> onTabChanged;

  const _DetailContent({
    required this.state,
    required this.tab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final event = state.event!;

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () async =>
          context.read<MapEventDetailBloc>().add(const RefreshMapEvent()),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          MapEventHero(event: event),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MapEventStatRow(
                  tiles: [
                    MapEventStatTile(
                      icon: Icons.people_alt_rounded,
                      value: '${event.attendeesCount}',
                      label: l10n.mapEventsStatAttendees,
                    ),
                    MapEventStatTile(
                      icon: Icons.directions_car_rounded,
                      value: event.maxParticipantCapacity == null
                          ? '${event.attendingCarsCount}'
                          : '${event.attendingCarsCount}/'
                              '${event.maxParticipantCapacity}',
                      label: l10n.mapEventsStatCars,
                      // Orange when the viewer's own car is on the list — the
                      // design's way of saying "you're in this one".
                      isHighlighted: state.myAcceptedEntry != null,
                    ),
                    MapEventStatTile(
                      icon: Icons.schedule_rounded,
                      value: MapEventFormat.time(context, event.startsAt),
                      label: event.isLive
                          ? l10n.mapEventsStatStarted
                          : l10n.mapEventsStatStarts,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                MapEventRsvpButtons(
                  state: state,
                  onToggle: (status) => context
                      .read<MapEventDetailBloc>()
                      .add(ToggleMapEventRsvp(status)),
                ),
                if (event.viewer.canRegisterCars) ...[
                  const SizedBox(height: 8),
                  MapEventParticipationButtons(
                    state: state,
                    onRegister: () => _register(context),
                    onWithdraw: () => _withdraw(context),
                  ),
                  if (event.isAtCapacity && state.myAcceptedEntry == null) ...[
                    const SizedBox(height: 8),
                    _Notice(text: l10n.mapEventsCapacityFull),
                  ],
                ],
                // Organizers get their tools from here; everyone else never
                // sees the row.
                if (event.viewer.isOrganizer) ...[
                  const SizedBox(height: 8),
                  _ManageButton(eventId: event.id),
                ],
                const SizedBox(height: 14),
                MapEventTabs(
                  active: tab,
                  onChanged: onTabChanged,
                  overviewLabel: l10n.mapEventsTabOverview,
                  carsLabel: l10n.mapEventsTabCars(event.attendingCarsCount),
                ),
                const SizedBox(height: 16),
                switch (tab) {
                  MapEventTab.overview => MapEventOverviewTab(
                      state: state,
                      onSeeAllCars: () => onTabChanged(MapEventTab.cars),
                    ),
                  MapEventTab.cars => MapEventCarsTab(state: state),
                },
                SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _register(BuildContext context) async {
    final bloc = context.read<MapEventDetailBloc>();
    final carId = await showEventCarPickerSheet(context);
    if (carId != null) bloc.add(RegisterCarForEvent(carId));
  }

  Future<void> _withdraw(BuildContext context) async {
    final bloc = context.read<MapEventDetailBloc>();
    // `POST /withdraw` takes out every car at once, so the dialog counts the
    // ones actually at stake — accepted and pending alike.
    final note = await showWithdrawEventDialog(
      context,
      carCount: state.withdrawableCarCount,
    );
    if (note != null) {
      bloc.add(SubmitEventWithdrawal(note.isEmpty ? null : note));
    }
  }
}

class _ManageButton extends StatelessWidget {
  final String eventId;

  const _ManageButton({required this.eventId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<MapEventDetailBloc>();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () async {
          await context.push(
            '/map-events/$eventId/manage',
            extra: bloc.state.event,
          );
          // Reviewing entries or removing an organizer changes what this page
          // shows, and the manage page has its own bloc — so refresh on return
          // rather than trying to keep the two in sync live.
          bloc.add(const RefreshMapEvent());
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.tune_rounded,
                size: 16,
                color: AppColors.ink,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.mapEventsManageTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;

  const _Notice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.mute),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, color: AppColors.mute),
          ),
        ),
      ],
    );
  }
}

class _DetailError extends StatelessWidget {
  final MapEventDetailState state;

  const _DetailError({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = state.error ?? const MapEventError(MapEventErrorCode.generic);
    final canRetry = error.code != MapEventErrorCode.notFound;

    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 12,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.chevron_left_rounded),
              color: AppColors.ink,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 34,
                    color: AppColors.muteSoft,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    mapEventErrorMessage(l10n, error),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      color: AppColors.ink2,
                    ),
                  ),
                  if (canRetry) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context
                          .read<MapEventDetailBloc>()
                          .add(const RefreshMapEvent()),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      child: Text(l10n.mapEventsRetry),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
