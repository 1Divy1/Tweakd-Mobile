import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../report/domain/entities/report_target.dart';
import '../../../report/presentation/widgets/report_reason_sheet.dart';
import '../../domain/entities/post.dart';
import '../bloc/post_detail/bloc.dart';
import '../bloc/post_detail/event.dart';
import '../bloc/post_detail/state.dart';
import '../utils/post_error_mapper.dart';
import 'edit_post_page.dart';
import '../widgets/post_card/post_options_sheet.dart';
import '../widgets/post_detail/comments_sheet.dart';
import '../widgets/post_detail/likers_sheet.dart';
import '../widgets/post_detail/post_detail_view.dart';
import '../../../../core/shared/layout/app_layout.dart';

/// Full-screen view of a single post. Owners get an edit/delete menu; everyone
/// can like, save, repost (someone else's post) and open the comments / likers
/// sheets. Pops `true` when
/// the post was edited or deleted so the caller can refresh its list.
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  /// Whether the post changed while open, so the profile grid can reload.
  bool _changed = false;

  bool _isOwner(PostEntity post) =>
      getIt<SupabaseClient>().auth.currentUser?.id == post.author.id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop(_changed);
      },
      child: BlocConsumer<PostDetailBloc, PostDetailState>(
        listener: (context, state) {
          if (state is PostDetailDeleted) {
            context.pop(true);
          }
          if (state is PostDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(postErrorMessage(l10n, state.code))),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.bg,
            body: SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    isDeleting: state is PostDetailLoaded && state.isDeleting,
                    onBack: () => context.pop(_changed),
                    // Owners get edit/delete; everyone else gets the report menu.
                    onMenu: state is PostDetailLoaded
                        ? () => _isOwner(state.post)
                              ? _showOwnerMenu(context, state.post)
                              : _reportPost(context, state.post)
                        : null,
                  ),
                  Expanded(
                    child: switch (state) {
                      PostDetailLoading() => Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ),
                      PostDetailError(:final code) => _ErrorView(
                        message: postErrorMessage(l10n, code),
                      ),
                      PostDetailLoaded(:final post) => SingleChildScrollView(
                        padding: AppLayout.inset(context),
                        child: PostDetailView(
                          post: post,
                          onToggleLike: () => context
                              .read<PostDetailBloc>()
                              .add(const ToggleLikePost()),
                          onToggleSave: () => context
                              .read<PostDetailBloc>()
                              .add(const ToggleSavePost()),
                          onToggleRepost: _isOwner(post)
                              ? null
                              : () {
                                  // A profile's Reposts grid reloads on return.
                                  _changed = true;
                                  context.read<PostDetailBloc>().add(
                                    const ToggleRepostPost(),
                                  );
                                },
                          onOpenComments: () => _openComments(context, post),
                          onOpenLikers: () =>
                              showLikersSheet(context, postId: post.id),
                        ),
                      ),
                      PostDetailDeleted() => const SizedBox.shrink(),
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openComments(BuildContext context, PostEntity post) {
    final bloc = context.read<PostDetailBloc>();
    showCommentsSheet(
      context,
      postId: post.id,
      initialCount: post.commentsCount,
      postOwnerId: post.author.id,
      onCountChanged: (count) => bloc.add(CommentCountChanged(count)),
    );
  }

  Future<void> _openEdit(BuildContext context, PostEntity post) async {
    final bloc = context.read<PostDetailBloc>();
    final navigator = Navigator.of(context);
    final result = await context.push<PostEditResult>(
      '/posts/${post.id}/edit',
      extra: post,
    );
    if (result == null) return;
    _changed = true;
    if (result.deleted) {
      // The post is gone — leave the detail screen and let the grid refresh.
      navigator.pop(true);
    } else if (result.updated != null) {
      bloc.add(PostUpdated(result.updated!));
    }
  }

  /// Non-owner "⋯" menu: opens the report flow and, on a successful report,
  /// leaves the detail screen (the post is hidden, not deleted).
  Future<void> _reportPost(BuildContext context, PostEntity post) async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showPostOptionsSheet(context);
    if (action != PostMenuAction.report || !context.mounted) return;

    final reported = await showReportSheet(
      context,
      target: PostReportTarget(post.id),
      title: l10n.postReport,
    );
    if (reported && context.mounted) context.pop(_changed);
  }

  void _showOwnerMenu(BuildContext context, PostEntity post) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<PostDetailBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppColors.ink),
              title: Text(
                l10n.postEditAction,
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _openEdit(context, post);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.danger),
              title: Text(
                l10n.postDeleteAction,
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmDelete(context, bloc);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, PostDetailBloc bloc) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.postDeleteTitle,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.postDeleteBody,
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: l10n.garageDialogCancel,
                      onTap: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogButton(
                      label: l10n.garageDialogDelete,
                      isDestructive: true,
                      onTap: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) bloc.add(const DeletePostPressed());
  }
}

class _TopBar extends StatelessWidget {
  final bool isDeleting;
  final VoidCallback onBack;
  final VoidCallback? onMenu;

  const _TopBar({required this.isDeleting, required this.onBack, this.onMenu});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(16, 8, 16, 8) + AppLayout.inset(context),
      child: Row(
        children: [
          _PillButton(
            onTap: onBack,
            child: Icon(Icons.chevron_left, color: AppColors.ink, size: 20),
          ),
          Expanded(
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.postDetailTitle,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (onMenu != null)
            _PillButton(
              onTap: isDeleting ? null : onMenu,
              child: isDeleting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.ink,
                      ),
                    )
                  : Icon(Icons.more_horiz, color: AppColors.ink, size: 20),
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PillButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DialogButton({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.danger : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? AppColors.danger : AppColors.line,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDestructive ? AppColors.onDanger : AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.mute, fontSize: 14),
        ),
      ),
    );
  }
}
