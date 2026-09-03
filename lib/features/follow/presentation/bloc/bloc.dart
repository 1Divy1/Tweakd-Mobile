import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/follow_list_user.dart';
import '../../domain/entities/follow_status.dart';
import '../../domain/usecases/follow_user.dart';
import '../../domain/usecases/get_follow_status.dart';
import '../../domain/usecases/get_followers.dart';
import '../../domain/usecases/get_following.dart';
import '../../domain/usecases/remove_follower.dart';
import '../../domain/usecases/unfollow_user.dart';
import '../utils/follow_error_mapper.dart';
import 'event.dart';
import 'state.dart';

@injectable
class FollowBloc extends Bloc<FollowEvent, FollowState> {
  
  // Use cases
  final GetFollowStatusUseCase getFollowStatus;
  final FollowUserUseCase followUser;
  final UnfollowUserUseCase unfollowUser;
  final GetFollowersUseCase getFollowers;
  final GetFollowingUseCase getFollowing;
  final RemoveFollowerUseCase removeFollower;

  FollowBloc({
    required this.getFollowStatus,
    required this.followUser,
    required this.unfollowUser,
    required this.getFollowers,
    required this.getFollowing,
    required this.removeFollower,
  }) : super(FollowStatusInitial()) {
    on<LoadFollowStatus>(_onLoadFollowStatus);
    on<ToggleFollow>(_onToggleFollow);
    on<ToggleFollowInList>(_onToggleFollowInList);
    on<RemoveFollowerFromList>(_onRemoveFollowerFromList);
    on<LoadFollowers>(_onLoadFollowers);
    on<LoadFollowing>(_onLoadFollowing);
  }

  FutureOr<void> _onLoadFollowStatus(
    LoadFollowStatus event,
    Emitter<FollowState> emit,
  ) async {
    emit(FollowStatusLoading());

    final result = await getFollowStatus(
      GetFollowStatusParams(username: event.username),
    );

    result.fold(
      (failure) => emit(
        FollowError(code: FollowErrorMapper.getCode(failure)),
      ),
      (status) => emit(FollowStatusLoaded(followStatus: status)),
    );
  }

  FutureOr<void> _onToggleFollow(
    ToggleFollow event,
    Emitter<FollowState> emit,
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
    Emitter<FollowState> emit,
  ) async {
    final result = await followUser(FollowUserParams(username: username));

    result.fold(
      (failure) {
        emit(FollowError(code: FollowErrorMapper.getCode(failure)));
        emit(FollowStatusLoaded(followStatus: previousStatus));
      },
      (newStatus) => emit(FollowStatusLoaded(followStatus: newStatus)),
    );
  }

  Future<void> _doUnfollow(
    String username,
    FollowStatusEntity previousStatus,
    Emitter<FollowState> emit,
  ) async {
    final result = await unfollowUser(UnfollowUserParams(username: username));

    result.fold(
      (failure) {
        emit(FollowError(code: FollowErrorMapper.getCode(failure)));
        emit(FollowStatusLoaded(followStatus: previousStatus));
      },
      (_) => emit(
        FollowStatusLoaded(
          followStatus: const FollowStatusEntity(status: FollowStatus.notFollowing),
        ),
      ),
    );
  }

  FutureOr<void> _onToggleFollowInList(
    ToggleFollowInList event,
    Emitter<FollowState> emit,
  ) async {
    final current = state;

    final List<FollowListUserEntity> originalUsers;
    if (current is FollowersLoaded) {
      originalUsers = current.followers;
    } else if (current is FollowingLoaded) {
      originalUsers = current.following;
    } else {
      return;
    }

    final idx = originalUsers.indexWhere((u) => u.username == event.username);
    if (idx == -1) return;

    final wasFollowing = originalUsers[idx].isFollowing;
    final optimistic = originalUsers
        .map((u) => u.username == event.username ? u.copyWith(isFollowing: !wasFollowing) : u)
        .toList();

    if (current is FollowersLoaded) {
      emit(FollowersLoaded(followers: optimistic));
    } else {
      emit(FollowingLoaded(following: optimistic));
    }

    final result = wasFollowing
        ? await unfollowUser(UnfollowUserParams(username: event.username))
        : await followUser(FollowUserParams(username: event.username));

    result.fold(
      (failure) {
        if (current is FollowersLoaded) {
          emit(FollowersLoaded(followers: originalUsers));
        } else {
          emit(FollowingLoaded(following: originalUsers));
        }
      },
      (_) {},
    );
  }

  FutureOr<void> _onRemoveFollowerFromList(
    RemoveFollowerFromList event,
    Emitter<FollowState> emit,
  ) async {
    final current = state;
    if (current is! FollowersLoaded) return;

    final originalFollowers = current.followers;
    final optimistic = originalFollowers.where((u) => u.username != event.username).toList();
    emit(FollowersLoaded(followers: optimistic));

    final result = await removeFollower(RemoveFollowerParams(username: event.username));

    result.fold(
      (failure) => emit(FollowersLoaded(followers: originalFollowers)),
      (_) {},
    );
  }
  
  FutureOr<void> _onLoadFollowers(LoadFollowers event, Emitter<FollowState> emit) async {
    emit(FollowersLoading());
    
    final result = await getFollowers(GetFollowersParams(username: event.username));

    result.fold(
      (failure) => emit(FollowError(code: FollowErrorMapper.getCode(failure))),
      (followers) {
        debugPrint('Loaded ${followers.length} followers for user ${event.username}:');
        debugPrint('Followers list: $followers');

        emit(FollowersLoaded(followers: followers));
      },
    );
  }

  FutureOr<void> _onLoadFollowing(LoadFollowing event, Emitter<FollowState> emit) async {
    emit(FollowingLoading());
    final result = await getFollowing(GetFollowingParams(username: event.username));

    result.fold(
      (failure) => emit(FollowError(code: FollowErrorMapper.getCode(failure))),
      (following) {
        debugPrint('Loaded ${following.length} following for user ${event.username}:');
        debugPrint('Following list: $following');

        emit(FollowingLoaded(following: following));
      },
    );
  }
}
