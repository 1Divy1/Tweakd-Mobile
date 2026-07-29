import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';

import '../../domain/failures/forum_failures.dart';

/// User-facing error situations the forums can surface. Blocs emit a code
/// (never a string); the UI maps it to localized copy via [forumErrorMessage].
enum ForumErrorCode {
  network,
  notFound,
  conflict,
  forbidden,

  /// 400 from a write — in practice a tagged profile/car that no longer
  /// exists, or a tagged car whose owner isn't tagged.
  invalidTags,
  generic,
}

class ForumErrorMapper {
  /// [validationCode] is what a 400 maps to. It stays [ForumErrorCode.generic]
  /// for most calls (a rejected cursor or sort says nothing to the user);
  /// writes that carry tags pass [ForumErrorCode.invalidTags], the only 400
  /// those endpoints raise in practice.
  static ForumErrorCode getCode(
    Failure failure, {
    ForumErrorCode validationCode = ForumErrorCode.generic,
  }) {
    if (failure is NetworkFailure) return ForumErrorCode.network;
    if (failure is ForumNotFoundFailure) return ForumErrorCode.notFound;
    if (failure is ForumConflictFailure) return ForumErrorCode.conflict;
    if (failure is ForumForbiddenFailure) return ForumErrorCode.forbidden;
    if (failure is ForumValidationFailure) return validationCode;
    return ForumErrorCode.generic;
  }
}

/// Turns a [ForumErrorCode] into localized copy. Lives in the presentation
/// layer because it needs an [AppLocalizations] from a widget.
String forumErrorMessage(AppLocalizations l10n, ForumErrorCode code) =>
    switch (code) {
      ForumErrorCode.network => l10n.forumsErrorNetwork,
      ForumErrorCode.notFound => l10n.forumsErrorNotFound,
      ForumErrorCode.conflict => l10n.forumsErrorConflict,
      ForumErrorCode.forbidden => l10n.forumsErrorForbidden,
      ForumErrorCode.invalidTags => l10n.forumsErrorInvalidTags,
      ForumErrorCode.generic => l10n.forumsErrorGeneric,
    };
