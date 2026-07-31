import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/tagged_item.dart';
import '../repositories/tags_repository.dart';

class GetTagsByUsernameParams {
  final String username;
  final String? cursor;
  final int size;
  const GetTagsByUsernameParams({
    required this.username,
    this.cursor,
    this.size = 20,
  });
}

@lazySingleton
class GetTagsByUsernameUseCase
    implements UseCase<TaggedItemPageEntity, GetTagsByUsernameParams> {
  final TagsRepository repository;

  GetTagsByUsernameUseCase(this.repository);

  @override
  Future<Either<Failure, TaggedItemPageEntity>> call(
    GetTagsByUsernameParams params,
  ) {
    return repository.getTagsByUsername(
      params.username,
      cursor: params.cursor,
      size: params.size,
    );
  }
}
