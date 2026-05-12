import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user_profile.dart';
import '../../domain/usecases/get_profile_by_username.dart';
import '../../domain/usecases/submit_onboarding.dart';
import '../utils/profile_error_mapper.dart';
import 'event.dart';
import 'state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUserProfileUseCase getCurrentUserProfile;
  final GetProfileByUsernameUseCase getProfileByUsername;
  final SubmitOnboardingUseCase submitOnboarding;

  ProfileBloc({
    required this.getCurrentUserProfile,
    required this.getProfileByUsername,
    required this.submitOnboarding,
  }) : super(ProfileLoading()) {
    on<FetchUserProfileData>(_onFetchUserProfileData);
    on<FetchProfileByUsername>(_onFetchProfileByUsername);
    on<SubmitOnboarding>(_onSubmitOnboarding);
  }

  FutureOr<void> _onFetchUserProfileData(
    FetchUserProfileData event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getCurrentUserProfile(GetCurrentUserParams(fetchFromRemote: event.fetchFromRemote));

    result.fold(
      (failure) => emit(ProfileError(ProfileErrorMapper.getMessage(failure))),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  FutureOr<void> _onFetchProfileByUsername(
    FetchProfileByUsername event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getProfileByUsername(
      GetProfileByUsernameParams(username: event.username),
    );

    result.fold(
      (failure) => emit(ProfileError(ProfileErrorMapper.getMessage(failure))),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  FutureOr<void> _onSubmitOnboarding(
    SubmitOnboarding event,
    Emitter<ProfileState> emit,
  ) async {
    emit(OnboardingSubmitting());

    final result = await submitOnboarding(
      SubmitOnboardingParams(username: event.username, bio: event.bio),
    );

    result.fold(
      (failure) =>
          emit(OnboardingError(ProfileErrorMapper.getMessage(failure))),
      (profile) => emit(OnboardingSubmitted(profile)),
    );
  }
}
