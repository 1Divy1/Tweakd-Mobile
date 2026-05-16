import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/garage.dart';
import '../repositories/garage_repository.dart';

class GetGarageByUsernameParams {
  final String username;
  const GetGarageByUsernameParams({required this.username});
}

@lazySingleton
class GetGarageByUsernameUseCase
    implements UseCase<GarageEntity, GetGarageByUsernameParams> {
  final GarageRepository repository;

  GetGarageByUsernameUseCase(this.repository);

  @override
  Future<Either<Failure, GarageEntity>> call(GetGarageByUsernameParams params) {
    return repository.getGarageByUsername(params.username);
  }
}
