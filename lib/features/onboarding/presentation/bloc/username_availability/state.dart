import 'package:equatable/equatable.dart';

import '../../utils/username_validator.dart';

abstract class UsernameAvailabilityState extends Equatable {
  const UsernameAvailabilityState();

  @override
  List<Object?> get props => [];
}

/// Idle: the field is empty, nothing to show beyond the neutral helper line.
class UsernameAvailabilityInitial extends UsernameAvailabilityState {
  const UsernameAvailabilityInitial();
}

/// The handle is malformed; [error] is the format violation to surface. No
/// backend call is made in this state. The UI maps it to localized copy.
class UsernameAvailabilityInvalid extends UsernameAvailabilityState {
  final UsernameValidationError error;

  const UsernameAvailabilityInvalid(this.error);

  @override
  List<Object?> get props => [error];
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

/// The availability check could not be completed (network/server error). The
/// UI supplies the localized "couldn't check" copy.
class UsernameAvailabilityFailed extends UsernameAvailabilityState {
  final String username;

  const UsernameAvailabilityFailed({required this.username});

  @override
  List<Object?> get props => [username];
}
