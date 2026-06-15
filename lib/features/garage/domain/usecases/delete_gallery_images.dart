import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garage_repository.dart';

class DeleteGalleryImagesParams {
  final String carId;
  final List<String> urls;
  const DeleteGalleryImagesParams({required this.carId, required this.urls});
}

@lazySingleton
class DeleteGalleryImagesUseCase
    implements UseCase<void, DeleteGalleryImagesParams> {
  final GarageRepository repository;

  DeleteGalleryImagesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteGalleryImagesParams params) {
    return repository.deleteGalleryImages(params.carId, params.urls);
  }
}
