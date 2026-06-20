import 'package:equatable/equatable.dart';

abstract class UsernameAvailabilityState extends Equatable {
  const UsernameAvailabilityState();

  @override
  List<Object?> get props => [];
}

/// Idle: the field is empty, nothing to show beyond the neutral helper line.
class UsernameAvailabilityInitial extends UsernameAvailabilityState {
  const UsernameAvailabilityInitial();
}

/// The handle is malformed; [message] is the format error to surface. No
/// backend call is made in this state.
class UsernameAvailabilityInvalid extends UsernameAvailabilityState {
  final String message;

  const UsernameAvailabilityInvalid(this.message);

  @override
  List<Object?> get props => [message];
}

/// The handle is well-formed and a backend availability check is pending or in
/// flight for [username].
class UsernameAvailabilityChecking extends UsernameAvailabilityState {
  final String username;

  const UsernameAvailabilityChecking(this.username);

  @override
  List<Object?> get props => [username];
}

/// [username] is free to claim.
class UsernameAvailable extends UsernameAvailabilityState {
  final String username;

  const UsernameAvailable(this.username);

  @override
  List<Object?> get props => [username];
}

/// [username] is already taken.
class UsernameTaken extends UsernameAvailabilityState {
  final String username;

  const UsernameTaken(this.username);

  @override
  List<Object?> get props => [username];
}

/// The availability check could not be completed (network/server error).
class UsernameAvailabilityFailed extends UsernameAvailabilityState {
  final String username;
  final String message;

  const UsernameAvailabilityFailed({
    required this.username,
    required this.message,
  });

  @override
  List<Object?> get props => [username, message];
}
