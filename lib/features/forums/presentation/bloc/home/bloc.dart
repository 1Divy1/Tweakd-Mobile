import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/forum_shortcut.dart';
import '../../../domain/entities/forum_topic.dart';
import '../../../domain/usecases/forum_shortcuts.dart';
import '../../../domain/usecases/get_forum_threads.dart';
import '../../../domain/usecases/get_forum_topics.dart';
import '../../utils/forum_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the forums home: the shortcuts row (pin / remove / reorder), the
/// global "hot in your forums" list with sort + cursor paging, and the topic
/// suggestions shown while the paddock is empty.
@injectable
class ForumsHomeBloc extends Bloc<ForumsHomeEvent, ForumsHomeState> {
  final GetForumShortcutsUseCase getShortcuts;
  final GetForumThreadsUseCase getThreads;
  final GetForumTopicsUseCase getTopics;
  final CreateForumShortcutUseCase createShortcut;
  final DeleteForumShortcutUseCase deleteShortcut;
  final ReorderForumShortcutsUseCase reorderShortcuts;

  ForumsHomeBloc({
    required this.getShortcuts,
    required this.getThreads,
    required this.getTopics,
    required this.createShortcut,
    required this.deleteShortcut,
    required this.reorderShortcuts,
  }) : super(const ForumsHomeState()) {
    on<LoadForumsHome>(_onLoad);
    on<RefreshForumsHome>(_onRefresh);
    on<ChangeForumsHomeSort>(_onChangeSort);
    on<LoadMoreForumsHome>(_onLoadMore);
    on<PinForumTopicShortcut>(_onPinTopic);
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
    final topicsFuture = getTopics(NoParams());
    final shortcutsResult = await shortcutsFuture;
    final threadsResult = await threadsFuture;
    final topicsResult = await topicsFuture;

    // Shortcuts and threads are the page — either failing is fatal. The topic
    // suggestions only feed the empty state, so their failure is silent.
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
      suggestedTopics: topicsResult.fold(
        (_) => const <ForumTopicEntity>[],
        _flattenTopics,
      ),
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
    } finally {
      event.completer?.complete();
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

  Future<void> _onPinTopic(
    PinForumTopicShortcut event,
    Emitter<ForumsHomeState> emit,
  ) async {
    final result = await createShortcut(CreateForumShortcutParams(
      name: event.topic.name,
      topicId: event.topic.id,
    ));
    result.fold(
      (f) => emit(state.copyWith(actionError: ForumErrorMapper.getCode(f))),
      (shortcut) =>
          emit(state.copyWith(shortcuts: [...state.shortcuts, shortcut])),
    );
  }

  Future<void> _onRemove(
    RemoveForumShortcut event,
    Emitter<ForumsHomeState> emit,
  ) async {
    final before = state.shortcuts;
    emit(state.copyWith(
      shortcuts: before.where((s) => s.id != event.shortcutId).toList(),
    ));

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

  /// Topic suggestions for the empty paddock, in backend sort order.
  static List<ForumTopicEntity> _flattenTopics(
    List<ForumTopicGroupEntity> groups,
  ) {
    final topics = [for (final g in groups) ...g.topics]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return topics.take(6).toList();
  }
}
