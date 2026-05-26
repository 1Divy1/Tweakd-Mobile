import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car_modification.dart';
import '../repositories/garage_repository.dart';

class AddModificationParams {
  final String carId;
  final ModRequestParams request;
  const AddModificationParams({required this.carId, required this.request});
}

@lazySingleton
class AddModificationUseCase
    implements UseCase<CarModificationEntity, AddModificationParams> {
  final GarageRepository repository;

  AddModificationUseCase(this.repository);

  @override
  Future<Either<Failure, CarModificationEntity>> call(
      AddModificationParams params) {
    return repository.addModification(params.carId, params.request);
  }
}
