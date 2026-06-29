import 'package:equatable/equatable.dart';

import '../../domain/entities/profile.dart';
import '../utils/profile_error_mapper.dart';

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
  final ProfileErrorCode code;

  const ProfileError(this.code);

  @override
  List<Object?> get props => [code];
}

class OnboardingSubmitting extends ProfileState {}

class OnboardingSubmitted extends ProfileState {
  final ProfileEntity profile;

  const OnboardingSubmitted(this.profile);

  @override
  List<Object?> get props => [profile];
}

class OnboardingError extends ProfileState {
  final ProfileErrorCode code;

  const OnboardingError(this.code);

  @override
  List<Object?> get props => [code];
}
