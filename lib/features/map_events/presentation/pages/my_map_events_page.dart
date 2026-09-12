import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/my_events/my_map_events_list.dart';

/// The standalone "My events" page.
///
/// The primary home for this list is the Events tab on the user's own profile;
/// this page is the deep-linkable version of the same list, reachable from the
/// create flow's confirmation and from anywhere that needs a full screen.
class MyMapEventsPage extends StatelessWidget {
  const MyMapEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.ink,
        ),
        title: Text(
          l10n.mapEventsMineTitle,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/map-events/create'),
            icon: const Icon(Icons.add_rounded),
            color: AppColors.accent,
            tooltip: l10n.mapCreateEvent,
          ),
        ],
      ),
      body: const MyMapEventsList(),
    );
  }
}
