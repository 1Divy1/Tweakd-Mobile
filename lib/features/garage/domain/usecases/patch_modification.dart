import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car_modification.dart';
import '../repositories/garage_repository.dart';

class PatchModificationParams {
  final String carId;
  final String modId;
  final ModPatchParams params;

  const PatchModificationParams({
    required this.carId,
    required this.modId,
    required this.params,
  });
}

@lazySingleton
class PatchModificationUseCase
    implements UseCase<CarModificationEntity, PatchModificationParams> {
  final GarageRepository repository;

  PatchModificationUseCase(this.repository);

  @override
  Future<Either<Failure, CarModificationEntity>> call(
      PatchModificationParams params) {
    return repository.patchModification(
        params.carId, params.modId, params.params);
  }
}
