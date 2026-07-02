import 'package:equatable/equatable.dart';

sealed class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the type and feature pickers. Dispatched once when the screen opens;
/// re-dispatch to retry after a load error.
class LoadFeedbackOptions extends FeedbackEvent {
  const LoadFeedbackOptions();
}

/// The user picked a feedback type (required). Selecting the "bug" type reveals
/// the reproduction-steps field.
class SelectFeedbackType extends FeedbackEvent {
  final String typeId;
  const SelectFeedbackType(this.typeId);

  @override
  List<Object?> get props => [typeId];
}

/// The user picked a related feature, or cleared it by passing null.
class SelectFeedbackFeature extends FeedbackEvent {
  final String? featureId;
  const SelectFeedbackFeature(this.featureId);

  @override
  List<Object?> get props => [featureId];
}

/// The user tapped "Send feedback". The free-text fields are carried on the
/// event (they live in the form's controllers, not in the bloc state).
class SubmitFeedbackPressed extends FeedbackEvent {
  final String content;
  final String? reproductionSteps;

  const SubmitFeedbackPressed({
    required this.content,
    this.reproductionSteps,
  });

  @override
  List<Object?> get props => [content, reproductionSteps];
}
