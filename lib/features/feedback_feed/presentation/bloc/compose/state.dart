import 'package:equatable/equatable.dart';

import '../../../domain/entities/feedback_option.dart';
import '../../utils/feedback_feed_error_mapper.dart';

/// The maximum message length the backend accepts.
const int kFeedbackMessageMaxLength = 500;

enum ComposeFeedbackStatus {
  /// Fetching the category chips.
  loadingTypes,

  /// Categories failed to load — nothing can be composed, so the screen shows
  /// a retry.
  typesError,

  ready,
  submitting,

  /// Posted — the page pops and the board refreshes.
  success,
}

class ComposeFeedbackState extends Equatable {
  final ComposeFeedbackStatus status;
  final List<FeedbackOptionEntity> types;
  final String? selectedTypeId;
  final String message;

  /// Set when a submit fails, shown inline above the post button.
  final FeedbackFeedErrorCode? submitError;

  const ComposeFeedbackState({
    this.status = ComposeFeedbackStatus.loadingTypes,
    this.types = const [],
    this.selectedTypeId,
    this.message = '',
    this.submitError,
  });

  bool get canSubmit =>
      status == ComposeFeedbackStatus.ready &&
      selectedTypeId != null &&
      message.trim().isNotEmpty &&
      message.length <= kFeedbackMessageMaxLength;

  ComposeFeedbackState copyWith({
    ComposeFeedbackStatus? status,
    List<FeedbackOptionEntity>? types,
    String? selectedTypeId,
    String? message,
    FeedbackFeedErrorCode? submitError,
    bool clearSubmitError = false,
  }) {
    return ComposeFeedbackState(
      status: status ?? this.status,
      types: types ?? this.types,
      selectedTypeId: selectedTypeId ?? this.selectedTypeId,
      message: message ?? this.message,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        types,
        selectedTypeId,
        message,
        submitError,
      ];
}
