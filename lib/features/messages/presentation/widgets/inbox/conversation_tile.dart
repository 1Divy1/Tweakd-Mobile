import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/conversation.dart';
import '../../utils/message_time.dart';
import '../shared/message_avatar.dart';
import '../shared/verified_badge.dart';

/// One conversation row of the inbox list.
class ConversationTile extends StatelessWidget {
  final ConversationEntity conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  bool get _hasUnread => conversation.unreadCount > 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = conversation.user;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            MessageAvatar(
              username: user.username,
              avatarUrl: user.avatarUrl,
              size: 56,
              showRing: _hasUnread || user.isOnline || user.isVerified,
              showOnlineDot: user.isOnline,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (user.isVerified) ...const [
                        SizedBox(width: 6),
                        VerifiedBadge(size: 15),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  _PreviewLine(
                    conversation: conversation,
                    l10n: l10n,
                    emphasized: _hasUnread,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  messageCompactAgo(l10n, conversation.lastMessageAt),
                  style: TextStyle(
                    color: _hasUnread ? AppColors.accent : AppColors.mute,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                _TrailingBadge(conversation: conversation),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Preview text: "You: …" for own messages, an icon + "Shared a post" for
/// shared posts, plain text otherwise. Unread previews render darker.
class _PreviewLine extends StatelessWidget {
  final ConversationEntity conversation;
  final AppLocalizations l10n;
  final bool emphasized;

  const _PreviewLine({
    required this.conversation,
    required this.l10n,
    required this.emphasized,
  });

  TextStyle get _style => TextStyle(
        color: emphasized ? AppColors.ink2 : AppColors.mute,
        fontSize: 14,
        fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
      );

  @override
  Widget build(BuildContext context) {
    if (conversation.previewKind == ConversationPreviewKind.sharedPost) {
      return Row(
        children: [
          const Icon(Icons.ios_share_rounded, size: 15, color: AppColors.mute),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l10n.messagesSharedPost,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _style,
            ),
          ),
        ],
      );
    }

    final text = conversation.isLastMessageMine
        ? l10n.messagesYouPrefix(conversation.preview)
        : conversation.preview;
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _style,
    );
  }
}

/// Right-edge indicator: unread count badge, or a mini avatar when the
/// viewer's own last message was seen.
class _TrailingBadge extends StatelessWidget {
  final ConversationEntity conversation;

  const _TrailingBadge({required this.conversation});

  @override
  Widget build(BuildContext context) {
    if (conversation.unreadCount > 0) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${conversation.unreadCount}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    if (conversation.isLastMessageMine && conversation.lastMessageSeen) {
      return MessageAvatar(
        username: conversation.user.username,
        avatarUrl: conversation.user.avatarUrl,
        size: 18,
      );
    }

    return const SizedBox(height: 22);
  }
}
