import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garage_repository.dart';

class ResolveImageUrlParams {
  final String storagePath;
  const ResolveImageUrlParams({required this.storagePath});
}

@lazySingleton
class ResolveImageUrlUseCase implements UseCase<String, ResolveImageUrlParams> {
  final GarageRepository repository;

  ResolveImageUrlUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ResolveImageUrlParams params) {
    return repository.resolveImageUrl(params.storagePath);
  }
}
