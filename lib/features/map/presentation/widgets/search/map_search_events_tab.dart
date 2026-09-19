import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../../../../core/shared/layout/app_layout.dart';
import '../../bloc/map_search/bloc.dart';
import '../../bloc/map_search/event.dart';
import '../../bloc/map_search/state.dart';
import '../../utils/map_search_selection.dart';
import 'map_search_event_tile.dart';
import 'map_search_paged_list.dart';
import 'map_search_status_chips.dart';

/// The Events tab: the Live / Upcoming / Past chips over the paged results.
/// Tapping a result pops the search screen with it.
class MapSearchEventsTab extends StatelessWidget {
  final MapSearchState state;

  const MapSearchEventsTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<MapSearchBloc>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4) +
              AppLayout.inset(context),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: MapSearchStatusChips(
              selected: state.statuses,
              onToggle: (status) => bloc.add(MapSearchStatusToggled(status)),
            ),
          ),
        ),
        Expanded(
          child: MapSearchPagedList(
            section: state.events,
            hasQuery: state.hasQuery,
            emptyMessage: l10n.mapSearchNoEvents(state.query),
            onLoadMore: () =>
                bloc.add(const MapSearchMoreRequested(MapSearchKind.events)),
            onRetry: () => bloc.add(const MapSearchRetried(MapSearchKind.events)),
            itemBuilder: (context, event) => MapSearchEventTile(
              event: event,
              onTap: () => context.pop(MapSearchEventSelection(event)),
            ),
          ),
        ),
      ],
    );
  }
}
