import 'package:equatable/equatable.dart';
import 'package:tweakd/features/garage/domain/entities/car_summary.dart';

/// One contest a card's car was entered in.
class ParticipantCardContestEntity extends Equatable {
  final String contestId;
  final String title;

  /// The car's frozen podium place (1–3), or null when it entered but placed
  /// nowhere.
  final int? finalRank;

  const ParticipantCardContestEntity({
    required this.contestId,
    required this.title,
    required this.finalRank,
  });

  @override
  List<Object?> get props => [contestId, title, finalRank];
}

/// A participant card: one car's day at one event, for every participant (an
/// accepted car — spectators get none).
///
/// Not stored anywhere: the backend derives it on read from the `(event, car)`
/// pair, so nobody can author or edit one and it always reflects the real
/// placements. It reaches the app two ways — `GET /map-events/{id}/cards` (the
/// viewer's own, on the event page) and `participant_card` on a feed post.
class ParticipantCardEntity extends Equatable {
  final String eventId;
  final String eventTitle;
  final int eventAttendeesCount;
  final CarSummaryEntity car;

  /// The car's best podium place across the event, or null (no pill).
  final int? bestRank;

  /// Every finished contest the car entered, podium places first; empty when
  /// it entered none (no contests row).
  final List<ParticipantCardContestEntity> contests;

  const ParticipantCardEntity({
    required this.eventId,
    required this.eventTitle,
    required this.eventAttendeesCount,
    required this.car,
    required this.bestRank,
    required this.contests,
  });

  @override
  List<Object?> get props =>
      [eventId, eventTitle, eventAttendeesCount, car, bestRank, contests];
}
