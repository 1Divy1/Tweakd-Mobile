import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/language_option.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class GetLanguageOptionsUseCase
    implements UseCase<List<LanguageOptionEntity>, NoParams> {
  final ProfileRepository repository;

  GetLanguageOptionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<LanguageOptionEntity>>> call(NoParams params) {
    return repository.getLanguageOptions();
  }
}
