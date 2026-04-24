import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';

class UsernameParams {
  final String username;
  UsernameParams({required this.username});
}

@lazySingleton
class UpdateUsernameUseCase implements UseCase<void, UsernameParams> {
  final AuthRepository repository;
  UpdateUsernameUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UsernameParams params) {
    return repository.updateUsername(params.username);
  }
}