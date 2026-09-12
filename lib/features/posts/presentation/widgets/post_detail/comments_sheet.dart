import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tweakd/core/shared/bloc/tag_picker/bloc.dart';
import 'package:tweakd/core/shared/widgets/tagging/tag_strip.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../report/domain/entities/report_target.dart';
import '../../../../report/presentation/widgets/report_reason_sheet.dart';
import '../../../domain/entities/post_comment.dart';
import '../../bloc/comments/bloc.dart';
import '../../bloc/comments/event.dart';
import '../../bloc/comments/state.dart';
import '../post_card/post_tags.dart';
import 'comment_tag_sheet.dart';
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
    // TagPickerBloc backs the composer's "tag people & their cars" flow; it is
    // provided here rather than on the route because the sheet is opened from
    // both the feed and the post detail page.
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider<CommentsBloc>(
          create: (_) => getIt<CommentsBloc>()
            ..add(LoadComments(postId, initialCount: initialCount)),
        ),
        BlocProvider<TagPickerBloc>(create: (_) => getIt<TagPickerBloc>()),
      ],
      child: BlocListener<CommentsBloc, CommentsState>(
        listenWhen: (a, b) => a.totalCount != b.totalCount,
        listener: (_, state) => onCountChanged(state.totalCount),
        child: _CommentsSheet(postId: postId, postOwnerId: postOwnerId),
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
  final String postId;
  final String postOwnerId;

  const _CommentsSheet({required this.postId, required this.postOwnerId});

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

  /// Opens the report flow for [comment]; hides it on a successful report.
  Future<void> _reportComment(PostCommentEntity comment) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<CommentsBloc>();
    final reported = await showReportSheet(
      context,
      target: CommentReportTarget(
        postId: widget.postId,
        commentId: comment.id,
      ),
      title: l10n.commentReport,
    );
    if (reported) bloc.add(HideComment(comment.id));
  }

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
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<CommentsBloc, CommentsState>(
              builder: (context, state) {
                return switch (state.status) {
                  CommentsStatus.loading => Center(
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
                          onReport: _reportComment,
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
            onOpenTags: () => showCommentTagSheet(context),
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
  final ValueChanged<PostCommentEntity> onReport;

  const _RootComment({
    required this.comment,
    required this.thread,
    required this.currentUserId,
    required this.postOwnerId,
    required this.onReply,
    required this.onReplyTo,
    required this.onReport,
  });

  bool _canDelete(PostCommentEntity c) =>
      currentUserId != null &&
      (c.author.id == currentUserId || postOwnerId == currentUserId);

  /// Anyone but the comment's own author can report it.
  bool _canReport(PostCommentEntity c) =>
      currentUserId != null && c.author.id != currentUserId;

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
          canReport: _canReport(comment),
          onToggleLike: () =>
              context.read<CommentsBloc>().add(ToggleCommentLike(comment.id)),
          onDelete: () =>
              context.read<CommentsBloc>().add(RemoveComment(comment.id)),
          onReply: onReply,
          onReport: () => onReport(comment),
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
              canReport: _canReport(reply),
              onToggleLike: () =>
                  context.read<CommentsBloc>().add(ToggleCommentLike(reply.id)),
              onDelete: () =>
                  context.read<CommentsBloc>().add(RemoveComment(reply.id)),
              onReply: () => onReplyTo(comment),
              onReport: () => onReport(reply),
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
              style: TextStyle(
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
  final bool canReport;
  final bool indented;
  final VoidCallback onToggleLike;
  final VoidCallback onDelete;
  final VoidCallback onReply;
  final VoidCallback onReport;

  const _CommentBody({
    required this.comment,
    required this.canDelete,
    required this.canReport,
    required this.onToggleLike,
    required this.onDelete,
    required this.onReply,
    required this.onReport,
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
                    style: TextStyle(
                      color: AppColors.ink2,
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: '${author.username} ',
                        style: TextStyle(
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
                if (!comment.deleted &&
                    (comment.taggedPeople.isNotEmpty ||
                        comment.taggedCars.isNotEmpty)) ...[
                  const SizedBox(height: 8),
                  PostTags(
                    people: comment.taggedPeople,
                    cars: comment.taggedCars,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      postTimeAgo(l10n, comment.createdAt),
                      style: TextStyle(
                        color: AppColors.muteSoft,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (comment.likeCount > 0) ...[
                      const SizedBox(width: 14),
                      Text(
                        l10n.postCommentLikesCount(comment.likeCount),
                        style: TextStyle(
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
                          style: TextStyle(
                            color: AppColors.mute,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    if (!comment.deleted && canReport) ...[
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: onReport,
                        child: Text(
                          l10n.commentReport,
                          style: TextStyle(
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
                          style: TextStyle(
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
              style: TextStyle(color: AppColors.danger),
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
  final VoidCallback onOpenTags;

  const _CommentInput({
    required this.controller,
    required this.focusNode,
    required this.bottomInset,
    required this.replyingTo,
    required this.onCancelReply,
    required this.onSend,
    required this.onOpenTags,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                        style: TextStyle(
                          color: AppColors.mute,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onCancelReply,
                      child: Icon(Icons.close_rounded,
                          size: 18, color: AppColors.mute),
                    ),
                  ],
                ),
              ),
            BlocBuilder<CommentsBloc, CommentsState>(
              buildWhen: (a, b) =>
                  a.pendingTaggedPeople != b.pendingTaggedPeople ||
                  a.pendingTaggedCars != b.pendingTaggedCars,
              builder: (context, state) => TagStrip(
                people: state.pendingTaggedPeople,
                cars: state.pendingTaggedCars,
                onRemovePerson: (id) =>
                    context.read<CommentsBloc>().add(RemoveCommentTagPerson(id)),
                onRemoveCar: (id) =>
                    context.read<CommentsBloc>().add(RemoveCommentTagCar(id)),
              ),
            ),
            Row(
              children: [
                BlocBuilder<CommentsBloc, CommentsState>(
                  buildWhen: (a, b) =>
                      a.pendingTaggedPeople != b.pendingTaggedPeople ||
                      a.pendingTaggedCars != b.pendingTaggedCars,
                  builder: (_, state) => _TagButton(
                    active: state.pendingTaggedPeople.isNotEmpty ||
                        state.pendingTaggedCars.isNotEmpty,
                    tooltip: l10n.forumsAddTagsTooltip,
                    onTap: onOpenTags,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      cursorColor: AppColors.accent,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        hintText: l10n.postCommentHint,
                        hintStyle: TextStyle(
                          color: AppColors.muteSoft,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                      decoration: BoxDecoration(
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

/// Opens the tag sheet; tinted while the comment being composed carries tags.
class _TagButton extends StatelessWidget {
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  const _TagButton({
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: active ? AppColors.accentSoft : AppColors.bg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_add_alt_1_rounded,
            size: 19,
            color: active ? AppColors.accent : AppColors.mute,
          ),
        ),
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          style: TextStyle(
            color: AppColors.mute,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
