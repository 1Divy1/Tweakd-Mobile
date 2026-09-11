import 'dart:async';

import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/core/shared/entities/image_ref.dart';
import 'package:tweakd/features/garage/domain/entities/car_summary.dart';
import 'package:tweakd/features/map_events/domain/entities/car_event_history.dart';
import 'package:tweakd/features/map_events/domain/entities/contest.dart';
import 'package:tweakd/features/map_events/domain/entities/contest_board_update.dart';
import 'package:tweakd/features/map_events/domain/entities/contest_enums.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_enums.dart';
import 'package:tweakd/features/map_events/domain/failures/map_event_failures.dart';
import 'package:tweakd/features/map_events/domain/repositories/map_event_contests_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tweakd/features/map_events/presentation/widgets/contests/participant_card.dart';
import 'package:tweakd/features/map_events/domain/entities/participant_card.dart';

/// Fixtures shared by the contest tests. The artwork URLs are empty on
/// purpose: a widget test has no network and `CarImage` short-circuits an
/// empty URL to its placeholder, which occupies the same box.
CarSummaryEntity car(String id, String brand, String model, String owner) =>
    CarSummaryEntity(
      id: id,
      brand: brand,
      model: model,
      coverImage: const ImageRef(key: 'k', url: ''),
      ownerId: 'owner-$owner',
      ownerUsername: owner,
      year: 2023,
      horsepower: 503,
      torque: 650,
    );

const category = ContestCategoryEntity(
  id: 'exhaust',
  label: 'Best exhaust system',
  icon: ContestCategoryIcon.exhaust,
);

ContestEntryEntity entry(
  CarSummaryEntity c,
  int votes,
  int rank, {
  int? finalRank,
  DateTime? lastVoteAt,
}) =>
    ContestEntryEntity(
      car: c,
      votesCount: votes,
      rank: rank,
      finalRank: finalRank,
      lastVoteAt: lastVoteAt,
    );

final now = DateTime(2026, 8, 11, 21, 12);

final m4 = car('c1', 'BMW', 'M4 Competition', 'torque_sasha');
final gt3 = car('c2', 'Porsche', '911 GT3', 'noctis_nico');
final supra = car('c3', 'Toyota', 'Supra MK4', 'jdm_jules');
final rs6 = car('c4', 'Audi', 'RS6 Avant', 'kenji_apex');

ContestEntity openContest({
  String? voteCarId,
  bool canVote = true,
  List<MyContestEntryEntity> myEntries = const [],
}) =>
    ContestEntity(
      id: 'k1',
      eventId: 'm1',
      category: category,
      title: 'Best exhaust system',
      criteria:
          'Judged on note and build quality — walk the row, listen, then vote.',
      status: ContestStatus.open,
      opensAt: now.subtract(const Duration(hours: 2)),
      closesAt: now.add(const Duration(hours: 1, minutes: 18)),
      finishedAt: null,
      finishedEarly: false,
      votesCount: 150,
      entriesCount: 4,
      entries: [
        entry(gt3, 61, 1, lastVoteAt: now.subtract(const Duration(minutes: 3))),
        entry(m4, 48, 2, lastVoteAt: now.subtract(const Duration(minutes: 8))),
        entry(supra, 37, 3, lastVoteAt: now.subtract(const Duration(minutes: 1))),
        entry(rs6, 4, 4, lastVoteAt: now.subtract(const Duration(minutes: 40))),
      ],
      viewer: ContestViewerEntity(
        canVote: canVote,
        voteCarId: voteCarId,
        canEnter: true,
        myEntries: myEntries,
      ),
      pendingEntries: const [],
      createdByUsername: 'torque_sasha',
      createdAt: now.subtract(const Duration(hours: 3)),
    );

ContestEntity scheduledContest({
  ContestStatus status = ContestStatus.scheduled,
}) =>
    ContestEntity(
      id: 'k5',
      eventId: 'm1',
      category: const ContestCategoryEntity(
        id: 'custom',
        label: 'Custom category',
        icon: ContestCategoryIcon.trophy,
      ),
      title: 'Best daily driver',
      criteria: 'Has to be insured, plated, and actually driven here.',
      status: status,
      opensAt: now.add(const Duration(minutes: 48)),
      closesAt: now.add(const Duration(hours: 2)),
      finishedAt: null,
      finishedEarly: false,
      votesCount: 0,
      entriesCount: 3,
      entries: [entry(m4, 0, 1), entry(rs6, 0, 2), entry(supra, 0, 3)],
      viewer: const ContestViewerEntity(
        canEnter: true,
        myEntries: [
          MyContestEntryEntity(
            carId: 'c1',
            status: ContestEntryStatus.accepted,
            rejectionReason: null,
          ),
        ],
      ),
      pendingEntries: const [],
      createdByUsername: 'torque_sasha',
      createdAt: now,
    );

ContestEntity finishedContest({bool viewerWon = false}) => ContestEntity(
      id: 'k4',
      eventId: 'm1',
      category: const ContestCategoryEntity(
        id: 'paint',
        label: 'Best paint / wrap',
        icon: ContestCategoryIcon.paint,
      ),
      title: 'Best paint / wrap',
      criteria: 'Depth, prep, and panel gaps under the terrace lights.',
      status: ContestStatus.finished,
      opensAt: now.subtract(const Duration(hours: 3)),
      closesAt: now.subtract(const Duration(hours: 1)),
      finishedAt: now.subtract(const Duration(hours: 1)),
      finishedEarly: false,
      votesCount: 204,
      entriesCount: 4,
      entries: [
        entry(m4, 78, 1, finalRank: 1),
        entry(gt3, 55, 2, finalRank: 2),
        entry(supra, 41, 3, finalRank: 3),
        entry(rs6, 30, 4, finalRank: 4),
      ],
      viewer: ContestViewerEntity(
        voteCarId: 'c2',
        myEntries: viewerWon
            ? const [
                MyContestEntryEntity(
                  carId: 'c1',
                  status: ContestEntryStatus.accepted,
                  rejectionReason: null,
                ),
              ]
            : const [],
      ),
      pendingEntries: const [],
      createdByUsername: 'torque_sasha',
      createdAt: now.subtract(const Duration(hours: 4)),
    );

final historyItem = CarEventHistoryItemEntity(
  event: CarEventHistoryEventEntity(
    id: 'm1',
    title: 'Casino Square Cars & Coffee',
    coverImageUrl: '',
    locationName: 'Place du Casino',
    startsAt: now.subtract(const Duration(hours: 3)),
    endsAt: now.add(const Duration(hours: 2)),
    status: MapEventStatus.previous,
  ),
  placements: [
    CarEventPlacementEntity(
      contestId: 'k4',
      title: 'Best paint / wrap',
      category: const ContestCategoryEntity(
        id: 'paint',
        label: 'Best paint / wrap',
        icon: ContestCategoryIcon.paint,
      ),
      finalRank: 1,
      finalVotesCount: 78,
      contestVotesCount: 204,
      finishedAt: now.subtract(const Duration(hours: 1)),
    ),
    CarEventPlacementEntity(
      contestId: 'k1',
      title: 'Best exhaust system',
      category: category,
      finalRank: 3,
      finalVotesCount: 31,
      contestVotesCount: 118,
      finishedAt: now.subtract(const Duration(minutes: 30)),
    ),
  ],
);

/// A scriptable in-memory [MapEventContestsRepository]. Every write answers
/// with [next] (or [failure]); the live streams are controllable.
class FakeContestsRepository implements MapEventContestsRepository {
  ContestEntity next;
  Failure? failure;
  final List<String> calls = [];
  final boardsController = StreamController<ContestBoardUpdate>.broadcast();
  final statusController = StreamController<ContestStatusUpdate>.broadcast();
  bool live = false;
  int subscriptions = 0;

  FakeContestsRepository(this.next);

  /// What [getMyParticipantCards] answers with.
  List<ParticipantCardEntity> participantCards = const [];

  @override
  Future<Either<Failure, List<ParticipantCardEntity>>> getMyParticipantCards(
    String eventId,
  ) async {
    calls.add('getMyParticipantCards');
    final f = failure;
    return f == null ? Right(participantCards) : Left(f);
  }

  Either<Failure, ContestEntity> _answer(String call) {
    calls.add(call);
    final f = failure;
    return f == null ? Right(next) : Left(f);
  }

  @override
  Future<Either<Failure, List<ContestCategoryEntity>>> getCategories() async =>
      const Right([category]);

  @override
  Future<Either<Failure, List<ContestEntity>>> getContests(
    String eventId, {
    CancelToken? cancelToken,
  }) async {
    calls.add('getContests');
    final f = failure;
    return f == null ? Right([next]) : Left(f);
  }

  @override
  Future<Either<Failure, ContestEntity>> getContest(
    String eventId,
    String contestId, {
    CancelToken? cancelToken,
  }) async =>
      _answer('getContest');

  @override
  Future<Either<Failure, ContestEntity>> createContest(
    String eventId, {
    required String categoryId,
    required String title,
    String? criteria,
    required DateTime opensAt,
    required DateTime closesAt,
  }) async =>
      _answer('createContest');

  @override
  Future<Either<Failure, ContestEntity>> updateContest(
    String eventId,
    String contestId, {
    String? title,
    String? criteria,
    DateTime? opensAt,
    DateTime? closesAt,
  }) async =>
      _answer('updateContest');

  @override
  Future<Either<Failure, ContestEntity>> openContest(
    String eventId,
    String contestId,
  ) async =>
      _answer('openContest');

  @override
  Future<Either<Failure, ContestEntity>> finishContest(
    String eventId,
    String contestId,
  ) async =>
      _answer('finishContest');

  @override
  Future<Either<Failure, void>> deleteContest(String eventId, String contestId) async {
    calls.add('deleteContest');
    return const Right(null);
  }

  @override
  Future<Either<Failure, ContestEntity>> requestEntry(
    String eventId,
    String contestId,
    String carId,
  ) async =>
      _answer('requestEntry:$contestId');

  @override
  Future<Either<Failure, ContestEntity>> withdrawEntry(
    String eventId,
    String contestId,
    String carId,
  ) async =>
      _answer('withdrawEntry:$contestId');

  @override
  Future<Either<Failure, ContestEntity>> decideEntry(
    String eventId,
    String contestId,
    String carId, {
    required ContestEntryStatus status,
    String? reason,
  }) async =>
      _answer('decideEntry');

  @override
  Future<Either<Failure, ContestEntity>> vote(
    String eventId,
    String contestId,
    String carId,
  ) async =>
      _answer('vote:$carId');

  @override
  Future<Either<Failure, List<CarEventHistoryItemEntity>>> getCarHistory(
    String carId, {
    CancelToken? cancelToken,
  }) async =>
      Right([historyItem]);

  @override
  Stream<ContestBoardUpdate> get boards => boardsController.stream;

  @override
  Stream<ContestStatusUpdate> get statusChanges => statusController.stream;

  @override
  bool isLive(String eventId) => live;

  @override
  Future<void> subscribeLive(String eventId) async => subscriptions++;

  @override
  Future<void> unsubscribeLive(String eventId) async => subscriptions--;
}

/// The 403 the vote endpoint answers with for your own car.
const ownCarFailure = ContestNotEligibleFailure("You can't vote for your own car");

/// A participant card for the layout matrix. [contestCount] drives how many
/// contests the car entered (0 = attended, entered nothing); [onPodium] decides
/// whether it placed anywhere, i.e. whether the card carries a placement pill.
ParticipantCardData participantCardData({
  required int contestCount,
  bool onPodium = true,
}) {
  const titles = [
    'Best paint / wrap',
    'Loudest',
    'Best interior',
    'Best wheels',
    'Best exhaust system',
    'Cleanest engine bay',
    'Best stance',
    'People\'s choice',
    'Best build story',
  ];
  return ParticipantCardData(
    eventId: 'm1',
    eventTitle: 'Casino Square Cars & Coffee',
    attendeesCount: 247,
    car: const CarSummaryLike(
      id: 'c1',
      brand: 'BMW',
      model: 'M4 Competition',
      coverImageUrl: null,
    ),
    contests: [
      for (var i = 0; i < contestCount; i++)
        ParticipantCardContest(
          contestId: 'k$i',
          title: titles[i % titles.length],
          rank: onPodium && i == 0 ? 1 : null,
        ),
    ],
  );
}
