import 'package:equatable/equatable.dart';

import '../../../badges/domain/entities/user_badge.dart';
import '../../../posts/domain/entities/post.dart';

/// One page of the global feed.
///
/// A feed item *is* a post, so [items] / [nextCursor] mirror the shared
/// `PostPageEntity`. The extra piece is [pendingBadgeCelebrations]: badges the
/// viewer has unlocked but not yet seen the animation for, embedded on the
/// **first page only** (`cursor` omitted) so launch needs no separate call.
/// Paged requests always carry an empty list.
class FeedPageEntity extends Equatable {
  final List<PostEntity> items;
  final String? nextCursor;
  final List<UserBadgeEntity> pendingBadgeCelebrations;

  const FeedPageEntity({
    required this.items,
    required this.nextCursor,
    this.pendingBadgeCelebrations = const [],
  });

  @override
  List<Object?> get props => [items, nextCursor, pendingBadgeCelebrations];
}
