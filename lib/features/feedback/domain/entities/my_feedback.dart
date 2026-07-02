import 'package:equatable/equatable.dart';

/// The moderation status of a piece of feedback, assigned server-side (e.g. by
/// an admin). [color] is an optional hex string (e.g. "#22C55E") the backend
/// suggests for the status badge; null means "use the app default".
class MyFeedbackStatusEntity extends Equatable {
  final String id;
  final String name;
  final String? color;

  const MyFeedbackStatusEntity({
    required this.id,
    required this.name,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name, color];
}

/// One piece of feedback the current user has submitted, as shown on the
/// "My feedback" screen. [feature] and [reproductionSteps] are null when the
/// user didn't fill them in. [type] and [feature] are already-resolved display
/// labels from the backend (not ids). [status] is server-managed and always
/// present; [response] is a moderator's reply, null until one is written.
class MyFeedbackEntity extends Equatable {
  final String id;
  final String content;
  final String type;
  final String? feature;
  final String? reproductionSteps;
  final String? response;
  final MyFeedbackStatusEntity status;
  final DateTime createdAt;

  const MyFeedbackEntity({
    required this.id,
    required this.content,
    required this.type,
    required this.feature,
    required this.reproductionSteps,
    required this.response,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    type,
    feature,
    reproductionSteps,
    response,
    status,
    createdAt,
  ];
}
