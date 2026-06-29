import 'package:equatable/equatable.dart';

import '../../../domain/entities/post_comment.dart';
import '../../utils/post_error_mapper.dart';

enum CommentsStatus { loading, success, failure }

/// The lazily-loaded reply thread under a single root comment. Replies are one
/// level deep — a reply never has its own thread.
class ReplyThread extends Equatable {
  final List<PostCommentEntity> items;
  final String? nextCursor;
  final bool expanded;
  final bool isLoading;

  const ReplyThread({
    this.items = const [],
    this.nextCursor,
    this.expanded = false,
    this.isLoading = false,
  });

  bool get hasMore => nextCursor != null;

  ReplyThread copyWith({
    List<PostCommentEntity>? items,
    String? nextCursor,
    bool? expanded,
    bool? isLoading,
  }) {
    return ReplyThread(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      expanded: expanded ?? this.expanded,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [items, nextCursor, expanded, isLoading];
}

class CommentsState extends Equatable {
  final CommentsStatus status;
  final List<PostCommentEntity> comments;
  final String? nextCursor;
  final bool isLoadingMore;

  /// True while a new comment or reply is being posted (drives the send
  /// button spinner).
  final bool isSubmitting;

  /// Running total of root comments on the post, kept in sync with add/delete
  /// so the detail view's counter can mirror it.
  final int totalCount;

  /// Reply threads keyed by their root comment id. Absent until first expanded.
  final Map<String, ReplyThread> replies;

  /// Set transiently when an action fails, so the UI can surface a message.
  final PostErrorCode? actionError;

  const CommentsState({
    this.status = CommentsStatus.loading,
    this.comments = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.totalCount = 0,
    this.replies = const {},
    this.actionError,
  });

  bool get hasMore => nextCursor != null;

  CommentsState copyWith({
    CommentsStatus? status,
    List<PostCommentEntity>? comments,
    String? nextCursor,
    bool? isLoadingMore,
    bool? isSubmitting,
    int? totalCount,
    Map<String, ReplyThread>? replies,
    PostErrorCode? actionError,
    bool clearActionError = false,
  }) {
    return CommentsState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      totalCount: totalCount ?? this.totalCount,
      replies: replies ?? this.replies,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        comments,
        nextCursor,
        isLoadingMore,
        isSubmitting,
        totalCount,
        replies,
        actionError,
      ];
}
