/// Shared JSON helpers for the map-events models.
///
/// The wire is snake_case and every timestamp is an ISO-8601 **UTC** instant.
/// Parsing goes straight to local time so nothing downstream has to remember to
/// convert before formatting a date, and writing goes back through UTC so the
/// device's timezone never leaks into a request body.
library;

DateTime parseInstant(dynamic value) {
  if (value is String && value.isNotEmpty) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed.toLocal();
  }
  // A required timestamp that won't parse is a malformed payload; the epoch is
  // an obviously-wrong value that keeps a list rendering instead of throwing.
  return DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? parseNullableInstant(dynamic value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value)?.toLocal();
  return null;
}

String formatInstant(DateTime value) => value.toUtc().toIso8601String();

/// Empty strings are treated as absent — the backend sends `null` for a missing
/// image or note, but a blank string means the same thing to the UI.
String? parseNullableString(dynamic value) {
  if (value is String && value.isNotEmpty) return value;
  return null;
}
