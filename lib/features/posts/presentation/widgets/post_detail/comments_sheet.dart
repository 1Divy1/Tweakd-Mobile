import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/post_comment.dart';
import '../../bloc/comments/bloc.dart';
import '../../bloc/comments/event.dart';
import '../../bloc/comments/state.dart';
import 'post_time.dart';

/// Opens the comments bottom sheet for [postId]. [onCountChanged] is called
/// whenever the total changes (from adds/deletes) so the caller — the post
/// detail view or the feed list — can keep its own counter in sync.
/// [postOwnerId] lets the post owner delete any comment.
Future<void> showCommentsSheet(
  BuildContext context, {
  required String postId,
  required int initialCount,
  required String postOwnerId,
  required ValueChanged<int> onCountChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider<CommentsBloc>(
      create: (_) => getIt<CommentsBloc>()
        ..add(LoadComments(postId, initialCount: initialCount)),
      child: BlocListener<CommentsBloc, CommentsState>(
        listenWhen: (a, b) => a.totalCount != b.totalCount,
        listener: (_, state) => onCountChanged(state.totalCount),
        child: _CommentsSheet(postOwnerId: postOwnerId),
      ),
    ),
  );
}

/// The comment the input is currently aimed at as a reply, if any.
class _ReplyTarget {
  final String commentId;
  final String username;
  const _ReplyTarget(this.commentId, this.username);
}

class _CommentsSheet extends StatefulWidget {
  final String postOwnerId;

  const _CommentsSheet({required this.postOwnerId});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _inputFocus = FocusNode();
  _ReplyTarget? _replyTarget;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 300) {
        context.read<CommentsBloc>().add(const LoadMoreComments());
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _startReply(PostCommentEntity comment) {
    setState(() => _replyTarget =
        _ReplyTarget(comment.id, comment.author.username));
    _inputFocus.requestFocus();
  }

  void _cancelReply() => setState(() => _replyTarget = null);

  void _submit() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    final target = _replyTarget;
    if (target != null) {
      context
          .read<CommentsBloc>()
          .add(SubmitReply(parentCommentId: target.commentId, content: text));
    } else {
      context.read<CommentsBloc>().add(SubmitComment(text));
    }
    _inputCtrl.clear();
    _cancelReply();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = getIt<SupabaseClient>().auth.currentUser?.id;
    final viewportInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, sheetScroll) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<CommentsBloc, CommentsState>(
            buildWhen: (a, b) => a.totalCount != b.totalCount,
            builder: (_, state) => Text(
              l10n.postCommentsTitle(state.totalCount),
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.line),
          Expanded(
            child: BlocBuilder<CommentsBloc, CommentsState>(
              builder: (context, state) {
                return switch (state.status) {
                  CommentsStatus.loading => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  CommentsStatus.failure => _CenteredMessage(
                      l10n.postCommentsLoadError,
                    ),
                  CommentsStatus.success when state.comments.isEmpty =>
                    _CenteredMessage(l10n.postCommentsEmpty),
                  CommentsStatus.success => ListView.builder(
                      controller: sheetScroll,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.comments.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i >= state.comments.length) {
                          context
                              .read<CommentsBloc>()
                              .add(const LoadMoreComments());
                          return const _LoadingRow();
                        }
                        final comment = state.comments[i];
                        return _RootComment(
                          comment: comment,
                          thread: state.replies[comment.id],
                          currentUserId: currentUserId,
                          postOwnerId: widget.postOwnerId,
                          onReply: () => _startReply(comment),
                          onReplyTo: _startReply,
                        );
                      },
                    ),
                };
              },
            ),
          ),
          _CommentInput(
            controller: _inputCtrl,
            focusNode: _inputFocus,
            bottomInset: viewportInset,
            replyingTo: _replyTarget?.username,
            onCancelReply: _cancelReply,
            onSend: _submit,
          ),
        ],
      ),
    );
  }
}

/// A root comment plus its lazily-loaded, indented reply thread.
class _RootComment extends StatelessWidget {
  final PostCommentEntity comment;
  final ReplyThread? thread;
  final String? currentUserId;
  final String postOwnerId;
  final VoidCallback onReply;
  final ValueChanged<PostCommentEntity> onReplyTo;

  const _RootComment({
    required this.comment,
    required this.thread,
    required this.currentUserId,
    required this.postOwnerId,
    required this.onReply,
    required this.onReplyTo,
  });

  bool _canDelete(PostCommentEntity c) =>
      currentUserId != null &&
      (c.author.id == currentUserId || postOwnerId == currentUserId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final expanded = thread?.expanded ?? false;
    final hasReplies = comment.replyCount > 0 ||
        (thread != null && thread!.items.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentBody(
          comment: comment,
          canDelete: _canDelete(comment),
          onToggleLike: () =>
              context.read<CommentsBloc>().add(ToggleCommentLike(comment.id)),
          onDelete: () =>
              context.read<CommentsBloc>().add(RemoveComment(comment.id)),
          onReply: onReply,
        ),
        if (hasReplies)
          Padding(
            padding: const EdgeInsets.only(left: 64, bottom: 4),
            child: _RepliesToggle(
              expanded: expanded,
              count: comment.replyCount,
              label: expanded
                  ? l10n.postRepliesHide
                  : (comment.replyCount > 0
                      ? l10n.postRepliesView(comment.replyCount)
                      : l10n.postRepliesViewGeneric),
              onTap: () =>
                  context.read<CommentsBloc>().add(ToggleReplies(comment.id)),
            ),
          ),
        if (expanded && thread != null) ...[
          for (final reply in thread!.items)
            _CommentBody(
              comment: reply,
              indented: true,
              canDelete: _canDelete(reply),
              onToggleLike: () =>
                  context.read<CommentsBloc>().add(ToggleCommentLike(reply.id)),
              onDelete: () =>
                  context.read<CommentsBloc>().add(RemoveComment(reply.id)),
              onReply: () => onReplyTo(comment),
            ),
          if (thread!.isLoading)
            const _LoadingRow()
          else if (thread!.hasMore)
            Padding(
              padding: const EdgeInsets.only(left: 64, bottom: 8),
              child: _RepliesToggle(
                expanded: true,
                count: 0,
                label: l10n.postRepliesViewMore,
                onTap: () => context
                    .read<CommentsBloc>()
                    .add(LoadMoreReplies(comment.id)),
              ),
            ),
        ],
      ],
    );
  }
}

class _RepliesToggle extends StatelessWidget {
  final bool expanded;
  final int count;
  final String label;
  final VoidCallback onTap;

  const _RepliesToggle({
    required this.expanded,
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(width: 24, height: 1, color: AppColors.line),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.mute,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentBody extends StatelessWidget {
  final PostCommentEntity comment;
  final bool canDelete;
  final bool indented;
  final VoidCallback onToggleLike;
  final VoidCallback onDelete;
  final VoidCallback onReply;

  const _CommentBody({
    required this.comment,
    required this.canDelete,
    required this.onToggleLike,
    required this.onDelete,
    required this.onReply,
    this.indented = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final author = comment.author;
    final initial = author.username.isNotEmpty
        ? author.username.characters.first.toUpperCase()
        : '?';
    final radius = indented ? 14.0 : 17.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(indented ? 52 : 16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () =>
                context.push('/users/${author.username}', extra: author.id),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: AppColors.accentSoft,
              backgroundImage: author.avatarUrl != null
                  ? CachedNetworkImageProvider(author.avatarUrl!)
                  : null,
              child: author.avatarUrl == null
                  ? Text(
                      initial,
                      style: TextStyle(
                        color: AppColors.accentHot,
                        fontSize: indented ? 11 : 13,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.ink2,
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: '${author.username} ',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: comment.content ?? l10n.postCommentDeleted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      postTimeAgo(l10n, comment.createdAt),
                      style: const TextStyle(
                        color: AppColors.muteSoft,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (comment.likeCount > 0) ...[
                      const SizedBox(width: 14),
                      Text(
                        l10n.postCommentLikesCount(comment.likeCount),
                        style: const TextStyle(
                          color: AppColors.mute,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (!comment.deleted) ...[
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: onReply,
                        child: Text(
                          l10n.postCommentReply,
                          style: const TextStyle(
                            color: AppColors.mute,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    if (canDelete) ...[
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: () => _confirmDelete(context),
                        child: Text(
                          l10n.postCommentDelete,
                          style: const TextStyle(
                            color: AppColors.mute,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (!comment.deleted)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggleLike,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  comment.viewerHasLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: comment.viewerHasLiked
                      ? AppColors.accent
                      : AppColors.muteSoft,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.postCommentDeleteTitle),
        content: Text(l10n.postCommentDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.garageDialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.garageDialogDelete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete();
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final double bottomInset;
  final String? replyingTo;
  final VoidCallback onCancelReply;
  final VoidCallback onSend;

  const _CommentInput({
    required this.controller,
    required this.focusNode,
    required this.bottomInset,
    required this.replyingTo,
    required this.onCancelReply,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyingTo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.postReplyingTo(replyingTo!),
                        style: const TextStyle(
                          color: AppColors.mute,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onCancelReply,
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.mute),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.line),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      cursorColor: AppColors.accent,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: l10n.postCommentHint,
                        hintStyle: const TextStyle(
                          color: AppColors.muteSoft,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                BlocBuilder<CommentsBloc, CommentsState>(
                  buildWhen: (a, b) => a.isSubmitting != b.isSubmitting,
                  builder: (_, state) => GestureDetector(
                    onTap: state.isSubmitting ? null : onSend,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: state.isSubmitting
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.arrow_upward_rounded,
                              color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.mute),
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String text;
  const _CenteredMessage(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.mute,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
