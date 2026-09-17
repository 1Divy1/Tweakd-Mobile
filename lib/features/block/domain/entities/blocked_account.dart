import 'package:equatable/equatable.dart';

/// An account the current user has blocked, as listed under
/// Settings → Blocked accounts.
class BlockedAccountEntity extends Equatable {
  final String id;
  final String username;
  final String? name;
  final String? avatarUrl;
  final DateTime? blockedAt;

  const BlockedAccountEntity({
    required this.id,
    required this.username,
    this.name,
    this.avatarUrl,
    this.blockedAt,
  });

  @override
  List<Object?> get props => [id, username, name, avatarUrl, blockedAt];
}
