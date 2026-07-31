import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:car_social_media_app/features/posts/presentation/widgets/post_detail/post_time.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/tagged_item.dart';
import 'tagged_comment_card.dart';
import 'tagged_post_card.dart';
import 'tagged_reply_card.dart';
import 'tagged_thread_card.dart';

/// One row of the tags feed. The frame (kind label, "tagged x ago", the "⋯"
/// menu on your own feed) is shared; the body is the read-only render of
/// whichever content kind the row carries.
///
/// The card is a single tap target that deep-links to the real content —
/// nothing inside it acts on the content itself. The nested chips and author
/// rows keep their own taps (a tagged car opens that car, an author opens their
/// profile), which is the behaviour those widgets have everywhere else.
class TaggedItemCard extends StatelessWidget {
  final TaggedItemEntity item;

  /// Whether the "⋯" → remove tag action is offered (own profile only).
  final bool canRemove;

  /// True while this item's untag request is in flight.
  final bool isRemoving;
  final VoidCallback onMenu;

  const TaggedItemCard({
    super.key,
    required this.item,
    required this.canRemove,
    required this.isRemoving,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final body = _body();
    // A row whose payload didn't arrive has nothing to render — skip it rather
    // than showing an empty frame.
    if (body == null) return const SizedBox.shrink();

    return Opacity(
      opacity: isRemoving ? 0.5 : 1,
      child: IgnorePointer(
        ignoring: isRemoving,
        child: GestureDetector(
          onTap: () => _open(context),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                  child: Row(
                    children: [
                      Icon(_kindIcon, size: 14, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _kindLabel(l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.mute,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Text(
                        '  ·  ${postTimeAgo(l10n, item.taggedAt)}',
                        style: const TextStyle(
                          color: AppColors.muteSoft,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (canRemove)
                        _MenuButton(isBusy: isRemoving, onTap: onMenu)
                      else
                        const SizedBox(width: 8),
                    ],
                  ),
                ),
                body,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _body() {
    return switch (item.kind) {
      TaggedItemKind.post => item.post == null
          ? null
          : TaggedPostCard(post: item.post!),
      TaggedItemKind.postComment => item.post == null || item.comment == null
          ? null
          : TaggedCommentCard(post: item.post!, comment: item.comment!),
      TaggedItemKind.forumThread => item.thread == null
          ? null
          : TaggedThreadCard(thread: item.thread!),
      TaggedItemKind.forumReply => item.thread == null || item.reply == null
          ? null
          : TaggedReplyCard(thread: item.thread!, reply: item.reply!),
    };
  }

  /// Comments open their parent post and replies open their parent thread —
  /// there is no route to a single comment or reply.
  void _open(BuildContext context) {
    switch (item.kind) {
      case TaggedItemKind.post:
      case TaggedItemKind.postComment:
        final post = item.post;
        if (post != null) context.push('/posts/${post.id}');
      case TaggedItemKind.forumThread:
      case TaggedItemKind.forumReply:
        final thread = item.thread;
        if (thread != null) context.push('/forums/threads/${thread.id}');
    }
  }

  IconData get _kindIcon => switch (item.kind) {
        TaggedItemKind.post => Icons.image_outlined,
        TaggedItemKind.postComment => Icons.mode_comment_outlined,
        TaggedItemKind.forumThread => Icons.forum_outlined,
        TaggedItemKind.forumReply => Icons.reply_rounded,
      };

  String _kindLabel(AppLocalizations l10n) => switch (item.kind) {
        TaggedItemKind.post => l10n.tagsKindPost,
        TaggedItemKind.postComment => l10n.tagsKindComment,
        TaggedItemKind.forumThread => l10n.tagsKindThread,
        TaggedItemKind.forumReply => l10n.tagsKindReply,
      };
}

class _MenuButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onTap;

  const _MenuButton({required this.isBusy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isBusy ? null : onTap,
      child: SizedBox(
        width: 40,
        height: 28,
        child: Center(
          child: isBusy
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.mute,
                  ),
                )
              : const Icon(Icons.more_horiz, size: 18, color: AppColors.mute),
        ),
      ),
    );
  }
}
