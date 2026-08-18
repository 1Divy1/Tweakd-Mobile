import 'package:equatable/equatable.dart';

sealed class ComposeFeedbackEvent extends Equatable {
  const ComposeFeedbackEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the category chips (`GET /types`).
class LoadFeedbackTypes extends ComposeFeedbackEvent {
  const LoadFeedbackTypes();
}

/// Picks a category. Exactly one is required to post.
class SelectFeedbackType extends ComposeFeedbackEvent {
  final String typeId;
  const SelectFeedbackType(this.typeId);

  @override
  List<Object?> get props => [typeId];
}

/// Mirrors the text field into the bloc so the post button and the character
/// counter can react to it.
class FeedbackMessageChanged extends ComposeFeedbackEvent {
  final String message;
  const FeedbackMessageChanged(this.message);

  @override
  List<Object?> get props => [message];
}

/// Publishes the message.
class SubmitFeedbackMessage extends ComposeFeedbackEvent {
  const SubmitFeedbackMessage();
}
