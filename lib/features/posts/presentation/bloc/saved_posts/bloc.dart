import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart' show Failure;
import '../../../domain/entities/post.dart';
import '../../../domain/entities/post_pages.dart';
import '../../../domain/usecases/get_saved_posts.dart';
import '../../utils/post_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Backs the "Saved posts" page: a cursor-paginated grid of the signed-in
/// user's saved posts, with pull-to-refresh and infinite scroll. Items are
/// deduped by id on every page merge — a post can shift pages between an
/// initial load and a refresh (e.g. it was unsaved/resaved mid-session).
@injectable
class SavedPostsBloc extends Bloc<SavedPostsEvent, SavedPostsState> {
  final GetSavedPostsUseCase getSavedPosts;

  SavedPostsBloc({required this.getSavedPosts})
      : super(const SavedPostsInitial()) {
    on<LoadSavedPosts>(_onLoad);
    on<RefreshSavedPosts>(_onRefresh);
    on<LoadMoreSavedPosts>(_onLoadMore);
  }

  Future<void> _onLoad(
    LoadSavedPosts event,
    Emitter<SavedPostsState> emit,
  ) async {
    emit(const SavedPostsLoading());
    final result = await getSavedPosts(const GetSavedPostsParams());
    _emitFirstPage(emit, result);
  }

  Future<void> _onRefresh(
    RefreshSavedPosts event,
    Emitter<SavedPostsState> emit,
  ) async {
    try {
      final result = await getSavedPosts(const GetSavedPostsParams());
      final current = state;
      result.fold(
        (failure) {
          // A failed refresh shouldn't blow away what's already on screen.
          if (current is! SavedPostsLoaded) {
            emit(SavedPostsError(PostErrorMapper.getCode(failure)));
          }
        },
        (page) => emit(SavedPostsLoaded(
          posts: _dedup(page.items),
          nextCursor: page.nextCursor,
        )),
      );
    } finally {
      if (!(event.completer?.isCompleted ?? true)) event.completer!.complete();
    }
  }

  Future<void> _onLoadMore(
    LoadMoreSavedPosts event,
    Emitter<SavedPostsState> emit,
  ) async {
    final current = state;
    if (current is! SavedPostsLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    final result = await getSavedPosts(
      GetSavedPostsParams(cursor: current.nextCursor),
    );

    result.fold(
      // A failed "load more" shouldn't blow away what's already on screen.
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (page) => emit(SavedPostsLoaded(
        posts: _dedup([...current.posts, ...page.items]),
        nextCursor: page.nextCursor,
      )),
    );
  }

  void _emitFirstPage(
    Emitter<SavedPostsState> emit,
    Either<Failure, PostPageEntity> result,
  ) {
    result.fold(
      (failure) => emit(SavedPostsError(PostErrorMapper.getCode(failure))),
      (page) => emit(SavedPostsLoaded(
        posts: _dedup(page.items),
        nextCursor: page.nextCursor,
      )),
    );
  }

  List<PostEntity> _dedup(List<PostEntity> posts) {
    final seen = <String>{};
    return [
      for (final p in posts)
        if (seen.add(p.id)) p,
    ];
  }
}
