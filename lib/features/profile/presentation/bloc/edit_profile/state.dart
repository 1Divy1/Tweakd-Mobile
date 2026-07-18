import 'package:equatable/equatable.dart';

import '../../../domain/entities/profile.dart';
import '../../utils/profile_error_mapper.dart';

enum EditProfilePhase {
  /// Idle — the user is editing the form.
  idle,

  /// The picked avatar is compressing/uploading through the 3-step pipeline.
  uploadingAvatar,

  /// The name/bio PATCH is in flight.
  savingProfile,

  /// The name/bio PATCH succeeded — the page should pop.
  saved,
}

class EditProfileState extends Equatable {
  /// The current profile. Its `avatarUrl` updates live after an avatar upload;
  /// `name`/`bio` stay the ORIGINAL values (used to diff on save) until saved.
  final ProfileEntity profile;

  final EditProfilePhase phase;

  /// Local file path of the avatar being uploaded — shown as an instant preview.
  final String? pendingAvatarPath;

  /// Last error, if any (avatar or save). Paired with [errorNonce] so identical
  /// consecutive errors still trigger a fresh one-shot snackbar.
  final ProfileErrorCode? errorCode;
  final int errorNonce;

  /// True once any server-side change (avatar or name/bio) has succeeded, so the
  /// caller knows to refresh the profile page on return.
  final bool changed;

  const EditProfileState({
    required this.profile,
    this.phase = EditProfilePhase.idle,
    this.pendingAvatarPath,
    this.errorCode,
    this.errorNonce = 0,
    this.changed = false,
  });

  EditProfileState copyWith({
    ProfileEntity? profile,
    EditProfilePhase? phase,
    String? pendingAvatarPath,
    bool clearPendingAvatarPath = false,
    ProfileErrorCode? errorCode,
    int? errorNonce,
    bool? changed,
  }) {
    return EditProfileState(
      profile: profile ?? this.profile,
      phase: phase ?? this.phase,
      pendingAvatarPath: clearPendingAvatarPath
          ? null
          : (pendingAvatarPath ?? this.pendingAvatarPath),
      errorCode: errorCode ?? this.errorCode,
      errorNonce: errorNonce ?? this.errorNonce,
      changed: changed ?? this.changed,
    );
  }

  @override
  List<Object?> get props => [
        profile,
        phase,
        pendingAvatarPath,
        errorCode,
        errorNonce,
        changed,
      ];
}
