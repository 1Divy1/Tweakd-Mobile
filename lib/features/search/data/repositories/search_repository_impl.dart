import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasource/search_api_data_source.dart';

@LazySingleton(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  final SearchApiDataSource searchApiDataSource;

  SearchRepositoryImpl(this.searchApiDataSource);

  @override
  Future<Either<Failure, List<SearchResultEntity>>> searchUsers(
    String query, {
    CancelToken? cancelToken,
  }) async {
    try {
      final results = await searchApiDataSource.searchUsers(
        query,
        cancelToken: cancelToken,
      );
      return Right(results.map((m) => m.toEntity()).toList());
    } on RequestCancelledException {
      return const Left(RequestCancelledFailure());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in searchUsers: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }
}
