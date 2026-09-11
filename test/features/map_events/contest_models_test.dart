import 'package:tweakd/features/map_events/data/models/contest_models.dart';
import 'package:tweakd/features/map_events/domain/entities/contest_board_update.dart';
import 'package:tweakd/features/map_events/domain/entities/contest_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/contest_fixtures.dart';

/// The wire mapping and the two pieces of client-side arithmetic — re-ranking
/// on a live board and the optimistic vote — are the parts most likely to
/// drift from the server silently, so each is pinned here.
void main() {
  group('ContestModel', () {
    test('maps a full payload', () {
      final contest = ContestModel.fromJson({
        'id': 'k1',
        'event_id': 'm1',
        'category': {'id': 'exhaust', 'label': 'Best exhaust system', 'icon': 'exhaust'},
        'title': 'Best exhaust system',
        'criteria': 'Walk the row, listen, then vote.',
        'status': 'open',
        'opens_at': '2026-08-11T15:30:00Z',
        'closes_at': '2026-08-11T19:30:00Z',
        'finished_at': null,
        'finished_early': false,
        'votes_count': 186,
        'entries_count': 2,
        'entries': [
          {
            'car': {
              'id': 'c2',
              'brand': 'Porsche',
              'model': '911 GT3',
              'year': 2021,
              'horsepower': 502,
              'torque': 470,
              'cover_image': null,
              'status': null,
              'owner': {'id': 'u2', 'username': 'noctis_nico'},
            },
            'votes_count': 61,
            'rank': 1,
            'final_rank': null,
            'last_vote_at': '2026-08-11T18:00:00Z',
          },
        ],
        'viewer': {
          'is_organizer': false,
          'can_vote': true,
          'vote_car_id': 'c2',
          'can_enter': true,
          'my_entries': [
            {'car_id': 'c1', 'status': 'pending', 'rejection_reason': null},
          ],
        },
        'pending_entries': [],
        'created_by': {'id': 'u1', 'name': 'Sasha', 'username': 'torque_sasha', 'avatar_url': null},
        'created_at': '2026-08-11T14:00:00Z',
      }).toEntity();

      expect(contest.id, 'k1');
      expect(contest.category.icon, ContestCategoryIcon.exhaust);
      expect(contest.status, ContestStatus.open);
      expect(contest.isOpen, isTrue);
      expect(contest.votesCount, 186);
      expect(contest.entries.single.car.ownerUsername, 'noctis_nico');
      expect(contest.entries.single.lastVoteAt, isNotNull);
      expect(contest.viewer.voteCarId, 'c2');
      expect(contest.viewer.hasVoted, isTrue);
      expect(contest.viewer.myEntries.single.status, ContestEntryStatus.pending);
      expect(contest.createdByUsername, 'torque_sasha');
      expect(contest.pendingEntries, isEmpty);
    });

    test('falls back on unknown enum values and missing blocks', () {
      final contest = ContestModel.fromJson({
        'id': 'k9',
        'event_id': 'm1',
        'title': 'Mystery',
        'status': 'paused',
        'opens_at': '2026-08-11T15:30:00Z',
        'closes_at': '2026-08-11T19:30:00Z',
        'created_at': '2026-08-11T14:00:00Z',
      }).toEntity();

      expect(contest.status, ContestStatus.scheduled);
      expect(contest.category.icon, ContestCategoryIcon.trophy);
      expect(contest.entries, isEmpty);
      expect(contest.viewer.canVote, isFalse);
      expect(contest.criteria, isNull);
    });
  });

  group('realtime payloads', () {
    test('parses a board and ignores a malformed one', () {
      final board = parseContestBoard({
        'contest_id': 'k1',
        'status': 'open',
        'votes_count': 151,
        'sent_at': '2026-08-11T18:12:00Z',
        'entries': [
          {'car_id': 'c2', 'votes_count': 62, 'last_vote_at': '2026-08-11T18:11:59Z'},
          {'car_id': 'c1', 'votes_count': 48, 'last_vote_at': null},
          {'bogus': true},
        ],
      });
      expect(board, isNotNull);
      expect(board!.entries['c2']!.votesCount, 62);
      expect(board.entries['c1']!.lastVoteAt, isNull);
      expect(board.entries.length, 2);
      expect(parseContestBoard({'status': 'open'}), isNull);
    });
  });

  group('ContestEntity', () {
    test('applyBoard replaces counts and re-ranks by the server rule', () {
      final contest = openContest(voteCarId: 'c1');
      final board = ContestBoardUpdate(
        contestId: 'k1',
        status: ContestStatus.open,
        votesCount: 152,
        entries: {
          // A tie at 62: the Supra reached it first, so it leads.
          'c2': ContestBoardRow(votesCount: 62, lastVoteAt: now),
          'c3': ContestBoardRow(votesCount: 62, lastVoteAt: now.subtract(const Duration(seconds: 30))),
          'c1': const ContestBoardRow(votesCount: 24, lastVoteAt: null),
          'c4': const ContestBoardRow(votesCount: 4, lastVoteAt: null),
        },
        sentAt: now,
      );

      final updated = contest.applyBoard(board);

      expect(updated.votesCount, 152);
      expect(updated.entries.map((e) => e.car.id), ['c3', 'c2', 'c1', 'c4']);
      expect(updated.entries.map((e) => e.rank), [1, 2, 3, 4]);
      // The viewer's choice survives a board.
      expect(updated.viewer.voteCarId, 'c1');
    });

    test('applyBoard ignores other contests and finished ones', () {
      final other = ContestBoardUpdate(
        contestId: 'zzz',
        status: ContestStatus.open,
        votesCount: 1,
        entries: const {},
        sentAt: now,
      );
      expect(openContest().applyBoard(other), openContest());
      final frozen = finishedContest();
      final board = ContestBoardUpdate(
        contestId: 'k4',
        status: ContestStatus.finished,
        votesCount: 999,
        entries: const {'c4': ContestBoardRow(votesCount: 999, lastVoteAt: null)},
        sentAt: now,
      );
      expect(frozen.applyBoard(board), frozen);
    });

    test('applyOptimisticVote moves one vote and marks the choice', () {
      final first = openContest().applyOptimisticVote('c3');
      expect(first.viewer.voteCarId, 'c3');
      expect(first.votesCount, 151);
      expect(first.entryFor('c3')!.votesCount, 38);

      final changed = first.applyOptimisticVote('c4');
      expect(changed.viewer.voteCarId, 'c4');
      // Total is unchanged on a change of vote; one car loses, one gains.
      expect(changed.votesCount, 151);
      expect(changed.entryFor('c3')!.votesCount, 37);
      expect(changed.entryFor('c4')!.votesCount, 5);

      // Voting for the same car again is a no-op.
      expect(changed.applyOptimisticVote('c4'), changed);
    });

    test('closing soon is under an hour, and only while open', () {
      final contest = openContest();
      expect(contest.isClosingSoon(now), isFalse);
      expect(contest.isClosingSoon(now.add(const Duration(minutes: 30))), isTrue);
      expect(scheduledContest().isClosingSoon(now), isFalse);
    });

    test('winner and podium need a vote', () {
      final finished = finishedContest();
      expect(finished.winner!.car.id, 'c1');
      expect(finished.podium.map((e) => e.car.id), ['c1', 'c2', 'c3']);
      expect(openContest().winner, isNull);
      expect(finishedContest(viewerWon: true).myPodiumEntry!.car.id, 'c1');
      expect(finishedContest().myPodiumEntry, isNull);
    });
  });
}
