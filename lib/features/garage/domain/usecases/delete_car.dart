import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garage_repository.dart';

class DeleteCarParams {
  final String carId;
  const DeleteCarParams({required this.carId});
}

@lazySingleton
class DeleteCarUseCase implements UseCase<void, DeleteCarParams> {
  final GarageRepository repository;

  DeleteCarUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCarParams params) {
    return repository.deleteCar(params.carId);
  }
}
