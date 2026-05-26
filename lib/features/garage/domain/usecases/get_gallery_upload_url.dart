import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/create_car_result.dart';
import '../repositories/garage_repository.dart';

class GetGalleryUploadUrlParams {
  final String carId;
  const GetGalleryUploadUrlParams({required this.carId});
}

@lazySingleton
class GetGalleryUploadUrlUseCase
    implements UseCase<UploadUrlResult, GetGalleryUploadUrlParams> {
  final GarageRepository repository;

  GetGalleryUploadUrlUseCase(this.repository);

  @override
  Future<Either<Failure, UploadUrlResult>> call(
      GetGalleryUploadUrlParams params) {
    return repository.getGalleryUploadUrl(params.carId);
  }
}
