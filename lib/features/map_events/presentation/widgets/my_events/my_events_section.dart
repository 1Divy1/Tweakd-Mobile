import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/my_events/bloc.dart';
import '../../bloc/my_events/event.dart';
import '../../bloc/my_events/state.dart';
import 'my_map_events_list.dart';

/// The Events tab on your own profile.
///
/// Loads lazily, the same way the Tags tab does: the bloc is provided by the
/// route with no event dispatched, and the first visit to the tab is what
/// triggers the fetch. A profile visit shouldn't pay for a list the user may
/// never open.
class MyEventsSection extends StatefulWidget {
  const MyEventsSection({super.key});

  @override
  State<MyEventsSection> createState() => _MyEventsSectionState();
}

class _MyEventsSectionState extends State<MyEventsSection> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<MyMapEventsBloc>();
    if (bloc.state is MyMapEventsInitial) {
      bloc.add(const LoadMyMapEvents());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Embedded: the profile page owns the scroll, so the list renders as a
    // plain column instead of nesting a second scrollable.
    return const MyMapEventsList(isEmbedded: true);
  }
}
