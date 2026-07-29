import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class SetAppLanguageParams {
  final String languageId;

  const SetAppLanguageParams({required this.languageId});
}

@lazySingleton
class SetAppLanguageUseCase
    implements UseCase<ProfileEntity, SetAppLanguageParams> {
  final ProfileRepository repository;

  SetAppLanguageUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(SetAppLanguageParams params) {
    return repository.setAppLanguage(params.languageId);
  }
}
