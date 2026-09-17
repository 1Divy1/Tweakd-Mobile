import 'package:equatable/equatable.dart';

/// The other participant of a DM conversation.
class MessageUserEntity extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;
  final bool isVerified;

  /// Whether the viewer and this user follow each other — drives the
  /// "You both follow each other" line on the chat intro header.
  final bool isMutualFollow;
  final int followersCount;

  const MessageUserEntity({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.isVerified = false,
    this.isMutualFollow = false,
    this.followersCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        avatarUrl,
        isVerified,
        isMutualFollow,
        followersCount,
      ];
}
