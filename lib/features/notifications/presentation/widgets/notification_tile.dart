import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../posts/presentation/widgets/post_detail/post_time.dart';
import '../../domain/entities/notification.dart';

/// One notification row: a type-coloured leading icon, the title, an optional
/// muted body excerpt, a relative timestamp and — while unread — a subtly
/// tinted background plus an accent dot.
class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unread = !notification.read;
    final body = notification.body?.trim();

    return Material(
      color: unread ? AppColors.accentSoft.withValues(alpha: 0.35) : AppColors.bg,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LeadingIcon(kind: _kindOf(notification.type)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 14.5,
                        height: 1.3,
                        fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    if (body != null && body.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.mute,
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      postTimeAgo(l10n, notification.createdAt),
                      style: const TextStyle(
                        color: AppColors.muteSoft,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (unread)
                Container(
                  margin: const EdgeInsets.only(left: 10, top: 6),
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static _NotificationIconKind _kindOf(NotificationType type) {
    switch (type) {
      case NotificationType.postLike:
      case NotificationType.forumThreadLike:
      case NotificationType.forumReplyLike:
        return _NotificationIconKind.like;
      case NotificationType.postComment:
      case NotificationType.forumThreadReply:
      case NotificationType.forumReplyReply:
        return _NotificationIconKind.comment;
      case NotificationType.postShare:
        return _NotificationIconKind.share;
      case NotificationType.unknown:
        return _NotificationIconKind.generic;
    }
  }
}

enum _NotificationIconKind { like, comment, share, generic }

/// The tinted round icon badge leading each row. Likes use the accent palette;
/// comments/replies and shares use a neutral ink-on-surface treatment.
class _LeadingIcon extends StatelessWidget {
  final _NotificationIconKind kind;

  const _LeadingIcon({required this.kind});

  @override
  Widget build(BuildContext context) {
    final (icon, fg, bg) = switch (kind) {
      _NotificationIconKind.like => (
          Icons.favorite_rounded,
          AppColors.accent,
          AppColors.accentSoft,
        ),
      _NotificationIconKind.comment => (
          Icons.mode_comment_rounded,
          AppColors.ink2,
          AppColors.line,
        ),
      _NotificationIconKind.share => (
          Icons.ios_share_rounded,
          AppColors.ink2,
          AppColors.line,
        ),
      _NotificationIconKind.generic => (
          Icons.notifications_rounded,
          AppColors.ink2,
          AppColors.line,
        ),
    };

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: 20),
    );
  }
}
