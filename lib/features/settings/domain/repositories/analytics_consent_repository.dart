import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';

abstract class AnalyticsConsentRepository {
  /// Whether the signed-in account has opted in to product analytics.
  Future<Either<Failure, bool>> getConsent();

  /// Saves the choice on the account, then switches tracking on or off.
  Future<Either<Failure, Unit>> setConsent(bool granted);
}
