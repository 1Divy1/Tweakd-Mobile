import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/forum_reply.dart';
import '../../../domain/usecases/create_forum_reply.dart';
import '../../../domain/usecases/forum_saves.dart';
import '../../../domain/usecases/get_forum_replies.dart';
import '../../../domain/usecases/get_forum_thread.dart';
import '../../../domain/usecases/modify_forum_reply.dart';
import '../../../domain/usecases/modify_forum_thread.dart';
import '../../../domain/usecases/toggle_forum_likes.dart';
import '../../utils/forum_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the thread page: detail + lazily expanded reply tree (level by
/// level, oldest first), optimistic likes, the reply composer, and the
/// author's edit/delete actions.
@injectable
class ForumThreadBloc extends Bloc<ForumThreadEvent, ForumThreadState> {
  final GetForumThreadUseCase getThread;
  final GetThreadRepliesUseCase getThreadReplies;
  final GetReplyChildrenUseCase getReplyChildren;
  final CreateForumReplyUseCase createReply;
  final LikeForumThreadUseCase likeThread;
  final UnlikeForumThreadUseCase unlikeThread;
  final LikeForumReplyUseCase likeReply;
  final UnlikeForumReplyUseCase unlikeReply;
  final EditForumThreadUseCase editThread;
  final DeleteForumThreadUseCase deleteThread;
  final EditForumReplyUseCase editReply;
  final DeleteForumReplyUseCase deleteReply;
  final SaveForumThreadUseCase saveThread;
  final UnsaveForumThreadUseCase unsaveThread;

  String _threadId = '';

  ForumThreadBloc({
    required this.getThread,
    required this.getThreadReplies,
    required this.getReplyChildren,
    required this.createReply,
    required this.likeThread,
    required this.unlikeThread,
    required this.likeReply,
    required this.unlikeReply,
    required this.editThread,
    required this.deleteThread,
    required this.editReply,
    required this.deleteReply,
    required this.saveThread,
    required this.unsaveThread,
  }) : super(const ForumThreadState()) {
    on<LoadForumThread>(_onLoad);
    on<LoadMoreThreadReplies>(_onLoadMoreReplies);
    on<ChangeReplySort>(_onChangeReplySort);
    on<ToggleReplyChildren>(_onToggleChildren);
    on<LoadMoreReplyChildren>(_onLoadMoreChildren);
    on<ToggleForumThreadLike>(_onToggleThreadLike);
    on<ToggleForumThreadSave>(_onToggleThreadSave);
    on<ToggleForumReplyLike>(_onToggleReplyLike);
    on<StartReplyTo>(_onStartReplyTo);
    on<SubmitForumReply>(_onSubmitReply);
    on<EditForumThreadBody>(_onEditThread);
    on<DeleteForumThreadRequested>(_onDeleteThread);
    on<EditForumReplyBody>(_onEditReply);
    on<DeleteForumReplyRequested>(_onDeleteReply);
  }

  Future<void> _onLoad(
    LoadForumThread event,
    Emitter<ForumThreadState> emit,
  ) async {
    _threadId = event.threadId;
    emit(const ForumThreadState(isLoading: true));

    final threadResult = await getThread(_threadId);
    await threadResult.fold(
      (f) async => emit(ForumThreadState(
        isLoading: false,
        errorCode: ForumErrorMapper.getCode(f),
      )),
      (thread) async {
        emit(ForumThreadState(
          isLoading: false,
          thread: thread,
          repliesLoading: true,
        ));

        final repliesResult = await getThreadReplies(
            GetForumRepliesParams(id: _threadId, sort: state.replySort));
        repliesResult.fold(
          (f) => emit(state.copyWith(
            repliesLoading: false,
            actionError: ForumErrorMapper.getCode(f),
          )),
          (page) => emit(state.copyWith(
            repliesLoading: false,
            replies: [for (final r in page.items) ReplyNode(reply: r)],
            repliesCursor: page.nextCursor,
            clearRepliesCursor: page.nextCursor == null,
          )),
        );
      },
    );
  }

  Future<void> _onLoadMoreReplies(
    LoadMoreThreadReplies event,
    Emitter<ForumThreadState> emit,
  ) async {
    if (state.isLoadingMoreReplies ||
        state.repliesLoading ||
        !state.hasMoreReplies) {
      return;
    }
    emit(state.copyWith(isLoadingMoreReplies: true));

    final result = await getThreadReplies(GetForumRepliesParams(
      id: _threadId,
      sort: state.replySort,
      cursor: state.repliesCursor,
    ));
    result.fold(
      (_) => emit(state.copyWith(isLoadingMoreReplies: false)),
      (page) {
        final seen = state.replies.map((n) => n.reply.id).toSet();
        final fresh = page.items.where((r) => seen.add(r.id));
        emit(state.copyWith(
          isLoadingMoreReplies: false,
          replies: [
            ...state.replies,
            for (final r in fresh) ReplyNode(reply: r),
          ],
          repliesCursor: page.nextCursor,
          clearRepliesCursor: page.nextCursor == null,
        ));
      },
    );
  }

  /// Switches oldest/newest and reloads the top-level replies (resetting the
  /// lazily-expanded tree, since order changed). Children re-fetch in the new
  /// order when re-expanded.
  Future<void> _onChangeReplySort(
    ChangeReplySort event,
    Emitter<ForumThreadState> emit,
  ) async {
    if (event.sort == state.replySort || state.thread == null) return;
    emit(state.copyWith(
      replySort: event.sort,
      repliesLoading: true,
      replies: const [],
      clearRepliesCursor: true,
    ));

    final result = await getThreadReplies(
        GetForumRepliesParams(id: _threadId, sort: event.sort));
    result.fold(
      (f) => emit(state.copyWith(
        repliesLoading: false,
        actionError: ForumErrorMapper.getCode(f),
      )),
      (page) => emit(state.copyWith(
        repliesLoading: false,
        replies: [for (final r in page.items) ReplyNode(reply: r)],
        repliesCursor: page.nextCursor,
        clearRepliesCursor: page.nextCursor == null,
      )),
    );
  }

  Future<void> _onToggleChildren(
    ToggleReplyChildren event,
    Emitter<ForumThreadState> emit,
  ) async {
    final node = findReplyNode(state.replies, event.postId);
    if (node == null || node.childrenLoading) return;

    if (node.childrenLoaded) {
      emit(state.copyWith(
        replies: updateReplyNode(state.replies, event.postId,
            (n) => n.copyWith(expanded: !n.expanded)),
      ));
      return;
    }

    emit(state.copyWith(
      replies: updateReplyNode(state.replies, event.postId,
          (n) => n.copyWith(childrenLoading: true)),
    ));

    final result = await getReplyChildren(
        GetForumRepliesParams(id: event.postId, sort: state.replySort));
    result.fold(
      (f) => emit(state.copyWith(
        replies: updateReplyNode(state.replies, event.postId,
            (n) => n.copyWith(childrenLoading: false)),
        actionError: ForumErrorMapper.getCode(f),
      )),
      (page) => emit(state.copyWith(
        replies: updateReplyNode(
          state.replies,
          event.postId,
          (n) => n.copyWith(
            childrenLoading: false,
            childrenLoaded: true,
            expanded: true,
            children: [for (final r in page.items) ReplyNode(reply: r)],
            childrenCursor: page.nextCursor,
            clearChildrenCursor: page.nextCursor == null,
          ),
        ),
      )),
    );
  }

  Future<void> _onLoadMoreChildren(
    LoadMoreReplyChildren event,
    Emitter<ForumThreadState> emit,
  ) async {
    final node = findReplyNode(state.replies, event.postId);
    if (node == null || node.childrenLoading || !node.hasMoreChildren) return;

    emit(state.copyWith(
      replies: updateReplyNode(state.replies, event.postId,
          (n) => n.copyWith(childrenLoading: true)),
    ));

    final result = await getReplyChildren(GetForumRepliesParams(
      id: event.postId,
      sort: state.replySort,
      cursor: node.childrenCursor,
    ));
    result.fold(
      (_) => emit(state.copyWith(
        replies: updateReplyNode(state.replies, event.postId,
            (n) => n.copyWith(childrenLoading: false)),
      )),
      (page) => emit(state.copyWith(
        replies: updateReplyNode(state.replies, event.postId, (n) {
          final seen = n.children.map((c) => c.reply.id).toSet();
          final fresh = page.items.where((r) => seen.add(r.id));
          return n.copyWith(
            childrenLoading: false,
            children: [
              ...n.children,
              for (final r in fresh) ReplyNode(reply: r),
            ],
            childrenCursor: page.nextCursor,
            clearChildrenCursor: page.nextCursor == null,
          );
        }),
      )),
    );
  }

  Future<void> _onToggleThreadLike(
    ToggleForumThreadLike event,
    Emitter<ForumThreadState> emit,
  ) async {
    final thread = state.thread;
    if (thread == null) return;

    final liked = thread.viewerHasLiked;
    emit(state.copyWith(
      thread: thread.copyWith(
        viewerHasLiked: !liked,
        likesCount: thread.likesCount + (liked ? -1 : 1),
      ),
    ));

    final result =
        liked ? await unlikeThread(_threadId) : await likeThread(_threadId);
    result.fold(
      (f) => emit(state.copyWith(
        thread: thread,
        actionError: ForumErrorMapper.getCode(f),
      )),
      (_) {},
    );
  }

  Future<void> _onToggleThreadSave(
    ToggleForumThreadSave event,
    Emitter<ForumThreadState> emit,
  ) async {
    final thread = state.thread;
    if (thread == null) return;

    final saved = thread.viewerHasSaved;
    emit(state.copyWith(thread: thread.copyWith(viewerHasSaved: !saved)));

    final result =
        saved ? await unsaveThread(_threadId) : await saveThread(_threadId);
    result.fold(
      (f) => emit(state.copyWith(
        thread: thread,
        actionError: ForumErrorMapper.getCode(f),
      )),
      (_) {},
    );
  }

  Future<void> _onToggleReplyLike(
    ToggleForumReplyLike event,
    Emitter<ForumThreadState> emit,
  ) async {
    final node = findReplyNode(state.replies, event.postId);
    if (node == null || node.reply.deleted) return;

    final liked = node.reply.viewerHasLiked;
    ForumReplyEntity flip(ForumReplyEntity r, bool to) => r.copyWith(
          viewerHasLiked: to,
          likesCount: r.likesCount + (to ? 1 : -1),
        );

    emit(state.copyWith(
      replies: updateReplyNode(state.replies, event.postId,
          (n) => n.copyWith(reply: flip(n.reply, !liked))),
    ));

    final result = liked
        ? await unlikeReply(event.postId)
        : await likeReply(event.postId);
    result.fold(
      (f) => emit(state.copyWith(
        replies: updateReplyNode(state.replies, event.postId,
            (n) => n.copyWith(reply: flip(n.reply, liked))),
        actionError: ForumErrorMapper.getCode(f),
      )),
      (_) {},
    );
  }

  void _onStartReplyTo(StartReplyTo event, Emitter<ForumThreadState> emit) {
    emit(state.copyWith(
      replyingToId: event.postId,
      replyingToUsername: event.username,
      clearReplyTarget: event.postId == null,
    ));
  }

  Future<void> _onSubmitReply(
    SubmitForumReply event,
    Emitter<ForumThreadState> emit,
  ) async {
    final content = event.content.trim();
    final thread = state.thread;
    if (content.isEmpty || thread == null || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true));

    final parentId = state.replyingToId;
    final result = await createReply(CreateForumReplyParams(
      threadId: _threadId,
      content: content,
      parentPostId: parentId,
    ));
    result.fold(
      (f) => emit(state.copyWith(
        isSubmitting: false,
        actionError: ForumErrorMapper.getCode(f),
      )),
      (reply) {
        final node = ReplyNode(reply: reply);
        final replies = parentId == null
            ? [...state.replies, node]
            : updateReplyNode(
                state.replies,
                parentId,
                (n) => n.copyWith(
                  children: [...n.children, node],
                  expanded: true,
                  reply:
                      n.reply.copyWith(replyCount: n.reply.replyCount + 1),
                ),
              );
        emit(state.copyWith(
          isSubmitting: false,
          replies: replies,
          thread: thread.copyWith(replyCount: thread.replyCount + 1),
          clearReplyTarget: true,
          bumpReplySent: true,
        ));
      },
    );
  }

  Future<void> _onEditThread(
    EditForumThreadBody event,
    Emitter<ForumThreadState> emit,
  ) async {
    final result = await editThread(EditForumThreadParams(
      threadId: _threadId,
      content: event.content,
    ));
    result.fold(
      (f) => emit(state.copyWith(actionError: ForumErrorMapper.getCode(f))),
      (updated) =>
          emit(state.copyWith(thread: state.thread?.copyWith(
        content: updated.content,
      ))),
    );
  }

  Future<void> _onDeleteThread(
    DeleteForumThreadRequested event,
    Emitter<ForumThreadState> emit,
  ) async {
    final result = await deleteThread(_threadId);
    result.fold(
      (f) => emit(state.copyWith(actionError: ForumErrorMapper.getCode(f))),
      (_) => emit(state.copyWith(threadDeleted: true)),
    );
  }

  Future<void> _onEditReply(
    EditForumReplyBody event,
    Emitter<ForumThreadState> emit,
  ) async {
    final result = await editReply(EditForumReplyParams(
      postId: event.postId,
      content: event.content,
    ));
    result.fold(
      (f) => emit(state.copyWith(actionError: ForumErrorMapper.getCode(f))),
      (updated) => emit(state.copyWith(
        replies: updateReplyNode(state.replies, event.postId,
            (n) => n.copyWith(reply: n.reply.copyWith(content: updated.content))),
      )),
    );
  }

  Future<void> _onDeleteReply(
    DeleteForumReplyRequested event,
    Emitter<ForumThreadState> emit,
  ) async {
    final node = findReplyNode(state.replies, event.postId);
    if (node == null) return;

    final result = await deleteReply(event.postId);
    result.fold(
      (f) => emit(state.copyWith(actionError: ForumErrorMapper.getCode(f))),
      (_) {
        final thread = state.thread;
        // Mirror the backend: with children it becomes a "[deleted]"
        // placeholder, childless it disappears (and the count drops).
        final hasChildren =
            node.reply.replyCount > 0 || node.children.isNotEmpty;
        if (hasChildren) {
          emit(state.copyWith(
            replies: updateReplyNode(
              state.replies,
              event.postId,
              (n) => n.copyWith(
                reply: ForumReplyEntity(
                  id: n.reply.id,
                  likesCount: n.reply.likesCount,
                  replyCount: n.reply.replyCount,
                  deleted: true,
                  createdAt: n.reply.createdAt,
                ),
              ),
            ),
          ));
        } else {
          emit(state.copyWith(
            replies: removeReplyNode(state.replies, event.postId),
            thread: thread?.copyWith(
              replyCount: (thread.replyCount - 1).clamp(0, 1 << 31),
            ),
          ));
        }
      },
    );
  }
}
