import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';

import '../../domain/failures/feedback_feed_failures.dart';

/// User-facing error situations the feedback board can surface. Blocs emit a
/// code (never a string); the UI maps it to localized copy via
/// [feedbackFeedErrorMessage].
enum FeedbackFeedErrorCode {
  network,

  /// The message is gone — someone deleted it while the list was on screen.
  notFound,

  /// Delete refused: staff have already picked the message up, so it is no
  /// longer the author's to remove.
  locked,

  generic,
}

class FeedbackFeedErrorMapper {
  static FeedbackFeedErrorCode getCode(Failure failure) {
    if (failure is NetworkFailure) return FeedbackFeedErrorCode.network;
    if (failure is FeedbackMessageLockedFailure) {
      return FeedbackFeedErrorCode.locked;
    }
    if (failure is FeedbackMessageNotFoundFailure) {
      return FeedbackFeedErrorCode.notFound;
    }
    return FeedbackFeedErrorCode.generic;
  }
}

/// Turns a [FeedbackFeedErrorCode] into localized copy. Lives in the
/// presentation layer because it needs an [AppLocalizations] from a widget.
String feedbackFeedErrorMessage(
  AppLocalizations l10n,
  FeedbackFeedErrorCode code,
) =>
    switch (code) {
      FeedbackFeedErrorCode.network => l10n.feedbackFeedErrorNetwork,
      FeedbackFeedErrorCode.notFound => l10n.feedbackFeedErrorNotFound,
      FeedbackFeedErrorCode.locked => l10n.feedbackFeedErrorLocked,
      FeedbackFeedErrorCode.generic => l10n.feedbackFeedErrorGeneric,
    };
