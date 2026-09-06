import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/feed/data/models/feed_page_model.dart';

/// The feed payload gained one key, `pending_badge_celebrations`. The risk is
/// the parse: a first page must surface the list, a paged response (empty list)
/// and any older payload (key absent) must both degrade to "nothing to
/// celebrate" rather than throw — the animation is an enhancement.
void main() {
  Map<String, dynamic> badgeJson(String id) => {
    'badge': {
      'id': id,
      'title': 'Pioneer',
      'description': 'One of the first members of the community.',
      'unlocked_url': 'https://assets.tweakd.app/badges/$id/unlocked.svg',
      'locked_url': 'https://assets.tweakd.app/badges/$id/locked.svg',
      'available': true,
      'created_at': '2026-09-03T16:22:34Z',
    },
    'earned_at': '2026-09-03T17:00:00Z',
  };

  group('FeedPageModel.fromJson', () {
    test('first page: parses posts, cursor and pending celebrations', () {
      final page = FeedPageModel.fromJson({
        'items': const [],
        'next_cursor': 'eyJyYW5rIjo',
        'pending_badge_celebrations': [
          badgeJson('pioneer'),
          badgeJson('podium'),
        ],
      }).toEntity();

      expect(page.nextCursor, 'eyJyYW5rIjo');
      expect(page.pendingBadgeCelebrations, hasLength(2));
      expect(page.pendingBadgeCelebrations.first.badge.id, 'pioneer');
      expect(page.pendingBadgeCelebrations.first.badge.title, 'Pioneer');
      expect(
        page.pendingBadgeCelebrations.first.earnedAt,
        DateTime.utc(2026, 9, 3, 17),
      );
    });

    test('paged response: empty celebration list', () {
      final page = FeedPageModel.fromJson({
        'items': const [],
        'next_cursor': null,
        'pending_badge_celebrations': const [],
      }).toEntity();

      expect(page.pendingBadgeCelebrations, isEmpty);
    });

    test('missing key degrades to an empty list, never null', () {
      final page = FeedPageModel.fromJson({
        'items': const [],
        'next_cursor': null,
      }).toEntity();

      expect(page.pendingBadgeCelebrations, isEmpty);
    });
  });
}
