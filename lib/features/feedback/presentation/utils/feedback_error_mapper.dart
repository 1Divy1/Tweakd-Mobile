import '../../../../core/error/base_failures.dart';
import '../../../../l10n/app_localizations.dart';

/// User-facing error situations the feedback flow can surface. The blocs emit
/// these codes (never strings); the UI maps them to localized copy via
/// [feedbackErrorMessage].
enum FeedbackErrorCode { network, generic }

class FeedbackErrorMapper {
  static FeedbackErrorCode getCode(Failure failure) {
    if (failure is NetworkFailure) return FeedbackErrorCode.network;
    return FeedbackErrorCode.generic;
  }
}

/// Turns a [FeedbackErrorCode] into localized copy. Lives in the presentation
/// layer because it needs an [AppLocalizations] from a widget.
String feedbackErrorMessage(AppLocalizations l10n, FeedbackErrorCode code) =>
    switch (code) {
      FeedbackErrorCode.network => l10n.feedbackErrorNetwork,
      FeedbackErrorCode.generic => l10n.feedbackErrorGeneric,
    };
