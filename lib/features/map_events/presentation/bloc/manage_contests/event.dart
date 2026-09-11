import 'package:equatable/equatable.dart';

import '../../../domain/entities/contest_board_update.dart';
import '../../../domain/entities/contest_enums.dart';

sealed class ManageContestsEvent extends Equatable {
  const ManageContestsEvent();

  @override
  List<Object?> get props => [];
}

class LoadManagedContests extends ManageContestsEvent {
  final String eventId;

  const LoadManagedContests(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class RefreshManagedContests extends ManageContestsEvent {
  const RefreshManagedContests();
}

/// Closes voting now. The result banner comes from the response.
class FinishManagedContest extends ManageContestsEvent {
  final String contestId;

  const FinishManagedContest(this.contestId);

  @override
  List<Object?> get props => [contestId];
}

/// `POST …/open` on a scheduled contest — the only way voting starts.
class OpenManagedContestNow extends ManageContestsEvent {
  final String contestId;

  const OpenManagedContestNow(this.contestId);

  @override
  List<Object?> get props => [contestId];
}

/// `PATCH closes_at` — moves the *planned* end shown to attendees. Voting
/// still runs until [FinishManagedContest].
class ExtendManagedContest extends ManageContestsEvent {
  final String contestId;
  final DateTime closesAt;

  const ExtendManagedContest(this.contestId, this.closesAt);

  @override
  List<Object?> get props => [contestId, closesAt];
}

class DecideManagedEntry extends ManageContestsEvent {
  final String contestId;
  final String carId;
  final ContestEntryStatus status;
  final String? reason;

  const DecideManagedEntry({
    required this.contestId,
    required this.carId,
    required this.status,
    this.reason,
  });

  @override
  List<Object?> get props => [contestId, carId, status, reason];
}

class DeleteManagedContest extends ManageContestsEvent {
  final String contestId;

  const DeleteManagedContest(this.contestId);

  @override
  List<Object?> get props => [contestId];
}

class ManagedContestBoardReceived extends ManageContestsEvent {
  final ContestBoardUpdate board;

  const ManagedContestBoardReceived(this.board);

  @override
  List<Object?> get props => [board];
}

class ManagedContestStatusReceived extends ManageContestsEvent {
  final ContestStatusUpdate update;

  const ManagedContestStatusReceived(this.update);

  @override
  List<Object?> get props => [update];
}

class DismissFinishedBanner extends ManageContestsEvent {
  const DismissFinishedBanner();
}

class ClearManageContestsError extends ManageContestsEvent {
  const ClearManageContestsError();
}
