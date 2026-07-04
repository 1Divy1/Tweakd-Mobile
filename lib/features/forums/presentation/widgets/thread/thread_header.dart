import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/forum_thread.dart';
import '../../utils/forum_format.dart';
import '../shared/forum_avatar.dart';
import '../shared/forum_chips.dart';

/// The OP block of the thread page: status banner, title, author line, body,
/// tags and the like / replies / share action row.
class ThreadHeader extends StatelessWidget {
  final ForumThreadDetailEntity thread;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleSave;
  final VoidCallback onReply;
  final VoidCallback onShare;

  const ThreadHeader({
    super.key,
    required this.thread,
    required this.onToggleLike,
    required this.onToggleSave,
    required this.onReply,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authorName = thread.author?.username;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (thread.pinned) ...[
            _Banner(
              icon: Icons.push_pin,
              label: l10n.forumsPinned,
              color: AppColors.accent,
            ),
            const SizedBox(height: 10),
          ],
          if (thread.locked) ...[
            _Banner(
              icon: Icons.lock_outline,
              label: l10n.forumsLocked,
              color: AppColors.mute,
            ),
            const SizedBox(height: 10),
          ],
          Text(
            thread.title,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ForumAvatar(
                username: authorName,
                avatarUrl: thread.author?.avatarUrl,
                size: 34,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName != null
                          ? '@$authorName'
                          : l10n.forumsDeletedPlaceholder,
                      style: TextStyle(
                        color:
                            authorName != null ? AppColors.ink : AppColors.mute,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.forumsPosted} · '
                      '${forumActiveAgo(l10n, thread.lastActivityAt)}',
                      style: const TextStyle(
                        color: AppColors.mute,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (thread.content != null && thread.content!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              thread.content!,
              style: const TextStyle(
                color: AppColors.ink2,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (thread.brand != null)
                ForumTagChip(label: thread.brand!.name, showDot: true),
              if (thread.model != null)
                ForumTagChip(label: thread.model!.model, showDot: true),
              for (final topic in thread.topics)
                ForumTagChip(label: topic.name),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionItem(
                icon: thread.viewerHasLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: forumCompactCount(thread.likesCount),
                color: thread.viewerHasLiked ? AppColors.accent : null,
                onTap: onToggleLike,
              ),
              _ActionItem(
                icon: Icons.mode_comment_outlined,
                label: forumCompactCount(thread.replyCount),
                onTap: onReply,
              ),
              _ActionItem(
                icon: thread.viewerHasSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: thread.viewerHasSaved
                    ? l10n.forumsSaved
                    : l10n.forumsSave,
                color: thread.viewerHasSaved ? AppColors.accent : null,
                onTap: onToggleSave,
              ),
              _ActionItem(
                icon: Icons.ios_share_rounded,
                label: l10n.forumsShare,
                onTap: onShare,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.line, height: 1),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Banner({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color ?? AppColors.ink2),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color ?? AppColors.mute,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
