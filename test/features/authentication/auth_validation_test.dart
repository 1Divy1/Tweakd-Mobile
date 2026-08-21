import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/features/authentication/domain/failures/auth_failures.dart';
import 'package:car_social_media_app/features/authentication/presentation/utils/auth_error_mapper.dart';
import 'package:car_social_media_app/features/authentication/presentation/utils/email_validator.dart';
import 'package:car_social_media_app/features/authentication/presentation/utils/password_policy.dart';
import 'package:flutter_test/flutter_test.dart';

/// The risk in this feature is a client check that disagrees with the server:
/// a password the form accepts but Supabase rejects (or vice versa) turns into
/// an unexplained failure at the worst moment, and a failure that maps to the
/// generic message hides the one thing the user needed to read.
void main() {
  group('PasswordPolicy', () {
    test('accepts a password meeting all four rules', () {
      expect(PasswordPolicy.isValid('Tweakd!23'), isTrue);
      expect(PasswordPolicy.unmetRules('Tweakd!23'), isEmpty);
    });

    test('reports exactly the rules that are unmet', () {
      expect(
        PasswordPolicy.unmetRules('short'),
        containsAll(<PasswordRule>[
          PasswordRule.minLength,
          PasswordRule.uppercase,
          PasswordRule.digit,
          PasswordRule.symbol,
        ]),
      );
      expect(
        PasswordPolicy.unmetRules('short'),
        isNot(contains(PasswordRule.lowercase)),
      );
    });

    test('rejects a password that is one rule short', () {
      // Everything but a symbol.
      expect(PasswordPolicy.isValid('Tweakd123'), isFalse);
      // Everything but an uppercase letter.
      expect(PasswordPolicy.isValid('tweakd!23'), isFalse);
      // Everything but a digit.
      expect(PasswordPolicy.isValid('Tweakd!!!'), isFalse);
      // Everything but length.
      expect(PasswordPolicy.isValid('Tw3!kd'), isFalse);
    });

    test('counts only symbols Supabase itself accepts', () {
      // '£' is not in Supabase's symbol set, so a password relying on it would
      // pass a looser client check and then be rejected server-side.
      expect(PasswordPolicy.isRuleMet(PasswordRule.symbol, 'Tweakd12£'), isFalse);
      for (final symbol in kPasswordSymbols.split('')) {
        expect(
          PasswordPolicy.isRuleMet(PasswordRule.symbol, 'Tweakd12$symbol'),
          isTrue,
          reason: 'symbol "$symbol" should satisfy the rule',
        );
      }
    });

    test('rejects passwords past the 72-character bcrypt limit', () {
      final tooLong = 'Aa1!${'x' * kPasswordMaxLength}';
      expect(tooLong.length, greaterThan(kPasswordMaxLength));
      expect(PasswordPolicy.unmetRules(tooLong), isEmpty);
      expect(PasswordPolicy.isValid(tooLong), isFalse);
    });
  });

  group('isValidEmail', () {
    test('accepts ordinary addresses', () {
      expect(isValidEmail('driver@tweakd.app'), isTrue);
      expect(isValidEmail('first.last+tag@sub.example.co.uk'), isTrue);
      expect(isValidEmail('  spaced@example.com  '), isTrue);
    });

    test('rejects malformed addresses', () {
      expect(isValidEmail(''), isFalse);
      expect(isValidEmail('driver'), isFalse);
      expect(isValidEmail('driver@'), isFalse);
      expect(isValidEmail('driver@localhost'), isFalse);
      expect(isValidEmail('driver@@tweakd.app'), isFalse);
      expect(isValidEmail('dri ver@tweakd.app'), isFalse);
    });

    test('rejects an address longer than Supabase allows', () {
      final long = '${'a' * kEmailMaxLength}@tweakd.app';
      expect(isValidEmail(long), isFalse);
    });
  });

  group('AuthErrorMapper', () {
    test('maps each auth failure to its own code', () {
      final cases = <Failure, AuthErrorCode>{
        const UnauthenticatedFailure(): AuthErrorCode.sessionExpired,
        const InvalidCredentialsFailure(): AuthErrorCode.invalidCredentials,
        const EmailNotConfirmedFailure(): AuthErrorCode.emailNotConfirmed,
        const WeakPasswordFailure(): AuthErrorCode.weakPassword,
        const InvalidCodeFailure(): AuthErrorCode.invalidCode,
        const ExpiredCodeFailure(): AuthErrorCode.expiredCode,
        const RateLimitedFailure(): AuthErrorCode.rateLimited,
        const SamePasswordFailure(): AuthErrorCode.samePassword,
        const SignUpDisabledFailure(): AuthErrorCode.signUpDisabled,
        const NetworkFailure('offline'): AuthErrorCode.network,
      };

      cases.forEach((failure, expected) {
        expect(
          AuthErrorMapper.getCode(failure),
          expected,
          reason: '${failure.runtimeType} should not collapse into generic',
        );
      });
    });

    test('falls back to generic for unrelated failures', () {
      expect(
        AuthErrorMapper.getCode(const ServerFailure('boom')),
        AuthErrorCode.generic,
      );
      expect(
        AuthErrorMapper.getCode(const UnknownFailure('boom')),
        AuthErrorCode.generic,
      );
    });
  });
}
