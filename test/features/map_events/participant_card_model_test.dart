// The feed must never break on a participant card: a malformed one drops the
// post back to an ordinary post instead of throwing out of a whole page parse.
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/map_events/data/models/participant_card_model.dart';

Map<String, dynamic> _card({Map<String, dynamic>? car, Object? eventId = 'm1'}) => {
      'event_id': eventId,
      'event_title': 'Casino Square Cars & Coffee',
      'event_attendees_count': 247,
      'car': car ??
          {
            'id': 'c1',
            'brand': 'BMW',
            'model': 'M4 Competition',
            'owner': {'id': 'u1', 'username': 'torque_sasha'},
          },
      'best_rank': 1,
      'contests': [
        {'contest_id': 'k1', 'title': 'Best paint / wrap', 'final_rank': 1},
        {'contest_id': 'k2', 'title': 'Loudest', 'final_rank': null},
        {'title': 'no id — skipped'},
      ],
    };

void main() {
  test('decodes a well-formed card', () {
    final card = ParticipantCardModel.tryParse(_card())!.toEntity();
    expect(card.eventId, 'm1');
    expect(card.eventTitle, 'Casino Square Cars & Coffee');
    expect(card.eventAttendeesCount, 247);
    expect(card.car.brand, 'BMW');
    expect(card.bestRank, 1);
    expect(card.contests.map((c) => c.contestId), ['k1', 'k2']);
    expect(card.contests[1].finalRank, isNull);
  });

  test('an absent or null card is simply no card', () {
    expect(ParticipantCardModel.tryParse(null), isNull);
    expect(ParticipantCardModel.tryParse('nope'), isNull);
  });

  test('a card whose car is missing a required key is dropped, not thrown', () {
    expect(
      ParticipantCardModel.tryParse(_card(car: {'id': 'c1', 'model': 'M4'})),
      isNull,
    );
  });

  test('a card without an event id is dropped', () {
    expect(ParticipantCardModel.tryParse(_card(eventId: null)), isNull);
  });

  test('a card with no contests keeps an empty list (no contests row)', () {
    final json = _card()..['contests'] = <dynamic>[];
    final card = ParticipantCardModel.tryParse(json)!.toEntity();
    expect(card.contests, isEmpty);
  });
}
