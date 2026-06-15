import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garage_repository.dart';

class DeleteCoverImageParams {
  final String carId;
  final String url;
  const DeleteCoverImageParams({required this.carId, required this.url});
}

@lazySingleton
class DeleteCoverImageUseCase implements UseCase<void, DeleteCoverImageParams> {
  final GarageRepository repository;

  DeleteCoverImageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCoverImageParams params) {
    return repository.deleteCoverImage(params.carId, params.url);
  }
}
