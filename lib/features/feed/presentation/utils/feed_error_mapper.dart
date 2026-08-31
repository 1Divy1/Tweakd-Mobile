import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/l10n/app_localizations.dart';

/// User-facing error situations the feed can surface. The bloc emits a code
/// (never a string); the UI maps it to localized copy via [feedErrorMessage].
enum FeedErrorCode { network, generic }

class FeedErrorMapper {
  static FeedErrorCode getCode(Failure failure) {
    if (failure is NetworkFailure) return FeedErrorCode.network;
    return FeedErrorCode.generic;
  }
}

/// Turns a [FeedErrorCode] into localized copy. Lives in the presentation layer
/// because it needs an [AppLocalizations] from a widget.
String feedErrorMessage(AppLocalizations l10n, FeedErrorCode code) =>
    switch (code) {
      FeedErrorCode.network => l10n.feedErrorNetwork,
      FeedErrorCode.generic => l10n.feedErrorGeneric,
    };
