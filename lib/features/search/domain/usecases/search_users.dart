import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

class SearchUsersParams {
  final String query;
  final CancelToken? cancelToken;

  const SearchUsersParams({required this.query, this.cancelToken});
}

@lazySingleton
class SearchUsersUseCase
    implements UseCase<List<SearchResultEntity>, SearchUsersParams> {
  final SearchRepository repository;

  SearchUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<SearchResultEntity>>> call(
    SearchUsersParams params,
  ) {
    return repository.searchUsers(
      params.query,
      cancelToken: params.cancelToken,
    );
  }
}
