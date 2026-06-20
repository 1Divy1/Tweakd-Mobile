import 'package:equatable/equatable.dart';

abstract class UsernameAvailabilityEvent extends Equatable {
  const UsernameAvailabilityEvent();

  @override
  List<Object?> get props => [];
}

/// Fired on every keystroke in the handle field. The bloc validates the format
/// locally and, when well-formed, debounces a backend availability check.
class UsernameChanged extends UsernameAvailabilityEvent {
  final String username;

  const UsernameChanged(this.username);

  @override
  List<Object?> get props => [username];
}

/// Internal event dispatched once the debounce window elapses. External callers
/// should use [UsernameChanged].
class PerformUsernameCheck extends UsernameAvailabilityEvent {
  final String username;

  const PerformUsernameCheck(this.username);

  @override
  List<Object?> get props => [username];
}
