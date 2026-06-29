import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/post_comment.dart';
import '../../../domain/usecases/add_comment.dart';
import '../../../domain/usecases/comment_actions.dart';
import '../../../domain/usecases/get_comment_replies.dart';
import '../../../domain/usecases/get_post_comments.dart';
import '../../utils/post_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Backs the comments bottom sheet for a single post: paged listing of root
/// comments plus one level of replies, with add, delete and like (all
/// optimistic) on any comment or reply.
@injectable
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final GetPostCommentsUseCase getComments;
  final GetCommentRepliesUseCase getReplies;
  final AddCommentUseCase addComment;
  final DeleteCommentUseCase deleteComment;
  final LikeCommentUseCase likeComment;
  final UnlikeCommentUseCase unlikeComment;

  late String _postId;

  CommentsBloc({
    required this.getComments,
    required this.getReplies,
    required this.addComment,
    required this.deleteComment,
    required this.likeComment,
    required this.unlikeComment,
  }) : super(const CommentsState()) {
    on<LoadComments>(_onLoad);
    on<LoadMoreComments>(_onLoadMore);
    on<SubmitComment>(_onSubmit);
    on<SubmitReply>(_onSubmitReply);
    on<ToggleReplies>(_onToggleReplies);
    on<LoadMoreReplies>(_onLoadMoreReplies);
    on<RemoveComment>(_onRemove);
    on<ToggleCommentLike>(_onToggleLike);
  }

  Future<void> _onLoad(LoadComments event, Emitter<CommentsState> emit) async {
    _postId = event.postId;
    emit(CommentsState(
      status: CommentsStatus.loading,
      totalCount: event.initialCount,
    ));

    final result = await getComments(GetPostCommentsParams(postId: _postId));
    result.fold(
      (_) => emit(state.copyWith(status: CommentsStatus.failure)),
      (page) => emit(state.copyWith(
        status: CommentsStatus.success,
        comments: _visibleRoots(page.items),
        nextCursor: page.nextCursor,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreComments event,
    Emitter<CommentsState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));

    final result = await getComments(
      GetPostCommentsParams(postId: _postId, cursor: state.nextCursor),
    );
    result.fold(
      (_) => emit(state.copyWith(isLoadingMore: false)),
      (page) => emit(state.copyWith(
        comments: [...state.comments, ..._visibleRoots(page.items)],
        nextCursor: page.nextCursor,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onSubmit(
    SubmitComment event,
    Emitter<CommentsState> emit,
  ) async {
    final content = event.content.trim();
    if (content.isEmpty || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, clearActionError: true));

    final result = await addComment(
      AddCommentParams(postId: _postId, content: content),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        actionError: PostErrorMapper.getCode(failure),
      )),
      (comment) => emit(state.copyWith(
        isSubmitting: false,
        comments: [comment, ...state.comments],
        totalCount: state.totalCount + 1,
      )),
    );
  }

  Future<void> _onSubmitReply(
    SubmitReply event,
    Emitter<CommentsState> emit,
  ) async {
    final content = event.content.trim();
    if (content.isEmpty || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, clearActionError: true));

    final result = await addComment(AddCommentParams(
      postId: _postId,
      content: content,
      parentCommentId: event.parentCommentId,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        actionError: PostErrorMapper.getCode(failure),
      )),
      (reply) {
        final parentId = event.parentCommentId;
        final thread = state.replies[parentId] ?? const ReplyThread();
        // Surface the new reply at the top of an auto-expanded thread.
        final updatedThread = thread.copyWith(
          items: [reply, ...thread.items],
          expanded: true,
        );
        emit(state.copyWith(
          isSubmitting: false,
          replies: _putThread(parentId, updatedThread),
          comments: _bumpReplyCount(parentId, 1),
        ));
      },
    );
  }

  Future<void> _onToggleReplies(
    ToggleReplies event,
    Emitter<CommentsState> emit,
  ) async {
    final id = event.commentId;
    final thread = state.replies[id];

    // Collapse an open thread.
    if (thread != null && thread.expanded) {
      emit(state.copyWith(
        replies: _putThread(id, thread.copyWith(expanded: false)),
      ));
      return;
    }

    // Already loaded — just re-expand without a network call.
    if (thread != null && thread.items.isNotEmpty) {
      emit(state.copyWith(
        replies: _putThread(id, thread.copyWith(expanded: true)),
      ));
      return;
    }

    // First open — load the first page.
    emit(state.copyWith(
      replies: _putThread(
        id,
        const ReplyThread(expanded: true, isLoading: true),
      ),
    ));

    final result = await getReplies(
      GetCommentRepliesParams(postId: _postId, commentId: id),
    );
    result.fold(
      (_) => emit(state.copyWith(
        replies: _putThread(id, const ReplyThread(expanded: true)),
      )),
      (page) => emit(state.copyWith(
        replies: _putThread(
          id,
          ReplyThread(
            items: _visibleReplies(page.items),
            nextCursor: page.nextCursor,
            expanded: true,
          ),
        ),
      )),
    );
  }

  Future<void> _onLoadMoreReplies(
    LoadMoreReplies event,
    Emitter<CommentsState> emit,
  ) async {
    final id = event.commentId;
    final thread = state.replies[id];
    if (thread == null || thread.isLoading || !thread.hasMore) return;

    emit(state.copyWith(
      replies: _putThread(id, thread.copyWith(isLoading: true)),
    ));

    final result = await getReplies(
      GetCommentRepliesParams(
        postId: _postId,
        commentId: id,
        cursor: thread.nextCursor,
      ),
    );
    result.fold(
      (_) => emit(state.copyWith(
        replies: _putThread(id, thread.copyWith(isLoading: false)),
      )),
      (page) => emit(state.copyWith(
        replies: _putThread(
          id,
          ReplyThread(
            items: [...thread.items, ..._visibleReplies(page.items)],
            nextCursor: page.nextCursor,
            expanded: true,
          ),
        ),
      )),
    );
  }

  Future<void> _onRemove(
    RemoveComment event,
    Emitter<CommentsState> emit,
  ) async {
    final id = event.commentId;
    final previous = state;

    // Case 1 — a root comment.
    final root = state.comments.where((c) => c.id == id).firstOrNull;
    if (root != null) {
      final thread = state.replies[id];
      final hasReplies =
          root.replyCount > 0 || (thread != null && thread.items.isNotEmpty);

      if (hasReplies) {
        // The backend keeps a deleted comment that still anchors replies as a
        // soft-deleted tombstone (deleted, no content). Mirror that here so the
        // thread stays visible instead of the parent vanishing — which would
        // empty the list and flash "no comments" until the next reload.
        emit(state.copyWith(
          comments: [
            for (final c in state.comments) c.id == id ? _tombstone(c) : c,
          ],
          totalCount: (state.totalCount - 1).clamp(0, 1 << 31),
        ));
      } else {
        // No replies to anchor — drop the comment (and any thread) entirely.
        final replies = Map<String, ReplyThread>.from(state.replies)
          ..remove(id);
        emit(state.copyWith(
          comments: state.comments.where((c) => c.id != id).toList(),
          totalCount: (state.totalCount - 1).clamp(0, 1 << 31),
          replies: replies,
        ));
      }

      final result = await deleteComment(
        CommentRefParams(postId: _postId, commentId: id),
      );
      result.fold(
        (failure) => emit(previous.copyWith(
          actionError: PostErrorMapper.getCode(failure),
        )),
        (_) {},
      );
      return;
    }

    // Case 2 — a reply: find its parent thread, drop it, decrement reply count.
    final parentId = _parentOf(id);
    if (parentId == null) return;
    final thread = state.replies[parentId]!;
    final parent = state.comments.where((c) => c.id == parentId).firstOrNull;
    final remainingItems = thread.items.where((c) => c.id != id).toList();

    if (parent != null &&
        parent.deleted &&
        remainingItems.isEmpty &&
        parent.replyCount - 1 <= 0) {
      // The parent was only kept as a tombstone to anchor this reply; with the
      // last reply gone it has nothing left to anchor, so remove it entirely.
      final replies = Map<String, ReplyThread>.from(state.replies)
        ..remove(parentId);
      emit(state.copyWith(
        comments: state.comments.where((c) => c.id != parentId).toList(),
        replies: replies,
      ));
    } else {
      emit(state.copyWith(
        replies: _putThread(parentId, thread.copyWith(items: remainingItems)),
        comments: _bumpReplyCount(parentId, -1),
      ));
    }

    final result = await deleteComment(
      CommentRefParams(postId: _postId, commentId: id),
    );
    result.fold(
      (failure) => emit(previous.copyWith(
        actionError: PostErrorMapper.getCode(failure),
      )),
      (_) {},
    );
  }

  Future<void> _onToggleLike(
    ToggleCommentLike event,
    Emitter<CommentsState> emit,
  ) async {
    final id = event.commentId;
    final target = _findComment(id);
    if (target == null) return;

    final liked = target.viewerHasLiked;
    final optimistic = target.copyWith(
      viewerHasLiked: !liked,
      likeCount: (target.likeCount + (liked ? -1 : 1)).clamp(0, 1 << 31),
    );
    emit(_replaceComment(optimistic));

    final params = CommentRefParams(postId: _postId, commentId: id);
    final result =
        liked ? await unlikeComment(params) : await likeComment(params);
    // Revert this one comment on failure.
    result.fold((_) => emit(_replaceComment(target)), (_) {});
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Map<String, ReplyThread> _putThread(String id, ReplyThread thread) {
    return {...state.replies, id: thread};
  }

  /// Root comments worth showing. A soft-deleted comment is only kept while it
  /// still anchors replies (replyCount > 0); a deleted leaf has nothing to
  /// anchor, so it's dropped rather than rendered as a "deleted" tombstone.
  List<PostCommentEntity> _visibleRoots(List<PostCommentEntity> items) =>
      items.where((c) => !c.deleted || c.replyCount > 0).toList();

  /// Replies are always leaves (threading is one level deep), so a deleted
  /// reply anchors nothing and is dropped.
  List<PostCommentEntity> _visibleReplies(List<PostCommentEntity> items) =>
      items.where((c) => !c.deleted).toList();

  /// A soft-deleted copy of [c] that still anchors its replies, matching the
  /// backend's deleted-comment shape: no content, no likes, reply count kept.
  PostCommentEntity _tombstone(PostCommentEntity c) => PostCommentEntity(
        id: c.id,
        author: c.author,
        content: null,
        parentCommentId: c.parentCommentId,
        deleted: true,
        likeCount: 0,
        viewerHasLiked: false,
        replyCount: c.replyCount,
        createdAt: c.createdAt,
      );

  /// Returns the comments list with [parentId]'s replyCount adjusted by [delta].
  List<PostCommentEntity> _bumpReplyCount(String parentId, int delta) {
    return [
      for (final c in state.comments)
        if (c.id == parentId)
          c.copyWith(replyCount: (c.replyCount + delta).clamp(0, 1 << 31))
        else
          c,
    ];
  }

  /// The root comment id owning the reply [replyId], or null if not found.
  String? _parentOf(String replyId) {
    for (final entry in state.replies.entries) {
      if (entry.value.items.any((r) => r.id == replyId)) return entry.key;
    }
    return null;
  }

  /// Finds a comment by id across root comments and every loaded reply thread.
  PostCommentEntity? _findComment(String id) {
    for (final c in state.comments) {
      if (c.id == id) return c;
    }
    for (final thread in state.replies.values) {
      for (final r in thread.items) {
        if (r.id == id) return r;
      }
    }
    return null;
  }

  /// Replaces [comment] wherever it lives (root list or a reply thread).
  CommentsState _replaceComment(PostCommentEntity comment) {
    if (state.comments.any((c) => c.id == comment.id)) {
      return state.copyWith(
        comments: [
          for (final c in state.comments) c.id == comment.id ? comment : c,
        ],
      );
    }
    final parentId = _parentOf(comment.id);
    if (parentId == null) return state;
    final thread = state.replies[parentId]!;
    return state.copyWith(
      replies: _putThread(
        parentId,
        thread.copyWith(
          items: [
            for (final r in thread.items) r.id == comment.id ? comment : r,
          ],
        ),
      ),
    );
  }
}
