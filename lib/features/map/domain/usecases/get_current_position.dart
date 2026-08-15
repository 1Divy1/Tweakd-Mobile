import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/geo_position.dart';
import '../repositories/map_repository.dart';

@lazySingleton
class GetCurrentPositionUseCase implements UseCase<GeoPosition, NoParams> {
  final MapRepository repository;

  GetCurrentPositionUseCase(this.repository);

  @override
  Future<Either<Failure, GeoPosition>> call(NoParams params) {
    return repository.getCurrentPosition();
  }
}
