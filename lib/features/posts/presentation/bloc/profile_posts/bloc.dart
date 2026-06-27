import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart' show Failure;
import '../../../domain/entities/post_pages.dart';
import '../../../domain/usecases/get_my_posts.dart';
import '../../../domain/usecases/get_posts_by_username.dart';
import '../../utils/post_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Backs the Posts tab grid on a profile. Loads either the caller's own posts or
/// another user's posts by username, and pages through them with a cursor.
@injectable
class ProfilePostsBloc extends Bloc<ProfilePostsEvent, ProfilePostsState> {
  final GetMyPostsUseCase getMyPosts;
  final GetPostsByUsernameUseCase getPostsByUsername;

  /// Set on the first load so [LoadMorePosts] knows which source to page.
  String? _username;

  ProfilePostsBloc({
    required this.getMyPosts,
    required this.getPostsByUsername,
  }) : super(const ProfilePostsInitial()) {
    on<LoadMyPosts>(_onLoadMyPosts);
    on<LoadPostsByUsername>(_onLoadByUsername);
    on<LoadMorePosts>(_onLoadMore);
    on<ReloadPosts>(_onReload);
  }

  Future<void> _onReload(
    ReloadPosts event,
    Emitter<ProfilePostsState> emit,
  ) async {
    final username = _username;
    if (username == null) {
      final result = await getMyPosts(const GetMyPostsParams());
      _emitFirstPage(emit, result);
    } else {
      final result = await getPostsByUsername(
        GetPostsByUsernameParams(username: username),
      );
      _emitFirstPage(emit, result);
    }
  }

  Future<void> _onLoadMyPosts(
    LoadMyPosts event,
    Emitter<ProfilePostsState> emit,
  ) async {
    _username = null;
    emit(const ProfilePostsLoading());
    final result = await getMyPosts(const GetMyPostsParams());
    _emitFirstPage(emit, result);
  }

  Future<void> _onLoadByUsername(
    LoadPostsByUsername event,
    Emitter<ProfilePostsState> emit,
  ) async {
    _username = event.username;
    emit(const ProfilePostsLoading());
    final result = await getPostsByUsername(
      GetPostsByUsernameParams(username: event.username),
    );
    _emitFirstPage(emit, result);
  }

  Future<void> _onLoadMore(
    LoadMorePosts event,
    Emitter<ProfilePostsState> emit,
  ) async {
    final current = state;
    if (current is! ProfilePostsLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    final cursor = current.nextCursor;
    final result = _username == null
        ? await getMyPosts(GetMyPostsParams(cursor: cursor))
        : await getPostsByUsername(
            GetPostsByUsernameParams(username: _username!, cursor: cursor),
          );

    result.fold(
      // A failed "load more" shouldn't blow away what's already on screen.
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (page) => emit(ProfilePostsLoaded(
        posts: [...current.posts, ...page.items],
        nextCursor: page.nextCursor,
      )),
    );
  }

  void _emitFirstPage(
    Emitter<ProfilePostsState> emit,
    Either<Failure, PostPageEntity> result,
  ) {
    result.fold(
      (failure) => emit(ProfilePostsError(PostErrorMapper.getCode(failure))),
      (page) => emit(ProfilePostsLoaded(
        posts: page.items,
        nextCursor: page.nextCursor,
      )),
    );
  }
}
