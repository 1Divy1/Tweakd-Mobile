import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car.dart';
import '../repositories/garage_repository.dart';

class UpdateCarParams {
  final String carId;
  final CarRequestParams request;
  const UpdateCarParams({required this.carId, required this.request});
}

@lazySingleton
class UpdateCarUseCase implements UseCase<CarEntity, UpdateCarParams> {
  final GarageRepository repository;

  UpdateCarUseCase(this.repository);

  @override
  Future<Either<Failure, CarEntity>> call(UpdateCarParams params) {
    return repository.updateCar(params.carId, params.request);
  }
}
