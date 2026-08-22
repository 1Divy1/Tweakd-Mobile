import 'package:tweakd/l10n/app_localizations.dart';

import '../../../../core/error/base_failures.dart';
import '../../domain/failures/profile_failures.dart';

/// User-facing error situations the profile flow can surface. The bloc emits
/// these codes (never strings); the UI maps them to localized copy via
/// [profileErrorMessage].
enum ProfileErrorCode {
  usernameTaken,
  sessionExpired,
  notFound,
  invalidUsername,
  invalidInput,
  avatarUploadFailed,
  languageUpdateFailed,
  network,
  generic,
}

class ProfileErrorMapper {
  static ProfileErrorCode getCode(Failure failure) {
    if (failure is UsernameTakenFailure) {
      return ProfileErrorCode.usernameTaken;
    }
    if (failure is UnauthenticatedFailure) {
      return ProfileErrorCode.sessionExpired;
    }
    if (failure is ProfileNotFoundFailure) {
      return ProfileErrorCode.notFound;
    }
    if (failure is InvalidUsernameFailure) {
      return ProfileErrorCode.invalidUsername;
    }
    if (failure is ProfileUpdateValidationFailure) {
      return ProfileErrorCode.invalidInput;
    }
    if (failure is AvatarUploadFailure) {
      return ProfileErrorCode.avatarUploadFailed;
    }
    if (failure is LanguageUpdateFailure) {
      return ProfileErrorCode.languageUpdateFailed;
    }
    if (failure is NetworkFailure) {
      return ProfileErrorCode.network;
    }
    return ProfileErrorCode.generic;
  }
}

/// Turns a [ProfileErrorCode] into localized copy. Lives in the presentation
/// layer because it needs an [AppLocalizations] from a widget.
String profileErrorMessage(AppLocalizations l10n, ProfileErrorCode code) =>
    switch (code) {
      ProfileErrorCode.usernameTaken => l10n.profileErrorUsernameTaken,
      ProfileErrorCode.sessionExpired => l10n.profileErrorSessionExpired,
      ProfileErrorCode.notFound => l10n.profileErrorNotFound,
      ProfileErrorCode.invalidUsername => l10n.profileErrorInvalidUsername,
      ProfileErrorCode.invalidInput => l10n.editProfileErrorInvalid,
      ProfileErrorCode.avatarUploadFailed => l10n.editProfileErrorAvatar,
      ProfileErrorCode.languageUpdateFailed => l10n.settingsLanguageUpdateError,
      ProfileErrorCode.network => l10n.profileErrorNetwork,
      ProfileErrorCode.generic => l10n.profileErrorGeneric,
    };
