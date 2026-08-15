import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// The sections a profile body can show. Posts is the default (left) tab, then
/// Garage, then Tags — everything this user (or one of their cars) was tagged
/// in elsewhere — and, on your own profile only, Events.
enum ProfileSection { posts, garage, tags, events }

/// The section switcher shown between the profile header and the active
/// section. Only one section is visible at a time.
///
/// [showEvents] is false on someone else's profile: `GET /map-events/mine` is
/// scoped to the caller, so there is no such thing as another user's events
/// list to show.
class ProfileSectionTabs extends StatelessWidget {
  final ProfileSection active;
  final ValueChanged<ProfileSection> onChanged;
  final bool showEvents;

  const ProfileSectionTabs({
    super.key,
    required this.active,
    required this.onChanged,
    this.showEvents = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _Tab(
            icon: Icons.grid_on_rounded,
            label: l10n.profileTabPosts,
            isActive: active == ProfileSection.posts,
            onTap: () => onChanged(ProfileSection.posts),
          ),
        ),
        Expanded(
          child: _Tab(
            icon: Icons.garage_rounded,
            label: l10n.profileTabGarage,
            isActive: active == ProfileSection.garage,
            onTap: () => onChanged(ProfileSection.garage),
          ),
        ),
        Expanded(
          child: _Tab(
            icon: Icons.sell_rounded,
            label: l10n.profileTabTags,
            isActive: active == ProfileSection.tags,
            onTap: () => onChanged(ProfileSection.tags),
          ),
        ),
        if (showEvents)
          Expanded(
            child: _Tab(
              icon: Icons.event_rounded,
              label: l10n.profileTabEvents,
              isActive: active == ProfileSection.events,
              onTap: () => onChanged(ProfileSection.events),
            ),
          ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.ink : AppColors.muteSoft;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.ink : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            // Three tabs share the row now, so a long localized label
            // ellipsizes instead of overflowing on narrow screens.
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
