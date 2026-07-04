import 'package:equatable/equatable.dart';

import '../../../domain/entities/forum_reply.dart';
import '../../../domain/entities/forum_thread.dart';
import '../../utils/forum_error_mapper.dart';

/// One reply plus everything the UI knows about its lazily-loaded children.
/// Children arrive level by level: nothing is fetched until the user expands
/// the node.
class ReplyNode extends Equatable {
  final ForumReplyEntity reply;
  final List<ReplyNode> children;
  final String? childrenCursor;
  final bool childrenLoaded;
  final bool childrenLoading;
  final bool expanded;

  const ReplyNode({
    required this.reply,
    this.children = const [],
    this.childrenCursor,
    this.childrenLoaded = false,
    this.childrenLoading = false,
    this.expanded = false,
  });

  bool get hasMoreChildren => childrenCursor != null;

  ReplyNode copyWith({
    ForumReplyEntity? reply,
    List<ReplyNode>? children,
    String? childrenCursor,
    bool clearChildrenCursor = false,
    bool? childrenLoaded,
    bool? childrenLoading,
    bool? expanded,
  }) {
    return ReplyNode(
      reply: reply ?? this.reply,
      children: children ?? this.children,
      childrenCursor:
          clearChildrenCursor ? null : (childrenCursor ?? this.childrenCursor),
      childrenLoaded: childrenLoaded ?? this.childrenLoaded,
      childrenLoading: childrenLoading ?? this.childrenLoading,
      expanded: expanded ?? this.expanded,
    );
  }

  @override
  List<Object?> get props => [
        reply,
        children,
        childrenCursor,
        childrenLoaded,
        childrenLoading,
        expanded,
      ];
}

/// Maps [f] over the node with [id], wherever it sits in the tree.
List<ReplyNode> updateReplyNode(
  List<ReplyNode> nodes,
  String id,
  ReplyNode Function(ReplyNode) f,
) {
  return [
    for (final n in nodes)
      if (n.reply.id == id)
        f(n)
      else
        n.copyWith(children: updateReplyNode(n.children, id, f)),
  ];
}

/// Removes the node with [id], wherever it sits in the tree.
List<ReplyNode> removeReplyNode(List<ReplyNode> nodes, String id) {
  return [
    for (final n in nodes)
      if (n.reply.id != id)
        n.copyWith(children: removeReplyNode(n.children, id)),
  ];
}

/// Finds the node with [id], or null.
ReplyNode? findReplyNode(List<ReplyNode> nodes, String id) {
  for (final n in nodes) {
    if (n.reply.id == id) return n;
    final inChildren = findReplyNode(n.children, id);
    if (inChildren != null) return inChildren;
  }
  return null;
}

/// Thread page state. One-shot signals ([replySentTick], [actionErrorTick],
/// [threadDeleted]) drive the input clear, snackbars and the page pop.
class ForumThreadState extends Equatable {
  final bool isLoading;
  final ForumErrorCode? errorCode;
  final ForumThreadDetailEntity? thread;
  final List<ReplyNode> replies;
  final String? repliesCursor;
  final bool repliesLoading;
  final bool isLoadingMoreReplies;
  final ForumReplySort replySort;
  final bool isSubmitting;
  final String? replyingToId;
  final String? replyingToUsername;
  final int replySentTick;
  final bool threadDeleted;
  final ForumErrorCode? actionError;
  final int actionErrorTick;

  const ForumThreadState({
    this.isLoading = true,
    this.errorCode,
    this.thread,
    this.replies = const [],
    this.repliesCursor,
    this.repliesLoading = false,
    this.isLoadingMoreReplies = false,
    this.replySort = ForumReplySort.oldest,
    this.isSubmitting = false,
    this.replyingToId,
    this.replyingToUsername,
    this.replySentTick = 0,
    this.threadDeleted = false,
    this.actionError,
    this.actionErrorTick = 0,
  });

  bool get hasMoreReplies => repliesCursor != null;

  ForumThreadState copyWith({
    bool? isLoading,
    ForumErrorCode? errorCode,
    ForumThreadDetailEntity? thread,
    List<ReplyNode>? replies,
    String? repliesCursor,
    bool clearRepliesCursor = false,
    bool? repliesLoading,
    bool? isLoadingMoreReplies,
    ForumReplySort? replySort,
    bool? isSubmitting,
    String? replyingToId,
    String? replyingToUsername,
    bool clearReplyTarget = false,
    bool bumpReplySent = false,
    bool? threadDeleted,
    ForumErrorCode? actionError,
  }) {
    return ForumThreadState(
      isLoading: isLoading ?? this.isLoading,
      errorCode: errorCode ?? this.errorCode,
      thread: thread ?? this.thread,
      replies: replies ?? this.replies,
      repliesCursor:
          clearRepliesCursor ? null : (repliesCursor ?? this.repliesCursor),
      repliesLoading: repliesLoading ?? this.repliesLoading,
      isLoadingMoreReplies: isLoadingMoreReplies ?? this.isLoadingMoreReplies,
      replySort: replySort ?? this.replySort,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      replyingToId:
          clearReplyTarget ? null : (replyingToId ?? this.replyingToId),
      replyingToUsername: clearReplyTarget
          ? null
          : (replyingToUsername ?? this.replyingToUsername),
      replySentTick: bumpReplySent ? replySentTick + 1 : replySentTick,
      threadDeleted: threadDeleted ?? this.threadDeleted,
      actionError: actionError ?? this.actionError,
      actionErrorTick:
          actionError != null ? actionErrorTick + 1 : actionErrorTick,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorCode,
        thread,
        replies,
        repliesCursor,
        repliesLoading,
        isLoadingMoreReplies,
        replySort,
        isSubmitting,
        replyingToId,
        replyingToUsername,
        replySentTick,
        threadDeleted,
        actionError,
        actionErrorTick,
      ];
}
