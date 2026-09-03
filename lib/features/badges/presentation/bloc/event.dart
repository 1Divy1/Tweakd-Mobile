import 'package:equatable/equatable.dart';

abstract class BadgesEvent extends Equatable {
  const BadgesEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch what the signed-in user hasn't unlocked yet. Dispatched when the
/// badges sheet opens, not on profile load — most visits never open it, and
/// the badges they *have* earned already arrived with the profile.
class LoadLockedBadges extends BadgesEvent {
  const LoadLockedBadges();
}
