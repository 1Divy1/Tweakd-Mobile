import 'package:flutter/material.dart';

import 'package:car_social_media_app/features/posts/presentation/widgets/post_detail/post_time.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/thread/state.dart';
import '../../utils/forum_format.dart';
import '../shared/forum_avatar.dart';
import '../shared/forum_tag_row.dart';

/// One reply and (when expanded) its lazily-loaded children, indented one
/// level per depth (visually capped so deep chains stay readable).
class ReplyTile extends StatelessWidget {
  final ReplyNode node;
  final int depth;
  final bool locked;
  final String? currentUserId;
  final void Function(ReplyNode) onToggleLike;
  final void Function(ReplyNode) onReply;
  final void Function(ReplyNode) onToggleChildren;
  final void Function(ReplyNode) onLoadMoreChildren;
  final void Function(ReplyNode) onMenu;

  const ReplyTile({
    super.key,
    required this.node,
    this.depth = 0,
    required this.locked,
    required this.currentUserId,
    required this.onToggleLike,
    required this.onReply,
    required this.onToggleChildren,
    required this.onLoadMoreChildren,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reply = node.reply;
    final authorName = reply.author?.username;
    final indent = 16.0 + (depth.clamp(0, 3)) * 22.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(indent, 10, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ForumAvatar(
                    username: authorName,
                    avatarUrl: reply.author?.avatarUrl,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      authorName != null
                          ? '@$authorName'
                          : l10n.forumsDeletedPlaceholder,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: authorName != null
                            ? AppColors.ink
                            : AppColors.mute,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (!reply.deleted && reply.isAuthor) ...[
                    const SizedBox(width: 6),
                    const _AuthorBadge(),
                  ],
                  Text(
                    '  ·  ${postTimeAgo(l10n, reply.createdAt)}',
                    style: const TextStyle(
                      color: AppColors.mute,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (!reply.deleted && authorName != null)
                    GestureDetector(
                      onTap: () => onMenu(node),
                      child: const Icon(
                        Icons.more_horiz,
                        size: 18,
                        color: AppColors.mute,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply.deleted
                          ? l10n.forumsDeletedPlaceholder
                          : (reply.content ?? ''),
                      style: TextStyle(
                        color: reply.deleted ? AppColors.mute : AppColors.ink2,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontStyle: reply.deleted
                            ? FontStyle.italic
                            : FontStyle.normal,
                        height: 1.4,
                      ),
                    ),
                    if (!reply.deleted &&
                        (reply.taggedPeople.isNotEmpty ||
                            reply.taggedCars.isNotEmpty)) ...[
                      const SizedBox(height: 8),
                      ForumTagRow(
                        people: reply.taggedPeople,
                        cars: reply.taggedCars,
                        dense: true,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (!reply.deleted) ...[
                          GestureDetector(
                            onTap: () => onToggleLike(node),
                            child: Row(
                              children: [
                                Icon(
                                  reply.viewerHasLiked
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 15,
                                  color: reply.viewerHasLiked
                                      ? AppColors.accent
                                      : AppColors.mute,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  forumCompactCount(reply.likesCount),
                                  style: TextStyle(
                                    color: reply.viewerHasLiked
                                        ? AppColors.accent
                                        : AppColors.mute,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (!locked)
                            GestureDetector(
                              onTap: () => onReply(node),
                              child: Text(
                                l10n.forumsReply,
                                style: const TextStyle(
                                  color: AppColors.mute,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          const SizedBox(width: 16),
                        ],
                        if (reply.replyCount > 0 || node.children.isNotEmpty)
                          _ExpandButton(
                            node: node,
                            l10n: l10n,
                            onTap: () => onToggleChildren(node),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (node.expanded) ...[
          for (final child in node.children)
            ReplyTile(
              node: child,
              depth: depth + 1,
              locked: locked,
              currentUserId: currentUserId,
              onToggleLike: onToggleLike,
              onReply: onReply,
              onToggleChildren: onToggleChildren,
              onLoadMoreChildren: onLoadMoreChildren,
              onMenu: onMenu,
            ),
          if (node.hasMoreChildren)
            Padding(
              padding: EdgeInsets.only(left: indent + 32, top: 8),
              child: GestureDetector(
                onTap: () => onLoadMoreChildren(node),
                child: Text(
                  l10n.forumsShowMoreReplies,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// The small "OP" pill shown next to a reply whose author is the thread's
/// original poster.
class _AuthorBadge extends StatelessWidget {
  const _AuthorBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        l10n.forumsAuthorBadge,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _ExpandButton extends StatelessWidget {
  final ReplyNode node;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _ExpandButton({
    required this.node,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (node.childrenLoading) {
      return const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.accent,
        ),
      );
    }
    final label = node.expanded
        ? l10n.forumsHideReplies
        : l10n.forumsShowReplies(node.reply.replyCount);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            node.expanded
                ? Icons.arrow_drop_up_rounded
                : Icons.arrow_drop_down_rounded,
            size: 18,
            color: AppColors.accent,
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
