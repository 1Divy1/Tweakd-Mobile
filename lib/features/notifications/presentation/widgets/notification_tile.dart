import 'package:flutter/material.dart';
import 'package:tweakd/core/theme/app_icons.dart';

import '../../../../core/shared/widgets/app_avatar.dart';
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
      color: unread
          ? AppColors.accentSoft.withValues(alpha: 0.35)
          : AppColors.bg,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LeadingIcon(
                kind: _kindOf(notification.type),
                actorId: notification.actorId,
                actorUsername: notification.actorUsername,
                avatarUrl: notification.actorAvatarUrl,
              ),
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
                        style: TextStyle(
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
                      style: TextStyle(
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
                  decoration: BoxDecoration(
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
        return _NotificationIconKind.repost;
      case NotificationType.postTag:
      case NotificationType.postCommentTag:
      case NotificationType.forumThreadTag:
      case NotificationType.forumReplyTag:
        return _NotificationIconKind.tag;
      case NotificationType.dm:
        return _NotificationIconKind.message;
      case NotificationType.mapEventApproved:
      case NotificationType.mapEventRejected:
      case NotificationType.mapEventCarDecided:
      case NotificationType.mapEventCarRegistered:
      case NotificationType.mapEventOrganizerAdded:
      case NotificationType.mapEventWithdrawalRequested:
      case NotificationType.mapEventWithdrawalDecided:
      case NotificationType.contestEntryRequested:
      case NotificationType.contestEntryDecided:
      case NotificationType.contestOpened:
      case NotificationType.contestResults:
      case NotificationType.contestPlaced:
      case NotificationType.participantCardReady:
        return _NotificationIconKind.event;
      case NotificationType.moderationWarning:
      case NotificationType.contentRemoved:
        return _NotificationIconKind.moderation;
      case NotificationType.feedbackStatus:
      case NotificationType.feedbackFeedStatusChanged:
      case NotificationType.ticketReply:
      case NotificationType.unknown:
        return _NotificationIconKind.generic;
    }
  }
}

enum _NotificationIconKind {
  like,
  comment,
  repost,
  tag,
  message,
  event,
  moderation,
  generic,
}

/// The row's leading visual. When a person caused the notification it shows
/// their avatar with a small type badge overlaid bottom-right (Instagram's
/// pattern) — the photo when the payload carries one, otherwise their initial.
/// System notifications with no actor get the plain tinted icon badge.
class _LeadingIcon extends StatelessWidget {
  static const double _size = 42;

  final _NotificationIconKind kind;
  final String? actorId;
  final String? actorUsername;
  final String? avatarUrl;

  const _LeadingIcon({
    required this.kind,
    this.actorId,
    this.actorUsername,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (actorId == null) {
      return _IconBadge(kind: kind, size: _size, iconSize: 20);
    }
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _ActorAvatar(
            username: actorUsername,
            avatarUrl: avatarUrl,
            size: _size,
          ),
          Positioned(
            right: -3,
            bottom: -3,
            child: _IconBadge(
              kind: kind,
              size: 20,
              iconSize: 11,
              border: Border.all(color: AppColors.bg, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular actor photo with an initial-letter fallback — the same treatment
/// as the forum and message avatars, including the decode-size cap so a
/// full-resolution upload isn't decoded for every row while scrolling.
class _ActorAvatar extends StatelessWidget {
  final String? username;
  final String? avatarUrl;
  final double size;

  const _ActorAvatar({
    required this.username,
    required this.avatarUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar(size: size, url: avatarUrl, name: username);
  }
}

class _IconBadge extends StatelessWidget {
  final _NotificationIconKind kind;
  final double size;
  final double iconSize;
  final BoxBorder? border;

  const _IconBadge({
    required this.kind,
    required this.size,
    required this.iconSize,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, fg, bg) = switch (kind) {
      _NotificationIconKind.like => (
        Icons.favorite_rounded,
        AppColors.ink2,
        AppColors.line,
      ),
      _NotificationIconKind.comment => (
        Icons.mode_comment_rounded,
        AppColors.ink2,
        AppColors.line,
      ),
      _NotificationIconKind.repost => (
        AppIcons.repost,
        AppColors.ink2,
        AppColors.line,
      ),
      _NotificationIconKind.tag => (
        Icons.local_offer_rounded,
        AppColors.ink2,
        AppColors.line,
      ),
      _NotificationIconKind.message => (
        Icons.mail_outline_rounded,
        AppColors.ink2,
        AppColors.line,
      ),
      _NotificationIconKind.event => (
        Icons.place_rounded,
        AppColors.ink2,
        AppColors.line,
      ),
      _NotificationIconKind.moderation => (
        Icons.gpp_maybe_rounded,
        AppColors.accent,
        AppColors.accentSoft,
      ),
      _NotificationIconKind.generic => (
        Icons.notifications_rounded,
        AppColors.ink2,
        AppColors.line,
      ),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: border,
      ),
      child: Icon(icon, color: fg, size: iconSize),
    );
  }
}
