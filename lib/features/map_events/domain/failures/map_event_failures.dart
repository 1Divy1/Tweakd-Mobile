import 'package:tweakd/core/error/base_failures.dart';

/// The event is gone, hidden, or was never visible to this viewer. As with
/// businesses, the backend doesn't distinguish those cases.
class MapEventNotFoundFailure extends Failure {
  const MapEventNotFoundFailure(String message) : super(message: message);
}

/// The caller isn't an organizer (or isn't the creator) of the event they just
/// tried to change. 403.
class MapEventForbiddenFailure extends Failure {
  const MapEventForbiddenFailure(String message) : super(message: message);
}

/// A 409 on the participation endpoints: the event has finished, the
/// registration deadline has passed, or the entry list is full.
///
/// The three cases are **not** modelled separately on purpose. The backend
/// distinguishes them only in prose, and the progress file's instruction is to
/// show the server's own message — so [message] is displayed verbatim rather
/// than mapped to a client-side string that could drift out of sync with it.
/// [errorCode] is carried through for anyone who later wants to branch on it.
class MapEventParticipationConflictFailure extends Failure {
  final String? errorCode;

  const MapEventParticipationConflictFailure(
    String message, {
    this.errorCode,
  }) : super(message: message);

  @override
  List<Object> get props => [message, errorCode ?? ''];
}

/// A 400 the user can fix by changing what they typed — a missing registration
/// deadline, a rule over 300 characters, an organizer who already organizes the
/// event. The server's message is the useful part.
class MapEventInvalidInputFailure extends Failure {
  const MapEventInvalidInputFailure(String message) : super(message: message);
}

/// A 403 on the contest endpoints: the viewer is not at the event (no
/// `attending` RSVP and no accepted car in the line-up), or tried to vote for
/// their own car. The backend says which in prose, so the
/// message is shown verbatim (same rule as the participation 409s).
class ContestNotEligibleFailure extends Failure {
  const ContestNotEligibleFailure(String message) : super(message: message);
}
