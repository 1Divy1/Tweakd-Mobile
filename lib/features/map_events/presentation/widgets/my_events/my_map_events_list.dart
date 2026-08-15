import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/my_events/bloc.dart';
import '../../bloc/my_events/event.dart';
import '../../bloc/my_events/state.dart';
import '../../utils/map_event_error_mapper.dart';
import 'my_map_event_card.dart';

/// The body of "My events", shared by the standalone page and the profile's
/// Events tab.
///
/// [isEmbedded] drops the scroll view and pull-to-refresh so the profile page's
/// own scroll owns the gesture — a nested scrollable inside a tab makes the
/// whole page feel broken.
class MyMapEventsList extends StatelessWidget {
  final bool isEmbedded;

  const MyMapEventsList({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyMapEventsBloc, MyMapEventsState>(
      builder: (context, state) {
        return switch (state) {
          MyMapEventsInitial() || MyMapEventsLoading() => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
          MyMapEventsError(:final error) => _ErrorView(error: error),
          MyMapEventsLoaded(:final events) when events.isEmpty =>
            const _EmptyView(),
          MyMapEventsLoaded() => _List(state: state, isEmbedded: isEmbedded),
        };
      },
    );
  }
}

class _List extends StatelessWidget {
  final MyMapEventsLoaded state;
  final bool isEmbedded;

  const _List({required this.state, required this.isEmbedded});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = <Widget>[
      for (final event in state.events) ...[
        MyMapEventCard(event: event),
        const SizedBox(height: 12),
      ],
      if (state.hasMore)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: state.isLoadingMore
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: () => context
                        .read<MyMapEventsBloc>()
                        .add(const LoadMoreMyMapEvents()),
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
    ];

    if (isEmbedded) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items,
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () async =>
          context.read<MyMapEventsBloc>().add(const RefreshMyMapEvents()),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: items,
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_outlined,
            size: 34,
            color: AppColors.muteSoft,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.mapEventsMineEmptyTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.mapEventsMineEmptyBody,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: AppColors.ink2,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => context.push('/map-events/create'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            child: Text(l10n.mapEventsMineCreate),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final MapEventError error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 30,
            color: AppColors.muteSoft,
          ),
          const SizedBox(height: 12),
          Text(
            mapEventErrorMessage(l10n, error),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.ink2),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                context.read<MyMapEventsBloc>().add(const LoadMyMapEvents()),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: Text(l10n.mapEventsRetry),
          ),
        ],
      ),
    );
  }
}
