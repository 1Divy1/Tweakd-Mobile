import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/create_car_result.dart';
import '../repositories/garage_repository.dart';

class GetCoverUploadUrlParams {
  final String carId;
  const GetCoverUploadUrlParams({required this.carId});
}

@lazySingleton
class GetCoverUploadUrlUseCase
    implements UseCase<UploadUrlResult, GetCoverUploadUrlParams> {
  final GarageRepository repository;

  GetCoverUploadUrlUseCase(this.repository);

  @override
  Future<Either<Failure, UploadUrlResult>> call(
      GetCoverUploadUrlParams params) {
    return repository.getCoverUploadUrl(params.carId);
  }
}
