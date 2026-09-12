import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../../domain/entities/participant_card.dart';
import '../../bloc/participant_cards/cubit.dart';
import '../../bloc/participant_cards/state.dart';
import '../../utils/participant_card_builder.dart';
import 'participant_card.dart';
import 'participant_card_share_sheet.dart';

/// "Your card" on a finished event's page: one participant card per car the
/// viewer brought, each with a share button. Renders nothing for spectators
/// and until an organizer marks the event finished (the list is empty then).
class ParticipantCardsSection extends StatelessWidget {
  final String eventId;

  const ParticipantCardsSection({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ParticipantCardsCubit, ParticipantCardsState>(
      builder: (context, state) {
        if (state.cards.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.participantCardSectionTitle(state.cards.length),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.mute,
              ),
            ),
            const SizedBox(height: 10),
            for (final card in state.cards) ...[
              _CardWithShare(eventId: eventId, card: card),
              const SizedBox(height: 18),
            ],
          ],
        );
      },
    );
  }
}

class _CardWithShare extends StatelessWidget {
  final String eventId;
  final ParticipantCardEntity card;

  const _CardWithShare({required this.eventId, required this.card});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = ParticipantCardBuilder.fromCard(card);
    // Opened from the viewer's own card: their car opens as the owner. The
    // event row is this page, so it gets no tap target (and no chevron). The
    // router is looked up on tap, not during build.
    void openCar() => context.push('/garage/cars/${data.car.id}', extra: true);
    void openContest(String contestId) =>
        context.push('/map-events/$eventId/contests/$contestId');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => Center(
            child: ParticipantCard(
              data: data,
              width: constraints.maxWidth.clamp(240.0, 340.0),
              onOpenCar: openCar,
              onOpenContest: openContest,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: () => showParticipantCardShareSheet(
              context,
              data: data,
              isMine: true,
              onOpenCar: openCar,
              onOpenContest: openContest,
            ),
            icon: const Icon(Icons.ios_share_rounded, size: 18),
            label: Text(l10n.participantCardShare),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
