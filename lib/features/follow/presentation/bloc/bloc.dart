import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/follow_status.dart';
import '../../domain/usecases/follow_user.dart';
import '../../domain/usecases/get_follow_status.dart';
import '../../domain/usecases/unfollow_user.dart';
import '../utils/follow_error_mapper.dart';
import 'event.dart';
import 'state.dart';

@injectable
class FollowStatusBloc extends Bloc<FollowStatusEvent, FollowStatusState> {
  final GetFollowStatusUseCase getFollowStatus;
  final FollowUserUseCase followUser;
  final UnfollowUserUseCase unfollowUser;

  FollowStatusBloc({
    required this.getFollowStatus,
    required this.followUser,
    required this.unfollowUser,
  }) : super(FollowStatusInitial()) {
    on<LoadFollowStatus>(_onLoadFollowStatus);
    on<ToggleFollow>(_onToggleFollow);
  }

  FutureOr<void> _onLoadFollowStatus(
    LoadFollowStatus event,
    Emitter<FollowStatusState> emit,
  ) async {
    emit(FollowStatusLoading());

    final result = await getFollowStatus(
      GetFollowStatusParams(username: event.username),
    );

    result.fold(
      (failure) => emit(
        FollowStatusError(message: FollowErrorMapper.getMessage(failure)),
      ),
      (status) => emit(FollowStatusLoaded(followStatus: status)),
    );
  }

  FutureOr<void> _onToggleFollow(
    ToggleFollow event,
    Emitter<FollowStatusState> emit,
  ) async {
    final current = state;
    if (current is! FollowStatusLoaded || current.isUpdating) return;

    emit(current.copyWith(isUpdating: true));

    if (current.followStatus.isNotFollowing) {
      await _doFollow(event.username, current.followStatus, emit);
    } else {
      await _doUnfollow(event.username, current.followStatus, emit);
    }
  }

  Future<void> _doFollow(
    String username,
    FollowStatusEntity previousStatus,
    Emitter<FollowStatusState> emit,
  ) async {
    final result = await followUser(FollowUserParams(username: username));

    result.fold(
      (failure) {
        emit(FollowStatusError(message: FollowErrorMapper.getMessage(failure)));
        emit(FollowStatusLoaded(followStatus: previousStatus));
      },
      (newStatus) => emit(FollowStatusLoaded(followStatus: newStatus)),
    );
  }

  Future<void> _doUnfollow(
    String username,
    FollowStatusEntity previousStatus,
    Emitter<FollowStatusState> emit,
  ) async {
    final result = await unfollowUser(UnfollowUserParams(username: username));

    result.fold(
      (failure) {
        emit(FollowStatusError(message: FollowErrorMapper.getMessage(failure)));
        emit(FollowStatusLoaded(followStatus: previousStatus));
      },
      (_) => emit(
        FollowStatusLoaded(
          followStatus: const FollowStatusEntity(status: FollowStatus.notFollowing),
        ),
      ),
    );
  }
}
