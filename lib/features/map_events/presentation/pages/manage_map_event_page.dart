import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/map_event.dart';
import '../bloc/manage_event/bloc.dart';
import '../bloc/manage_event/event.dart';
import '../bloc/manage_event/state.dart';
import '../utils/map_event_error_mapper.dart';
import '../widgets/manage/manage_event_sections.dart';
import '../widgets/shared/map_event_chips.dart';

/// The organizer's console: entry requests, withdrawal requests, the organizer
/// list, and the event's lifecycle actions.
///
/// Only reachable from the detail page's organizer-gated button — every read on
/// this screen is a 403 for anyone else.
class ManageMapEventPage extends StatelessWidget {
  final String eventId;

  /// Passed through `extra` so the header has a title before the fetch lands.
  final MapEventEntity? event;

  const ManageMapEventPage({
    super.key,
    required this.eventId,
    this.event,
  });

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
          l10n.mapEventsManageTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ManageMapEventBloc, ManageMapEventState>(
        listener: (context, state) {
          final error = state.actionError;
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(mapEventErrorMessage(l10n, error)),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context
                .read<ManageMapEventBloc>()
                .add(const ClearManageEventError());
          }
          // The event is gone; there's nothing left for this page to manage.
          if (state.isDeleted) context.pop();
        },
        builder: (context, state) {
          if (state.status == ManageMapEventStatus.loading &&
              state.event == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ManageMapEventStatus.failure) {
            final error =
                state.error ?? const MapEventError(MapEventErrorCode.generic);
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mapEventErrorMessage(l10n, error),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppColors.ink2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context
                          .read<ManageMapEventBloc>()
                          .add(LoadMapEventManagement(eventId)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                      ),
                      child: Text(l10n.mapEventsRetry),
                    ),
                  ],
                ),
              ),
            );
          }

          final managed = state.event ?? event;

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async => context
                .read<ManageMapEventBloc>()
                .add(const RefreshMapEventManagement()),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.paddingOf(context).bottom + 28,
              ),
              children: [
                if (managed != null) ...[
                  _EventSummary(event: managed),
                  const SizedBox(height: 22),
                ],
                ManageEntriesSection(state: state),
                const SizedBox(height: 22),
                ManageWithdrawalsSection(state: state),
                const SizedBox(height: 22),
                if (managed != null) ...[
                  ManageOrganizersSection(state: state, event: managed),
                  const SizedBox(height: 22),
                  ManageLifecycleSection(state: state, event: managed),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EventSummary extends StatelessWidget {
  final MapEventEntity event;

  const _EventSummary({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              MapEventStatusChip(status: event.status),
              const SizedBox(width: 8),
              MapEventApprovalChip(approval: event.approvalStatus),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            event.locationName,
            style: const TextStyle(fontSize: 13, color: AppColors.mute),
          ),
        ],
      ),
    );
  }
}
