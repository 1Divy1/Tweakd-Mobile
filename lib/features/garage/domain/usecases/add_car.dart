import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car.dart';
import '../repositories/garage_repository.dart';

@lazySingleton
class AddCarUseCase implements UseCase<CarEntity, CreateCarParams> {
  final GarageRepository repository;

  AddCarUseCase(this.repository);

  @override
  Future<Either<Failure, CarEntity>> call(CreateCarParams params) {
    return repository.addCar(params);
  }
}
