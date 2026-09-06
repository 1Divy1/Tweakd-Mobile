import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car_share.dart';
import '../repositories/garage_repository.dart';

class EnsureCarShareLinkParams {
  final String carId;
  const EnsureCarShareLinkParams({required this.carId});
}

/// Opens (and, the first time, mints) a car's share link. Idempotent: the code
/// is stable for the life of the car, which is what makes a printed sticker
/// safe to glue on.
@lazySingleton
class EnsureCarShareLinkUseCase
    implements UseCase<CarShareEntity, EnsureCarShareLinkParams> {
  final GarageRepository repository;

  EnsureCarShareLinkUseCase(this.repository);

  @override
  Future<Either<Failure, CarShareEntity>> call(
    EnsureCarShareLinkParams params,
  ) {
    return repository.ensureShareLink(params.carId);
  }
}
