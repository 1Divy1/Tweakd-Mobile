import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/create_car_result.dart';
import '../repositories/garage_repository.dart';

class GetModificationUploadUrlsParams {
  final String carId;
  final String modId;
  final List<ModUploadRequest> files;

  const GetModificationUploadUrlsParams({
    required this.carId,
    required this.modId,
    required this.files,
  });
}

@lazySingleton
class GetModificationUploadUrlsUseCase
    implements
        UseCase<ModUploadUrlsResult, GetModificationUploadUrlsParams> {
  final GarageRepository repository;

  GetModificationUploadUrlsUseCase(this.repository);

  @override
  Future<Either<Failure, ModUploadUrlsResult>> call(
      GetModificationUploadUrlsParams params) {
    return repository.getModificationUploadUrls(
        params.carId, params.modId, params.files);
  }
}
