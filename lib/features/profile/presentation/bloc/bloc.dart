import 'dart:async';

import 'package:car_social_media_app/features/profile/presentation/bloc/event.dart';
import 'package:car_social_media_app/features/profile/presentation/bloc/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileLoading()) {
    on<FetchUserProfileData>(_onFetchUserProfileData);
  }

  FutureOr<void> _onFetchUserProfileData(FetchUserProfileData event, Emitter<ProfileState> emit) async {
    
  }
}