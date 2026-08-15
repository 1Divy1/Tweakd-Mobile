import 'package:car_social_media_app/l10n/app_localizations.dart';

import '../../../../core/error/base_failures.dart';
import '../../domain/failures/map_failures.dart';

/// User-facing error situations the map can surface. The bloc emits a code
/// (never a string); the UI maps it to localized copy via [mapErrorMessage].
enum MapErrorCode { network, notFound, locationUnavailable, generic }

class MapErrorMapper {
  static MapErrorCode getCode(Failure failure) {
    if (failure is NetworkFailure) return MapErrorCode.network;
    if (failure is BusinessNotFoundFailure) return MapErrorCode.notFound;
    if (failure is LocationUnavailableFailure) {
      return MapErrorCode.locationUnavailable;
    }
    return MapErrorCode.generic;
  }
}

String mapErrorMessage(AppLocalizations l10n, MapErrorCode code) =>
    switch (code) {
      MapErrorCode.network => l10n.mapErrorNetwork,
      MapErrorCode.notFound => l10n.mapErrorBusinessNotFound,
      MapErrorCode.locationUnavailable => l10n.mapErrorLocationUnavailable,
      MapErrorCode.generic => l10n.mapErrorGeneric,
    };
