import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/onboarding reference/community_role_entity.dart';
import '../repositories/onboarding_repository.dart';

@lazySingleton
class GetCommunityRolesUseCase
    implements UseCase<List<CommunityRoleEntity>, NoParams> {
  final OnboardingRepository repository;

  GetCommunityRolesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CommunityRoleEntity>>> call(NoParams _) =>
      repository.getCommunityRoles();
}
