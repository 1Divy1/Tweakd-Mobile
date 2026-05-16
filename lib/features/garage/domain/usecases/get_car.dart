import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car.dart';
import '../repositories/garage_repository.dart';

class GetCarParams {
  final String carId;
  const GetCarParams({required this.carId});
}

@lazySingleton
class GetCarUseCase implements UseCase<CarEntity, GetCarParams> {
  final GarageRepository repository;

  GetCarUseCase(this.repository);

  @override
  Future<Either<Failure, CarEntity>> call(GetCarParams params) {
    return repository.getCar(params.carId);
  }
}
