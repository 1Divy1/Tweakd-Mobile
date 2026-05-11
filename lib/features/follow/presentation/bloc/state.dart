import 'package:equatable/equatable.dart';

import '../../domain/entities/follow_status.dart';

abstract class FollowStatusState extends Equatable {
  const FollowStatusState();

  @override
  List<Object?> get props => [];
}

class FollowStatusInitial extends FollowStatusState {}

class FollowStatusLoading extends FollowStatusState {}

class FollowStatusLoaded extends FollowStatusState {
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

class FollowStatusError extends FollowStatusState {
  final String message;

  const FollowStatusError({required this.message});

  @override
  List<Object?> get props => [message];
}
