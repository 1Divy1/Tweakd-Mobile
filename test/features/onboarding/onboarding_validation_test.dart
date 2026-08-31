import 'package:tweakd/features/onboarding/presentation/utils/name_validator.dart';
import 'package:flutter_test/flutter_test.dart';

/// The display name is the one profile field with a single chance to be set:
/// Apple hands it over only on a first-ever sign-in, and nothing else in the
/// app asks for it. A rule that wrongly rejects a real name blocks onboarding
/// outright, and one that wrongly accepts a blank writes an empty name the
/// user can never fix from here.
void main() {
  group('validateOnboardingName', () {
    test('accepts ordinary names', () {
      expect(validateOnboardingName('David Mesaros'), isNull);
      expect(validateOnboardingName('Bo'), isNull);
    });

    test('accepts names outside plain ASCII', () {
      // Accents, apostrophes, hyphens and non-Latin scripts are all real names
      // — only length is enforced, so none of these may be rejected.
      expect(validateOnboardingName('Ștefan Popescu'), isNull);
      expect(validateOnboardingName("Fiona O'Sullivan"), isNull);
      expect(validateOnboardingName('Anne-Marie García'), isNull);
      expect(validateOnboardingName('Дмитрий'), isNull);
    });

    test('rejects an empty name', () {
      expect(validateOnboardingName(''), NameValidationError.empty);
    });

    test('rejects a name shorter than the minimum', () {
      expect(validateOnboardingName('D'), NameValidationError.tooShort);
    });

    test('rejects a name past the maximum', () {
      expect(
        validateOnboardingName('a' * (nameMaxLength + 1)),
        NameValidationError.tooLong,
      );
      // The boundary itself is still valid.
      expect(validateOnboardingName('a' * nameMaxLength), isNull);
    });
  });
}
