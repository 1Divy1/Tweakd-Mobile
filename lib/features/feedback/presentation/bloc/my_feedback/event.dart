import 'package:equatable/equatable.dart';

sealed class MyFeedbackEvent extends Equatable {
  const MyFeedbackEvent();

  @override
  List<Object?> get props => [];
}

/// Loads (or reloads, for retry / pull-to-refresh) the user's submitted feedback.
class LoadMyFeedback extends MyFeedbackEvent {
  const LoadMyFeedback();
}
