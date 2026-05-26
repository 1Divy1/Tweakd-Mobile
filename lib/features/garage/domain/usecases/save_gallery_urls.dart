import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garage_repository.dart';

class SaveGalleryUrlsParams {
  final String carId;
  final List<String> urls;
  const SaveGalleryUrlsParams({required this.carId, required this.urls});
}

@lazySingleton
class SaveGalleryUrlsUseCase implements UseCase<void, SaveGalleryUrlsParams> {
  final GarageRepository repository;

  SaveGalleryUrlsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveGalleryUrlsParams params) {
    return repository.saveGalleryUrls(params.carId, params.urls);
  }
}
