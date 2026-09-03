import 'package:equatable/equatable.dart';

import 'badge.dart';

/// A badge a user has unlocked, and when.
///
/// The badge is nested rather than flattened so the same widget renders a
/// profile badge and a catalogue one — the only thing a held badge adds is the
/// date. This mirrors the backend's `UserBadgeDto`.
class UserBadgeEntity extends Equatable {
  final BadgeEntity badge;
  final DateTime? earnedAt;

  const UserBadgeEntity({required this.badge, this.earnedAt});

  @override
  List<Object?> get props => [badge, earnedAt];
}
