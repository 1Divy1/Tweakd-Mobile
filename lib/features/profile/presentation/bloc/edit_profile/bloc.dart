import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/profile.dart';
import '../../../domain/usecases/change_profile_avatar.dart';
import '../../../domain/usecases/update_profile.dart';
import '../../utils/profile_error_mapper.dart';
import 'event.dart';
import 'state.dart';

@injectable
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final UpdateProfileUseCase updateProfile;
  final ChangeProfileAvatarUseCase changeProfileAvatar;

  EditProfileBloc({
    required this.updateProfile,
    required this.changeProfileAvatar,
    @factoryParam required ProfileEntity profile,
  }) : super(EditProfileState(profile: profile)) {
    on<EditProfileStarted>(_onStarted);
    on<EditProfileAvatarSelected>(_onAvatarSelected);
    on<EditProfileSaved>(_onSaved);
  }

  void _onStarted(EditProfileStarted event, Emitter<EditProfileState> emit) {
    emit(EditProfileState(profile: event.profile));
  }

  Future<void> _onAvatarSelected(
    EditProfileAvatarSelected event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(state.copyWith(
      phase: EditProfilePhase.uploadingAvatar,
      pendingAvatarPath: event.imagePath,
    ));

    final result = await changeProfileAvatar(
      ChangeProfileAvatarParams(imagePath: event.imagePath),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        phase: EditProfilePhase.idle,
        clearPendingAvatarPath: true,
        errorCode: ProfileErrorMapper.getCode(failure),
        errorNonce: state.errorNonce + 1,
      )),
      (updated) => emit(state.copyWith(
        profile: updated,
        phase: EditProfilePhase.idle,
        clearPendingAvatarPath: true,
        changed: true,
      )),
    );
  }

  Future<void> _onSaved(
    EditProfileSaved event,
    Emitter<EditProfileState> emit,
  ) async {
    final trimmedName = event.name.trim();
    final trimmedBio = event.bio.trim();

    // Diff against the original values: null = unchanged, '' = clear.
    final name = trimmedName == state.profile.name ? null : trimmedName;
    final bio = trimmedBio == state.profile.bio ? null : trimmedBio;

    // Nothing changed — treat as an immediate success so the page just pops.
    if (name == null && bio == null) {
      emit(state.copyWith(phase: EditProfilePhase.saved));
      return;
    }

    emit(state.copyWith(phase: EditProfilePhase.savingProfile));

    final result = await updateProfile(UpdateProfileParams(name: name, bio: bio));

    result.fold(
      (failure) => emit(state.copyWith(
        phase: EditProfilePhase.idle,
        errorCode: ProfileErrorMapper.getCode(failure),
        errorNonce: state.errorNonce + 1,
      )),
      (updated) => emit(state.copyWith(
        profile: updated,
        phase: EditProfilePhase.saved,
        changed: true,
      )),
    );
  }
}
