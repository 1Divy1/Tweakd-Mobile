import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/feedback_message.dart';
import '../../domain/entities/feedback_option.dart';
import '../../domain/entities/feedback_sort.dart';
import '../../domain/failures/feedback_feed_failures.dart';
import '../../domain/repositories/feedback_feed_repository.dart';
import '../datasources/feedback_feed_api_data_source.dart';

@LazySingleton(as: FeedbackFeedRepository)
class FeedbackFeedRepositoryImpl implements FeedbackFeedRepository {
  final FeedbackFeedApiDataSource dataSource;

  FeedbackFeedRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<FeedbackOptionEntity>>> getTypes() {
    return _guard(
      () async {
        final models = await dataSource.getTypes();
        return models.map((m) => m.toEntity()).toList();
      },
      context: 'getTypes',
      fallback: 'Failed to load the feedback categories.',
    );
  }

  @override
  Future<Either<Failure, List<FeedbackOptionEntity>>> getStatuses() {
    return _guard(
      () async {
        final models = await dataSource.getStatuses();
        return models.map((m) => m.toEntity()).toList();
      },
      context: 'getStatuses',
      fallback: 'Failed to load the feedback statuses.',
    );
  }

  @override
  Future<Either<Failure, FeedbackMessagePageEntity>> getFeed({
    required FeedbackSort sort,
    String? cursor,
    int size = 20,
  }) {
    return _guard(
      () async {
        final page = await dataSource.getFeed(
          sort: sort.wireValue,
          cursor: cursor,
          size: size,
        );
        return page.toEntity();
      },
      context: 'getFeed',
      fallback: 'Failed to load the feedback board.',
    );
  }

  @override
  Future<Either<Failure, FeedbackMessagePageEntity>> getCompleted({
    String? cursor,
    int size = 20,
  }) {
    return _guard(
      () async {
        final page = await dataSource.getCompleted(cursor: cursor, size: size);
        return page.toEntity();
      },
      context: 'getCompleted',
      fallback: 'Failed to load the completed requests.',
    );
  }

  @override
  Future<Either<Failure, FeedbackMessageEntity>> getMessage(String messageId) {
    return _guard(
      () async => (await dataSource.getMessage(messageId)).toEntity(),
      context: 'getMessage',
      fallback: 'Failed to load this feedback message.',
    );
  }

  @override
  Future<Either<Failure, Unit>> createMessage({
    required String typeId,
    required String message,
  }) {
    return _guard(
      () async {
        await dataSource.createMessage(typeId: typeId, message: message);
        return unit;
      },
      context: 'createMessage',
      fallback: 'Failed to post your feedback.',
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage(String messageId) {
    return _guard(
      () async {
        await dataSource.deleteMessage(messageId);
        return unit;
      },
      context: 'deleteMessage',
      fallback: 'Failed to delete your feedback.',
      // 409 means staff already picked the message up, so it can no longer be
      // deleted — the UI says so instead of showing a generic error.
      onConflict: (message) => FeedbackMessageLockedFailure(message),
    );
  }

  @override
  Future<Either<Failure, FeedbackMessageEntity>> vote({
    required String messageId,
    required int value,
  }) {
    return _guard(
      () async => (await dataSource.vote(messageId: messageId, value: value))
          .toEntity(),
      context: 'vote',
      fallback: 'Failed to register your vote.',
    );
  }

  @override
  Future<Either<Failure, FeedbackMessageEntity>> withdrawVote(
    String messageId,
  ) {
    return _guard(
      () async => (await dataSource.withdrawVote(messageId)).toEntity(),
      context: 'withdrawVote',
      fallback: 'Failed to withdraw your vote.',
    );
  }

  /// Runs [action], translating the data layer's exceptions into failures. Every
  /// method shares the same mapping; only the 409 case differs, so callers that
  /// care pass [onConflict].
  Future<Either<Failure, T>> _guard<T>(
    Future<T> Function() action, {
    required String context,
    required String fallback,
    Failure Function(String message)? onConflict,
  }) async {
    try {
      return Right(await action());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ConflictException catch (e) {
      return Left(onConflict?.call(e.message) ?? ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return Left(FeedbackMessageNotFoundFailure(e.message));
      }
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('feedback feed $context error: $e');
      return Left(UnknownFailure(fallback));
    }
  }
}
