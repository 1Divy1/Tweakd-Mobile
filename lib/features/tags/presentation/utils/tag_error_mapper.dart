import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';

import '../../domain/failures/tag_failures.dart';

/// User-facing error situations the tags feed can surface. Blocs emit these
/// codes (never strings); the UI maps them to localized copy via
/// [tagErrorMessage].
enum TagErrorCode { contentGone, invalidCursor, generic }

class TagErrorMapper {
  static TagErrorCode getCode(Failure failure) {
    if (failure is TaggedContentNotFoundFailure) return TagErrorCode.contentGone;
    if (failure is InvalidTagCursorFailure) return TagErrorCode.invalidCursor;
    return TagErrorCode.generic;
  }
}

/// Turns a [TagErrorCode] into localized copy. Lives in the presentation layer
/// because it needs an [AppLocalizations] from a widget.
String tagErrorMessage(AppLocalizations l10n, TagErrorCode code) =>
    switch (code) {
      TagErrorCode.contentGone => l10n.tagsErrorContentGone,
      TagErrorCode.invalidCursor => l10n.tagsErrorGeneric,
      TagErrorCode.generic => l10n.tagsErrorGeneric,
    };
