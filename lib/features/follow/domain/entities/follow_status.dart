enum FollowStatus { notFollowing, pending, accepted }

class FollowStatusEntity {
  final FollowStatus status;

  const FollowStatusEntity({required this.status});

  bool get isFollowing => status == FollowStatus.accepted;
  bool get isPending => status == FollowStatus.pending;
  bool get isNotFollowing => status == FollowStatus.notFollowing;
}
