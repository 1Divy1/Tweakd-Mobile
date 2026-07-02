import 'package:equatable/equatable.dart';

import '../../../domain/entities/feedback_feature.dart';
import '../../../domain/entities/feedback_type.dart';
import '../../utils/feedback_error_mapper.dart';

/// The type id that unlocks the reproduction-steps field. The backend keys the
/// "bug" category with this id.
const String kBugFeedbackTypeId = 'bug';

/// Lifecycle of the feedback submit screen.
/// - [loadingOptions]/[optionsError] — fetching the type + feature pickers.
/// - [ready] — pickers loaded; the form is editable (also the state after a
///   failed submit, with [errorCode] set to surface the message).
/// - [submitting] — the submit POST is in flight.
/// - [success] — the feedback went through; the screen can close.
enum FeedbackStatus { loadingOptions, optionsError, ready, submitting, success }

class FeedbackState extends Equatable {
  final FeedbackStatus status;
  final List<FeedbackTypeEntity> types;
  final List<FeedbackFeatureEntity> features;
  final FeedbackTypeEntity? selectedType;
  final FeedbackFeatureEntity? selectedFeature;

  /// Set after a failed submit so the UI can surface a message; cleared on the
  /// next submit attempt.
  final FeedbackErrorCode? errorCode;

  const FeedbackState({
    this.status = FeedbackStatus.loadingOptions,
    this.types = const [],
    this.features = const [],
    this.selectedType,
    this.selectedFeature,
    this.errorCode,
  });

  /// Whether the reproduction-steps field should be shown (bug reports only).
  bool get isBug => selectedType?.id == kBugFeedbackTypeId;

  bool get isSubmitting => status == FeedbackStatus.submitting;

  FeedbackState copyWith({
    FeedbackStatus? status,
    List<FeedbackTypeEntity>? types,
    List<FeedbackFeatureEntity>? features,
    FeedbackTypeEntity? selectedType,
    FeedbackFeatureEntity? selectedFeature,
    bool clearSelectedFeature = false,
    FeedbackErrorCode? errorCode,
    bool clearError = false,
  }) {
    return FeedbackState(
      status: status ?? this.status,
      types: types ?? this.types,
      features: features ?? this.features,
      selectedType: selectedType ?? this.selectedType,
      selectedFeature: clearSelectedFeature
          ? null
          : (selectedFeature ?? this.selectedFeature),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }

  @override
  List<Object?> get props => [
        status,
        types,
        features,
        selectedType,
        selectedFeature,
        errorCode,
      ];
}
