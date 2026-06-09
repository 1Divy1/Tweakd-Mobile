import 'package:equatable/equatable.dart';

abstract class FollowEvent extends Equatable {
  const FollowEvent();

  @override
  List<Object?> get props => [];
}

// ---------- Basic follow actions ----------

class LoadFollowStatus extends FollowEvent {
  final String username;

  const LoadFollowStatus(this.username);

  @override
  List<Object?> get props => [username];
}

class ToggleFollow extends FollowEvent {
  final String username;

  const ToggleFollow(this.username);

  @override
  List<Object?> get props => [username];
}

class ToggleFollowInList extends FollowEvent {
  final String username;

  const ToggleFollowInList(this.username);

  @override
  List<Object?> get props => [username];
}

// ---------- Followers & Following ----------

class LoadFollowers extends FollowEvent {
  final String username;

  const LoadFollowers(this.username);

  @override
  List<Object?> get props => [username];
}

class LoadFollowing extends FollowEvent {
  final String username;

  const LoadFollowing(this.username);

  @override
  List<Object?> get props => [username];
}
