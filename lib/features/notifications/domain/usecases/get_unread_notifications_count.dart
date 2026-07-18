import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notifications_repository.dart';

/// Unread notification count — drives the feed top-bar notifications badge.
@lazySingleton
class GetUnreadNotificationsCountUseCase implements UseCase<int, NoParams> {
  final NotificationsRepository repository;

  GetUnreadNotificationsCountUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) =>
      repository.getUnreadCount();
}
