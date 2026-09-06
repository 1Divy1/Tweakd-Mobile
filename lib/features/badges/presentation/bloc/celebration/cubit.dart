import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/user_badge.dart';
import '../../../domain/usecases/mark_badge_celebrated.dart';
import 'state.dart';

/// App-level queue of badge unlock animations still owed to the viewer.
///
/// Provided once at the app root (see `main.dart`) and read by
/// `BadgeCelebrationOverlay`, which sits above the router so a celebration can
/// play over whatever page the user is on. The queue is fed by the feed page
/// from `FeedLoaded.pendingBadgeCelebrations` — the launch payload — so there
/// is no request of its own on start.
///
/// A singleton, not a factory: it has to outlive every page and keep its
/// "already shown this run" set intact across navigation.
@lazySingleton
class BadgeCelebrationCubit extends Cubit<BadgeCelebrationState> {
  final MarkBadgeCelebratedUseCase _markCelebrated;

  /// Badge ids already enqueued in this app run. Guards against the same
  /// unlock being re-queued when the feed is refreshed before the backend
  /// acknowledgement lands.
  final Set<String> _seen = {};

  BadgeCelebrationCubit(this._markCelebrated)
    : super(const BadgeCelebrationState.empty());

  /// Adds any not-yet-seen badges to the tail of the queue.
  void enqueue(List<UserBadgeEntity> badges) {
    final fresh = badges.where((b) => _seen.add(b.badge.id)).toList();
    if (fresh.isEmpty) return;
    emit(BadgeCelebrationState([...state.queue, ...fresh]));
  }

  /// The animation for [BadgeCelebrationState.current] has finished. Tell the
  /// backend (fire-and-forget — the endpoint is idempotent and a failure just
  /// means it replays next launch) and advance the queue.
  void dismissCurrent() {
    final current = state.current;
    if (current == null) return;
    unawaited(_markCelebrated(MarkBadgeCelebratedParams(current.badge.id)));
    emit(BadgeCelebrationState(state.queue.skip(1).toList()));
  }

  /// Drops everything on sign-out, so a badge the previous user just earned
  /// cannot animate for whoever signs in next.
  void reset() {
    _seen.clear();
    emit(const BadgeCelebrationState.empty());
  }
}
