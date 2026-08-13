import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/map_event_attendee.dart';
import '../../domain/entities/map_event_enums.dart';
import '../bloc/attendees/bloc.dart';
import '../bloc/attendees/event.dart';
import '../bloc/attendees/state.dart';
import '../utils/map_event_error_mapper.dart';

/// "See all attendees": the two RSVP lists, each cursor-paginated.
class MapEventAttendeesPage extends StatefulWidget {
  const MapEventAttendeesPage({super.key});

  @override
  State<MapEventAttendeesPage> createState() => _MapEventAttendeesPageState();
}

class _MapEventAttendeesPageState extends State<MapEventAttendeesPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Loads the next page while the user is still 400px from the bottom, so the
  /// list rarely stops under a finger that's still scrolling.
  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      context
          .read<MapEventAttendeesBloc>()
          .add(const LoadMoreMapEventAttendees());
    }
  }

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
          l10n.mapEventsAttendeesPageTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<MapEventAttendeesBloc, MapEventAttendeesState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: _FilterTabs(state: state),
              ),
              Expanded(child: _Body(state: state, controller: _scroll)),
            ],
          );
        },
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final MapEventAttendeesState state;

  const _FilterTabs({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<MapEventAttendeesBloc>();

    Widget tab(MapEventAttendance status, String label) {
      final isActive = state.filter == status;
      return Expanded(
        child: Material(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: () => bloc.add(ChangeAttendeeFilter(status)),
            borderRadius: BorderRadius.circular(13),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isActive ? AppColors.ink : AppColors.mute,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.line2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          tab(MapEventAttendance.attending, l10n.mapEventsFilterAttending),
          tab(MapEventAttendance.interested, l10n.mapEventsFilterInterested),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final MapEventAttendeesState state;
  final ScrollController controller;

  const _Body({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.status == MapEventAttendeesStatus.loading &&
        state.attendees.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == MapEventAttendeesStatus.failure) {
      final error =
          state.error ?? const MapEventError(MapEventErrorCode.generic);
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            mapEventErrorMessage(l10n, error),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.ink2),
          ),
        ),
      );
    }

    if (state.attendees.isEmpty) {
      return Center(
        child: Text(
          l10n.mapEventsAttendeesEmpty,
          style: const TextStyle(fontSize: 14, color: AppColors.mute),
        ),
      );
    }

    return ListView.separated(
      controller: controller,
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.paddingOf(context).bottom + 20,
      ),
      itemCount: state.attendees.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= state.attendees.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return _AttendeeRow(attendee: state.attendees[index]);
      },
    );
  }
}

class _AttendeeRow extends StatelessWidget {
  final MapEventAttendeeEntity attendee;

  const _AttendeeRow({required this.attendee});

  @override
  Widget build(BuildContext context) {
    final url = attendee.avatarUrl;
    // The shared profile DTO only recently gained a display name, so a row
    // without one still has to read properly: the handle carries it alone.
    final name = attendee.name;
    final hasName = name != null && name.isNotEmpty;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push('/users/${attendee.username}', extra: attendee.id),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.accentSoft,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: (url == null || url.isEmpty)
                    ? Center(
                        child: Text(
                          attendee.username.isEmpty
                              ? '?'
                              : attendee.username.characters.first
                                  .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                      )
                    : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasName ? name : '@${attendee.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    if (hasName) ...[
                      const SizedBox(height: 2),
                      Text(
                        '@${attendee.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mute,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.muteSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
