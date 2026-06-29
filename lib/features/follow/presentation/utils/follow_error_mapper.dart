import 'package:car_social_media_app/l10n/app_localizations.dart';

import '../../../../core/error/base_failures.dart';
import '../../domain/failures/follow_failures.dart';

/// User-facing error situations the follow flow can surface. The bloc emits
/// these codes (never strings); the UI maps them to localized copy via
/// [followErrorMessage].
enum FollowErrorCode {
  cannotFollowSelf,
  privateProfile,
  userNotFound,
  requestNotFound,
  sessionExpired,
  generic,
}

class FollowErrorMapper {
  static FollowErrorCode getCode(Failure failure) {
    if (failure is CannotFollowSelfFailure) {
      return FollowErrorCode.cannotFollowSelf;
    }
    if (failure is PrivateProfileFailure) return FollowErrorCode.privateProfile;
    if (failure is TargetUserNotFoundFailure) {
      return FollowErrorCode.userNotFound;
    }
    if (failure is FollowRequestNotFoundFailure) {
      return FollowErrorCode.requestNotFound;
    }
    if (failure is UnauthenticatedFollowFailure) {
      return FollowErrorCode.sessionExpired;
    }
    return FollowErrorCode.generic;
  }
}

/// Turns a [FollowErrorCode] into localized copy. Lives in the presentation
/// layer because it needs an [AppLocalizations] from a widget.
String followErrorMessage(AppLocalizations l10n, FollowErrorCode code) =>
    switch (code) {
      FollowErrorCode.cannotFollowSelf => l10n.followErrorCannotFollowSelf,
      FollowErrorCode.privateProfile => l10n.followErrorPrivateProfile,
      FollowErrorCode.userNotFound => l10n.followErrorUserNotFound,
      FollowErrorCode.requestNotFound => l10n.followErrorRequestNotFound,
      FollowErrorCode.sessionExpired => l10n.followErrorSessionExpired,
      FollowErrorCode.generic => l10n.followErrorGeneric,
    };
