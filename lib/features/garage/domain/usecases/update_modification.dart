import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garage_repository.dart';

class UpdateModificationParams extends Equatable {
  final String carId;
  final String modId;
  final ModRequestParams request;

  const UpdateModificationParams({
    required this.carId,
    required this.modId,
    required this.request,
  });

  @override
  List<Object?> get props => [carId, modId, request];
}

@lazySingleton
class UpdateModificationUseCase implements UseCase<void, UpdateModificationParams> {
  final GarageRepository repository;

  UpdateModificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateModificationParams params) async {
    return await repository.updateModification(
        params.carId, params.modId, params.request);
  }
}
