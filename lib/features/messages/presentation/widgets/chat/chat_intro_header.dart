import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/message_user.dart';
import '../shared/message_avatar.dart';

/// The intro block at the top of a conversation: big avatar, username and
/// the mutual-follow / followers line.
class ChatIntroHeader extends StatelessWidget {
  final MessageUserEntity user;

  const ChatIntroHeader({super.key, required this.user});

  String get _compactFollowers {
    final n = user.followersCount;
    if (n < 1000) return '$n';
    final v = n / 1000;
    final s = v.toStringAsFixed(v >= 10 ? 0 : 1).replaceFirst('.0', '');
    return '${s}k';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      child: Column(
        children: [
          MessageAvatar(
            username: user.username,
            avatarUrl: user.avatarUrl,
            size: 96,
            showRing: true,
          ),
          const SizedBox(height: 16),
          Text(
            user.username,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (user.isMutualFollow) ...[
            const SizedBox(height: 8),
            Text(
              l10n.messagesMutualFollow(_compactFollowers),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.mute,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
