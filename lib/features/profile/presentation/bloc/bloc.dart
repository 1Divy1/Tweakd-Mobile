import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user_profile.dart';
import '../utils/profile_error_mapper.dart';
import 'event.dart';
import 'state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUserProfileUseCase getCurrentUserProfile;

  ProfileBloc({required this.getCurrentUserProfile}) : super(ProfileLoading()) {
    on<FetchUserProfileData>(_onFetchUserProfileData);
  }

  FutureOr<void> _onFetchUserProfileData(
    FetchUserProfileData event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getCurrentUserProfile(NoParams());

    result.fold(
      (failure) => emit(ProfileError(ProfileErrorMapper.getMessage(failure))),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }
}
