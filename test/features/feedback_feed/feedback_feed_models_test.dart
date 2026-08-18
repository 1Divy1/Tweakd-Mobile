import 'package:car_social_media_app/features/feedback_feed/data/models/feedback_feed_models.dart';
import 'package:car_social_media_app/features/feedback_feed/domain/entities/feedback_message.dart';
import 'package:car_social_media_app/features/feedback_feed/domain/entities/feedback_option.dart';
import 'package:car_social_media_app/features/feedback_feed/domain/entities/feedback_sort.dart';
import 'package:flutter_test/flutter_test.dart';

/// The board's risk sits in two places: the snake_case mapping (where a
/// mistyped key yields a plausible card full of defaults rather than an error)
/// and the optimistic vote arithmetic that runs before the server answers.
void main() {
  Map<String, dynamic> messageJson({
    Object? myVote,
    String statusId = 'sent',
    bool viewerIsAuthor = false,
    bool deleted = false,
  }) =>
      {
        'id': 'm1',
        'author': {
          'id': 'u1',
          'name': 'Dana Wheelwell',
          'username': 'wheelwell_dana',
          'avatar_url': null,
        },
        'message': 'Cover photo resets when I reorder the gallery.',
        'type': {'id': 'bug', 'label': 'Bug'},
        'status': {'id': statusId, 'label': 'Sent'},
        'staff_response': null,
        'up_votes': 512,
        'down_votes': 37,
        'net_votes': 475,
        'my_vote': myVote,
        'viewer_is_author': viewerIsAuthor,
        'deleted': deleted,
        'created_at': '2026-08-15T09:30:00Z',
        'completed_at': null,
      };

  group('FeedbackMessageModel', () {
    test('maps a full payload', () {
      final message = FeedbackMessageModel.fromJson(messageJson()).toEntity();

      expect(message.id, 'm1');
      expect(message.author.username, 'wheelwell_dana');
      expect(message.type.id, kFeedbackTypeBug);
      expect(message.type.label, 'Bug');
      expect(message.upVotes, 512);
      expect(message.downVotes, 37);
      expect(message.netVotes, 475);
      expect(message.completedAt, isNull);
    });

    test('my_vote is accepted as a number or a numeric string', () {
      int? voteOf(Object? raw) =>
          FeedbackMessageModel.fromJson(messageJson(myVote: raw)).myVote;

      expect(voteOf(1), 1);
      expect(voteOf(-1), -1);
      expect(voteOf('1'), 1);
      expect(voteOf('-1'), -1);
    });

    test('an absent or nonsensical my_vote means "no vote"', () {
      int? voteOf(Object? raw) =>
          FeedbackMessageModel.fromJson(messageJson(myVote: raw)).myVote;

      expect(voteOf(null), isNull);
      expect(voteOf(0), isNull);
      expect(voteOf(7), isNull);
      expect(voteOf('up'), isNull);
    });

    test('net_votes falls back to the difference when the field is absent', () {
      final json = messageJson()..remove('net_votes');

      expect(FeedbackMessageModel.fromJson(json).netVotes, 512 - 37);
    });

    test('instants are parsed to local time', () {
      final message = FeedbackMessageModel.fromJson(messageJson()).toEntity();

      expect(message.createdAt.isUtc, isFalse);
      expect(
        message.createdAt.toUtc().toIso8601String(),
        startsWith('2026-08-15T09:30:00'),
      );
    });

    test('only the author may delete, and only while the status is sent', () {
      FeedbackMessageEntity build({
        required String statusId,
        required bool isAuthor,
      }) =>
          FeedbackMessageModel.fromJson(
            messageJson(statusId: statusId, viewerIsAuthor: isAuthor),
          ).toEntity();

      expect(
        build(statusId: kFeedbackStatusSent, isAuthor: true).canDelete,
        isTrue,
      );
      expect(
        build(statusId: kFeedbackStatusSent, isAuthor: false).canDelete,
        isFalse,
      );
      expect(
        build(statusId: kFeedbackStatusUnderDevelopment, isAuthor: true)
            .canDelete,
        isFalse,
      );
      expect(
        build(statusId: kFeedbackStatusCompleted, isAuthor: true).canDelete,
        isFalse,
      );
    });
  });

  group('FeedbackMessagePageModel', () {
    test('a null cursor is the only end-of-list signal', () {
      final page = FeedbackMessagePageModel.fromJson({
        'items': [messageJson()],
        'next_cursor': null,
      }).toEntity();

      expect(page.items, hasLength(1));
      expect(page.nextCursor, isNull);
    });

    test('deleted messages never reach the UI', () {
      final page = FeedbackMessagePageModel.fromJson({
        'items': [messageJson(), messageJson(deleted: true)],
        'next_cursor': 'abc',
      }).toEntity();

      expect(page.items, hasLength(1));
      expect(page.nextCursor, 'abc');
    });

    test('a missing items array yields an empty page rather than throwing', () {
      final page =
          FeedbackMessagePageModel.fromJson(const {}).toEntity();

      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
    });
  });

  group('optimistic vote arithmetic', () {
    final base = FeedbackMessageModel.fromJson(messageJson()).toEntity();

    test('an up vote from nothing bumps ups and the net score', () {
      final voted = base.withVote(1);

      expect(voted.upVotes, 513);
      expect(voted.downVotes, 37);
      expect(voted.netVotes, 476);
      expect(voted.myVote, 1);
    });

    test('switching sides moves the vote across, not just onto the new one',
        () {
      final voted = base.withVote(1).withVote(-1);

      expect(voted.upVotes, 512);
      expect(voted.downVotes, 38);
      expect(voted.netVotes, 474);
      expect(voted.myVote, -1);
    });

    test('withdrawing returns to the starting tallies', () {
      final voted = base.withVote(1).withVote(null);

      expect(voted.upVotes, base.upVotes);
      expect(voted.downVotes, base.downVotes);
      expect(voted.netVotes, base.netVotes);
      expect(voted.myVote, isNull);
    });

    test('tallies never go negative if the server disagrees with us', () {
      final zeroed = FeedbackMessageModel.fromJson(
        messageJson(myVote: 1)..['up_votes'] = 0,
      ).toEntity();

      expect(zeroed.withVote(null).upVotes, 0);
    });
  });

  group('FeedbackSort', () {
    test('sends the wire values the backend documents', () {
      expect(FeedbackSort.newest.wireValue, 'newest');
      expect(FeedbackSort.popular.wireValue, 'popular');
      expect(FeedbackSort.oldest.wireValue, 'oldest');
    });
  });
}
