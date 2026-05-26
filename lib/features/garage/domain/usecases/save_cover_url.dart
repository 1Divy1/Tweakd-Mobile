import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garage_repository.dart';

class SaveCoverUrlParams {
  final String carId;
  final String finalUrl;
  const SaveCoverUrlParams({required this.carId, required this.finalUrl});
}

@lazySingleton
class SaveCoverUrlUseCase implements UseCase<void, SaveCoverUrlParams> {
  final GarageRepository repository;

  SaveCoverUrlUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveCoverUrlParams params) {
    return repository.saveCoverUrl(params.carId, params.finalUrl);
  }
}
