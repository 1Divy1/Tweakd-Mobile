import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/push_device.dart';
import '../repositories/notifications_repository.dart';

/// Registers this installation's FCM token against the signed-in user.
@lazySingleton
class RegisterDeviceUseCase implements UseCase<void, PushDeviceEntity> {
  final NotificationsRepository repository;

  RegisterDeviceUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PushDeviceEntity device) =>
      repository.registerDevice(device);
}
