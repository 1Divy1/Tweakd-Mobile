import 'package:equatable/equatable.dart';

import '../../domain/entities/profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class OnboardingSubmitting extends ProfileState {}

class OnboardingSubmitted extends ProfileState {
  final ProfileEntity profile;

  const OnboardingSubmitted(this.profile);

  @override
  List<Object?> get props => [profile];
}

class OnboardingError extends ProfileState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
