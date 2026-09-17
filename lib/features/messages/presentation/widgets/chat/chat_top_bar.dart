import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/message_user.dart';
import '../shared/message_avatar.dart';
import '../shared/verified_badge.dart';
import '../../../../../core/shared/layout/app_layout.dart';

/// Chat header: back button, the other user's avatar, name + verified badge.
/// No online status (the app has no presence) and no call button — calls are
/// intentionally out of the app's scope.
class ChatTopBar extends StatelessWidget {
  final MessageUserEntity? user;
  final VoidCallback onBack;

  /// Tapping the peer's avatar or name opens their public profile.
  final VoidCallback? onOpenProfile;

  const ChatTopBar({
    super.key,
    required this.user,
    required this.onBack,
    this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final user = this.user;

    return Container(
      padding:
          const EdgeInsets.fromLTRB(16, 12, 16, 10) + AppLayout.inset(context),
      decoration: BoxDecoration(color: AppColors.bg),
      child: Row(
        children: [
          AppPillButton(icon: Icons.chevron_left_rounded, onTap: onBack),
          const SizedBox(width: 12),
          if (user != null) ...[
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onOpenProfile,
                child: Row(
                  children: [
                    MessageAvatar(
                      username: user.username,
                      avatarUrl: user.avatarUrl,
                      size: 42,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 17,
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
                    ),
                  ],
                ),
              ),
            ),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}
