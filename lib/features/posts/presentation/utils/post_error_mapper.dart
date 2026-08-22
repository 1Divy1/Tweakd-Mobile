import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../domain/failures/post_failures.dart';

/// User-facing error situations the post flows can surface. Blocs emit these
/// codes (never strings); the UI maps them to localized copy via
/// [postErrorMessage]. [imageUploadFailed] is emitted directly by the bloc for a
/// situation that doesn't originate from a [Failure].
enum PostErrorCode {
  postNotFound,
  notOwner,
  invalidTags,
  imageUploadFailed,
  generic,
}

/// In-flight phases shown on the create-post wizard's publish button.
enum CreatePostPhase { creating, uploadingImages }

class PostErrorMapper {
  static PostErrorCode getCode(Failure failure) {
    if (failure is PostNotFoundFailure) return PostErrorCode.postNotFound;
    if (failure is NotPostOwnerFailure) return PostErrorCode.notOwner;
    if (failure is InvalidTagFailure) return PostErrorCode.invalidTags;
    return PostErrorCode.generic;
  }
}

/// Turns a [PostErrorCode] into localized copy. Lives in the presentation layer
/// because it needs an [AppLocalizations] from a widget.
String postErrorMessage(AppLocalizations l10n, PostErrorCode code) =>
    switch (code) {
      PostErrorCode.postNotFound => l10n.postErrorNotFound,
      PostErrorCode.notOwner => l10n.postErrorNotOwner,
      PostErrorCode.invalidTags => l10n.postErrorInvalidTags,
      PostErrorCode.imageUploadFailed => l10n.postErrorImageUpload,
      PostErrorCode.generic => l10n.postErrorGeneric,
    };
