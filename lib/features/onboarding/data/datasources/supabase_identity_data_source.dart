import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reads identity details Supabase already holds about the signed-in user.
///
/// The only Supabase touch point in this feature — everything else here talks
/// to the Spring backend. It exists because the display name a social provider
/// supplies lands in the Supabase user metadata, and the onboarding form
/// prefills its name field from it.
///
/// Read-only, and a local one at that: it inspects the session the client
/// already holds, so there is no network call and nothing is ever written back.
@lazySingleton
class SupabaseIdentityDataSource {
  final SupabaseClient supabaseClient;

  SupabaseIdentityDataSource(this.supabaseClient);

  /// The full name the sign-up provider supplied, or null when there is none —
  /// an email/password account, or an Apple account that has signed in before
  /// (Apple sends the name only on the very first sign-in ever).
  ///
  /// The key order deliberately mirrors the `handle_new_user` database trigger,
  /// so the value prefilled here and the one the trigger wrote can never
  /// disagree about which key wins.
  String? get providerFullName {
    final metadata = supabaseClient.auth.currentUser?.userMetadata;
    if (metadata == null) return null;

    String? read(String key) {
      final value = metadata[key];
      if (value is! String) return null;
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    String? join(String firstKey, String lastKey) {
      final parts = [read(firstKey), read(lastKey)].whereType<String>();
      return parts.isEmpty ? null : parts.join(' ');
    }

    return read('full_name') ??
        read('name') ??
        join('first_name', 'last_name') ??
        join('given_name', 'family_name');
  }
}
