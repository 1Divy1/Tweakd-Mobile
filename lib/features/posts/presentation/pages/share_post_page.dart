import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/post.dart';
import '../bloc/share_post/bloc.dart';
import '../bloc/share_post/event.dart';
import '../bloc/share_post/state.dart';
import '../utils/post_error_mapper.dart';

/// Dedicated screen for sharing a post with an optional note. Pops `true` once
/// the share succeeds so the caller can confirm it.
class SharePostPage extends StatefulWidget {
  final PostEntity post;

  const SharePostPage({super.key, required this.post});

  @override
  State<SharePostPage> createState() => _SharePostPageState();
}

class _SharePostPageState extends State<SharePostPage> {
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _share() {
    context.read<SharePostBloc>().add(
          SubmitShare(
            postId: widget.post.id,
            content: _noteCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<SharePostBloc, SharePostState>(
      listener: (context, state) {
        if (state.status == ShareStatus.success) {
          context.pop(true);
        }
        if (state.status == ShareStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                postErrorMessage(l10n, state.errorCode ?? PostErrorCode.generic),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.isSubmitting;
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(
                  isSubmitting: isSubmitting,
                  onClose: isSubmitting ? null : () => context.pop(),
                  onShare: isSubmitting ? null : _share,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PostPreview(post: widget.post),
                        const SizedBox(height: 24),
                        Text(
                          l10n.postShareNoteLabel,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _NoteField(
                          controller: _noteCtrl,
                          enabled: !isSubmitting,
                          hint: l10n.postShareNoteHint,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PostPreview extends StatelessWidget {
  final PostEntity post;

  const _PostPreview({required this.post});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final images = [...post.images]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final thumbUrl = images.isNotEmpty ? images.first.imageUrl : null;
    final caption = post.description?.trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: thumbUrl != null
                  ? CachedNetworkImage(
                      imageUrl: thumbUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: AppColors.bg),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.bg,
                        child: const Icon(Icons.image_not_supported_outlined,
                            color: AppColors.muteSoft, size: 22),
                      ),
                    )
                  : Container(
                      color: AppColors.bg,
                      child: const Icon(Icons.photo_outlined,
                          color: AppColors.muteSoft, size: 22),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.author.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (caption != null && caption.isNotEmpty)
                      ? caption
                      : l10n.postSharePreviewNoCaption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: (caption != null && caption.isNotEmpty)
                        ? AppColors.mute
                        : AppColors.muteSoft,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String hint;

  const _NoteField({
    required this.controller,
    required this.enabled,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        enabled: enabled,
        cursorColor: AppColors.accent,
        minLines: 3,
        maxLines: 6,
        maxLength: 500,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.muteSoft,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
          counterStyle: const TextStyle(
            color: AppColors.muteSoft,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback? onClose;
  final VoidCallback? onShare;

  const _TopBar({
    required this.isSubmitting,
    this.onClose,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 44,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(Icons.close_rounded,
                  color: AppColors.ink, size: 20),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                l10n.postShareTitle,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onShare,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: isSubmitting ? AppColors.muteSoft : AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.postShareSend,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
