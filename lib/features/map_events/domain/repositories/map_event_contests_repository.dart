import 'package:tweakd/core/error/base_failures.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../entities/car_event_history.dart';
import '../entities/contest.dart';
import '../entities/contest_board_update.dart';
import '../entities/contest_enums.dart';
import '../entities/participant_card.dart';

/// Contests inside an event — `/map-events/{id}/contests/*` plus the car
/// history read. Kept apart from [MapEventsRepository] so that interface stops
/// growing; both are implemented over the same HTTP client.
///
/// Every write answers with the fresh [ContestEntity], so no write needs a
/// follow-up read.
abstract class MapEventContestsRepository {
  Future<Either<Failure, List<ContestCategoryEntity>>> getCategories();

  Future<Either<Failure, List<ContestEntity>>> getContests(
    String eventId, {
    CancelToken? cancelToken,
  });

  Future<Either<Failure, ContestEntity>> getContest(
    String eventId,
    String contestId, {
    CancelToken? cancelToken,
  });

  Future<Either<Failure, ContestEntity>> createContest(
    String eventId, {
    required String categoryId,
    required String title,
    String? criteria,
    required DateTime opensAt,
    required DateTime closesAt,
  });

  /// Null fields are left unchanged.
  Future<Either<Failure, ContestEntity>> updateContest(
    String eventId,
    String contestId, {
    String? title,
    String? criteria,
    DateTime? opensAt,
    DateTime? closesAt,
  });

  /// Starts voting now. Idempotent — an already-open contest comes back as is.
  Future<Either<Failure, ContestEntity>> openContest(
    String eventId,
    String contestId,
  );

  Future<Either<Failure, ContestEntity>> finishContest(
    String eventId,
    String contestId,
  );

  Future<Either<Failure, void>> deleteContest(String eventId, String contestId);

  Future<Either<Failure, ContestEntity>> requestEntry(
    String eventId,
    String contestId,
    String carId,
  );

  Future<Either<Failure, ContestEntity>> withdrawEntry(
    String eventId,
    String contestId,
    String carId,
  );

  Future<Either<Failure, ContestEntity>> decideEntry(
    String eventId,
    String contestId,
    String carId, {
    required ContestEntryStatus status,
    String? reason,
  });

  Future<Either<Failure, ContestEntity>> vote(
    String eventId,
    String contestId,
    String carId,
  );

  Future<Either<Failure, List<CarEventHistoryItemEntity>>> getCarHistory(
    String carId, {
    CancelToken? cancelToken,
  });

  // ── Live boards ────────────────────────────────────────────────────────────
  //
  // The realtime topic is per event and ref-counted: two screens watching the
  // same event share one channel. These never fail loudly — a channel that
  // won't join leaves [isLive] false, and the bloc polls instead.

  Stream<ContestBoardUpdate> get boards;
  Stream<ContestStatusUpdate> get statusChanges;
  bool isLive(String eventId);
  Future<void> subscribeLive(String eventId);
  Future<void> unsubscribeLive(String eventId);

  /// The viewer's participant cards for [eventId] — one per car they had
  /// accepted into it. Empty until an organizer marks the event finished.
  Future<Either<Failure, List<ParticipantCardEntity>>> getMyParticipantCards(
    String eventId,
  );
}
