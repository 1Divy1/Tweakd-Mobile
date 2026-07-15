import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';

/// User-facing error situations messaging can surface. The bloc emits a code
/// (never a string); the UI maps it to localized copy via
/// [messagesErrorMessage].
enum MessagesErrorCode { network, generic }

class MessagesErrorMapper {
  static MessagesErrorCode getCode(Failure failure) {
    if (failure is NetworkFailure) return MessagesErrorCode.network;
    return MessagesErrorCode.generic;
  }
}

String messagesErrorMessage(AppLocalizations l10n, MessagesErrorCode code) =>
    switch (code) {
      MessagesErrorCode.network => l10n.messagesErrorNetwork,
      MessagesErrorCode.generic => l10n.messagesErrorGeneric,
    };
