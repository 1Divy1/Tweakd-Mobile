import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notifications_repository.dart';

/// Fetches one cursor page of the viewer's notifications.
@lazySingleton
class GetNotificationsUseCase
    implements UseCase<NotificationPageEntity, GetNotificationsParams> {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, NotificationPageEntity>> call(
    GetNotificationsParams params,
  ) =>
      repository.getNotifications(cursor: params.cursor, size: params.size);
}

class GetNotificationsParams {
  final String? cursor;
  final int size;

  const GetNotificationsParams({this.cursor, this.size = 20});
}
