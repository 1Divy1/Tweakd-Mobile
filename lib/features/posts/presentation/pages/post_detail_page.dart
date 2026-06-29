import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/post.dart';
import '../bloc/post_detail/bloc.dart';
import '../bloc/post_detail/event.dart';
import '../bloc/post_detail/state.dart';
import '../utils/post_error_mapper.dart';
import 'edit_post_page.dart';
import '../widgets/post_detail/comments_sheet.dart';
import '../widgets/post_detail/likers_sheet.dart';
import '../widgets/post_detail/post_detail_view.dart';

/// Full-screen view of a single post. Owners get an edit/delete menu; everyone
/// can like, save, share and open the comments / likers sheets. Pops `true` when
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
                    isOwner:
                        state is PostDetailLoaded && _isOwner(state.post),
                    isDeleting:
                        state is PostDetailLoaded && state.isDeleting,
                    onBack: () => context.pop(_changed),
                    onMenu: state is PostDetailLoaded
                        ? () => _showOwnerMenu(context, state.post)
                        : null,
                  ),
                  Expanded(
                    child: switch (state) {
                      PostDetailLoading() => const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent),
                        ),
                      PostDetailError(:final code) => _ErrorView(
                          message: postErrorMessage(l10n, code),
                        ),
                      PostDetailLoaded(:final post) => SingleChildScrollView(
                          child: PostDetailView(
                            post: post,
                            onToggleLike: () => context
                                .read<PostDetailBloc>()
                                .add(const ToggleLikePost()),
                            onToggleSave: () => context
                                .read<PostDetailBloc>()
                                .add(const ToggleSavePost()),
                            onShare: () => _openShare(context, post),
                            onOpenComments: () => _openComments(context, post),
                            onOpenLikers: () => showLikersSheet(
                              context,
                              postId: post.id,
                            ),
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

  Future<void> _openShare(BuildContext context, PostEntity post) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final shared = await context.push<bool>(
      '/posts/${post.id}/share',
      extra: post,
    );
    if (shared == true) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.postShareSuccess)),
      );
    }
  }

  void _openComments(BuildContext context, PostEntity post) {
    showCommentsSheet(
      context,
      postId: post.id,
      initialCount: post.commentsCount,
      postOwnerId: post.author.id,
      postDetailBloc: context.read<PostDetailBloc>(),
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
              leading: const Icon(Icons.edit_outlined, color: AppColors.ink),
              title: Text(
                l10n.postEditAction,
                style: const TextStyle(
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
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                l10n.postDeleteAction,
                style: const TextStyle(
                  color: Colors.red,
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
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.postDeleteBody,
                style: const TextStyle(
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
  final bool isOwner;
  final bool isDeleting;
  final VoidCallback onBack;
  final VoidCallback? onMenu;

  const _TopBar({
    required this.isOwner,
    required this.isDeleting,
    required this.onBack,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _PillButton(
            onTap: onBack,
            child: const Icon(Icons.chevron_left, color: AppColors.ink, size: 20),
          ),
          Expanded(
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.postDetailTitle,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ),
          if (isOwner)
            _PillButton(
              onTap: isDeleting ? null : onMenu,
              child: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.ink,
                      ),
                    )
                  : const Icon(Icons.more_horiz, color: AppColors.ink, size: 20),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
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
          color: isDestructive ? Colors.red : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDestructive ? Colors.red : AppColors.line),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDestructive ? Colors.white : AppColors.ink,
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
          style: const TextStyle(color: AppColors.mute, fontSize: 14),
        ),
      ),
    );
  }
}
