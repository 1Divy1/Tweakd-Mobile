import '../../../../core/error/base_failures.dart';

/// The author tried to delete a message that staff have already picked up
/// (status moved past `sent`) — the backend answers 409. The list is refreshed
/// afterwards so the stale card catches up with its real status.
class FeedbackMessageLockedFailure extends Failure {
  const FeedbackMessageLockedFailure(String message) : super(message: message);
}

/// The message no longer exists — someone deleted it between the list loading
/// and the action being taken (404).
class FeedbackMessageNotFoundFailure extends Failure {
  const FeedbackMessageNotFoundFailure(String message) : super(message: message);
}
