import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/follow_request.dart';
import '../entities/follow_status.dart';
import '../entities/follow_user.dart';

abstract class FollowRepository {
  Future<Either<Failure, FollowStatusEntity>> follow(String username);

  Future<Either<Failure, Unit>> unfollow(String username);

  Future<Either<Failure, FollowStatusEntity>> getFollowStatus(String username);

  Future<Either<Failure, List<FollowRequestEntity>>> getPendingRequests();

  Future<Either<Failure, Unit>> acceptRequest(String username);

  Future<Either<Failure, Unit>> rejectRequest(String username);

  Future<Either<Failure, List<FollowUserEntity>>> getFollowers(String username);

  Future<Either<Failure, List<FollowUserEntity>>> getFollowing(String username);
}
