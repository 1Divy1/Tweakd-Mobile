import 'package:tweakd/features/garage/data/models/car_summary_model.dart';

import '../../domain/entities/car_event_history.dart';
import '../../domain/entities/contest.dart';
import '../../domain/entities/contest_board_update.dart';
import '../../domain/entities/contest_enums.dart';
import '../../domain/entities/map_event_enums.dart';
import 'map_event_json.dart';

// ── Categories ─────────────────────────────────────────────────────────────

class ContestCategoryModel {
  final String id;
  final String label;
  final String? icon;

  const ContestCategoryModel({
    required this.id,
    required this.label,
    required this.icon,
  });

  factory ContestCategoryModel.fromJson(Map<String, dynamic> json) {
    return ContestCategoryModel(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      icon: json['icon'] as String?,
    );
  }

  ContestCategoryEntity toEntity() => ContestCategoryEntity(
        id: id,
        label: label,
        icon: ContestCategoryIcon.fromApi(icon),
      );
}

// ── Entries ────────────────────────────────────────────────────────────────

class ContestEntryModel {
  final CarSummaryModel car;
  final int votesCount;
  final int rank;
  final int? finalRank;
  final DateTime? lastVoteAt;

  const ContestEntryModel({
    required this.car,
    required this.votesCount,
    required this.rank,
    required this.finalRank,
    required this.lastVoteAt,
  });

  factory ContestEntryModel.fromJson(Map<String, dynamic> json) {
    return ContestEntryModel(
      // Same `CarSummaryDto` the garage module models — reused, not redeclared.
      car: CarSummaryModel.fromJson(json['car'] as Map<String, dynamic>),
      votesCount: (json['votes_count'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      finalRank: (json['final_rank'] as num?)?.toInt(),
      lastVoteAt: parseNullableInstant(json['last_vote_at']),
    );
  }

  ContestEntryEntity toEntity() => ContestEntryEntity(
        car: car.toEntity(),
        votesCount: votesCount,
        rank: rank,
        finalRank: finalRank,
        lastVoteAt: lastVoteAt,
      );
}

class ContestPendingEntryModel {
  final CarSummaryModel car;
  final DateTime requestedAt;

  const ContestPendingEntryModel({required this.car, required this.requestedAt});

  factory ContestPendingEntryModel.fromJson(Map<String, dynamic> json) {
    return ContestPendingEntryModel(
      car: CarSummaryModel.fromJson(json['car'] as Map<String, dynamic>),
      requestedAt: parseInstant(json['requested_at']),
    );
  }

  ContestPendingEntryEntity toEntity() =>
      ContestPendingEntryEntity(car: car.toEntity(), requestedAt: requestedAt);
}

class ContestMyEntryModel {
  final String carId;
  final String? status;
  final String? rejectionReason;

  const ContestMyEntryModel({
    required this.carId,
    required this.status,
    required this.rejectionReason,
  });

  factory ContestMyEntryModel.fromJson(Map<String, dynamic> json) {
    return ContestMyEntryModel(
      carId: json['car_id'] as String,
      status: json['status'] as String?,
      rejectionReason: parseNullableString(json['rejection_reason']),
    );
  }

  MyContestEntryEntity toEntity() => MyContestEntryEntity(
        carId: carId,
        status: ContestEntryStatus.fromApi(status),
        rejectionReason: rejectionReason,
      );
}

class ContestViewerModel {
  final bool isOrganizer;
  final bool canVote;
  final String? voteCarId;
  final bool canEnter;
  final List<ContestMyEntryModel> myEntries;

  const ContestViewerModel({
    required this.isOrganizer,
    required this.canVote,
    required this.voteCarId,
    required this.canEnter,
    required this.myEntries,
  });

  factory ContestViewerModel.fromJson(Map<String, dynamic>? json) {
    final j = json ?? const <String, dynamic>{};
    return ContestViewerModel(
      isOrganizer: j['is_organizer'] as bool? ?? false,
      canVote: j['can_vote'] as bool? ?? false,
      voteCarId: parseNullableString(j['vote_car_id']),
      canEnter: j['can_enter'] as bool? ?? false,
      myEntries: [
        for (final e in (j['my_entries'] as List<dynamic>? ?? const []))
          ContestMyEntryModel.fromJson(e as Map<String, dynamic>),
      ],
    );
  }

  ContestViewerEntity toEntity() => ContestViewerEntity(
        isOrganizer: isOrganizer,
        canVote: canVote,
        voteCarId: voteCarId,
        canEnter: canEnter,
        myEntries: [for (final e in myEntries) e.toEntity()],
      );
}

// ── Contest ────────────────────────────────────────────────────────────────

// ── Event summary ──────────────────────────────────────────────────────────

/// The event embedded in a contest read. Every field is defensive: the whole
/// object is absent on a backend that predates it, and the card degrades to the
/// event title threaded through the route rather than rendering blanks.
class ContestEventSummaryModel {
  final String id;
  final String title;
  final String? coverImageUrl;
  final String? locationName;
  final DateTime? startsAt;
  final int attendeesCount;
  final int attendingCarsCount;
  final int contestsCount;
  final String? status;

  const ContestEventSummaryModel({
    required this.id,
    required this.title,
    required this.coverImageUrl,
    required this.locationName,
    required this.startsAt,
    required this.attendeesCount,
    required this.attendingCarsCount,
    required this.contestsCount,
    required this.status,
  });

  factory ContestEventSummaryModel.fromJson(Map<String, dynamic> json) {
    return ContestEventSummaryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      coverImageUrl: parseNullableString(json['cover_image_url']),
      locationName: parseNullableString(json['location_name']),
      startsAt: parseNullableInstant(json['starts_at']),
      attendeesCount: (json['attendees_count'] as num?)?.toInt() ?? 0,
      attendingCarsCount: (json['attending_cars_count'] as num?)?.toInt() ?? 0,
      contestsCount: (json['contests_count'] as num?)?.toInt() ?? 0,
      status: json['status'] as String?,
    );
  }

  ContestEventSummaryEntity toEntity() => ContestEventSummaryEntity(
        id: id,
        title: title,
        coverImageUrl: coverImageUrl,
        locationName: locationName,
        startsAt: startsAt,
        attendeesCount: attendeesCount,
        attendingCarsCount: attendingCarsCount,
        contestsCount: contestsCount,
        status: status,
      );
}

class ContestModel {
  final String id;
  final String eventId;
  final ContestCategoryModel category;
  final String title;
  final String? criteria;
  final String? status;
  final DateTime opensAt;
  final DateTime closesAt;
  final DateTime? finishedAt;
  final bool finishedEarly;
  final int votesCount;
  final int entriesCount;
  final List<ContestEntryModel> entries;
  final ContestViewerModel viewer;
  final List<ContestPendingEntryModel> pendingEntries;
  final String? createdByUsername;
  final DateTime createdAt;
  final ContestEventSummaryModel? event;

  const ContestModel({
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
    required this.event,
  });

  factory ContestModel.fromJson(Map<String, dynamic> json) {
    final createdBy = json['created_by'] as Map<String, dynamic>?;
    return ContestModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      category: ContestCategoryModel.fromJson(
        json['category'] as Map<String, dynamic>? ?? const {'id': 'custom'},
      ),
      title: json['title'] as String? ?? '',
      criteria: parseNullableString(json['criteria']),
      status: json['status'] as String?,
      opensAt: parseInstant(json['opens_at']),
      closesAt: parseInstant(json['closes_at']),
      finishedAt: parseNullableInstant(json['finished_at']),
      finishedEarly: json['finished_early'] as bool? ?? false,
      votesCount: (json['votes_count'] as num?)?.toInt() ?? 0,
      entriesCount: (json['entries_count'] as num?)?.toInt() ?? 0,
      entries: [
        for (final e in (json['entries'] as List<dynamic>? ?? const []))
          ContestEntryModel.fromJson(e as Map<String, dynamic>),
      ],
      viewer: ContestViewerModel.fromJson(json['viewer'] as Map<String, dynamic>?),
      pendingEntries: [
        for (final e in (json['pending_entries'] as List<dynamic>? ?? const []))
          ContestPendingEntryModel.fromJson(e as Map<String, dynamic>),
      ],
      createdByUsername: parseNullableString(createdBy?['username']),
      createdAt: parseInstant(json['created_at']),
      event: switch (json['event']) {
        final Map<String, dynamic> e => ContestEventSummaryModel.fromJson(e),
        _ => null,
      },
    );
  }

  ContestEntity toEntity() => ContestEntity(
        id: id,
        eventId: eventId,
        category: category.toEntity(),
        title: title,
        criteria: criteria,
        status: ContestStatus.fromApi(status),
        opensAt: opensAt,
        closesAt: closesAt,
        finishedAt: finishedAt,
        finishedEarly: finishedEarly,
        votesCount: votesCount,
        entriesCount: entriesCount,
        entries: [for (final e in entries) e.toEntity()],
        viewer: viewer.toEntity(),
        pendingEntries: [for (final e in pendingEntries) e.toEntity()],
        createdByUsername: createdByUsername,
        createdAt: createdAt,
        event: event?.toEntity(),
      );
}

// ── Realtime payloads ──────────────────────────────────────────────────────

/// Decodes a `board` broadcast. Returns null for anything malformed rather
/// than throwing inside a socket callback.
ContestBoardUpdate? parseContestBoard(Map<String, dynamic> payload) {
  final contestId = payload['contest_id'];
  if (contestId is! String || contestId.isEmpty) return null;
  final rows = <String, ContestBoardRow>{};
  for (final raw in (payload['entries'] as List<dynamic>? ?? const [])) {
    if (raw is! Map) continue;
    final carId = raw['car_id'];
    if (carId is! String) continue;
    rows[carId] = ContestBoardRow(
      votesCount: (raw['votes_count'] as num?)?.toInt() ?? 0,
      lastVoteAt: parseNullableInstant(raw['last_vote_at']),
    );
  }
  return ContestBoardUpdate(
    contestId: contestId,
    status: ContestStatus.fromApi(payload['status'] as String?),
    votesCount: (payload['votes_count'] as num?)?.toInt() ?? 0,
    entries: rows,
    sentAt: parseNullableInstant(payload['sent_at']),
  );
}

ContestStatusUpdate? parseContestStatus(Map<String, dynamic> payload) {
  final contestId = payload['contest_id'];
  if (contestId is! String || contestId.isEmpty) return null;
  return ContestStatusUpdate(
    contestId: contestId,
    status: ContestStatus.fromApi(payload['status'] as String?),
  );
}

// ── Car history ────────────────────────────────────────────────────────────

class CarEventPlacementModel {
  final String contestId;
  final String title;
  final ContestCategoryModel category;
  final int finalRank;
  final int finalVotesCount;
  final int contestVotesCount;
  final DateTime? finishedAt;

  const CarEventPlacementModel({
    required this.contestId,
    required this.title,
    required this.category,
    required this.finalRank,
    required this.finalVotesCount,
    required this.contestVotesCount,
    required this.finishedAt,
  });

  factory CarEventPlacementModel.fromJson(Map<String, dynamic> json) {
    return CarEventPlacementModel(
      contestId: json['contest_id'] as String,
      title: json['title'] as String? ?? '',
      category: ContestCategoryModel.fromJson(
        json['category'] as Map<String, dynamic>? ?? const {'id': 'custom'},
      ),
      finalRank: (json['final_rank'] as num?)?.toInt() ?? 0,
      finalVotesCount: (json['final_votes_count'] as num?)?.toInt() ?? 0,
      contestVotesCount: (json['contest_votes_count'] as num?)?.toInt() ?? 0,
      finishedAt: parseNullableInstant(json['finished_at']),
    );
  }

  CarEventPlacementEntity toEntity() => CarEventPlacementEntity(
        contestId: contestId,
        title: title,
        category: category.toEntity(),
        finalRank: finalRank,
        finalVotesCount: finalVotesCount,
        contestVotesCount: contestVotesCount,
        finishedAt: finishedAt,
      );
}

class CarEventHistoryItemModel {
  final String eventId;
  final String title;
  final String? coverImageUrl;
  final String locationName;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? status;
  final List<CarEventPlacementModel> placements;

  const CarEventHistoryItemModel({
    required this.eventId,
    required this.title,
    required this.coverImageUrl,
    required this.locationName,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.placements,
  });

  factory CarEventHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final event = json['event'] as Map<String, dynamic>? ?? const {};
    return CarEventHistoryItemModel(
      eventId: event['id'] as String? ?? '',
      title: event['title'] as String? ?? '',
      coverImageUrl: parseNullableString(event['cover_image_url']),
      locationName: event['location_name'] as String? ?? '',
      startsAt: parseInstant(event['starts_at']),
      endsAt: parseNullableInstant(event['ends_at']),
      status: event['status'] as String?,
      placements: [
        for (final p in (json['placements'] as List<dynamic>? ?? const []))
          CarEventPlacementModel.fromJson(p as Map<String, dynamic>),
      ],
    );
  }

  CarEventHistoryItemEntity toEntity() => CarEventHistoryItemEntity(
        event: CarEventHistoryEventEntity(
          id: eventId,
          title: title,
          coverImageUrl: coverImageUrl,
          locationName: locationName,
          startsAt: startsAt,
          endsAt: endsAt,
          status: MapEventStatus.fromApi(status),
        ),
        placements: [for (final p in placements) p.toEntity()],
      );
}
