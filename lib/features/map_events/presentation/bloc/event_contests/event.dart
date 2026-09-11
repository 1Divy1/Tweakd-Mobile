import 'package:equatable/equatable.dart';

import '../../../domain/entities/contest.dart';
import '../../../domain/entities/contest_board_update.dart';

sealed class EventContestsEvent extends Equatable {
  const EventContestsEvent();

  @override
  List<Object?> get props => [];
}

class LoadEventContests extends EventContestsEvent {
  final String eventId;

  const LoadEventContests(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// Silent re-read: keeps what's on screen on failure.
class RefreshEventContests extends EventContestsEvent {
  const RefreshEventContests();
}

/// A live board landed on the event's topic.
class EventContestBoardReceived extends EventContestsEvent {
  final ContestBoardUpdate board;

  const EventContestBoardReceived(this.board);

  @override
  List<Object?> get props => [board];
}

/// A contest opened / finished / moved its window: re-read that one.
class EventContestStatusReceived extends EventContestsEvent {
  final ContestStatusUpdate update;

  const EventContestStatusReceived(this.update);

  @override
  List<Object?> get props => [update];
}

/// Another screen (the contest page, the organizer console) got a fresh copy
/// of a contest back from a write — merge it so the tab agrees without a read.
class EventContestUpdated extends EventContestsEvent {
  final ContestEntity contest;

  const EventContestUpdated(this.contest);

  @override
  List<Object?> get props => [contest];
}

/// The enter-your-car sheet's result: which contests to ask into and which to
/// pull [carId] out of. Each is its own request; they run in parallel.
class SaveContestEntries extends EventContestsEvent {
  final String carId;
  final Set<String> enterContestIds;
  final Set<String> leaveContestIds;

  const SaveContestEntries({
    required this.carId,
    required this.enterContestIds,
    required this.leaveContestIds,
  });

  @override
  List<Object?> get props => [carId, enterContestIds, leaveContestIds];
}

class ClearEventContestsError extends EventContestsEvent {
  const ClearEventContestsError();
}
