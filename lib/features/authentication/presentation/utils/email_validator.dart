/// Client-side email shape check for the auth forms.
///
/// Deliberately permissive: this only exists to catch obvious typos before a
/// round trip. Supabase does the authoritative validation, and the only real
/// proof an address works is the confirmation email arriving.
final RegExp _emailPattern = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
);

/// Supabase rejects addresses longer than this outright.
const int kEmailMaxLength = 255;

bool isValidEmail(String email) {
  final trimmed = email.trim();
  return trimmed.length <= kEmailMaxLength && _emailPattern.hasMatch(trimmed);
}
