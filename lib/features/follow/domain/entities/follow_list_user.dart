import 'package:equatable/equatable.dart';

class FollowListUserEntity extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;
  final bool isFollowing;

  const FollowListUserEntity({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.isFollowing,
  });

  FollowListUserEntity copyWith({bool? isFollowing}) {
    return FollowListUserEntity(
      id: id,
      username: username,
      avatarUrl: avatarUrl,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [id, username, avatarUrl, isFollowing];
}
