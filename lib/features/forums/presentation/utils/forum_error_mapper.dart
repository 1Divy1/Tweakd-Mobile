import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';

import '../../domain/failures/forum_failures.dart';

/// User-facing error situations the forums can surface. Blocs emit a code
/// (never a string); the UI maps it to localized copy via [forumErrorMessage].
enum ForumErrorCode { network, notFound, conflict, forbidden, generic }

class ForumErrorMapper {
  static ForumErrorCode getCode(Failure failure) {
    if (failure is NetworkFailure) return ForumErrorCode.network;
    if (failure is ForumNotFoundFailure) return ForumErrorCode.notFound;
    if (failure is ForumConflictFailure) return ForumErrorCode.conflict;
    if (failure is ForumForbiddenFailure) return ForumErrorCode.forbidden;
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
      ForumErrorCode.generic => l10n.forumsErrorGeneric,
    };
