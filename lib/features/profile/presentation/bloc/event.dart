import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserProfileData extends ProfileEvent {
  final bool fetchFromRemote;

  const FetchUserProfileData({this.fetchFromRemote = false});

  @override
  List<Object> get props => [fetchFromRemote];
}

class FetchProfileByUsername extends ProfileEvent {
  final String username;

  const FetchProfileByUsername(this.username);

  @override
  List<Object?> get props => [username];
}

class SubmitOnboarding extends ProfileEvent {
  final String username;
  final String? bio;

  const SubmitOnboarding({required this.username, this.bio});

  @override
  List<Object?> get props => [username, bio];
}

