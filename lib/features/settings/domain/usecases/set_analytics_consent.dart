import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/analytics_consent_repository.dart';

/// Params: whether the user now grants consent.
@lazySingleton
class SetAnalyticsConsent implements UseCase<Unit, bool> {
  final AnalyticsConsentRepository repository;

  SetAnalyticsConsent(this.repository);

  @override
  Future<Either<Failure, Unit>> call(bool granted) =>
      repository.setConsent(granted);
}
