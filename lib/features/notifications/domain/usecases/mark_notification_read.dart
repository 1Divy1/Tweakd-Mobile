import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notifications_repository.dart';

/// Marks a single notification read.
@lazySingleton
class MarkNotificationReadUseCase implements UseCase<void, String> {
  final NotificationsRepository repository;

  MarkNotificationReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) => repository.markRead(id);
}
