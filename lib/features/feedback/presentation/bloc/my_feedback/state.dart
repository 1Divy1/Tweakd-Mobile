import 'package:equatable/equatable.dart';

import '../../../domain/entities/my_feedback.dart';
import '../../utils/feedback_error_mapper.dart';

sealed class MyFeedbackState extends Equatable {
  const MyFeedbackState();

  @override
  List<Object?> get props => [];
}

class MyFeedbackInitial extends MyFeedbackState {
  const MyFeedbackInitial();
}

class MyFeedbackLoading extends MyFeedbackState {
  const MyFeedbackLoading();
}

class MyFeedbackLoaded extends MyFeedbackState {
  final List<MyFeedbackEntity> feedback;
  const MyFeedbackLoaded(this.feedback);

  @override
  List<Object?> get props => [feedback];
}

class MyFeedbackError extends MyFeedbackState {
  final FeedbackErrorCode code;
  const MyFeedbackError(this.code);

  @override
  List<Object?> get props => [code];
}
