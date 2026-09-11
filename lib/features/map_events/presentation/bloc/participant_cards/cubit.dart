import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/map_event_contests.dart';
import 'state.dart';

/// Loads the viewer's participant cards for one event — the event page's
/// "Your card" section. One per car they had accepted into the event; empty
/// until an organizer marks it finished, and always empty for spectators.
@injectable
class ParticipantCardsCubit extends Cubit<ParticipantCardsState> {
  final GetMyParticipantCardsUseCase getCards;

  ParticipantCardsCubit(this.getCards) : super(const ParticipantCardsState());

  /// Quietly empty on failure: the section is a bonus on the event page,
  /// never a reason to put an error on it.
  Future<void> load(String eventId) async {
    final result = await getCards(eventId);
    if (isClosed) return;
    emit(ParticipantCardsState(
      cards: result.getOrElse(() => const []),
      loaded: true,
    ));
  }
}
