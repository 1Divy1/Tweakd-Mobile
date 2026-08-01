import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/message_user.dart';
import '../shared/message_avatar.dart';
import '../shared/verified_badge.dart';

/// Chat header: back button, the other user's avatar, name + verified badge
/// and a status line — a pulsing "Active now" while the peer is online, or
/// "Last seen …" once they drop offline (nothing for users never seen
/// online). No call button — calls are intentionally out of the app's scope.
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
    final l10n = AppLocalizations.of(context)!;
    final user = this.user;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: const BoxDecoration(
        color: AppColors.bg,
      ),
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
                      showRing: true,
                      showOnlineDot: user.isOnline,
                    ),
                    const SizedBox(width: 12),
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
                  if (user.isOnline) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const _PulsingDot(),
                        const SizedBox(width: 6),
                        Text(
                          l10n.messagesActiveNowStatus,
                          style: const TextStyle(
                            color: AppColors.mute,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Nothing is rendered when the peer is offline: Supabase
                  // Presence reports who is connected now and keeps no
                  // last-seen history.
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

/// The soft-pulsing accent dot next to "Active now".
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
