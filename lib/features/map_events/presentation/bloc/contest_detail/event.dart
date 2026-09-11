import 'package:equatable/equatable.dart';

import '../../../domain/entities/contest.dart';
import '../../../domain/entities/contest_board_update.dart';

sealed class ContestDetailEvent extends Equatable {
  const ContestDetailEvent();

  @override
  List<Object?> get props => [];
}

/// [initial] is the copy the tab already had, so the page paints at once and
/// the read only refreshes it.
class LoadContest extends ContestDetailEvent {
  final String eventId;
  final String contestId;
  final ContestEntity? initial;

  const LoadContest({
    required this.eventId,
    required this.contestId,
    this.initial,
  });

  @override
  List<Object?> get props => [eventId, contestId, initial];
}

class RefreshContest extends ContestDetailEvent {
  const RefreshContest();
}

/// Cast or change the viewer's vote. Optimistic: the board moves at once and
/// the server's copy replaces it; a failure rolls back and explains.
class CastVote extends ContestDetailEvent {
  final String carId;

  const CastVote(this.carId);

  @override
  List<Object?> get props => [carId];
}

class ContestBoardReceived extends ContestDetailEvent {
  final ContestBoardUpdate board;

  const ContestBoardReceived(this.board);

  @override
  List<Object?> get props => [board];
}

class ContestStatusReceived extends ContestDetailEvent {
  final ContestStatusUpdate update;

  const ContestStatusReceived(this.update);

  @override
  List<Object?> get props => [update];
}

class ClearContestActionError extends ContestDetailEvent {
  const ClearContestActionError();
}
