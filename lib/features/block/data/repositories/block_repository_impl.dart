import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/blocked_account.dart';
import '../../domain/failures/block_failures.dart';
import '../../domain/repositories/block_repository.dart';
import '../datasources/block_api_data_source.dart';

@LazySingleton(as: BlockRepository)
class BlockRepositoryImpl implements BlockRepository {
  final BlockApiDataSource dataSource;

  BlockRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Unit>> block(String username) {
    return _guard('block', () async {
      await dataSource.block(username);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> unblock(String username) {
    return _guard('unblock', () async {
      await dataSource.unblock(username);
      return unit;
    });
  }

  @override
  Future<Either<Failure, List<BlockedAccountEntity>>> getBlockedAccounts() {
    return _guard('getBlockedAccounts', () async {
      final models = await dataSource.getBlockedAccounts();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  /// The one exception → failure mapping shared by every call here.
  Future<Either<Failure, T>> _guard<T>(
    String action,
    Future<T> Function() run,
  ) async {
    try {
      return Right(await run());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ApiException catch (e) {
      if (e.statusCode == 400) return const Left(CannotBlockSelfFailure());
      if (e.statusCode == 404) return const Left(BlockTargetNotFoundFailure());
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('$action error: $e');
      return const Left(UnknownFailure('Something went wrong.'));
    }
  }
}
