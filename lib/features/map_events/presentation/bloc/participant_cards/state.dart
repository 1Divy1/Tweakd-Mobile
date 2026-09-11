import 'package:equatable/equatable.dart';

import '../../../domain/entities/participant_card.dart';

/// The viewer's participant cards for the event on screen.
class ParticipantCardsState extends Equatable {
  final List<ParticipantCardEntity> cards;
  final bool loaded;

  const ParticipantCardsState({this.cards = const [], this.loaded = false});

  @override
  List<Object?> get props => [cards, loaded];
}
