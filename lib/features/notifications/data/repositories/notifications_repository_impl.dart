import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_api_data_source.dart';

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsDataSource dataSource;

  NotificationsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, NotificationPageEntity>> getNotifications({
    String? cursor,
    int size = 20,
  }) async {
    try {
      final model =
          await dataSource.getNotifications(cursor: cursor, size: size);
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getNotifications error: $e');
      return const Left(UnknownFailure('Failed to load notifications.'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await dataSource.getUnreadCount();
      return Right(count);
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getUnreadCount (notifications) error: $e');
      return const Left(UnknownFailure('Failed to load the unread count.'));
    }
  }

  @override
  Future<Either<Failure, void>> markRead(String id) async {
    try {
      await dataSource.markRead(id);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('markRead (notification) error: $e');
      return const Left(UnknownFailure('Failed to mark the notification read.'));
    }
  }

  @override
  Future<Either<Failure, int>> markAllRead() async {
    try {
      final updated = await dataSource.markAllRead();
      return Right(updated);
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('markAllRead (notifications) error: $e');
      return const Left(UnknownFailure('Failed to mark all read.'));
    }
  }
}
