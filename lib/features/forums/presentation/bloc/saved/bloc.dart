import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/forum_saves.dart';
import '../../utils/forum_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the saved-threads screen: a newest-save-first cursor-paged list with
/// unsave (which drops the thread from the list).
@injectable
class SavedThreadsBloc extends Bloc<SavedThreadsEvent, SavedThreadsState> {
  final GetSavedForumThreadsUseCase getSavedThreads;
  final UnsaveForumThreadUseCase unsaveThread;

  SavedThreadsBloc({
    required this.getSavedThreads,
    required this.unsaveThread,
  }) : super(const SavedThreadsState()) {
    on<LoadSavedThreads>(_onLoad);
    on<RefreshSavedThreads>(_onRefresh);
    on<LoadMoreSavedThreads>(_onLoadMore);
    on<UnsaveSavedThread>(_onUnsave);
  }

  Future<void> _onLoad(
    LoadSavedThreads event,
    Emitter<SavedThreadsState> emit,
  ) async {
    emit(const SavedThreadsState(isLoading: true));
    final result = await getSavedThreads(const GetSavedThreadsParams());
    result.fold(
      (f) => emit(SavedThreadsState(
        isLoading: false,
        errorCode: ForumErrorMapper.getCode(f),
      )),
      (page) => emit(SavedThreadsState(
        isLoading: false,
        threads: page.items,
        nextCursor: page.nextCursor,
      )),
    );
  }

  Future<void> _onRefresh(
    RefreshSavedThreads event,
    Emitter<SavedThreadsState> emit,
  ) async {
    try {
      final result = await getSavedThreads(const GetSavedThreadsParams());
      result.fold(
        (f) => emit(state.copyWith(actionError: ForumErrorMapper.getCode(f))),
        (page) => emit(state.copyWith(
          isLoading: false,
          threads: page.items,
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
          clearError: true,
        )),
      );
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onLoadMore(
    LoadMoreSavedThreads event,
    Emitter<SavedThreadsState> emit,
  ) async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));

    final result = await getSavedThreads(
        GetSavedThreadsParams(cursor: state.nextCursor));
    result.fold(
      (_) => emit(state.copyWith(isLoadingMore: false)),
      (page) {
        final seen = state.threads.map((t) => t.id).toSet();
        final fresh = page.items.where((t) => seen.add(t.id));
        emit(state.copyWith(
          isLoadingMore: false,
          threads: [...state.threads, ...fresh],
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
        ));
      },
    );
  }

  Future<void> _onUnsave(
    UnsaveSavedThread event,
    Emitter<SavedThreadsState> emit,
  ) async {
    final before = state.threads;
    final removed = before.where((t) => t.id != event.threadId).toList();
    if (removed.length == before.length) return;
    emit(state.copyWith(threads: removed));

    final result = await unsaveThread(event.threadId);
    result.fold(
      (f) => emit(state.copyWith(
        threads: before,
        actionError: ForumErrorMapper.getCode(f),
      )),
      (_) {},
    );
  }
}
