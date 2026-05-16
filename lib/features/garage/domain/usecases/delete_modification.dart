import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garage_repository.dart';

class DeleteModificationParams {
  final String carId;
  final String modId;
  const DeleteModificationParams({required this.carId, required this.modId});
}

@lazySingleton
class DeleteModificationUseCase
    implements UseCase<void, DeleteModificationParams> {
  final GarageRepository repository;

  DeleteModificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteModificationParams params) =>
      repository.deleteModification(params.carId, params.modId);
}
