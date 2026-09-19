import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../bloc/map_search/bloc.dart';
import '../../bloc/map_search/event.dart';
import '../../bloc/map_search/state.dart';
import '../../utils/map_search_selection.dart';
import 'map_search_business_tile.dart';
import 'map_search_paged_list.dart';

/// The Businesses tab: the paged results. Tapping one pops the search screen
/// with it.
class MapSearchBusinessesTab extends StatelessWidget {
  final MapSearchState state;

  const MapSearchBusinessesTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<MapSearchBloc>();

    return MapSearchPagedList(
      section: state.businesses,
      hasQuery: state.hasQuery,
      emptyMessage: l10n.mapSearchNoBusinesses(state.query),
      onLoadMore: () =>
          bloc.add(const MapSearchMoreRequested(MapSearchKind.businesses)),
      onRetry: () => bloc.add(const MapSearchRetried(MapSearchKind.businesses)),
      itemBuilder: (context, business) => MapSearchBusinessTile(
        business: business,
        onTap: () => context.pop(MapSearchBusinessSelection(business)),
      ),
    );
  }
}
