import 'package:equatable/equatable.dart';

import 'contest_enums.dart';

/// One row of a live board: a car's current count and when it last moved.
class ContestBoardRow extends Equatable {
  final int votesCount;
  final DateTime? lastVoteAt;

  const ContestBoardRow({required this.votesCount, required this.lastVoteAt});

  @override
  List<Object?> get props => [votesCount, lastVoteAt];
}

/// A `board` message off the event's realtime topic: the tallies of one
/// contest, car ids and counts only. Never a voter.
class ContestBoardUpdate extends Equatable {
  final String contestId;
  final ContestStatus status;
  final int votesCount;
  final Map<String, ContestBoardRow> entries;
  final DateTime? sentAt;

  const ContestBoardUpdate({
    required this.contestId,
    required this.status,
    required this.votesCount,
    required this.entries,
    required this.sentAt,
  });

  @override
  List<Object?> get props => [contestId, status, votesCount, entries, sentAt];
}

/// A `status` message: a contest opened, finished, or had its window changed.
/// The client re-reads that contest rather than trusting a partial payload.
class ContestStatusUpdate extends Equatable {
  final String contestId;
  final ContestStatus status;

  const ContestStatusUpdate({required this.contestId, required this.status});

  @override
  List<Object?> get props => [contestId, status];
}
