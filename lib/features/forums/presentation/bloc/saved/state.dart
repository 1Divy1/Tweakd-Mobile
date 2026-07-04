import 'package:equatable/equatable.dart';

import '../../../domain/entities/forum_thread.dart';
import '../../utils/forum_error_mapper.dart';

/// State of the saved-threads screen. [actionError] is a one-shot snackbar
/// signal keyed on [actionErrorTick].
class SavedThreadsState extends Equatable {
  final bool isLoading;
  final ForumErrorCode? errorCode;
  final List<ForumThreadEntity> threads;
  final String? nextCursor;
  final bool isLoadingMore;
  final ForumErrorCode? actionError;
  final int actionErrorTick;

  const SavedThreadsState({
    this.isLoading = true,
    this.errorCode,
    this.threads = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.actionError,
    this.actionErrorTick = 0,
  });

  bool get hasMore => nextCursor != null;

  SavedThreadsState copyWith({
    bool? isLoading,
    ForumErrorCode? errorCode,
    bool clearError = false,
    List<ForumThreadEntity>? threads,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? isLoadingMore,
    ForumErrorCode? actionError,
  }) {
    return SavedThreadsState(
      isLoading: isLoading ?? this.isLoading,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      threads: threads ?? this.threads,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      actionError: actionError ?? this.actionError,
      actionErrorTick:
          actionError != null ? actionErrorTick + 1 : actionErrorTick,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorCode,
        threads,
        nextCursor,
        isLoadingMore,
        actionError,
        actionErrorTick,
      ];
}
