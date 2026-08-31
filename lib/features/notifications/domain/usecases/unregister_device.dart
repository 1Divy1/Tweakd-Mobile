import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notifications_repository.dart';

/// Removes this installation's push registration. Must run before sign-out —
/// the request is authorized with the session it is retiring.
@lazySingleton
class UnregisterDeviceUseCase implements UseCase<void, String> {
  final NotificationsRepository repository;

  UnregisterDeviceUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String token) =>
      repository.unregisterDevice(token);
}
