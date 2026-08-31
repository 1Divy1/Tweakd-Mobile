import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:equatable/equatable.dart';

import '../../domain/failures/map_event_failures.dart';

/// User-facing error situations the map-events feature can surface. Blocs emit
/// these codes (never raw strings); the UI localizes them via
/// [mapEventErrorMessage].
enum MapEventErrorCode {
  network,
  notFound,
  forbidden,

  /// A 409 on the participation endpoints — finished / deadline passed / full.
  conflict,

  /// A 400 the user can fix by editing what they typed.
  invalidInput,

  /// A multi-car registration hit a conflict partway through and some of the
  /// cars that already landed as **accepted** (a no-approval event) couldn't
  /// be automatically undone — only a still-pending row can be cancelled.
  partialRegistration,

  generic,
}

/// An error plus, for the two cases where the backend is the only thing that
/// knows *why*, the server's own sentence.
///
/// The backend distinguishes "this event has finished", "the registration
/// deadline has passed" and "this event has reached its participant capacity"
/// only in prose — there is no error code to branch on — so those messages are
/// shown verbatim rather than flattened into one vague client-side string.
///
/// ⚠️ Those sentences are **not localized** (see `MAP_EVENTS_NOTES.md`): a
/// Romanian user sees the English message. [message] falls back to the
/// localized copy for [code] when the server sends nothing.
class MapEventError extends Equatable {
  final MapEventErrorCode code;
  final String? serverMessage;

  /// Only set for [MapEventErrorCode.partialRegistration]: how many of a
  /// batch registration actually stuck versus how many were requested.
  final int? registeredCount;
  final int? requestedCount;

  const MapEventError(
    this.code, {
    this.serverMessage,
    this.registeredCount,
    this.requestedCount,
  });

  @override
  List<Object?> get props =>
      [code, serverMessage, registeredCount, requestedCount];
}

class MapEventErrorMapper {
  static MapEventError from(Failure failure) {
    if (failure is NetworkFailure) {
      return const MapEventError(MapEventErrorCode.network);
    }
    if (failure is MapEventNotFoundFailure) {
      return const MapEventError(MapEventErrorCode.notFound);
    }
    if (failure is MapEventForbiddenFailure) {
      return const MapEventError(MapEventErrorCode.forbidden);
    }
    if (failure is MapEventParticipationConflictFailure) {
      return MapEventError(
        MapEventErrorCode.conflict,
        serverMessage: failure.message,
      );
    }
    if (failure is MapEventInvalidInputFailure) {
      return MapEventError(
        MapEventErrorCode.invalidInput,
        serverMessage: failure.message,
      );
    }
    return const MapEventError(MapEventErrorCode.generic);
  }

  static MapEventErrorCode getCode(Failure failure) => from(failure).code;
}

/// Turns a [MapEventError] into copy for the user. Lives in the presentation
/// layer because it needs an [AppLocalizations] from a widget.
String mapEventErrorMessage(AppLocalizations l10n, MapEventError error) {
  final server = error.serverMessage;
  final serverIsUseful = server != null && server.trim().isNotEmpty;

  return switch (error.code) {
    MapEventErrorCode.network => l10n.mapEventsErrorNetwork,
    MapEventErrorCode.notFound => l10n.mapEventsErrorNotFound,
    MapEventErrorCode.forbidden => l10n.mapEventsErrorForbidden,
    MapEventErrorCode.conflict =>
      serverIsUseful ? server : l10n.mapEventsErrorConflict,
    MapEventErrorCode.invalidInput =>
      serverIsUseful ? server : l10n.mapEventsErrorInvalidInput,
    MapEventErrorCode.partialRegistration => l10n.mapEventsBulkRegisterPartial(
        error.registeredCount ?? 0,
        (error.requestedCount ?? 0) - (error.registeredCount ?? 0),
      ),
    MapEventErrorCode.generic => l10n.mapEventsErrorGeneric,
  };
}
