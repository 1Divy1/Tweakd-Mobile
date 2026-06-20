import 'package:flutter/material.dart';

import '../../../../../core/services/push_permission_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/notification_preferences.dart';
import '../onboarding_fields.dart';

/// Step 6 — notification preferences, grouped by topic. Defaults are opt-in
/// (see [NotificationPreferences.defaults]). The "meets & events" group header
/// reflects the discovery radius chosen on the previous step.
class NotificationsStep extends StatelessWidget {
  final NotificationPreferences prefs;
  final int radiusKm;
  final ValueChanged<NotificationPreferences> onChanged;

  /// Current OS-level push permission, surfaced in the banner at the top.
  final PushPermission pushPermission;

  /// Triggers the system permission prompt (when [pushPermission] is
  /// [PushPermission.canRequest]).
  final VoidCallback onEnablePush;

  /// Opens the OS settings screen (when push is [PushPermission.blocked]).
  final VoidCallback onOpenPushSettings;

  const NotificationsStep({
    super.key,
    required this.prefs,
    required this.radiusKm,
    required this.onChanged,
    required this.pushPermission,
    required this.onEnablePush,
    required this.onOpenPushSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingSectionHeader(
          label: '06 — NOTIFICATIONS',
          title: 'What should we ping you about?',
          subtitle: 'Stay on top of what matters. You can fine-tune any of '
              'these later.',
        ),
        const SizedBox(height: 20),
        _PushPermissionBanner(
          permission: pushPermission,
          onEnable: onEnablePush,
          onOpenSettings: onOpenPushSettings,
        ),
        const SizedBox(height: 24),
        _GroupLabel('ON YOUR CONTENT'),
        _ToggleRow(
          icon: Icons.favorite_rounded,
          iconColor: AppColors.accent,
          title: 'Likes',
          subtitle: 'When someone likes your builds & posts',
          value: prefs.likesEnabled,
          onChanged: (v) => onChanged(prefs.copyWith(likesEnabled: v)),
        ),
        _ToggleRow(
          icon: Icons.mode_comment_outlined,
          title: 'Comments',
          subtitle: 'Replies and threads on your content',
          value: prefs.commentsEnabled,
          onChanged: (v) => onChanged(prefs.copyWith(commentsEnabled: v)),
        ),
        _ToggleRow(
          icon: Icons.ios_share_rounded,
          title: 'Shares',
          subtitle: 'When your content gets reposted',
          value: prefs.sharesEnabled,
          onChanged: (v) => onChanged(prefs.copyWith(sharesEnabled: v)),
        ),
        const SizedBox(height: 18),
        _GroupLabel('MESSAGES'),
        _ToggleRow(
          icon: Icons.mail_outline_rounded,
          title: 'Direct messages',
          subtitle: 'New DMs and message requests',
          value: prefs.dmsEnabled,
          onChanged: (v) => onChanged(prefs.copyWith(dmsEnabled: v)),
        ),
        const SizedBox(height: 18),
        _GroupLabel('MEETS & EVENTS · WITHIN $radiusKm KM'),
        _ToggleRow(
          icon: Icons.bolt_rounded,
          iconColor: AppColors.accent,
          title: 'Flash meets',
          subtitle: 'Spontaneous link-ups happening near you',
          value: prefs.flashMeetsEnabled,
          onChanged: (v) => onChanged(prefs.copyWith(flashMeetsEnabled: v)),
        ),
        _ToggleRow(
          icon: Icons.calendar_today_rounded,
          title: 'Organized events',
          subtitle: 'Shows, track days & cars-and-coffee',
          value: prefs.organizedEventsEnabled,
          onChanged: (v) =>
              onChanged(prefs.copyWith(organizedEventsEnabled: v)),
        ),
        const SizedBox(height: 18),
        _GroupLabel('MARKETPLACE'),
        _ToggleRow(
          icon: Icons.shopping_bag_outlined,
          title: 'Price drops',
          subtitle: 'When a saved item gets a discount',
          value: prefs.priceDropsEnabled,
          onChanged: (v) => onChanged(prefs.copyWith(priceDropsEnabled: v)),
        ),
      ],
    );
  }
}

/// Banner at the top of the step reflecting the OS-level push permission.
///
/// - [PushPermission.canRequest] → accent call-to-action that fires the system
///   prompt. Without it the per-topic toggles below have no way to reach the
///   device.
/// - [PushPermission.granted] → quiet confirmation.
/// - [PushPermission.blocked] → a nudge to re-enable from system settings.
class _PushPermissionBanner extends StatelessWidget {
  final PushPermission permission;
  final VoidCallback onEnable;
  final VoidCallback onOpenSettings;

  const _PushPermissionBanner({
    required this.permission,
    required this.onEnable,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    switch (permission) {
      case PushPermission.granted:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.notifications_active_rounded,
                    size: 20, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Push notifications are on. Pick what you want to hear about '
                  'below.',
                  style: TextStyle(
                    color: AppColors.ink2,
                    fontSize: 13.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.check_circle_rounded,
                  size: 22, color: AppColors.accent),
            ],
          ),
        );

      case PushPermission.blocked:
        return _ActionBanner(
          icon: Icons.notifications_off_rounded,
          title: 'Push notifications are turned off',
          subtitle:
              'They\'re blocked in your system settings. Turn them on to get '
              'pinged about the topics below.',
          actionLabel: 'OPEN SETTINGS',
          onAction: onOpenSettings,
          filled: false,
        );

      case PushPermission.canRequest:
        return _ActionBanner(
          icon: Icons.notifications_active_rounded,
          title: 'Turn on push notifications',
          subtitle: 'Allow notifications so we can ping you about the topics '
              'you pick below.',
          actionLabel: 'ENABLE',
          onAction: onEnable,
          filled: true,
        );
    }
  }
}

/// Shared layout for the actionable variants of [_PushPermissionBanner].
/// [filled] paints the accent call-to-action treatment; otherwise it's a
/// neutral surface card.
class _ActionBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final bool filled;

  const _ActionBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final accentText = filled ? Colors.white : AppColors.ink;
    final subtitleColor = filled ? Colors.white.withAlpha(220) : AppColors.mute;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: filled ? AppColors.accent : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: filled ? null : Border.all(color: AppColors.line),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: AppColors.accent.withAlpha(70),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: filled ? Colors.white.withAlpha(38) : AppColors.bg,
                  borderRadius: BorderRadius.circular(11),
                  border:
                      filled ? null : Border.all(color: AppColors.line),
                ),
                child: Icon(icon,
                    size: 20,
                    color: filled ? Colors.white : AppColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: accentText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onAction,
            child: Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                color: filled ? Colors.white : AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    color: filled ? AppColors.accent : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: OnboardingFieldLabel(text),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.line),
              ),
              child: Icon(icon, size: 20, color: iconColor ?? AppColors.ink2),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.mute,
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _Toggle(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

/// Pill switch matching the design — accent track when on, neutral when off.
class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 50,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.accent : AppColors.muteSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
