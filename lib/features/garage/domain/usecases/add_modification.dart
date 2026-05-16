import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/create_car_result.dart';
import '../repositories/garage_repository.dart';

class AddModificationParams {
  final String carId;
  final ModRequestParams request;
  const AddModificationParams({required this.carId, required this.request});
}

@lazySingleton
class AddModificationUseCase
    implements UseCase<AddModificationResult, AddModificationParams> {
  final GarageRepository repository;

  AddModificationUseCase(this.repository);

  @override
  Future<Either<Failure, AddModificationResult>> call(
      AddModificationParams params) {
    return repository.addModification(params.carId, params.request);
  }
}
