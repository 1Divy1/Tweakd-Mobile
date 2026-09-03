import 'package:equatable/equatable.dart';

import '../../domain/entities/badge.dart';
import '../utils/badge_error_mapper.dart';

abstract class BadgesState extends Equatable {
  const BadgesState();

  @override
  List<Object?> get props => [];
}

/// Nothing asked for yet — the sheet hasn't been opened this visit.
class BadgesInitial extends BadgesState {
  const BadgesInitial();
}

class BadgesLoading extends BadgesState {
  const BadgesLoading();
}

class BadgesLoaded extends BadgesState {
  /// The badges this user has yet to earn, in the backend's order.
  final List<BadgeEntity> locked;

  const BadgesLoaded(this.locked);

  @override
  List<Object?> get props => [locked];
}

class BadgesError extends BadgesState {
  final BadgeErrorCode code;

  const BadgesError(this.code);

  @override
  List<Object?> get props => [code];
}
