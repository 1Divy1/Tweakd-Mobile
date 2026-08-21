/// The password rules the signup and reset forms enforce.
///
/// These mirror what Supabase must be configured to require server-side
/// (Auth → Password settings: minimum length 8, required characters
/// "lowercase, uppercase, digits and symbols"). The client check is only there
/// to fail fast with a readable checklist — the server stays the real gate, so
/// if the two ever drift, Supabase wins and the form surfaces its
/// `weak_password` error.
library;

/// Supabase's own minimum. Keep in step with the dashboard setting.
const int kPasswordMinLength = 8;

/// bcrypt hashes at most 72 bytes, and Supabase rejects anything longer, so the
/// input fields cap here rather than letting the server bounce the request.
const int kPasswordMaxLength = 72;

/// The exact symbol set Supabase accepts for its "symbols" requirement. Using a
/// looser definition here (e.g. "anything not alphanumeric") would let a
/// password pass the form and then be rejected by the server.
const String kPasswordSymbols = r"""!@#$%^&*()_+-=[]{};'\:"|<>?,./`~""";

/// One requirement, shown as its own line in the live checklist.
enum PasswordRule { minLength, lowercase, uppercase, digit, symbol }

class PasswordPolicy {
  const PasswordPolicy._();

  /// The rules [password] does **not** yet satisfy, in display order.
  static List<PasswordRule> unmetRules(String password) {
    return PasswordRule.values
        .where((rule) => !isRuleMet(rule, password))
        .toList(growable: false);
  }

  static bool isRuleMet(PasswordRule rule, String password) {
    return switch (rule) {
      PasswordRule.minLength => password.length >= kPasswordMinLength,
      PasswordRule.lowercase => password.contains(RegExp(r'[a-z]')),
      PasswordRule.uppercase => password.contains(RegExp(r'[A-Z]')),
      PasswordRule.digit => password.contains(RegExp(r'[0-9]')),
      PasswordRule.symbol => password.split('').any(kPasswordSymbols.contains),
    };
  }

  /// True when every rule passes and the password is within the server's
  /// accepted length.
  static bool isValid(String password) =>
      password.length <= kPasswordMaxLength && unmetRules(password).isEmpty;
}
