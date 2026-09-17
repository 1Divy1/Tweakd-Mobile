import 'dart:async';

import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/contest.dart';
import '../../domain/entities/contest_enums.dart';
import '../../domain/entities/map_event.dart';
import '../bloc/manage_contests/bloc.dart';
import '../bloc/manage_contests/event.dart';
import '../bloc/manage_contests/state.dart';
import '../utils/map_event_error_mapper.dart';
import '../widgets/contests/org_contest_card.dart';
import '../widgets/contests/organizer_sheets.dart';
import '../widgets/shared/map_event_chips.dart';
import '../../../../core/shared/layout/app_layout.dart';

/// The organizer's contests console for one event.
class OrganizerContestsPage extends StatefulWidget {
  final MapEventEntity event;

  const OrganizerContestsPage({super.key, required this.event});

  @override
  State<OrganizerContestsPage> createState() => _OrganizerContestsPageState();
}

class _OrganizerContestsPageState extends State<OrganizerContestsPage> {
  Timer? _clock;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final event = widget.event;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocConsumer<ManageContestsBloc, ManageContestsState>(
        listenWhen: (a, b) => a.actionError != b.actionError,
        listener: (context, state) {
          final error = state.actionError;
          if (error == null) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(mapEventErrorMessage(l10n, error)),
            behavior: SnackBarBehavior.floating,
          ));
          context.read<ManageContestsBloc>().add(const ClearManageContestsError());
        },
        builder: (context, state) {
          return Column(
            children: [
              _Header(
                event: event,
                onCreate: () => _create(context),
              ),
              Expanded(
                child: switch (state.status) {
                  ManageContestsStatus.initial ||
                  ManageContestsStatus.loading =>
                    const Center(child: CircularProgressIndicator()),
                  ManageContestsStatus.failure => _Error(state: state),
                  ManageContestsStatus.loaded => RefreshIndicator(
                      color: AppColors.accent,
                      onRefresh: () async => context
                          .read<ManageContestsBloc>()
                          .add(const RefreshManagedContests()),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          4,
                          16,
                          MediaQuery.paddingOf(context).bottom + 28,
                        ) + AppLayout.inset(context),
                        children: [
                          if (state.justFinished != null) ...[
                            _FinishedBanner(
                              contest: state.justFinished!,
                              onDismiss: () => context
                                  .read<ManageContestsBloc>()
                                  .add(const DismissFinishedBanner()),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _Stats(state: state),
                          const SizedBox(height: 20),
                          if (state.contests.isEmpty)
                            _EmptyCard(text: l10n.contestsOrganizerEmpty),
                          _Group(
                            label: l10n.contestsRunningNow,
                            contests: state.open,
                            state: state,
                            now: _now,
                            event: event,
                          ),
                          _Group(
                            label: l10n.contestsScheduled,
                            contests: state.scheduled,
                            state: state,
                            now: _now,
                            event: event,
                          ),
                          _Group(
                            label: l10n.contestsFinished,
                            contests: state.finished,
                            state: state,
                            now: _now,
                            event: event,
                          ),
                          const SizedBox(height: 4),
                          Material(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () => _create(context),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_rounded, size: 18, color: AppColors.accent),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        state.contests.isEmpty
                                            ? l10n.contestsAddFirst
                                            : l10n.contestsAddAnother,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final bloc = context.read<ManageContestsBloc>();
    await context.push('/map-events/${widget.event.id}/manage/contests/new', extra: widget.event);
    bloc.add(const RefreshManagedContests());
  }
}

class _Group extends StatelessWidget {
  final String label;
  final List<ContestEntity> contests;
  final ManageContestsState state;
  final DateTime now;
  final MapEventEntity event;

  const _Group({
    required this.label,
    required this.contests,
    required this.state,
    required this.now,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    if (contests.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapEventSectionLabel(label: label),
        const SizedBox(height: 10),
        for (final c in contests) ...[
          OrgContestCard(
            contest: c,
            now: now,
            isBusy: state.busyContestId == c.id,
            onOpen: () => context.push(
              '/map-events/${event.id}/contests/${c.id}',
              extra: {'contest': c, 'eventTitle': event.title},
            ),
            onFinish: () => _finish(context, c),
            onOpenNow: () => context.read<ManageContestsBloc>().add(OpenManagedContestNow(c.id)),
            onExtend: () => _extend(context, c),
            onEdit: () => _edit(context, c),
            onDelete: () => _delete(context, c),
            onAccept: (carId) => context.read<ManageContestsBloc>().add(DecideManagedEntry(
                  contestId: c.id,
                  carId: carId,
                  status: ContestEntryStatus.accepted,
                )),
            onDecline: (carId) => _decline(context, c, carId),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _finish(BuildContext context, ContestEntity contest) async {
    final bloc = context.read<ManageContestsBloc>();
    if (await showFinishContestSheet(context, contest: contest, now: now)) {
      bloc.add(FinishManagedContest(contest.id));
    }
  }

  Future<void> _extend(BuildContext context, ContestEntity contest) async {
    final bloc = context.read<ManageContestsBloc>();
    final closesAt = await showExtendContestSheet(context, contest: contest);
    if (closesAt != null) bloc.add(ExtendManagedContest(contest.id, closesAt));
  }

  Future<void> _edit(BuildContext context, ContestEntity contest) async {
    final bloc = context.read<ManageContestsBloc>();
    await context.push(
      '/map-events/${event.id}/manage/contests/${contest.id}/edit',
      extra: {'event': event, 'contest': contest},
    );
    bloc.add(const RefreshManagedContests());
  }

  Future<void> _delete(BuildContext context, ContestEntity contest) async {
    final bloc = context.read<ManageContestsBloc>();
    if (await showDeleteContestDialog(context)) {
      bloc.add(DeleteManagedContest(contest.id));
    }
  }

  Future<void> _decline(BuildContext context, ContestEntity contest, String carId) async {
    final bloc = context.read<ManageContestsBloc>();
    final reason = await showDeclineContestEntryDialog(context);
    if (reason != null) {
      bloc.add(DecideManagedEntry(
        contestId: contest.id,
        carId: carId,
        status: ContestEntryStatus.rejected,
        reason: reason,
      ));
    }
  }
}

class _Header extends StatelessWidget {
  final MapEventEntity event;
  final VoidCallback onCreate;

  const _Header({required this.event, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.chevron_left_rounded),
                color: AppColors.ink,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.contestsOrganizerTitle,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink),
                    ),
                    Text(
                      l10n.contestsOrganizerSubtitle(event.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: AppColors.mute),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onCreate,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.7),
                ),
                child: Text(l10n.contestsNew),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  final ManageContestsState state;

  const _Stats({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tiles = [
      ('${state.open.length}', l10n.contestsStatRunning, state.open.isNotEmpty),
      ('${state.scheduled.length}', l10n.contestsStatScheduled, false),
      ('${state.totalVotes}', l10n.contestsStatVotesTonight, false),
    ];
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tiles[i].$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: tiles[i].$3 ? AppColors.accent : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tiles[i].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: AppColors.mute,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FinishedBanner extends StatelessWidget {
  final ContestEntity contest;
  final VoidCallback onDismiss;

  const _FinishedBanner({required this.contest, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 8, 13),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.inkPanel.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.accent),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.contestsFinishedBanner(contest.title),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.inkPanel),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.contestsFinishedBannerBody,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: AppColors.inkPanel.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded, size: 14),
            color: AppColors.inkPanel,
            style: IconButton.styleFrom(backgroundColor: AppColors.inkPanel.withValues(alpha: 0.12)),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;

  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.mute),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final ManageContestsState state;

  const _Error({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = state.error ?? const MapEventError(MapEventErrorCode.generic);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mapEventErrorMessage(l10n, error),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.5, height: 1.4, color: AppColors.ink2),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<ManageContestsBloc>().add(const RefreshManagedContests()),
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
              child: Text(l10n.mapEventsRetry),
            ),
          ],
        ),
      ),
    );
  }
}
