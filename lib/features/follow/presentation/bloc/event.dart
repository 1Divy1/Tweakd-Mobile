import 'package:equatable/equatable.dart';

abstract class FollowStatusEvent extends Equatable {
  const FollowStatusEvent();

  @override
  List<Object?> get props => [];
}

class LoadFollowStatus extends FollowStatusEvent {
  final String username;

  const LoadFollowStatus(this.username);

  @override
  List<Object?> get props => [username];
}

class ToggleFollow extends FollowStatusEvent {
  final String username;

  const ToggleFollow(this.username);

  @override
  List<Object?> get props => [username];
}
