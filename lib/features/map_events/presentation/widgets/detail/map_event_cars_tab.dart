import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/event_detail/bloc.dart';
import '../../bloc/event_detail/event.dart';
import '../../bloc/event_detail/state.dart';
import '../shared/event_car_picker_sheet.dart';
import '../shared/map_event_car_card.dart';
import '../shared/map_event_participation_strip.dart';

/// The Cars tab: the viewer's own entry status (if there's anything to say)
/// above the public entry list.
///
/// The list is `?status=accepted` only — the design's "N APPROVED" header means
/// exactly that, and the unfiltered endpoint would fold in withdrawn rows.
class MapEventCarsTab extends StatelessWidget {
  final MapEventDetailState state;

  const MapEventCarsTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final event = state.event!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapEventParticipationStrip(
          state: state,
          onTryAnotherCar: () => _register(context),
          onCancelRequest: (carId) => context
              .read<MapEventDetailBloc>()
              .add(CancelPendingCarRegistration(carId)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l10n.mapEventsEntryListTitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            Text(
              l10n.mapEventsApprovedCount(event.attendingCarsCount),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: AppColors.mute,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.isLoadingCars && state.cars.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.cars.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  size: 28,
                  color: AppColors.muteSoft,
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.mapEventsEntryListEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.mute,
                  ),
                ),
              ],
            ),
          )
        else ...[
          for (final participant in state.cars) ...[
            MapEventCarCard(participant: participant),
            const SizedBox(height: 12),
          ],
          if (state.hasMoreCars)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Center(
                child: state.isLoadingMoreCars
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: () => context
                            .read<MapEventDetailBloc>()
                            .add(const LoadMoreEventCars()),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        child: Text(l10n.mapEventsSeeAll),
                      ),
              ),
            ),
        ],
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
