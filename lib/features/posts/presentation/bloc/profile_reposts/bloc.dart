import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart' show Failure;
import '../../../domain/entities/post_pages.dart';
import '../../../domain/usecases/get_posts_by_username.dart';
import '../../../domain/usecases/get_reposts_by_username.dart';
import '../../utils/post_error_mapper.dart';
import '../profile_posts/event.dart';
import '../profile_posts/state.dart';

/// Backs the Reposts tab grid on a profile — own or someone else's, both read
/// by username. Speaks the Posts tab's events and states, so the same grid
/// section renders either: [LoadPostsByUsername] loads, [LoadMorePosts] pages,
/// [ReloadPosts] refreshes. Provided with the profile route but loaded only
/// when the tab is first opened.
@injectable
class ProfileRepostsBloc extends Bloc<ProfilePostsEvent, ProfilePostsState> {
  final GetRepostsByUsernameUseCase getReposts;

  /// Set on the first load so paging and reloads know whose reposts to fetch.
  String? _username;

  ProfileRepostsBloc(this.getReposts) : super(const ProfilePostsInitial()) {
    on<LoadPostsByUsername>(_onLoad);
    on<LoadMorePosts>(_onLoadMore);
    on<ReloadPosts>(_onReload);
  }

  Future<void> _onLoad(
    LoadPostsByUsername event,
    Emitter<ProfilePostsState> emit,
  ) async {
    _username = event.username;
    emit(const ProfilePostsLoading());
    final result = await getReposts(
      GetPostsByUsernameParams(username: event.username),
    );
    _emitFirstPage(emit, result);
  }

  Future<void> _onReload(
    ReloadPosts event,
    Emitter<ProfilePostsState> emit,
  ) async {
    final username = _username;
    if (username == null) return;
    final result = await getReposts(
      GetPostsByUsernameParams(username: username),
    );
    _emitFirstPage(emit, result);
  }

  Future<void> _onLoadMore(
    LoadMorePosts event,
    Emitter<ProfilePostsState> emit,
  ) async {
    final current = state;
    final username = _username;
    if (username == null ||
        current is! ProfilePostsLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    final result = await getReposts(
      GetPostsByUsernameParams(username: username, cursor: current.nextCursor),
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
