import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_badge.dart';

/// The badges still waiting for their one-time unlock animation.
///
/// [queue] is played front to back (oldest unlock first, matching the
/// backend's order); [current] is whichever is on screen now. Empty means the
/// overlay draws nothing.
class BadgeCelebrationState extends Equatable {
  final List<UserBadgeEntity> queue;

  const BadgeCelebrationState(this.queue);

  const BadgeCelebrationState.empty() : queue = const [];

  UserBadgeEntity? get current => queue.isEmpty ? null : queue.first;

  bool get isShowing => queue.isNotEmpty;

  @override
  List<Object?> get props => [queue];
}
