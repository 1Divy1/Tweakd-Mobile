import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/analytics_consent_repository.dart';

@lazySingleton
class GetAnalyticsConsent implements UseCase<bool, NoParams> {
  final AnalyticsConsentRepository repository;

  GetAnalyticsConsent(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      repository.getConsent();
}
