import 'package:equatable/equatable.dart';

import '../../../domain/entities/feedback_message.dart';
import '../../../domain/entities/feedback_sort.dart';
import '../../utils/feedback_feed_error_mapper.dart';

/// The feedback board. One composite state (rather than a sealed hierarchy) so
/// the sort tabs stay on screen while a re-sort loads.
///
/// [actionError] is a one-shot snackbar signal for vote/delete failures —
/// listeners key on [actionErrorTick], never on the value alone, so the same
/// error twice in a row still shows.
class FeedbackBoardState extends Equatable {
  final bool isLoading;
  final FeedbackFeedErrorCode? errorCode;
  final List<FeedbackMessageEntity> messages;
  final String? nextCursor;
  final bool isLoadingMore;
  final FeedbackSort sort;
  final FeedbackFeedErrorCode? actionError;
  final int actionErrorTick;

  const FeedbackBoardState({
    this.isLoading = true,
    this.errorCode,
    this.messages = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.sort = FeedbackSort.newest,
    this.actionError,
    this.actionErrorTick = 0,
  });

  bool get hasMore => nextCursor != null;

  FeedbackBoardState copyWith({
    bool? isLoading,
    FeedbackFeedErrorCode? errorCode,
    bool clearError = false,
    List<FeedbackMessageEntity>? messages,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? isLoadingMore,
    FeedbackSort? sort,
    FeedbackFeedErrorCode? actionError,
  }) {
    return FeedbackBoardState(
      isLoading: isLoading ?? this.isLoading,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      messages: messages ?? this.messages,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
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
        messages,
        nextCursor,
        isLoadingMore,
        sort,
        actionError,
        actionErrorTick,
      ];
}
