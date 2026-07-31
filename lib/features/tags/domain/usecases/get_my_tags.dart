import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/tagged_item.dart';
import '../repositories/tags_repository.dart';

class GetMyTagsParams {
  final String? cursor;
  final int size;
  const GetMyTagsParams({this.cursor, this.size = 20});
}

@lazySingleton
class GetMyTagsUseCase
    implements UseCase<TaggedItemPageEntity, GetMyTagsParams> {
  final TagsRepository repository;

  GetMyTagsUseCase(this.repository);

  @override
  Future<Either<Failure, TaggedItemPageEntity>> call(GetMyTagsParams params) {
    return repository.getMyTags(cursor: params.cursor, size: params.size);
  }
}
