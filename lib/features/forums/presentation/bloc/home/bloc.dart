import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/forum_shortcut.dart';
import '../../../domain/entities/forum_thread.dart';
import '../../../domain/usecases/forum_saves.dart';
import '../../../domain/usecases/forum_shortcuts.dart';
import '../../../domain/usecases/get_forum_threads.dart';
import '../../utils/forum_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the forums home: the shortcuts row (pin / remove / reorder) and the
/// global thread list with sort + cursor paging. With no shortcuts the same
/// list is shown as "popular right now", always in the hot order.
@injectable
class ForumsHomeBloc extends Bloc<ForumsHomeEvent, ForumsHomeState> {
  final GetForumShortcutsUseCase getShortcuts;
  final GetForumThreadsUseCase getThreads;
  final DeleteForumShortcutUseCase deleteShortcut;
  final ReorderForumShortcutsUseCase reorderShortcuts;
  final SaveForumThreadUseCase saveThread;
  final UnsaveForumThreadUseCase unsaveThread;

  ForumsHomeBloc({
    required this.getShortcuts,
    required this.getThreads,
    required this.deleteShortcut,
    required this.reorderShortcuts,
    required this.saveThread,
    required this.unsaveThread,
  }) : super(const ForumsHomeState()) {
    on<LoadForumsHome>(_onLoad);
    on<RefreshForumsHome>(_onRefresh);
    on<ChangeForumsHomeSort>(_onChangeSort);
    on<LoadMoreForumsHome>(_onLoadMore);
    on<ToggleForumSaveInFeed>(_onToggleSave);
    on<RemoveForumShortcut>(_onRemove);
    on<MoveForumShortcut>(_onMove);
  }

  Future<void> _onLoad(
    LoadForumsHome event,
    Emitter<ForumsHomeState> emit,
  ) async {
    emit(const ForumsHomeState(isLoading: true));

    // Fire in parallel, await individually to keep the Either types.
    final shortcutsFuture = getShortcuts(NoParams());
    final threadsFuture = getThreads(GetForumThreadsParams(sort: state.sort));
    final shortcutsResult = await shortcutsFuture;
    final threadsResult = await threadsFuture;

    // Shortcuts and threads are the page — either failing is fatal.
    ForumErrorCode? fatal;
    shortcutsResult.fold((f) => fatal = ForumErrorMapper.getCode(f), (_) {});
    threadsResult.fold((f) => fatal ??= ForumErrorMapper.getCode(f), (_) {});
    if (fatal != null) {
      emit(ForumsHomeState(isLoading: false, errorCode: fatal));
      return;
    }

    emit(ForumsHomeState(
      isLoading: false,
      sort: state.sort,
      shortcuts:
          shortcutsResult.getOrElse(() => const <ForumShortcutEntity>[]),
      threads: threadsResult.fold((_) => const [], (page) => page.items),
      nextCursor: threadsResult.fold((_) => null, (page) => page.nextCursor),
    ));
  }

  Future<void> _onRefresh(
    RefreshForumsHome event,
    Emitter<ForumsHomeState> emit,
  ) async {
    try {
      final shortcutsFuture = getShortcuts(NoParams());
      final threadsFuture =
          getThreads(GetForumThreadsParams(sort: state.sort));
      final shortcutsResult = await shortcutsFuture;
      final threadsResult = await threadsFuture;

      var next = state;
      shortcutsResult.fold(
        (f) => next = next.copyWith(actionError: ForumErrorMapper.getCode(f)),
        (shortcuts) => next = next.copyWith(shortcuts: shortcuts),
      );
      threadsResult.fold(
        (f) => next = next.copyWith(actionError: ForumErrorMapper.getCode(f)),
        (page) => next = next.copyWith(
          threads: page.items,
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
        ),
      );
      emit(next.copyWith(isLoading: false, clearError: true));
      // Shortcuts may have been removed elsewhere (e.g. a hub page).
      if (next.shortcuts.isEmpty) _resetToHot();
    } finally {
      event.completer?.complete();
    }
  }

  /// The empty paddock lists "popular right now" without sort tabs, so a
  /// New / Active sort picked while shortcuts existed must not linger there.
  void _resetToHot() {
    if (state.sort != ForumThreadSort.hot) {
      add(const ChangeForumsHomeSort(ForumThreadSort.hot));
    }
  }

  Future<void> _onChangeSort(
    ChangeForumsHomeSort event,
    Emitter<ForumsHomeState> emit,
  ) async {
    if (event.sort == state.sort) return;
    emit(state.copyWith(sort: event.sort, isThreadsLoading: true));

    final result = await getThreads(GetForumThreadsParams(sort: event.sort));
    result.fold(
      (f) => emit(state.copyWith(
        isThreadsLoading: false,
        actionError: ForumErrorMapper.getCode(f),
      )),
      (page) => emit(state.copyWith(
        isThreadsLoading: false,
        threads: page.items,
        nextCursor: page.nextCursor,
        clearNextCursor: page.nextCursor == null,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreForumsHome event,
    Emitter<ForumsHomeState> emit,
  ) async {
    if (state.isLoadingMore || state.isThreadsLoading || !state.hasMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));

    final result = await getThreads(GetForumThreadsParams(
      sort: state.sort,
      cursor: state.nextCursor,
    ));
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

  Future<void> _onToggleSave(
    ToggleForumSaveInFeed event,
    Emitter<ForumsHomeState> emit,
  ) async {
    final index = state.threads.indexWhere((t) => t.id == event.threadId);
    if (index < 0) return;
    final original = state.threads[index];
    final saved = original.viewerHasSaved;

    List<ForumThreadEntity> withSaved(bool value) {
      final next = [...state.threads];
      next[index] = next[index].withSaved(value);
      return next;
    }

    emit(state.copyWith(threads: withSaved(!saved)));

    final result = saved
        ? await unsaveThread(event.threadId)
        : await saveThread(event.threadId);
    result.fold(
      (f) => emit(state.copyWith(
        threads: withSaved(saved),
        actionError: ForumErrorMapper.getCode(f),
      )),
      (_) {},
    );
  }

  Future<void> _onRemove(
    RemoveForumShortcut event,
    Emitter<ForumsHomeState> emit,
  ) async {
    final before = state.shortcuts;
    final remaining = before.where((s) => s.id != event.shortcutId).toList();
    emit(state.copyWith(shortcuts: remaining));
    if (remaining.isEmpty) _resetToHot();

    final result = await deleteShortcut(event.shortcutId);
    result.fold(
      (f) => emit(state.copyWith(
        shortcuts: before,
        actionError: ForumErrorMapper.getCode(f),
      )),
      (_) {},
    );
  }

  Future<void> _onMove(
    MoveForumShortcut event,
    Emitter<ForumsHomeState> emit,
  ) async {
    final before = state.shortcuts;
    if (event.oldIndex < 0 ||
        event.oldIndex >= before.length ||
        event.newIndex < 0 ||
        event.newIndex >= before.length) {
      return;
    }

    final moved = [...before];
    final item = moved.removeAt(event.oldIndex);
    moved.insert(event.newIndex, item);
    emit(state.copyWith(shortcuts: moved));

    final result = await reorderShortcuts(moved.map((s) => s.id).toList());
    result.fold(
      (f) => emit(state.copyWith(
        shortcuts: before,
        actionError: ForumErrorMapper.getCode(f),
      )),
      (serverOrder) => emit(state.copyWith(shortcuts: serverOrder)),
    );
  }
}
