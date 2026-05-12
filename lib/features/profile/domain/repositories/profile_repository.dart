import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getCurrentUserProfile({bool forceRefresh});

  Future<Either<Failure, ProfileEntity>> submitOnboarding({
    required String username,
    String? bio,
  });

  Future<Either<Failure, ProfileEntity>> getProfileByUsername(String username);
}
