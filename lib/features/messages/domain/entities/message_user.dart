import 'package:equatable/equatable.dart';

/// The other participant of a DM conversation.
class MessageUserEntity extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;
  final bool isVerified;
  final bool isOnline;

  /// When the user was last online. Null while [isOnline] is true, and also
  /// null for users never seen online (no "Last seen" line rendered).
  final DateTime? lastSeenAt;

  /// Whether the viewer and this user follow each other — drives the
  /// "You both follow each other" line on the chat intro header.
  final bool isMutualFollow;
  final int followersCount;

  const MessageUserEntity({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeenAt,
    this.isMutualFollow = false,
    this.followersCount = 0,
  });

  /// Copy with fresh presence. Online and last-seen always change together
  /// (online ⇒ lastSeenAt is null), hence one method instead of a copyWith
  /// that can't express "set lastSeenAt back to null".
  MessageUserEntity withPresence({
    required bool isOnline,
    required DateTime? lastSeenAt,
  }) =>
      MessageUserEntity(
        id: id,
        username: username,
        avatarUrl: avatarUrl,
        isVerified: isVerified,
        isOnline: isOnline,
        lastSeenAt: isOnline ? null : lastSeenAt,
        isMutualFollow: isMutualFollow,
        followersCount: followersCount,
      );

  @override
  List<Object?> get props => [
        id,
        username,
        avatarUrl,
        isVerified,
        isOnline,
        lastSeenAt,
        isMutualFollow,
        followersCount,
      ];
}
