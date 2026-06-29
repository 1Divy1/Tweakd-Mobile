import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garage_repository.dart';

class SaveGalleryKeysParams {
  final String carId;
  final List<String> keys;
  const SaveGalleryKeysParams({required this.carId, required this.keys});
}

@lazySingleton
class SaveGalleryKeysUseCase implements UseCase<void, SaveGalleryKeysParams> {
  final GarageRepository repository;

  SaveGalleryKeysUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveGalleryKeysParams params) {
    return repository.saveGalleryKeys(params.carId, params.keys);
  }
}
