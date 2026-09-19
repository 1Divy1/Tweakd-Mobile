import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/map_events/presentation/bloc/event_detail/bloc.dart';
import 'package:tweakd/features/map_events/presentation/bloc/event_detail/event.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/map_defaults.dart';
import '../bloc/map/bloc.dart';
import '../bloc/map/event.dart';
import '../utils/map_search_selection.dart';
import '../utils/route_uncovered.dart';

/// The bar across the top of the map: the search pill and the orange **+**.
///
/// The pill is not a text field. It opens the search screen (`/map/search`),
/// which is pushed over the map so the map stays mounted. When that screen
/// pops with a result, the map flies to it and opens its popup. An event
/// result also starts loading into `MapEventDetailBloc`, exactly as a tapped
/// pin does.
///
/// The **+** opens the create-event flow, which is the map's only entry point
/// to it.
class MapTopBar extends StatelessWidget {
  const MapTopBar({super.key});

  Future<void> _openSearch(BuildContext context) async {
    final mapBloc = context.read<MapBloc>();
    final detailBloc = context.read<MapEventDetailBloc>();
    // Results rank nearest to where the map last loaded pins. That can be up to
    // the refetch distance away from the live camera centre, which is close
    // enough for ordering.
    final centre = mapBloc.state.fetchCentre ?? kMapFallbackCentre;
    // Captured before the await: the map's own route, which the search page
    // is about to cover.
    final mapRoute = ModalRoute.of(context);

    final selection = await context.push<MapSearchSelection>(
      '/map/search',
      extra: centre,
    );
    if (selection == null || mapBloc.isClosed) return;

    // The result arrives while the search page is still sliding away. A camera
    // flight started now is dropped on iOS (see routeUncovered), so wait until
    // the map is back on screen.
    await routeUncovered(mapRoute);
    if (mapBloc.isClosed) return;

    switch (selection) {
      case MapSearchBusinessSelection(:final pin):
        mapBloc.add(MapSearchBusinessChosen(pin));
      case MapSearchEventSelection(:final pin):
        mapBloc.add(MapSearchEventChosen(pin));
        if (!detailBloc.isClosed) detailBloc.add(LoadMapEvent(pin.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: l10n.mapSearchOpen,
            excludeSemantics: true,
            // The shadow sits behind the Material, not inside the InkWell: a
            // shadow painted over the fill would grey the pill's interior.
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowAlpha(0x14),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  onTap: () => _openSearch(context),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: AppColors.muteSoft,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            l10n.mapSearchPlaceholder,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.muteSoft,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          button: true,
          label: l10n.mapCreateEvent,
          child: Material(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: () => context.push('/map-events/create'),
              borderRadius: BorderRadius.circular(15),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.add_rounded, size: 24, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
