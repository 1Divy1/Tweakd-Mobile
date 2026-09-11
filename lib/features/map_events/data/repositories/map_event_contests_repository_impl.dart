import 'package:tweakd/core/error/base_exceptions.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/core/realtime/contest_realtime_service.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/car_event_history.dart';
import '../../domain/entities/contest.dart';
import '../../domain/entities/contest_board_update.dart';
import '../../domain/entities/contest_enums.dart';
import '../../domain/failures/map_event_failures.dart';
import '../../domain/repositories/map_event_contests_repository.dart';
import '../datasources/map_event_contests_api_data_source.dart';
import '../models/contest_models.dart';
import '../../domain/entities/participant_card.dart';

@LazySingleton(as: MapEventContestsRepository)
class MapEventContestsRepositoryImpl implements MapEventContestsRepository {
  final MapEventContestsApiDataSource api;
  final ContestRealtimeService realtime;

  MapEventContestsRepositoryImpl(this.api, this.realtime);

  @override
  Future<Either<Failure, List<ContestCategoryEntity>>> getCategories() {
    return _guard('getCategories', () async {
      final rows = await api.getCategories();
      return [for (final r in rows) r.toEntity()];
    });
  }

  @override
  Future<Either<Failure, List<ContestEntity>>> getContests(
    String eventId, {
    CancelToken? cancelToken,
  }) {
    return _guard('getContests', () async {
      final rows = await api.getContests(eventId, cancelToken: cancelToken);
      return [for (final r in rows) r.toEntity()];
    });
  }

  @override
  Future<Either<Failure, ContestEntity>> getContest(
    String eventId,
    String contestId, {
    CancelToken? cancelToken,
  }) {
    return _guard('getContest', () async {
      final row = await api.getContest(eventId, contestId, cancelToken: cancelToken);
      return row.toEntity();
    });
  }

  @override
  Future<Either<Failure, ContestEntity>> createContest(
    String eventId, {
    required String categoryId,
    required String title,
    String? criteria,
    required DateTime opensAt,
    required DateTime closesAt,
  }) {
    return _guard('createContest', () async {
      final row = await api.createContest(
        eventId,
        categoryId: categoryId,
        title: title,
        criteria: criteria,
        opensAt: opensAt,
        closesAt: closesAt,
      );
      return row.toEntity();
    });
  }

  @override
  Future<Either<Failure, ContestEntity>> updateContest(
    String eventId,
    String contestId, {
    String? title,
    String? criteria,
    DateTime? opensAt,
    DateTime? closesAt,
  }) {
    return _guard('updateContest', () async {
      final row = await api.updateContest(
        eventId,
        contestId,
        title: title,
        criteria: criteria,
        opensAt: opensAt,
        closesAt: closesAt,
      );
      return row.toEntity();
    });
  }

  @override
  Future<Either<Failure, ContestEntity>> openContest(
    String eventId,
    String contestId,
  ) {
    return _guard('openContest', () async {
      final row = await api.openContest(eventId, contestId);
      return row.toEntity();
    });
  }

  @override
  Future<Either<Failure, ContestEntity>> finishContest(
    String eventId,
    String contestId,
  ) {
    return _guard('finishContest', () async {
      final row = await api.finishContest(eventId, contestId);
      return row.toEntity();
    });
  }

  @override
  Future<Either<Failure, void>> deleteContest(String eventId, String contestId) {
    return _guard('deleteContest', () => api.deleteContest(eventId, contestId));
  }

  @override
  Future<Either<Failure, ContestEntity>> requestEntry(
    String eventId,
    String contestId,
    String carId,
  ) {
    return _guard('requestEntry', () async {
      final row = await api.requestEntry(eventId, contestId, carId);
      return row.toEntity();
    });
  }

  @override
  Future<Either<Failure, ContestEntity>> withdrawEntry(
    String eventId,
    String contestId,
    String carId,
  ) {
    return _guard('withdrawEntry', () async {
      final row = await api.withdrawEntry(eventId, contestId, carId);
      return row.toEntity();
    });
  }

  @override
  Future<Either<Failure, ContestEntity>> decideEntry(
    String eventId,
    String contestId,
    String carId, {
    required ContestEntryStatus status,
    String? reason,
  }) {
    return _guard('decideEntry', () async {
      final row = await api.decideEntry(
        eventId,
        contestId,
        carId,
        status: status.apiValue,
        reason: reason,
      );
      return row.toEntity();
    });
  }

  @override
  Future<Either<Failure, ContestEntity>> vote(
    String eventId,
    String contestId,
    String carId,
  ) {
    return _guard('vote', () async {
      final row = await api.vote(eventId, contestId, carId);
      return row.toEntity();
    });
  }

  @override
  Future<Either<Failure, List<CarEventHistoryItemEntity>>> getCarHistory(
    String carId, {
    CancelToken? cancelToken,
  }) {
    return _guard('getCarHistory', () async {
      final rows = await api.getCarHistory(carId, cancelToken: cancelToken);
      return [for (final r in rows) r.toEntity()];
    });
  }

  // ── Live boards ────────────────────────────────────────────────────────────

  @override
  Stream<ContestBoardUpdate> get boards => realtime.boards
      .map(parseContestBoard)
      .where((b) => b != null)
      .cast<ContestBoardUpdate>();

  @override
  Stream<ContestStatusUpdate> get statusChanges => realtime.statusChanges
      .map(parseContestStatus)
      .where((s) => s != null)
      .cast<ContestStatusUpdate>();

  @override
  bool isLive(String eventId) => realtime.isLive(eventId);

  @override
  Future<void> subscribeLive(String eventId) => realtime.subscribe(eventId);

  @override
  Future<void> unsubscribeLive(String eventId) => realtime.unsubscribe(eventId);

  /// Same shape as `MapEventsRepositoryImpl._guard`, with one difference: a
  /// 403 becomes [ContestNotEligibleFailure], whose message the UI shows
  /// verbatim — "you can't vote for your own car" is worth more than a generic
  /// forbidden line.
  Future<Either<Failure, T>> _guard<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    try {
      return Right(await action());
    } on RequestCancelledException {
      return const Left(RequestCancelledFailure());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConflictException catch (e) {
      return Left(
        MapEventParticipationConflictFailure(e.message, errorCode: e.errorCode),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(switch (e.statusCode) {
        404 => MapEventNotFoundFailure(e.message),
        403 => ContestNotEligibleFailure(e.message),
        400 || 422 => MapEventInvalidInputFailure(e.message),
        _ => ServerFailure(e.message),
      });
    } catch (e) {
      debugPrint('Unexpected error in MapEventContestsRepository.$operation: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, List<ParticipantCardEntity>>> getMyParticipantCards(
    String eventId,
  ) {
    return _guard('getMyParticipantCards', () async {
      final rows = await api.getMyParticipantCards(eventId);
      return [for (final r in rows) r.toEntity()];
    });
  }
}
