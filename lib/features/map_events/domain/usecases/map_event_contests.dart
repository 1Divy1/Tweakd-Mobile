import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../entities/car_event_history.dart';
import '../entities/contest.dart';
import '../entities/contest_board_update.dart';
import '../entities/contest_enums.dart';
import '../repositories/map_event_contests_repository.dart';
import '../entities/participant_card.dart';

// ── Reads ────────────────────────────────────────────────────────────────────

@lazySingleton
class GetContestCategoriesUseCase
    implements UseCase<List<ContestCategoryEntity>, NoParams> {
  final MapEventContestsRepository repository;

  GetContestCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ContestCategoryEntity>>> call(NoParams params) {
    return repository.getCategories();
  }
}

class GetEventContestsParams {
  final String eventId;
  final CancelToken? cancelToken;

  const GetEventContestsParams({required this.eventId, this.cancelToken});
}

/// `GET /{id}/contests` — every contest of the event with its ballot embedded.
@lazySingleton
class GetEventContestsUseCase
    implements UseCase<List<ContestEntity>, GetEventContestsParams> {
  final MapEventContestsRepository repository;

  GetEventContestsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ContestEntity>>> call(
    GetEventContestsParams params,
  ) {
    return repository.getContests(params.eventId, cancelToken: params.cancelToken);
  }
}

class ContestParams {
  final String eventId;
  final String contestId;
  final CancelToken? cancelToken;

  const ContestParams({
    required this.eventId,
    required this.contestId,
    this.cancelToken,
  });
}

@lazySingleton
class GetContestUseCase implements UseCase<ContestEntity, ContestParams> {
  final MapEventContestsRepository repository;

  GetContestUseCase(this.repository);

  @override
  Future<Either<Failure, ContestEntity>> call(ContestParams params) {
    return repository.getContest(
      params.eventId,
      params.contestId,
      cancelToken: params.cancelToken,
    );
  }
}

// ── Organizer ────────────────────────────────────────────────────────────────

class CreateContestParams {
  final String eventId;
  final String categoryId;
  final String title;
  final String? criteria;
  final DateTime opensAt;
  final DateTime closesAt;

  const CreateContestParams({
    required this.eventId,
    required this.categoryId,
    required this.title,
    required this.criteria,
    required this.opensAt,
    required this.closesAt,
  });
}

@lazySingleton
class CreateContestUseCase
    implements UseCase<ContestEntity, CreateContestParams> {
  final MapEventContestsRepository repository;

  CreateContestUseCase(this.repository);

  @override
  Future<Either<Failure, ContestEntity>> call(CreateContestParams params) {
    return repository.createContest(
      params.eventId,
      categoryId: params.categoryId,
      title: params.title,
      criteria: params.criteria,
      opensAt: params.opensAt,
      closesAt: params.closesAt,
    );
  }
}

/// A partial update. Null = unchanged. `opensAt` / `closesAt` are the planned
/// window shown to attendees — moving them never opens or closes anything.
class UpdateContestParams {
  final String eventId;
  final String contestId;
  final String? title;
  final String? criteria;
  final DateTime? opensAt;
  final DateTime? closesAt;

  const UpdateContestParams({
    required this.eventId,
    required this.contestId,
    this.title,
    this.criteria,
    this.opensAt,
    this.closesAt,
  });
}

@lazySingleton
class UpdateContestUseCase
    implements UseCase<ContestEntity, UpdateContestParams> {
  final MapEventContestsRepository repository;

  UpdateContestUseCase(this.repository);

  @override
  Future<Either<Failure, ContestEntity>> call(UpdateContestParams params) {
    return repository.updateContest(
      params.eventId,
      params.contestId,
      title: params.title,
      criteria: params.criteria,
      opensAt: params.opensAt,
      closesAt: params.closesAt,
    );
  }
}

/// `POST /{id}/contests/{contest_id}/open` — starts voting now and tells the
/// meet. Nothing else opens a contest: the planned `opens_at` is a label.
/// Idempotent on the backend.
@lazySingleton
class OpenContestUseCase implements UseCase<ContestEntity, ContestParams> {
  final MapEventContestsRepository repository;

  OpenContestUseCase(this.repository);

  @override
  Future<Either<Failure, ContestEntity>> call(ContestParams params) {
    return repository.openContest(params.eventId, params.contestId);
  }
}

/// `POST /{id}/contests/{contest_id}/finish` — closes voting now, freezes the
/// standings and pays the podium. Idempotent on the backend.
@lazySingleton
class FinishContestUseCase implements UseCase<ContestEntity, ContestParams> {
  final MapEventContestsRepository repository;

  FinishContestUseCase(this.repository);

  @override
  Future<Either<Failure, ContestEntity>> call(ContestParams params) {
    return repository.finishContest(params.eventId, params.contestId);
  }
}

/// Only a contest that hasn't opened yet can be deleted.
@lazySingleton
class DeleteContestUseCase implements UseCase<void, ContestParams> {
  final MapEventContestsRepository repository;

  DeleteContestUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ContestParams params) {
    return repository.deleteContest(params.eventId, params.contestId);
  }
}

class ContestEntryParams {
  final String eventId;
  final String contestId;
  final String carId;

  const ContestEntryParams({
    required this.eventId,
    required this.contestId,
    required this.carId,
  });
}

/// `POST /{id}/contests/{contest_id}/entries` — asks to enter one of the
/// viewer's accepted event cars. Re-sending a live entry is a no-op.
@lazySingleton
class RequestContestEntryUseCase
    implements UseCase<ContestEntity, ContestEntryParams> {
  final MapEventContestsRepository repository;

  RequestContestEntryUseCase(this.repository);

  @override
  Future<Either<Failure, ContestEntity>> call(ContestEntryParams params) {
    return repository.requestEntry(
      params.eventId,
      params.contestId,
      params.carId,
    );
  }
}

/// `DELETE .../entries/{car_id}` — a pending request outright; an accepted
/// entry only while the contest is still scheduled (409 after).
@lazySingleton
class WithdrawContestEntryUseCase
    implements UseCase<ContestEntity, ContestEntryParams> {
  final MapEventContestsRepository repository;

  WithdrawContestEntryUseCase(this.repository);

  @override
  Future<Either<Failure, ContestEntity>> call(ContestEntryParams params) {
    return repository.withdrawEntry(
      params.eventId,
      params.contestId,
      params.carId,
    );
  }
}

class DecideContestEntryParams {
  final String eventId;
  final String contestId;
  final String carId;
  final ContestEntryStatus status;

  /// Required when rejecting; the backend 400s on a blank one.
  final String? reason;

  const DecideContestEntryParams({
    required this.eventId,
    required this.contestId,
    required this.carId,
    required this.status,
    this.reason,
  });
}

@lazySingleton
class DecideContestEntryUseCase
    implements UseCase<ContestEntity, DecideContestEntryParams> {
  final MapEventContestsRepository repository;

  DecideContestEntryUseCase(this.repository);

  @override
  Future<Either<Failure, ContestEntity>> call(DecideContestEntryParams params) {
    return repository.decideEntry(
      params.eventId,
      params.contestId,
      params.carId,
      status: params.status,
      reason: params.reason,
    );
  }
}

// ── Voting ───────────────────────────────────────────────────────────────────

/// `PUT /{id}/contests/{contest_id}/vote` — casts or changes the viewer's
/// vote. 403 when not at the event (no RSVP and no accepted car) or for their
/// own car, 409 outside the window.
@lazySingleton
class CastContestVoteUseCase
    implements UseCase<ContestEntity, ContestEntryParams> {
  final MapEventContestsRepository repository;

  CastContestVoteUseCase(this.repository);

  @override
  Future<Either<Failure, ContestEntity>> call(ContestEntryParams params) {
    return repository.vote(params.eventId, params.contestId, params.carId);
  }
}

// ── Car history ──────────────────────────────────────────────────────────────

class GetCarEventHistoryParams {
  final String carId;
  final CancelToken? cancelToken;

  const GetCarEventHistoryParams({required this.carId, this.cancelToken});
}

/// `GET /map-events/cars/{car_id}/history` — the car's attended events with
/// its podium places, newest first.
@lazySingleton
class GetCarEventHistoryUseCase
    implements UseCase<List<CarEventHistoryItemEntity>, GetCarEventHistoryParams> {
  final MapEventContestsRepository repository;

  GetCarEventHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarEventHistoryItemEntity>>> call(
    GetCarEventHistoryParams params,
  ) {
    return repository.getCarHistory(params.carId, cancelToken: params.cancelToken);
  }
}

// ── Live boards ──────────────────────────────────────────────────────────────

/// The realtime side of contests, as one object a bloc can hold: join an
/// event's board topic (ref-counted), read the streams, know whether the
/// channel is actually up so polling can fill in when it isn't.
///
/// Not a [UseCase]: it is a session, not a call. Kept in the domain layer so
/// blocs still depend on nothing below it.
@lazySingleton
class ContestLiveUpdates {
  final MapEventContestsRepository repository;

  ContestLiveUpdates(this.repository);

  Stream<ContestBoardUpdate> get boards => repository.boards;
  Stream<ContestStatusUpdate> get statusChanges => repository.statusChanges;
  bool isLive(String eventId) => repository.isLive(eventId);
  Future<void> subscribe(String eventId) => repository.subscribeLive(eventId);
  Future<void> unsubscribe(String eventId) => repository.unsubscribeLive(eventId);
}

/// The viewer's participant cards for one event (the event page's "Your
/// card" section).
@lazySingleton
class GetMyParticipantCardsUseCase
    implements UseCase<List<ParticipantCardEntity>, String> {
  final MapEventContestsRepository repository;

  GetMyParticipantCardsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ParticipantCardEntity>>> call(String eventId) {
    return repository.getMyParticipantCards(eventId);
  }
}
