import 'package:tweakd/l10n/app_localizations.dart';

/// Display-name rules. Deliberately permissive about characters — real names
/// carry accents, apostrophes, hyphens and non-Latin scripts — so only length
/// is enforced. The backend imposes no bound of its own.
const int nameMinLength = 2;
const int nameMaxLength = 50;

/// The ways a display name can fail local validation. The presentation layer
/// turns these into localized copy via [nameValidationMessage]; the rule logic
/// itself stays free of user-facing strings.
enum NameValidationError { empty, tooShort, tooLong }

/// Returns the error for [name], or null when it is acceptable. [name] is
/// expected to be trimmed by the caller.
NameValidationError? validateOnboardingName(String name) {
  if (name.isEmpty) return NameValidationError.empty;
  if (name.length < nameMinLength) return NameValidationError.tooShort;
  if (name.length > nameMaxLength) return NameValidationError.tooLong;
  return null;
}

/// Maps a [NameValidationError] to its localized message. Lives in the
/// presentation layer because it needs an [AppLocalizations] from a widget.
String nameValidationMessage(
  AppLocalizations l10n,
  NameValidationError error,
) => switch (error) {
  NameValidationError.empty => l10n.onboardingNameErrorEmpty,
  NameValidationError.tooShort => l10n.onboardingNameErrorTooShort(
    nameMinLength,
  ),
  NameValidationError.tooLong => l10n.onboardingNameErrorTooLong(nameMaxLength),
};
