import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garage_repository.dart';

class DeleteCarImageParams {
  final String carId;
  final String imageId;
  const DeleteCarImageParams({required this.carId, required this.imageId});
}

@lazySingleton
class DeleteCarImageUseCase implements UseCase<void, DeleteCarImageParams> {
  final GarageRepository repository;

  DeleteCarImageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCarImageParams params) =>
      repository.deleteCarImage(params.carId, params.imageId);
}
