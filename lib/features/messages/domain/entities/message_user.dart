import 'package:equatable/equatable.dart';

/// The other participant of a DM conversation.
class MessageUserEntity extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;
  final bool isVerified;
  final bool isOnline;

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
    this.isMutualFollow = false,
    this.followersCount = 0,
  });

  /// Copy with fresh presence.
  MessageUserEntity withPresence({required bool isOnline}) =>
      MessageUserEntity(
        id: id,
        username: username,
        avatarUrl: avatarUrl,
        isVerified: isVerified,
        isOnline: isOnline,
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
        isMutualFollow,
        followersCount,
      ];
}
