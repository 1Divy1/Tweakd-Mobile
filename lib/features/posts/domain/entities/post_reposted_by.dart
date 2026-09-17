import 'package:equatable/equatable.dart';

import 'post_user.dart';

/// Who, among the accounts the viewer follows, reposted a post — the reason it
/// is in their feed ("andrei and 2 others reposted"). Only feed posts carry it.
class RepostedByEntity extends Equatable {
  /// Up to two of them, most recent repost first. Never empty.
  final List<PostUserEntity> users;

  /// How many followed accounts reposted it in all; at least [users] long.
  final int totalCount;

  const RepostedByEntity({required this.users, required this.totalCount});

  @override
  List<Object?> get props => [users, totalCount];
}
