import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/messages_repository.dart';

/// Total unread DM count across all conversations — drives the app-level
/// DMs badge on the feed top bar.
@lazySingleton
class GetUnreadCountUseCase implements UseCase<int, NoParams> {
  final MessagesRepository repository;

  GetUnreadCountUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) =>
      repository.getUnreadCount();
}
