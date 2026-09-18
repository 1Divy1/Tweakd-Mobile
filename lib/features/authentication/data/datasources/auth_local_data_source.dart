import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Remembers, on the device, which user last finished onboarding.
///
/// This is what lets a cold start skip the network entirely: a saved session
/// whose user id matches the marker goes straight to the feed, and the
/// `profiles` lookup runs in the background instead of behind the splash.
///
/// Only "onboarded" is ever stored — never "requires onboarding". That flag
/// only flips one way (true → false), so a remembered `false` can't go stale,
/// while a remembered `true` would send a user who just finished onboarding
/// back to it on their next launch.
///
/// Lives in secure storage next to the Supabase session, so the logout sweep
/// (`FlutterSecureStorage().deleteAll()`) takes it with everything else.
@lazySingleton
class AuthLocalDataSource {
  static const _onboardedUserKey = 'onboarded_user_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Whether [userId] is the user last seen with onboarding complete. A read
  /// failure answers false: the app then just takes the slower, checked path.
  Future<bool> isOnboarded(String userId) async {
    try {
      return await _storage.read(key: _onboardedUserKey) == userId;
    } catch (e) {
      debugPrint('Failed to read the onboarded marker: ${e.runtimeType}');
      return false;
    }
  }

  Future<void> markOnboarded(String userId) async {
    try {
      await _storage.write(key: _onboardedUserKey, value: userId);
    } catch (e) {
      debugPrint('Failed to save the onboarded marker: ${e.runtimeType}');
    }
  }
}
