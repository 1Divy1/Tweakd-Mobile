import 'package:http/http.dart' as net;
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/base_exceptions.dart';

/// The account's analytics opt-in, `profiles.analytics_consent`.
///
/// Read straight from the caller's own `profiles` row (the one table the app
/// may select directly) and written through the `set_analytics_consent` RPC —
/// the row itself is not writable from the app.
@lazySingleton
class AnalyticsConsentDataSource {
  final SupabaseClient supabaseClient;

  AnalyticsConsentDataSource(this.supabaseClient);

  String get _userId {
    final id = supabaseClient.auth.currentSession?.user.id;
    if (id == null) throw UnauthenticatedException('No active session.');
    return id;
  }

  /// The signed-in user's id, for handing the new choice to analytics.
  String get currentUserId => _userId;

  Future<bool> getConsent() => _guard(() async {
    final row = await supabaseClient
        .from('profiles')
        .select('analytics_consent')
        .eq('id', _userId)
        .single();
    return row['analytics_consent'] as bool? ?? false;
  });

  Future<void> setConsent(bool granted) => _guard(() async {
    _userId; // fail fast without a session
    await supabaseClient.rpc(
      'set_analytics_consent',
      params: {'p_granted': granted},
    );
  });

  /// Supabase throws its own exception types; per the error pipeline they must
  /// never leak past the data layer.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      if (e.code == '42501') throw UnauthenticatedException(e.message);
      throw ServerException(e.message);
    } on AuthException catch (e) {
      throw UnauthenticatedException(e.message);
    } on net.ClientException {
      throw NetworkException();
    }
  }
}
