import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/my_report.dart';
import '../../domain/entities/report_reason.dart';
import '../../domain/entities/report_target.dart';
import '../../domain/failures/report_failures.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_api_data_source.dart';

@LazySingleton(as: ReportRepository)
class ReportRepositoryImpl implements ReportRepository {
  final ReportApiDataSource dataSource;

  ReportRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ReportReasonEntity>>> getReasons(
    ReportTarget target,
  ) async {
    try {
      final models = switch (target) {
        PostReportTarget() => await dataSource.getPostReasons(),
        CommentReportTarget() => await dataSource.getCommentReasons(),
        ProfileReportTarget() => await dataSource.getProfileReasons(),
      };
      return Right(models.map((m) => m.toEntity()).toList());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getReasons error: $e');
      return const Left(UnknownFailure('Failed to load report reasons.'));
    }
  }

  @override
  Future<Either<Failure, void>> submitReport(
    ReportTarget target,
    String reasonId,
  ) async {
    try {
      switch (target) {
        case PostReportTarget(:final postId):
          await dataSource.reportPost(postId, reasonId);
        case CommentReportTarget(:final postId, :final commentId):
          await dataSource.reportComment(postId, commentId, reasonId);
        case ProfileReportTarget(:final username):
          await dataSource.reportProfile(username, reasonId);
      }
      return const Right(null);
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ConflictException {
      // 409 — the viewer already reported this target.
      return const Left(AlreadyReportedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const Left(ReportTargetNotFoundFailure());
      if (e.statusCode == 400) {
        // A 400 means self-report for a post/profile, but a bad/mismatched
        // reason for a comment.
        return target is CommentReportTarget
            ? const Left(InvalidReportReasonFailure())
            : const Left(SelfReportFailure());
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('submitReport error: $e');
      return const Left(UnknownFailure('Failed to submit report.'));
    }
  }

  @override
  Future<Either<Failure, List<MyReportEntity>>> getMyReports() async {
    try {
      final models = await dataSource.getMyReports();
      return Right(models.map((m) => m.toEntity()).toList());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getMyReports error: $e');
      return const Left(UnknownFailure('Failed to load your reports.'));
    }
  }
}
