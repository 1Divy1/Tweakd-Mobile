import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/notifications/domain/entities/notification.dart';

/// The risk here is that a push payload is turned into a router path *before*
/// anything has validated it, and on a cold start before the user is even on
/// screen. Two things are worth pinning down: that every notification kind
/// lands where it should, and that a payload which isn't what we expect is
/// refused rather than interpolated into a route.

/// Resolves a raw wire `type` the way a tap does — `PushNavigator` for a push,
/// `NotificationEntity.targetRoute` for a row in the list. Both funnel through
/// `NotificationType.fromWire` + `notificationRouteFor`.
String? routeForWireType(String rawType, Map<String, String> payload) =>
    notificationRouteFor(NotificationType.fromWire(rawType), payload);

void main() {
  group('notificationRouteFor', () {
    test('post kinds open the post detail', () {
      expect(
        notificationRouteFor(
          NotificationType.postLike,
          const {'post_id': 'abc123'},
        ),
        '/posts/abc123',
      );
      expect(
        notificationRouteFor(
          NotificationType.postComment,
          const {'post_id': '42'},
        ),
        '/posts/42',
      );
    });

    test('forum kinds open the thread', () {
      expect(
        notificationRouteFor(
          NotificationType.forumReplyTag,
          const {'thread_id': '8f14e45f-ceea-467a-9575-1a1a1a1a1a1a'},
        ),
        '/forums/threads/8f14e45f-ceea-467a-9575-1a1a1a1a1a1a',
      );
    });

    test('a dm opens the conversation', () {
      expect(
        notificationRouteFor(
          NotificationType.dm,
          const {'conversation_id': 'c-1'},
        ),
        '/messages/c-1',
      );
    });

    test('a dm with no conversation id still opens the inbox', () {
      expect(notificationRouteFor(NotificationType.dm, const {}), '/messages');
    });

    test('map event kinds open the event', () {
      expect(
        notificationRouteFor(
          NotificationType.mapEventCarRegistered,
          const {'event_id': 'e-1', 'car_id': 'car-1'},
        ),
        '/map-events/e-1',
      );
    });

    test('an unknown kind has nowhere to go', () {
      expect(
        notificationRouteFor(NotificationType.unknown, const {'post_id': 'x'}),
        isNull,
      );
    });

    test('a known kind missing its id has nowhere to go', () {
      expect(notificationRouteFor(NotificationType.postLike, const {}), isNull);
      expect(notificationRouteFor(NotificationType.forumThreadLike, const {}),
          isNull);
      expect(notificationRouteFor(NotificationType.mapEventApproved, const {}),
          isNull);
      expect(
          notificationRouteFor(NotificationType.moderationWarning, const {}),
          isNull);
    });

    test('an id that could reshape the path is refused', () {
      for (final hostile in [
        '../admin',
        '..',
        'abc/def',
        'abc?redirect=/admin',
        'abc#frag',
        'abc def',
        '',
      ]) {
        expect(
          notificationRouteFor(NotificationType.postLike, {'post_id': hostile}),
          isNull,
          reason: 'post_id "$hostile" must not reach the router',
        );
      }
    });

    test('a hostile id is refused on the newer routes too', () {
      expect(
        notificationRouteFor(
          NotificationType.mapEventApproved,
          const {'event_id': '../admin'},
        ),
        isNull,
      );
      expect(
        notificationRouteFor(
          NotificationType.moderationWarning,
          const {'target_type': 'post', 'target_id': 'abc/def'},
        ),
        isNull,
      );
    });

    test('an absurdly long id is refused', () {
      expect(
        notificationRouteFor(
          NotificationType.postLike,
          {'post_id': 'a' * 65},
        ),
        isNull,
      );
    });
  });

  group('routing by wire type', () {
    test('a dm opens the conversation, needing nothing but its id', () {
      // These are the keys the `dm_send_message` RPC actually writes. The
      // client used to look for `peer_id`/`peer_username`, which never existed
      // on the wire, and fell back to the inbox on every single DM tap.
      expect(
        routeForWireType('dm', const {
          'conversation_id': 'c-1',
          'actor_id': 'u-9',
          'actor_username': 'wheelwell_dana',
          'message_id': 'm-3',
        }),
        '/messages/c-1',
      );
    });

    test('a thin dm payload still opens the conversation', () {
      // The chat resolves its own peer, so nothing beyond the conversation id
      // may be load-bearing for the deep link.
      expect(
        routeForWireType('dm', const {'conversation_id': 'c-1'}),
        '/messages/c-1',
      );
    });

    test('a dm with no conversation id falls back to the inbox', () {
      expect(routeForWireType('dm', const {'actor_id': 'u-9'}), '/messages');
    });

    test('an unrecognised wire type resolves to nothing', () {
      expect(routeForWireType('brand_new_kind', const {'post_id': 'p-1'}),
          isNull);
    });

    test('every type the backend emits resolves to a destination', () {
      // Guards the gap this change closed: 13 of the backend's types were
      // absent from `fromWire`, fell through to `unknown`, and opened nothing.
      // A type added server-side without a route here fails this test.
      const cases = <String, Map<String, String>>{
        'post_like': {'post_id': 'p-1'},
        'post_share': {'post_id': 'p-1'},
        'post_comment': {'post_id': 'p-1', 'comment_id': 'c-2'},
        'post_tag': {'post_id': 'p-1', 'car_tagged': 'true'},
        'post_comment_tag': {'post_id': 'p-1', 'comment_id': 'c-2'},
        'forum_thread_reply': {'thread_id': 't-1', 'reply_id': 'r-1'},
        'forum_reply_reply': {'thread_id': 't-1', 'reply_id': 'r-1'},
        'forum_thread_like': {'thread_id': 't-1'},
        'forum_reply_like': {'thread_id': 't-1', 'reply_id': 'r-1'},
        'forum_thread_tag': {'thread_id': 't-1', 'car_tagged': 'false'},
        'forum_reply_tag': {'thread_id': 't-1', 'reply_id': 'r-1'},
        'map_event_approved': {'event_id': 'e-1'},
        'map_event_rejected': {'event_id': 'e-1'},
        'map_event_car_decided': {'event_id': 'e-1', 'car_id': 'car-1'},
        'map_event_car_registered': {'event_id': 'e-1', 'car_id': 'car-1'},
        'map_event_organizer_added': {'event_id': 'e-1'},
        'map_event_withdrawal_requested': {'event_id': 'e-1'},
        'map_event_withdrawal_decided': {'event_id': 'e-1'},
        'feedback_status': {'feedback_id': 'f-1', 'status': 'shipped'},
        'feedback_status_changed': {'message_id': 'm-1', 'new_status': 'done'},
        'ticket_reply': {'ticket_id': 'tk-1'},
        'moderation_warning': {'target_type': 'post', 'target_id': 'p-1'},
        'dm': {'conversation_id': 'c-1'},
      };

      cases.forEach((type, payload) {
        expect(
          routeForWireType(type, payload),
          isNotNull,
          reason: '$type must open something',
        );
      });
    });

    test('expected destinations for the newly routed types', () {
      expect(routeForWireType('post_tag', const {'post_id': 'p-1'}),
          '/posts/p-1');
      expect(
        // The comment id is on the wire but the post detail page cannot open
        // on a child yet, so the parent post is the destination.
        routeForWireType(
            'post_comment_tag', const {'post_id': 'p-1', 'comment_id': 'c-2'}),
        '/posts/p-1',
      );
      expect(
        routeForWireType('map_event_organizer_added', const {'event_id': 'e-1'}),
        '/map-events/e-1',
      );
      expect(routeForWireType('feedback_status', const {}), '/feedback/mine');
      expect(routeForWireType('ticket_reply', const {}), '/reports');
      // Two different feedback surfaces, two different screens.
      expect(routeForWireType('feedback_status_changed', const {}),
          '/feedback-feed');
    });

    test('moderation targets route by target_type', () {
      expect(
        routeForWireType('moderation_warning',
            const {'target_type': 'post', 'target_id': 'p-1'}),
        '/posts/p-1',
      );
      expect(
        routeForWireType('moderation_warning',
            const {'target_type': 'forum_thread', 'target_id': 't-1'}),
        '/forums/threads/t-1',
      );
      // A child target has no parent id in the payload, so there is nothing
      // to open. An unrecognised target_type must not be interpolated either.
      expect(
        routeForWireType('moderation_warning',
            const {'target_type': 'comment', 'target_id': 'c-1'}),
        isNull,
      );
      expect(
        routeForWireType('moderation_warning',
            const {'target_type': '../admin', 'target_id': 'x'}),
        isNull,
      );
    });

    test('content_removed points at deleted content, so it opens nothing', () {
      expect(
        routeForWireType('content_removed',
            const {'target_type': 'post', 'target_id': 'p-1'}),
        isNull,
      );
    });
  });

  group('NotificationEntity.targetRoute', () {
    test('resolves through the same rules as a push', () {
      final entity = NotificationEntity(
        id: 'n1',
        type: NotificationType.forumThreadReply,
        rawType: 'forum_thread_reply',
        title: 'New reply',
        body: null,
        payload: const {'thread_id': 't-7'},
        read: false,
        createdAt: DateTime(2026, 8, 29),
      );

      expect(entity.targetRoute, '/forums/threads/t-7');
    });
  });
}
