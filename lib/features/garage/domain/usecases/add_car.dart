import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/create_car_result.dart';
import '../repositories/garage_repository.dart';

@lazySingleton
class AddCarUseCase implements UseCase<CreateCarResult, CreateCarParams> {
  final GarageRepository repository;

  AddCarUseCase(this.repository);

  @override
  Future<Either<Failure, CreateCarResult>> call(CreateCarParams params) {
    return repository.addCar(params);
  }
}
