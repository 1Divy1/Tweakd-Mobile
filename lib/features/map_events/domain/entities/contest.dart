import 'package:tweakd/features/garage/domain/entities/car_summary.dart';
import 'package:equatable/equatable.dart';

import 'contest_board_update.dart';
import 'contest_enums.dart';

/// A contest category — reference data behind the create screen's tile grid.
class ContestCategoryEntity extends Equatable {
  final String id;
  final String label;
  final ContestCategoryIcon icon;

  const ContestCategoryEntity({
    required this.id,
    required this.label,
    required this.icon,
  });

  bool get isCustom => id == 'custom';

  @override
  List<Object?> get props => [id, label, icon];
}

/// One car on the ballot. [rank] is the server's position at read time; the
/// bloc re-ranks locally when a live board lands (see [ContestEntity.applyBoard]).
class ContestEntryEntity extends Equatable {
  final CarSummaryEntity car;
  final int votesCount;
  final int rank;

  /// Frozen position once the contest is finished, else null.
  final int? finalRank;

  /// When the car most recently gained a vote — the tie-break. Null with no
  /// votes yet.
  final DateTime? lastVoteAt;

  const ContestEntryEntity({
    required this.car,
    required this.votesCount,
    required this.rank,
    required this.finalRank,
    required this.lastVoteAt,
  });

  /// A podium place only counts with at least one vote — the backend's rule,
  /// applied here so an empty contest never shows three trophies.
  bool get isOnPodium =>
      finalRank != null && finalRank! <= 3 && votesCount >= 1;

  ContestEntryEntity copyWith({
    int? votesCount,
    int? rank,
    DateTime? lastVoteAt,
    bool clearLastVoteAt = false,
  }) {
    return ContestEntryEntity(
      car: car,
      votesCount: votesCount ?? this.votesCount,
      rank: rank ?? this.rank,
      finalRank: finalRank,
      lastVoteAt: clearLastVoteAt ? null : (lastVoteAt ?? this.lastVoteAt),
    );
  }

  @override
  List<Object?> get props => [car, votesCount, rank, finalRank, lastVoteAt];
}

/// A car waiting for an organizer's decision. Organizers only.
class ContestPendingEntryEntity extends Equatable {
  final CarSummaryEntity car;
  final DateTime requestedAt;

  const ContestPendingEntryEntity({
    required this.car,
    required this.requestedAt,
  });

  @override
  List<Object?> get props => [car, requestedAt];
}

/// Where one of the viewer's own cars stands in a contest.
class MyContestEntryEntity extends Equatable {
  final String carId;
  final ContestEntryStatus status;
  final String? rejectionReason;

  const MyContestEntryEntity({
    required this.carId,
    required this.status,
    required this.rejectionReason,
  });

  @override
  List<Object?> get props => [carId, status, rejectionReason];
}

/// What *this* viewer may do with the contest, as the backend sees it.
class ContestViewerEntity extends Equatable {
  final bool isOrganizer;

  /// Whether a vote would be accepted right now: at the event (an `attending`
  /// RSVP or an accepted car in the line-up), voting open, event not over.
  /// Resolved server-side; the UI only decides how to say no.
  final bool canVote;
  final String? voteCarId;

  /// Whether the viewer has an accepted event car that could still be entered.
  final bool canEnter;
  final List<MyContestEntryEntity> myEntries;

  const ContestViewerEntity({
    this.isOrganizer = false,
    this.canVote = false,
    this.voteCarId,
    this.canEnter = false,
    this.myEntries = const [],
  });

  bool get hasVoted => voteCarId != null;

  MyContestEntryEntity? entryFor(String carId) {
    for (final e in myEntries) {
      if (e.carId == carId) return e;
    }
    return null;
  }

  /// The viewer's cars that are on the ballot or waiting to be.
  List<String> get liveEntryCarIds =>
      [for (final e in myEntries) if (e.status.isLive) e.carId];

  ContestViewerEntity copyWith({String? voteCarId, bool clearVote = false}) {
    return ContestViewerEntity(
      isOrganizer: isOrganizer,
      canVote: canVote,
      voteCarId: clearVote ? null : (voteCarId ?? this.voteCarId),
      canEnter: canEnter,
      myEntries: myEntries,
    );
  }

  @override
  List<Object?> get props =>
      [isOrganizer, canVote, voteCarId, canEnter, myEntries];
}

/// A contest in full — `GET /map-events/{id}/contests/{contest_id}`, and the
/// response body of every write.
class ContestEntity extends Equatable {
  final String id;
  final String eventId;
  final ContestCategoryEntity category;
  final String title;
  final String? criteria;
  final ContestStatus status;
  final DateTime opensAt;
  final DateTime closesAt;
  final DateTime? finishedAt;
  final bool finishedEarly;
  final int votesCount;
  final int entriesCount;

  /// The accepted entries, ranked. Every car appears once.
  final List<ContestEntryEntity> entries;
  final ContestViewerEntity viewer;

  /// Organizers only; empty for everyone else.
  final List<ContestPendingEntryEntity> pendingEntries;
  final String? createdByUsername;
  final DateTime createdAt;

  /// The event this contest runs inside. Null against a backend that predates
  /// the embedded summary — see [ContestEventSummaryEntity].
  final ContestEventSummaryEntity? event;

  const ContestEntity({
    required this.id,
    required this.eventId,
    required this.category,
    required this.title,
    required this.criteria,
    required this.status,
    required this.opensAt,
    required this.closesAt,
    required this.finishedAt,
    required this.finishedEarly,
    required this.votesCount,
    required this.entriesCount,
    required this.entries,
    required this.viewer,
    required this.pendingEntries,
    required this.createdByUsername,
    required this.createdAt,
    this.event,
  });

  /// Under an hour left of the *planned* window — the chip and CTA change tone
  /// to nudge people to vote. The contest does not actually close then; an
  /// organizer does that.
  static const closingSoonWindow = Duration(hours: 1);

  bool get isScheduled => status == ContestStatus.scheduled;
  bool get isOpen => status == ContestStatus.open;
  bool get isFinished => status == ContestStatus.finished;

  /// Whether the planned end is still ahead. Past it, an open contest simply
  /// stays open — the countdown stops being meaningful and the UI says
  /// "voting open" instead.
  bool hasPlannedTimeLeft(DateTime now) => now.isBefore(closesAt);

  bool isClosingSoon(DateTime now) =>
      isOpen && !closesAt.isBefore(now) && closesAt.difference(now) < closingSoonWindow;

  Duration timeLeft(DateTime now) {
    final left = closesAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  Duration opensIn(DateTime now) {
    final left = opensAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  /// The finished contest's winner — null while it's running, or when nobody
  /// voted (no podium without a vote).
  ContestEntryEntity? get winner {
    if (!isFinished || entries.isEmpty) return null;
    final first = entries.first;
    return first.votesCount >= 1 ? first : null;
  }

  /// The top three with at least one vote, rank ascending.
  List<ContestEntryEntity> get podium =>
      [for (final e in entries) if (e.isOnPodium) e];

  ContestEntryEntity? entryFor(String carId) {
    for (final e in entries) {
      if (e.car.id == carId) return e;
    }
    return null;
  }

  /// The entry the viewer votes for, if it's still on the ballot.
  ContestEntryEntity? get myVoteEntry {
    final id = viewer.voteCarId;
    return id == null ? null : entryFor(id);
  }

  /// The viewer's own accepted car on the ballot, podium or not — what decides
  /// whether they get a participant card at all. Best-placed first when they
  /// entered more than one car.
  ContestEntryEntity? get myEntry {
    ContestEntryEntity? best;
    for (final e in entries) {
      if (viewer.entryFor(e.car.id)?.status != ContestEntryStatus.accepted) {
        continue;
      }
      if (best == null || e.rank < best.rank) best = e;
    }
    return best;
  }

  /// Whether the viewer's own car is on the podium — what turns the finished
  /// footer into "SHARE YOUR WIN".
  ContestEntryEntity? get myPodiumEntry {
    for (final e in podium) {
      if (viewer.entryFor(e.car.id)?.status == ContestEntryStatus.accepted) {
        return e;
      }
    }
    return null;
  }

  /// Applies a live board: per-entry counts replaced, the ballot re-ranked by
  /// the server's own rule (votes desc, whoever reached the count first, then
  /// car id). A finished contest ignores boards — its ranks are frozen.
  ContestEntity applyBoard(ContestBoardUpdate board) {
    if (board.contestId != id || isFinished) return this;
    final updated = [
      for (final e in entries)
        () {
          final row = board.entries[e.car.id];
          return row == null
              ? e
              : e.copyWith(
                  votesCount: row.votesCount,
                  lastVoteAt: row.lastVoteAt,
                  clearLastVoteAt: row.lastVoteAt == null,
                );
        }(),
    ];
    return copyWith(
      entries: rankEntries(updated),
      votesCount: board.votesCount,
    );
  }

  /// A local +1 for an optimistic vote: the new car gains one, the previous
  /// choice (if any) loses one, then the board re-ranks.
  ContestEntity applyOptimisticVote(String carId) {
    final previous = viewer.voteCarId;
    if (previous == carId) return this;
    final now = DateTime.now();
    final updated = [
      for (final e in entries)
        if (e.car.id == carId)
          e.copyWith(votesCount: e.votesCount + 1, lastVoteAt: now)
        else if (e.car.id == previous && e.votesCount > 0)
          e.copyWith(votesCount: e.votesCount - 1)
        else
          e,
    ];
    return copyWith(
      entries: rankEntries(updated),
      votesCount: previous == null ? votesCount + 1 : votesCount,
      viewer: viewer.copyWith(voteCarId: carId),
    );
  }

  /// The ordering rule, in one place. Mirrors `ContestFinalizer.rank` on the
  /// backend so a local re-rank agrees with the next server read.
  static List<ContestEntryEntity> rankEntries(List<ContestEntryEntity> rows) {
    final sorted = [...rows]..sort((a, b) {
        final byVotes = b.votesCount.compareTo(a.votesCount);
        if (byVotes != 0) return byVotes;
        final la = a.lastVoteAt, lb = b.lastVoteAt;
        if (la != null && lb != null) {
          final byTime = la.compareTo(lb);
          if (byTime != 0) return byTime;
        } else if (la != null) {
          return -1;
        } else if (lb != null) {
          return 1;
        }
        return a.car.id.compareTo(b.car.id);
      });
    return [
      for (var i = 0; i < sorted.length; i++) sorted[i].copyWith(rank: i + 1),
    ];
  }

  ContestEntity copyWith({
    List<ContestEntryEntity>? entries,
    int? votesCount,
    ContestViewerEntity? viewer,
  }) {
    return ContestEntity(
      id: id,
      eventId: eventId,
      category: category,
      title: title,
      criteria: criteria,
      status: status,
      opensAt: opensAt,
      closesAt: closesAt,
      finishedAt: finishedAt,
      finishedEarly: finishedEarly,
      votesCount: votesCount ?? this.votesCount,
      entriesCount: entriesCount,
      entries: entries ?? this.entries,
      viewer: viewer ?? this.viewer,
      pendingEntries: pendingEntries,
      createdByUsername: createdByUsername,
      createdAt: createdAt,
      event: event,
    );
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        category,
        title,
        criteria,
        status,
        opensAt,
        closesAt,
        finishedAt,
        finishedEarly,
        votesCount,
        entriesCount,
        entries,
        viewer,
        pendingEntries,
        createdByUsername,
        createdAt,
        event,
      ];
}

/// The event a contest belongs to, as embedded in the contest read.
///
/// The participant card needs event context — the title for its EVENT row and
/// the attendee count for its footer line — which the contest endpoint did not
/// return before this was added (`WINNER_CARD_REDESIGN_PROGRESS.md` §3). It is
/// nullable all the way up so the app keeps working against a backend that
/// predates it; the card falls back to the event title threaded through the
/// route when it is absent.
class ContestEventSummaryEntity extends Equatable {
  final String id;
  final String title;
  final String? coverImageUrl;
  final String? locationName;
  final DateTime? startsAt;
  final int attendeesCount;
  final int attendingCarsCount;

  /// How many contests the event ran in total — not just the one being read.
  final int contestsCount;

  /// The event's own status (`previous` once an organizer marks it finished).
  final String? status;

  const ContestEventSummaryEntity({
    required this.id,
    required this.title,
    this.coverImageUrl,
    this.locationName,
    this.startsAt,
    this.attendeesCount = 0,
    this.attendingCarsCount = 0,
    this.contestsCount = 0,
    this.status,
  });

  /// Participant cards exist only once an organizer marks the event finished.
  bool get isFinished => status == 'previous';

  @override
  List<Object?> get props => [
        id,
        title,
        coverImageUrl,
        locationName,
        startsAt,
        attendeesCount,
        attendingCarsCount,
        contestsCount,
        status,
      ];
}
