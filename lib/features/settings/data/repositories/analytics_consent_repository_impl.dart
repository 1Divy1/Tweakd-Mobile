import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../../authentication/domain/failures/auth_failures.dart';
import '../../domain/repositories/analytics_consent_repository.dart';
import '../datasources/analytics_consent_data_source.dart';

@LazySingleton(as: AnalyticsConsentRepository)
class AnalyticsConsentRepositoryImpl implements AnalyticsConsentRepository {
  final AnalyticsConsentDataSource dataSource;
  final AnalyticsService analytics;

  AnalyticsConsentRepositoryImpl(this.dataSource, this.analytics);

  @override
  Future<Either<Failure, bool>> getConsent() => _attempt(dataSource.getConsent);

  @override
  Future<Either<Failure, Unit>> setConsent(bool granted) => _attempt(() async {
    await dataSource.setConsent(granted);
    // Only once the account says so: tracking follows the saved choice, never
    // a toggle that failed to save. Awaited so the caller can record the
    // opt-in itself as the first tracked event.
    await analytics.applyConsent(
      userId: dataSource.currentUserId,
      granted: granted,
    );
    return unit;
  });

  Future<Either<Failure, T>> _attempt<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }
}
