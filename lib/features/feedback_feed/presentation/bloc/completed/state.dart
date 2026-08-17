import 'package:equatable/equatable.dart';

import '../../../domain/entities/feedback_message.dart';
import '../../utils/feedback_feed_error_mapper.dart';

/// The completed-requests screen. Read-only, so there is no action-error
/// channel here — nothing on this screen writes.
class CompletedFeedbackState extends Equatable {
  final bool isLoading;
  final FeedbackFeedErrorCode? errorCode;
  final List<FeedbackMessageEntity> messages;
  final String? nextCursor;
  final bool isLoadingMore;

  const CompletedFeedbackState({
    this.isLoading = true,
    this.errorCode,
    this.messages = const [],
    this.nextCursor,
    this.isLoadingMore = false,
  });

  bool get hasMore => nextCursor != null;

  CompletedFeedbackState copyWith({
    bool? isLoading,
    FeedbackFeedErrorCode? errorCode,
    bool clearError = false,
    List<FeedbackMessageEntity>? messages,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? isLoadingMore,
  }) {
    return CompletedFeedbackState(
      isLoading: isLoading ?? this.isLoading,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      messages: messages ?? this.messages,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorCode,
        messages,
        nextCursor,
        isLoadingMore,
      ];
}
