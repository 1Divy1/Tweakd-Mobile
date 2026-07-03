import 'package:equatable/equatable.dart';

import 'forum_reply.dart';
import 'forum_thread.dart';

/// One cursor page of threads. [nextCursor] is opaque; null means last page.
class ForumThreadPageEntity extends Equatable {
  final List<ForumThreadEntity> items;
  final String? nextCursor;

  const ForumThreadPageEntity({required this.items, this.nextCursor});

  @override
  List<Object?> get props => [items, nextCursor];
}

/// One cursor page of replies (top-level of a thread, or the direct children
/// of one reply).
class ForumReplyPageEntity extends Equatable {
  final List<ForumReplyEntity> items;
  final String? nextCursor;

  const ForumReplyPageEntity({required this.items, this.nextCursor});

  @override
  List<Object?> get props => [items, nextCursor];
}
