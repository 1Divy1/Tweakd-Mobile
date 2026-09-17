import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/network/rate_limit_notifier.dart';

/// The notifier decides whether a 429 is worth telling the user about: one
/// message per burst, a new one when the wait materially grows or the burst
/// is over, and never for background-only limits.
void main() {
  late DateTime now;
  late RateLimitNotifier notifier;
  late List<RateLimitNotice> seen;

  setUp(() {
    now = DateTime.utc(2026, 9, 16, 12);
    notifier = RateLimitNotifier.withClock(() => now);
    seen = [];
    notifier.notices.listen(seen.add);
  });

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('a burst of refused requests becomes one notice', () async {
    notifier.report(retryAfter: const Duration(seconds: 3), limit: 'general');
    now = now.add(const Duration(milliseconds: 200));
    notifier.report(retryAfter: const Duration(seconds: 4), limit: 'general');
    notifier.report(retryAfter: const Duration(seconds: 3), limit: 'general');
    await flush();

    expect(seen, [const RateLimitNotice(retryAfter: Duration(seconds: 3))]);
  });

  test('a much longer wait inside the burst replaces the message', () async {
    notifier.report(retryAfter: const Duration(seconds: 2), limit: 'general');
    notifier.report(
      retryAfter: const Duration(minutes: 2),
      limit: 'posts.create',
    );
    await flush();

    expect(seen.map((n) => n.retryAfter), [
      const Duration(seconds: 2),
      const Duration(minutes: 2),
    ]);
  });

  test('a hit after the burst window is news again', () async {
    notifier.report(retryAfter: const Duration(seconds: 10), limit: 'comments');
    now = now.add(const Duration(seconds: 5));
    notifier.report(retryAfter: const Duration(seconds: 5), limit: 'comments');
    await flush();

    expect(seen, hasLength(2));
  });

  test('background-only limits are never shown', () async {
    notifier.report(retryAfter: const Duration(hours: 1), limit: 'devices');
    await flush();

    expect(seen, isEmpty);
  });

  test('an unknown wait is still reported', () async {
    notifier.report();
    await flush();

    expect(seen, [const RateLimitNotice()]);
  });
}
