import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car_image.dart';
import '../repositories/garage_repository.dart';

class GetCarImagesParams {
  final String carId;
  const GetCarImagesParams({required this.carId});
}

@lazySingleton
class GetCarImagesUseCase
    implements UseCase<List<CarImageEntity>, GetCarImagesParams> {
  final GarageRepository repository;

  GetCarImagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarImageEntity>>> call(
          GetCarImagesParams params) =>
      repository.listCarImages(params.carId);
}
