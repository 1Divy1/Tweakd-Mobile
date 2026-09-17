import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/message_user.dart';
import '../shared/message_avatar.dart';

/// "ACTIVE NOW" section: a horizontal strip of online users' avatars with
/// their short name below.
class ActiveNowRow extends StatelessWidget {
  final List<MessageUserEntity> users;
  final ValueChanged<MessageUserEntity> onUserTap;

  const ActiveNowRow({super.key, required this.users, required this.onUserTap});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            l10n.messagesActiveNow,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(width: 18),
            itemBuilder: (context, index) {
              final user = users[index];
              return GestureDetector(
                onTap: () => onUserTap(user),
                child: Column(
                  children: [
                    MessageAvatar(
                      username: user.username,
                      avatarUrl: user.avatarUrl,
                      size: 56,
                      showOnlineDot: true,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      // "marcus_vlox" → "marcus" under the avatar.
                      user.username.split('_').first,
                      style: TextStyle(
                        color: AppColors.ink2,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Divider(height: 1, thickness: 1, color: AppColors.line2),
      ],
    );
  }
}
