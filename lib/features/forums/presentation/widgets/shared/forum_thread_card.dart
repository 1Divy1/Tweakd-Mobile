import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/forum_thread.dart';
import '../../utils/forum_format.dart';
import 'forum_avatar.dart';
import 'forum_chips.dart';
import 'forum_tag_row.dart';

/// A thread in a list (home feed, hubs). The excerpt is optional (refined
/// hubs show it, dense lists don't); car tags already implied by the hub's
/// filter can be hidden.
class ForumThreadCard extends StatelessWidget {
  final ForumThreadEntity thread;
  final VoidCallback onTap;
  final bool showExcerpt;
  final bool hideBrandTag;
  final bool hideModelTag;

  /// When set, a bookmark toggle is shown on the card; null hides it.
  final VoidCallback? onToggleSave;

  const ForumThreadCard({
    super.key,
    required this.thread,
    required this.onTap,
    this.showExcerpt = false,
    this.hideBrandTag = false,
    this.hideModelTag = false,
    this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authorName = thread.author?.username;

    final tags = <Widget>[
      if (!hideBrandTag && thread.brand != null)
        ForumTagChip(label: thread.brand!.name, showDot: false),
      if (!hideModelTag && thread.model != null)
        ForumTagChip(label: thread.model!.model, showDot: false),
      for (final topic in thread.topics) ForumTagChip(label: topic.name),
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thread.pinned) ...[
              _StatusRow(
                icon: Icons.push_pin,
                label: l10n.forumsPinned,
                color: AppColors.accent,
              ),
              const SizedBox(height: 8),
            ] else if (thread.locked) ...[
              _StatusRow(
                icon: Icons.lock_outline,
                label: l10n.forumsLocked,
                color: AppColors.mute,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              thread.title,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            if (showExcerpt &&
                thread is ForumThreadDetailEntity &&
                (thread as ForumThreadDetailEntity).content != null) ...[
              const SizedBox(height: 6),
              Text(
                (thread as ForumThreadDetailEntity).content!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.mute,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                ForumAvatar(
                  username: authorName,
                  avatarUrl: thread.author?.avatarUrl,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    authorName != null
                        ? '@$authorName'
                        : l10n.forumsDeletedPlaceholder,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: authorName != null ? AppColors.ink : AppColors.mute,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '     ${forumActiveAgo(l10n, thread.lastActivityAt)}',
                  style: const TextStyle(
                    color: AppColors.mute,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: tags),
            ],
            if (thread.taggedPeople.isNotEmpty ||
                thread.taggedCars.isNotEmpty) ...[
              const SizedBox(height: 8),
              ForumTagRow(
                people: thread.taggedPeople,
                cars: thread.taggedCars,
                dense: true,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _CountItem(
                  icon: Icons.mode_comment_outlined,
                  count: thread.replyCount,
                ),
                const SizedBox(width: 16),
                _CountItem(
                  icon: Icons.favorite_border_rounded,
                  count: thread.likesCount,
                ),
                if (onToggleSave != null) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: onToggleSave,
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      thread.viewerHasSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 19,
                      color: thread.viewerHasSaved
                          ? AppColors.accent
                          : AppColors.mute,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _CountItem extends StatelessWidget {
  final IconData icon;
  final int count;

  const _CountItem({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.mute),
        const SizedBox(width: 4),
        Text(
          forumCompactCount(count),
          style: const TextStyle(
            color: AppColors.mute,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
