import 'package:equatable/equatable.dart';

import 'contest.dart';
import 'map_event_enums.dart';

/// A podium place a car earned in a finished contest — the car's "badge".
class CarEventPlacementEntity extends Equatable {
  final String contestId;
  final String title;
  final ContestCategoryEntity category;
  final int finalRank;
  final int finalVotesCount;
  final int contestVotesCount;
  final DateTime? finishedAt;

  const CarEventPlacementEntity({
    required this.contestId,
    required this.title,
    required this.category,
    required this.finalRank,
    required this.finalVotesCount,
    required this.contestVotesCount,
    required this.finishedAt,
  });

  bool get isWin => finalRank == 1;

  @override
  List<Object?> get props => [
        contestId,
        title,
        category,
        finalRank,
        finalVotesCount,
        contestVotesCount,
        finishedAt,
      ];
}

/// The slice of an event a history row needs — enough for a tappable row.
class CarEventHistoryEventEntity extends Equatable {
  final String id;
  final String title;
  final String? coverImageUrl;
  final String locationName;
  final DateTime startsAt;
  final DateTime? endsAt;
  final MapEventStatus status;

  const CarEventHistoryEventEntity({
    required this.id,
    required this.title,
    required this.coverImageUrl,
    required this.locationName,
    required this.startsAt,
    required this.endsAt,
    required this.status,
  });

  @override
  List<Object?> get props =>
      [id, title, coverImageUrl, locationName, startsAt, endsAt, status];
}

/// One event a car attended, with whatever it won there.
class CarEventHistoryItemEntity extends Equatable {
  final CarEventHistoryEventEntity event;
  final List<CarEventPlacementEntity> placements;

  const CarEventHistoryItemEntity({
    required this.event,
    required this.placements,
  });

  @override
  List<Object?> get props => [event, placements];
}
