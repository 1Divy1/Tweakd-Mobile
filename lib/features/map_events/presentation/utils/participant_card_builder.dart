import '../../domain/entities/contest.dart';
import '../../domain/entities/participant_card.dart';
import '../widgets/contests/participant_card.dart';

/// Assembles a [ParticipantCardData] from the contest data the app already
/// holds.
///
/// Phase 1 only: the card is really a backend resource keyed `(event, car)`
/// (`WINNER_CARD_REDESIGN_PROGRESS.md` §2.0), and once
/// `GET /map-events/{id}/cards` exists this builder goes away. Until then the
/// contest page composes the same shape client-side, which means it can only see
/// the contests the app has loaded:
///
/// - from the contests tab, [eventContests] holds every contest of the event, so
///   the list is complete;
/// - on a deep link straight to one contest there is no tab bloc, so
///   [eventContests] is just that contest and the card under-reports. Acceptable
///   for Phase 1, and the reason not to ship the card to the feed from here.
class ParticipantCardBuilder {
  ParticipantCardBuilder._();

  /// A server-derived card (Phase 2) — from the event page's card list or a
  /// feed post. The backend has already ordered everything, so this is a
  /// straight mapping.
  static ParticipantCardData fromCard(ParticipantCardEntity card) {
    return ParticipantCardData(
      eventId: card.eventId,
      eventTitle: card.eventTitle,
      attendeesCount: card.eventAttendeesCount,
      car: CarSummaryLike(
        id: card.car.id,
        brand: card.car.brand,
        model: card.car.model,
        coverImageUrl: card.car.coverImage?.url,
      ),
      contests: [
        for (final c in card.contests)
          ParticipantCardContest(
            contestId: c.contestId,
            title: c.title,
            rank: c.finalRank,
          ),
      ],
    );
  }

  static ParticipantCardData? build({
    required List<ContestEntity> eventContests,
    required String carId,
    required String fallbackEventTitle,
  }) {
    if (eventContests.isEmpty) return null;

    // Whichever contest carries the embedded event summary wins; the route's
    // title is the fallback, and it is empty on a deep link.
    ContestEventSummaryEntity? summary;
    for (final c in eventContests) {
      if (c.event != null) {
        summary = c.event;
        break;
      }
    }

    ContestEntryEntity? anyEntry;
    final entered = <ParticipantCardContest>[];
    for (final contest in eventContests) {
      final entry = contest.entryFor(carId);
      if (entry == null) continue;
      anyEntry ??= entry;
      // The card is an after-the-fact artifact: a contest still running has no
      // placement to report, so it stays off until it finishes.
      if (!contest.isFinished) continue;
      entered.add(ParticipantCardContest(
        contestId: contest.id,
        title: contest.title,
        rank: entry.isOnPodium ? entry.finalRank : null,
      ));
    }
    // No accepted entry anywhere means this car was never on a ballot, so there
    // is no card to draw from here.
    if (anyEntry == null) return null;

    // Podium first, best rank first; the rest alphabetical so the one-line list
    // is stable between builds.
    entered.sort((a, b) {
      final ra = a.isOnPodium ? a.rank! : 1 << 20;
      final rb = b.isOnPodium ? b.rank! : 1 << 20;
      final byRank = ra.compareTo(rb);
      return byRank != 0 ? byRank : a.title.compareTo(b.title);
    });

    final car = anyEntry.car;
    return ParticipantCardData(
      eventId: eventContests.first.eventId,
      eventTitle: summary?.title ?? fallbackEventTitle,
      attendeesCount: summary?.attendeesCount ?? 0,
      car: CarSummaryLike(
        id: car.id,
        brand: car.brand,
        model: car.model,
        coverImageUrl: car.coverImage?.url,
      ),
      contests: entered,
    );
  }
}
