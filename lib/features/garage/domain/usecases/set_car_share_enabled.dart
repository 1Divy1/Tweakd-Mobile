import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car_share.dart';
import '../repositories/garage_repository.dart';

class SetCarShareEnabledParams {
  final String carId;
  final bool enabled;
  const SetCarShareEnabledParams({required this.carId, required this.enabled});
}

/// Pauses or resumes a car's public page. There is deliberately no
/// "regenerate": the code may already be on a sticker, and silently
/// invalidating that is a foot-gun, not a feature.
@lazySingleton
class SetCarShareEnabledUseCase
    implements UseCase<CarShareEntity, SetCarShareEnabledParams> {
  final GarageRepository repository;

  SetCarShareEnabledUseCase(this.repository);

  @override
  Future<Either<Failure, CarShareEntity>> call(SetCarShareEnabledParams params) {
    return repository.setShareLinkEnabled(params.carId, params.enabled);
  }
}
