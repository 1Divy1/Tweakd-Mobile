import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../domain/failures/garage_failures.dart';

/// User-facing error situations the garage flows can surface. Blocs emit these
/// codes (never strings); the UI maps them to localized copy via
/// [garageErrorMessage]. The last four are emitted directly by blocs for
/// situations that don't originate from a [Failure].
enum GarageErrorCode {
  carNotFound,
  garageNotFound,
  privateGarage,
  notOwner,
  invalidReference,
  generic,
  refDataLoadFailed,
  categoriesLoadFailed,
  photoUploadFailed,
  editSaveFailed,
}

/// In-flight phases shown on the register/edit wizard's submit button.
enum AddCarPhase { creating, uploadingPhotos, savingChanges, savingPhotos }

class GarageErrorMapper {
  static GarageErrorCode getCode(Failure failure) {
    if (failure is CarNotFoundFailure) return GarageErrorCode.carNotFound;
    if (failure is GarageNotFoundFailure) return GarageErrorCode.garageNotFound;
    if (failure is PrivateGarageFailure) return GarageErrorCode.privateGarage;
    if (failure is NotCarOwnerFailure) return GarageErrorCode.notOwner;
    if (failure is InvalidReferenceFailure) {
      return GarageErrorCode.invalidReference;
    }
    return GarageErrorCode.generic;
  }
}

/// Turns a [GarageErrorCode] into localized copy. Lives in the presentation
/// layer because it needs an [AppLocalizations] from a widget.
String garageErrorMessage(AppLocalizations l10n, GarageErrorCode code) =>
    switch (code) {
      GarageErrorCode.carNotFound => l10n.garageErrorCarNotFound,
      GarageErrorCode.garageNotFound => l10n.garageErrorGarageNotFound,
      GarageErrorCode.privateGarage => l10n.garageErrorPrivateGarage,
      GarageErrorCode.notOwner => l10n.garageErrorNotOwner,
      GarageErrorCode.invalidReference => l10n.garageErrorInvalidReference,
      GarageErrorCode.generic => l10n.garageErrorGeneric,
      GarageErrorCode.refDataLoadFailed => l10n.garageErrorRefDataLoadFailed,
      GarageErrorCode.categoriesLoadFailed =>
        l10n.garageErrorCategoriesLoadFailed,
      GarageErrorCode.photoUploadFailed => l10n.garageErrorPhotoUploadFailed,
      GarageErrorCode.editSaveFailed => l10n.garageErrorEditSaveFailed,
    };

/// Turns an [AddCarPhase] into the localized submit-button label.
String addCarPhaseLabel(AppLocalizations l10n, AddCarPhase phase) =>
    switch (phase) {
      AddCarPhase.creating => l10n.garagePhaseCreating,
      AddCarPhase.uploadingPhotos => l10n.garagePhaseUploadingPhotos,
      AddCarPhase.savingChanges => l10n.garagePhaseSavingChanges,
      AddCarPhase.savingPhotos => l10n.garagePhaseSavingPhotos,
    };
