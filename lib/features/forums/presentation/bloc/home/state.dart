import 'package:equatable/equatable.dart';

import '../../../domain/entities/forum_shortcut.dart';
import '../../../domain/entities/forum_thread.dart';
import '../../utils/forum_error_mapper.dart';

/// One composite state for the forums home: the shortcuts row and the
/// hot-feed list load together but fail softly where possible.
/// [actionError] is a one-shot snackbar signal — listeners key on
/// [actionErrorTick], never on the value alone.
class ForumsHomeState extends Equatable {
  final bool isLoading;
  final ForumErrorCode? errorCode;
  final List<ForumShortcutEntity> shortcuts;
  final List<ForumThreadEntity> threads;
  final String? nextCursor;
  final bool isThreadsLoading;
  final bool isLoadingMore;
  final ForumThreadSort sort;
  final ForumErrorCode? actionError;
  final int actionErrorTick;

  const ForumsHomeState({
    this.isLoading = true,
    this.errorCode,
    this.shortcuts = const [],
    this.threads = const [],
    this.nextCursor,
    this.isThreadsLoading = false,
    this.isLoadingMore = false,
    this.sort = ForumThreadSort.hot,
    this.actionError,
    this.actionErrorTick = 0,
  });

  bool get hasMore => nextCursor != null;

  ForumsHomeState copyWith({
    bool? isLoading,
    ForumErrorCode? errorCode,
    bool clearError = false,
    List<ForumShortcutEntity>? shortcuts,
    List<ForumThreadEntity>? threads,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? isThreadsLoading,
    bool? isLoadingMore,
    ForumThreadSort? sort,
    ForumErrorCode? actionError,
  }) {
    return ForumsHomeState(
      isLoading: isLoading ?? this.isLoading,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      shortcuts: shortcuts ?? this.shortcuts,
      threads: threads ?? this.threads,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      isThreadsLoading: isThreadsLoading ?? this.isThreadsLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      sort: sort ?? this.sort,
      actionError: actionError ?? this.actionError,
      actionErrorTick:
          actionError != null ? actionErrorTick + 1 : actionErrorTick,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorCode,
        shortcuts,
        threads,
        nextCursor,
        isThreadsLoading,
        isLoadingMore,
        sort,
        actionError,
        actionErrorTick,
      ];
}
