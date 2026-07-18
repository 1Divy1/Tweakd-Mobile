import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notifications_repository.dart';

/// Marks every notification read; resolves with the number updated.
@lazySingleton
class MarkAllNotificationsReadUseCase implements UseCase<int, NoParams> {
  final NotificationsRepository repository;

  MarkAllNotificationsReadUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) =>
      repository.markAllRead();
}
