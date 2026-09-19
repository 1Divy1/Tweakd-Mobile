import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../../../core/shared/layout/app_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/map_search/bloc.dart';
import '../bloc/map_search/event.dart';
import '../bloc/map_search/state.dart';
import '../widgets/search/map_search_businesses_tab.dart';
import '../widgets/search/map_search_events_tab.dart';
import '../widgets/search/map_search_field_bar.dart';

/// Search over the whole map: events and businesses, each in its own tab.
///
/// Pushed over the map rather than drawn inside it, so the map underneath is
/// never torn down (Mapbox bills per map load). Tapping a result pops back
/// with a [MapSearchSelection]; the map flies to it and opens its popup.
class MapSearchPage extends StatefulWidget {
  const MapSearchPage({super.key});

  @override
  State<MapSearchPage> createState() => _MapSearchPageState();
}

class _MapSearchPageState extends State<MapSearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<MapSearchBloc>();

    return DefaultTabController(
      length: MapSearchKind.values.length,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 16, 8) +
                    AppLayout.inset(context, maxWidth: AppLayout.formWidth),
                child: MapSearchFieldBar(
                  controller: _controller,
                  onChanged: (value) => bloc.add(MapSearchQueryChanged(value)),
                  onClear: () {
                    _controller.clear();
                    bloc.add(const MapSearchCleared());
                  },
                ),
              ),
              Padding(
                padding: AppLayout.inset(context),
                child: TabBar(
                  labelColor: AppColors.ink,
                  unselectedLabelColor: AppColors.mute,
                  indicatorColor: AppColors.accent,
                  dividerColor: AppColors.line,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  tabs: [
                    Tab(text: l10n.mapSearchTabEvents),
                    Tab(text: l10n.mapSearchTabBusinesses),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<MapSearchBloc, MapSearchState>(
                  builder: (context, state) => TabBarView(
                    children: [
                      MapSearchEventsTab(state: state),
                      MapSearchBusinessesTab(state: state),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
