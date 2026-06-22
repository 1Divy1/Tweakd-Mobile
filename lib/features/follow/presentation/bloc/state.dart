import 'package:equatable/equatable.dart';

import '../../domain/entities/follow_list_user.dart';
import '../../domain/entities/follow_status.dart';
import '../utils/follow_error_mapper.dart';

abstract class FollowState extends Equatable {
  const FollowState();

  @override
  List<Object?> get props => [];
}

// ---------- Basic follow states ----------

class FollowStatusInitial extends FollowState {}

class FollowStatusLoading extends FollowState {}

class FollowStatusLoaded extends FollowState {
  final FollowStatusEntity followStatus;
  final bool isUpdating;

  const FollowStatusLoaded({required this.followStatus, this.isUpdating = false});

  FollowStatusLoaded copyWith({FollowStatusEntity? followStatus, bool? isUpdating}) {
    return FollowStatusLoaded(
      followStatus: followStatus ?? this.followStatus,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [followStatus.status, isUpdating];
}

class FollowError extends FollowState {
  final FollowErrorCode code;

  const FollowError({required this.code});

  @override
  List<Object?> get props => [code];
}

// ---------- Followers & Following states ----------

class FollowersLoading extends FollowState {}

class FollowingLoading extends FollowState {}

class FollowersLoaded extends FollowState {
  final List<FollowListUserEntity> followers;

  const FollowersLoaded({required this.followers});

  @override
  List<Object?> get props => [followers];
}

class FollowingLoaded extends FollowState {
  final List<FollowListUserEntity> following;

  const FollowingLoaded({required this.following});

  @override
  List<Object?> get props => [following];
}
