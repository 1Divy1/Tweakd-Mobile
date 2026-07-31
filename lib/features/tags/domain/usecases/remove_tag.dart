import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/tagged_item.dart';
import '../repositories/tags_repository.dart';

class RemoveTagParams {
  final TaggedItemKind kind;
  final String targetId;
  const RemoveTagParams({required this.kind, required this.targetId});
}

@lazySingleton
class RemoveTagUseCase implements UseCase<void, RemoveTagParams> {
  final TagsRepository repository;

  RemoveTagUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveTagParams params) {
    return repository.removeTag(params.kind, params.targetId);
  }
}
