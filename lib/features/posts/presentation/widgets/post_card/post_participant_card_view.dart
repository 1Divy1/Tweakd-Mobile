import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tweakd/features/map_events/presentation/utils/participant_card_builder.dart';
import 'package:tweakd/features/map_events/presentation/widgets/contests/participant_card.dart';

import 'package:tweakd/features/map_events/domain/entities/participant_card.dart';

/// A post's participant card, drawn where an ordinary post draws its images.
///
/// This is what makes the card work in the feed at all: rendered natively
/// rather than as a flattened PNG, its three tap targets route for real — car
/// name → car page, event → event page, a contest → that contest — while the
/// photo stays inert, as designed.
///
/// [interactive] false renders it display-only (chevrons off, no taps), for
/// surfaces where the whole post is a single tap target.
class PostParticipantCardView extends StatelessWidget {
  final ParticipantCardEntity card;
  final bool interactive;

  const PostParticipantCardView({
    super.key,
    required this.card,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    final data = ParticipantCardBuilder.fromCard(card);
    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: ParticipantCard(
          data: data,
          width: constraints.maxWidth,
          interactive: interactive,
          // `extra: false` matches the post's car tags: the feed doesn't know
          // whether the viewer owns the car, so it opens the read-only page.
          onOpenCar: interactive
              ? () => context.push('/garage/cars/${card.car.id}', extra: false)
              : null,
          onOpenEvent: interactive
              ? () => context.push('/map-events/${card.eventId}')
              : null,
          onOpenContest: interactive
              ? (contestId) => context
                  .push('/map-events/${card.eventId}/contests/$contestId')
              : null,
        ),
      ),
    );
  }
}
