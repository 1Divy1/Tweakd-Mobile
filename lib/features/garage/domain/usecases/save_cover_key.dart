import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garage_repository.dart';

class SaveCoverKeyParams {
  final String carId;
  final String key;
  const SaveCoverKeyParams({required this.carId, required this.key});
}

@lazySingleton
class SaveCoverKeyUseCase implements UseCase<void, SaveCoverKeyParams> {
  final GarageRepository repository;

  SaveCoverKeyUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveCoverKeyParams params) {
    return repository.saveCoverKey(params.carId, params.key);
  }
}
