import 'package:equatable/equatable.dart';

/// An `{ id, label }` pair from the backend — used for both a message's
/// **category** (`GET /types`) and its **roadmap status** (`GET /statuses`).
///
/// The [label] is display-ready copy owned by the backend; the client never
/// translates it. Only badge colours are keyed off [id] (see
/// `feedback_feed_visuals.dart`), so an id the app has never seen still renders
/// with its server-provided label and a neutral colour.
class FeedbackOptionEntity extends Equatable {
  final String id;
  final String label;

  const FeedbackOptionEntity({required this.id, required this.label});

  @override
  List<Object?> get props => [id, label];
}

/// Well-known category ids. The compose screen and the badge colours use these;
/// anything else falls back to neutral styling.
const String kFeedbackTypeBug = 'bug';
const String kFeedbackTypeFeatureRequest = 'feature_request';
const String kFeedbackTypeFeatureImprovement = 'feature_improvement';

/// Well-known status ids. `sent` is the only status where the author may still
/// delete their message; `completed` messages live on the separate
/// completed-requests screen.
const String kFeedbackStatusSent = 'sent';
const String kFeedbackStatusUnderDevelopment = 'under_development';
const String kFeedbackStatusCompleted = 'completed';
