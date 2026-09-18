/// Product analytics, behind an app-owned interface so features never talk to
/// the vendor SDK directly (see `PostHogAnalyticsService`).
///
/// Analytics is **opt-in** and the choice lives on the account
/// (`profiles.analytics_consent`). Until [applyConsent] has been told the
/// signed-in user agreed, every call here is a no-op — including [track] and
/// [screen], so call sites never have to check consent themselves.
///
/// Event rules (ANALYTICS_PROGRESS.md): names are `snake_case` `object_verb`
/// constants from `AnalyticsEvents`; fire only after the backend confirmed the
/// action; properties are enums, counts and booleans — never free text, and
/// never another user's id or username.
abstract class AnalyticsService {
  /// Sets the SDK up at launch. [currentUserId] is the user of the restored
  /// session, if any: when the device remembers that user consented, tracking
  /// resumes right away instead of after the background profile check. Never
  /// throws, and is not awaited on the launch path.
  Future<void> start({String? currentUserId});

  /// The account's current consent, as just read from (or written to) the
  /// server. Granted: tracking is enabled and tied to [userId] (the Supabase
  /// id — nothing else identifies the person). Refused: tracking stops.
  Future<void> applyConsent({required String userId, required bool granted});

  /// Sign-out: forget the user and stop tracking until the next account's
  /// consent is known.
  Future<void> clearUser();

  /// Records [event] (an `AnalyticsEvents` constant) if tracking is on.
  void track(String event, [Map<String, Object>? properties]);

  /// Records a screen view. [name] is a route *pattern* (`/users/:username`),
  /// never a filled-in path, so no usernames or ids leak into screen names.
  void screen(String name);
}

/// Does nothing. The default for blocs constructed by hand (tests), so adding
/// analytics to a bloc never forces every test to supply a fake.
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> start({String? currentUserId}) async {}

  @override
  Future<void> applyConsent({
    required String userId,
    required bool granted,
  }) async {}

  @override
  Future<void> clearUser() async {}

  @override
  void track(String event, [Map<String, Object>? properties]) {}

  @override
  void screen(String name) {}
}
