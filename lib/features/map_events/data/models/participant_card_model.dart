import 'package:tweakd/features/garage/data/models/car_summary_model.dart';

import '../../domain/entities/participant_card.dart';

/// A participant card as the API sends it — `GET /map-events/{id}/cards` rows and
/// a post's `participant_card`. Decoded
/// defensively: a card that fails to parse is dropped and the post renders as
/// an ordinary one, rather than one bad row breaking a whole feed page.
class ParticipantCardModel {
  final String eventId;
  final String eventTitle;
  final int eventAttendeesCount;
  final CarSummaryModel car;
  final int? bestRank;
  final List<ParticipantCardContestEntity> contests;

  const ParticipantCardModel({
    required this.eventId,
    required this.eventTitle,
    required this.eventAttendeesCount,
    required this.car,
    required this.bestRank,
    required this.contests,
  });

  static ParticipantCardModel? tryParse(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final car = json['car'];
    final eventId = json['event_id'];
    if (car is! Map<String, dynamic> || eventId is! String) return null;
    // CarSummaryModel.fromJson hard-casts its required keys, so a car missing
    // `brand` (say) throws a TypeError — caught here so the promise above holds.
    try {
      return ParticipantCardModel(
        eventId: eventId,
        eventTitle: json['event_title'] as String? ?? '',
        eventAttendeesCount:
            (json['event_attendees_count'] as num?)?.toInt() ?? 0,
        car: CarSummaryModel.fromJson(car),
        bestRank: (json['best_rank'] as num?)?.toInt(),
        contests: [
          for (final c in (json['contests'] as List<dynamic>? ?? const []))
            if (c is Map<String, dynamic> && c['contest_id'] is String)
              ParticipantCardContestEntity(
                contestId: c['contest_id'] as String,
                title: c['title'] as String? ?? '',
                finalRank: (c['final_rank'] as num?)?.toInt(),
              ),
        ],
      );
    } on TypeError {
      return null;
    }
  }

  ParticipantCardEntity toEntity() => ParticipantCardEntity(
        eventId: eventId,
        eventTitle: eventTitle,
        eventAttendeesCount: eventAttendeesCount,
        car: car.toEntity(),
        bestRank: bestRank,
        contests: contests,
      );
}
