import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_suggestion.dart';
import '../repositories/forums_repository.dart';

class GetForumSuggestionsParams {
  final int limit;

  const GetForumSuggestionsParams({this.limit = 10});
}

/// The most active brands, models and topics for the empty-paddock hub picker.
@lazySingleton
class GetForumSuggestionsUseCase
    implements
        UseCase<List<ForumSuggestionEntity>, GetForumSuggestionsParams> {
  final ForumsRepository repository;

  GetForumSuggestionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ForumSuggestionEntity>>> call(
      GetForumSuggestionsParams params) {
    return repository.getSuggestions(limit: params.limit);
  }
}
