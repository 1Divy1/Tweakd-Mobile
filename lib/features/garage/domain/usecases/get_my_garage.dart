import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/garage.dart';
import '../repositories/garage_repository.dart';

@lazySingleton
class GetMyGarageUseCase implements UseCase<GarageEntity, NoParams> {
  final GarageRepository repository;

  GetMyGarageUseCase(this.repository);

  @override
  Future<Either<Failure, GarageEntity>> call(NoParams params) {
    return repository.getMyGarage();
  }
}
