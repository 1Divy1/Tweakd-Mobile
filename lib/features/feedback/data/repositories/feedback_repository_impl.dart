import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/feedback_feature.dart';
import '../../domain/entities/feedback_type.dart';
import '../../domain/entities/my_feedback.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../datasources/feedback_api_data_source.dart';

@LazySingleton(as: FeedbackRepository)
class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackApiDataSource dataSource;

  FeedbackRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<FeedbackTypeEntity>>> getTypes() async {
    try {
      final models = await dataSource.getTypes();
      return Right(models.map((m) => m.toEntity()).toList());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getFeedbackTypes error: $e');
      return const Left(UnknownFailure('Failed to load feedback types.'));
    }
  }

  @override
  Future<Either<Failure, List<FeedbackFeatureEntity>>> getFeatures() async {
    try {
      final models = await dataSource.getFeatures();
      return Right(models.map((m) => m.toEntity()).toList());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getFeedbackFeatures error: $e');
      return const Left(UnknownFailure('Failed to load feedback features.'));
    }
  }

  @override
  Future<Either<Failure, void>> submitFeedback(
    FeedbackSubmission submission,
  ) async {
    try {
      await dataSource.submitFeedback(
        content: submission.content,
        type: submission.typeId,
        feature: submission.featureId,
        reproductionSteps: submission.reproductionSteps,
      );
      return const Right(null);
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('submitFeedback error: $e');
      return const Left(UnknownFailure('Failed to submit feedback.'));
    }
  }

  @override
  Future<Either<Failure, List<MyFeedbackEntity>>> getMyFeedback() async {
    try {
      final models = await dataSource.getMyFeedback();
      return Right(models.map((m) => m.toEntity()).toList());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getMyFeedback error: $e');
      return const Left(UnknownFailure('Failed to load your feedback.'));
    }
  }
}
