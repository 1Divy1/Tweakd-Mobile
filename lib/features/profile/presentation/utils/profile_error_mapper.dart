import 'package:car_social_media_app/l10n/app_localizations.dart';

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
      ProfileErrorCode.generic => l10n.profileErrorGeneric,
    };
