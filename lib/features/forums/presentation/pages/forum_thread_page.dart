import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tweakd/features/report/domain/entities/report_target.dart';
import 'package:tweakd/features/report/presentation/widgets/report_reason_sheet.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/thread/bloc.dart';
import '../bloc/thread/event.dart';
import '../bloc/thread/state.dart';
import '../utils/forum_error_mapper.dart';
import '../widgets/shared/forum_error_view.dart';
import '../widgets/shared/forum_section_label.dart';
import '../widgets/shared/forum_sub_top_bar.dart';
import '../widgets/shared/forum_thread_body_skeleton.dart';
import '../utils/forum_tags.dart';
import '../widgets/thread/forum_edit_sheet.dart';
import '../widgets/thread/reply_input_bar.dart';
import '../widgets/thread/reply_sort_toggle.dart';
import '../widgets/thread/reply_tag_sheet.dart';
import '../widgets/thread/reply_tile.dart';
import '../widgets/thread/thread_header.dart';

class ForumThreadPage extends StatefulWidget {
  final String threadId;

  const ForumThreadPage({super.key, required this.threadId});

  @override
  State<ForumThreadPage> createState() => _ForumThreadPageState();
}

class _ForumThreadPageState extends State<ForumThreadPage> {
  final _scrollController = ScrollController();
  final _replyController = TextEditingController();
  final _replyFocus = FocusNode();

  String? get _currentUserId => getIt<SupabaseClient>().auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _replyController.dispose();
    _replyFocus.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      context.read<ForumThreadBloc>().add(const LoadMoreThreadReplies());
    }
  }

  void _startReply(ReplyNode node) {
    context.read<ForumThreadBloc>().add(StartReplyTo(
          postId: node.reply.id,
          username: node.reply.author?.username,
        ));
    _replyFocus.requestFocus();
  }

  /// The thread top bar "⋯" menu. The author gets edit/delete; everyone else
  /// gets Report.
  Future<void> _openThreadMenu(bool isAuthor) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<ForumThreadBloc>();
    final thread = bloc.state.thread;
    if (thread == null) return;

    if (!isAuthor) {
      final reported = await showReportSheet(
        context,
        target: ForumThreadReportTarget(thread.id),
        title: l10n.forumsReportThreadTitle,
      );
      // A reported thread is left in place; drop back to where the viewer came
      // from so it isn't front and centre.
      if (reported && mounted) context.pop();
      return;
    }

    final action = await _showActionsSheet(
      edit: l10n.forumsEditThread,
      delete: l10n.forumsDeleteThread,
    );
    if (!mounted || action == null) return;

    if (action == _MenuAction.edit) {
      final edit = await showForumEditSheet(
        context,
        title: l10n.forumsEditThread,
        initialText: thread.content ?? '',
        initialPeople: forumTaggedPeopleToSelection(thread.taggedPeople),
        initialCars: forumTaggedCarsToSelection(
          thread.taggedCars,
          currentUserId: _currentUserId,
        ),
        allowEmpty: false, // a thread must keep a body
      );
      if (edit != null) {
        bloc.add(EditForumThreadBody(
          edit.text,
          taggedPeople: edit.taggedPeople,
          taggedCars: edit.taggedCars,
        ));
      }
    } else {
      final confirmed = await _confirm(
        title: l10n.forumsDeleteThreadConfirmTitle,
        body: l10n.forumsDeleteThreadConfirmBody,
      );
      if (confirmed) bloc.add(const DeleteForumThreadRequested());
    }
  }

  /// A reply's "⋯" menu. The author gets edit/delete; everyone else gets Report.
  Future<void> _openReplyMenu(ReplyNode node) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<ForumThreadBloc>();
    final isOwn = node.reply.author?.id == _currentUserId;

    if (!isOwn) {
      await showReportSheet(
        context,
        target: ForumReplyReportTarget(node.reply.id),
        title: l10n.forumsReportReplyTitle,
      );
      return;
    }

    final action = await _showActionsSheet(
      edit: l10n.forumsEditReply,
      delete: l10n.forumsDeleteReply,
    );
    if (!mounted || action == null) return;

    if (action == _MenuAction.edit) {
      final edit = await showForumEditSheet(
        context,
        title: l10n.forumsEditReply,
        initialText: node.reply.content ?? '',
        initialPeople: forumTaggedPeopleToSelection(node.reply.taggedPeople),
        initialCars: forumTaggedCarsToSelection(
          node.reply.taggedCars,
          currentUserId: _currentUserId,
        ),
      );
      if (edit != null && edit.text.isNotEmpty) {
        bloc.add(EditForumReplyBody(
          node.reply.id,
          edit.text,
          taggedPeople: edit.taggedPeople,
          taggedCars: edit.taggedCars,
        ));
      }
    } else {
      final confirmed = await _confirm(
        title: l10n.forumsDeleteReplyConfirmTitle,
        body: l10n.forumsDeleteReplyConfirmBody,
      );
      if (confirmed) bloc.add(DeleteForumReplyRequested(node.reply.id));
    }
  }

  Future<_MenuAction?> _showActionsSheet({
    required String edit,
    required String delete,
  }) {
    return showModalBottomSheet<_MenuAction>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppColors.ink),
              title: Text(
                edit,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              onTap: () => Navigator.of(context).pop(_MenuAction.edit),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: AppColors.accentHot),
              title: Text(
                delete,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentHot,
                ),
              ),
              onTap: () => Navigator.of(context).pop(_MenuAction.delete),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirm({required String title, required String body}) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          body,
          style: TextStyle(
            color: AppColors.mute,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(
                color: AppColors.mute,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.forumsDelete,
              style: TextStyle(
                color: AppColors.accentHot,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _comingSoon() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.forumsComingSoon)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ForumThreadBloc, ForumThreadState>(
          listenWhen: (prev, curr) =>
              prev.replySentTick != curr.replySentTick ||
              prev.threadDeleted != curr.threadDeleted ||
              (curr.actionError != null &&
                  prev.actionErrorTick != curr.actionErrorTick),
          listener: (context, state) {
            if (state.threadDeleted) {
              context.pop();
              return;
            }
            if (state.replySentTick > 0 &&
                state.actionError == null &&
                _replyController.text.isNotEmpty) {
              _replyController.clear();
              _replyFocus.unfocus();
            }
            if (state.actionError != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content:
                      Text(forumErrorMessage(l10n, state.actionError!)),
                ));
            }
          },
          builder: (context, state) {
            final thread = state.thread;
            final isAuthor = thread != null &&
                !thread.deleted &&
                thread.author != null &&
                thread.author!.id == _currentUserId;

            return Column(
              children: [
                ForumSubTopBar(
                  title: l10n.forumsThreadTitle,
                  trailing: (thread != null && !thread.deleted)
                      ? AppPillButton(
                          icon: Icons.more_horiz,
                          onTap: () => _openThreadMenu(isAuthor),
                        )
                      : null,
                ),
                Expanded(
                  child: switch ((state.isLoading, state.errorCode)) {
                    (true, _) => const ForumThreadBodySkeleton(),
                    (false, final code?) => ForumErrorView(
                        message: forumErrorMessage(l10n, code),
                        onRetry: () => context
                            .read<ForumThreadBloc>()
                            .add(LoadForumThread(widget.threadId)),
                      ),
                    _ => _ThreadContent(
                        state: state,
                        scrollController: _scrollController,
                        currentUserId: _currentUserId,
                        onShare: _comingSoon,
                        onFocusComposer: () {
                          context
                              .read<ForumThreadBloc>()
                              .add(const StartReplyTo());
                          _replyFocus.requestFocus();
                        },
                        onStartReply: _startReply,
                        onReplyMenu: _openReplyMenu,
                      ),
                  },
                ),
                if (thread != null)
                  thread.locked
                      ? const LockedBar()
                      : ReplyInputBar(
                          controller: _replyController,
                          focusNode: _replyFocus,
                          isSubmitting: state.isSubmitting,
                          replyingToUsername: state.replyingToUsername,
                          taggedPeople: state.replyTaggedPeople,
                          taggedCars: state.replyTaggedCars,
                          onSend: () => context
                              .read<ForumThreadBloc>()
                              .add(SubmitForumReply(_replyController.text)),
                          onCancelTarget: () => context
                              .read<ForumThreadBloc>()
                              .add(const StartReplyTo()),
                          onOpenTags: () => showForumReplyTagSheet(context),
                          onRemoveTaggedPerson: (id) => context
                              .read<ForumThreadBloc>()
                              .add(RemoveReplyTagPerson(id)),
                          onRemoveTaggedCar: (id) => context
                              .read<ForumThreadBloc>()
                              .add(RemoveReplyTagCar(id)),
                        ),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum _MenuAction { edit, delete }

class _ThreadContent extends StatelessWidget {
  final ForumThreadState state;
  final ScrollController scrollController;
  final String? currentUserId;
  final VoidCallback onShare;
  final VoidCallback onFocusComposer;
  final void Function(ReplyNode) onStartReply;
  final void Function(ReplyNode) onReplyMenu;

  const _ThreadContent({
    required this.state,
    required this.scrollController,
    required this.currentUserId,
    required this.onShare,
    required this.onFocusComposer,
    required this.onStartReply,
    required this.onReplyMenu,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<ForumThreadBloc>();
    final thread = state.thread!;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 4),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                ThreadHeader(
                  thread: thread,
                  onToggleLike: () => bloc.add(const ToggleForumThreadLike()),
                  onToggleSave: () => bloc.add(const ToggleForumThreadSave()),
                  onReply: onFocusComposer,
                  onShare: onShare,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: ForumSectionLabel(
                          label: l10n.forumsRepliesHeader(thread.replyCount),
                        ),
                      ),
                      if (thread.replyCount > 0)
                        ReplySortToggle(
                          active: state.replySort,
                          onChanged: (sort) => bloc.add(ChangeReplySort(sort)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state.repliesLoading)
          const SliverToBoxAdapter(child: ForumReplyListSkeleton())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final node = state.replies[index];
                return ReplyTile(
                  key: ValueKey(node.reply.id),
                  node: node,
                  locked: thread.locked,
                  currentUserId: currentUserId,
                  onToggleLike: (n) =>
                      bloc.add(ToggleForumReplyLike(n.reply.id)),
                  onReply: onStartReply,
                  onToggleChildren: (n) =>
                      bloc.add(ToggleReplyChildren(n.reply.id)),
                  onLoadMoreChildren: (n) =>
                      bloc.add(LoadMoreReplyChildren(n.reply.id)),
                  onMenu: onReplyMenu,
                );
              },
              childCount: state.replies.length,
            ),
          ),
        if (!state.repliesLoading && state.isLoadingMoreReplies)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
