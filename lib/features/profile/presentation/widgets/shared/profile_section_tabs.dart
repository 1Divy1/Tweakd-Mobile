import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// The two sections a profile body can show. Posts is the default (left) tab,
/// Garage sits on the right — mirroring Instagram's posts / reels switcher.
enum ProfileSection { posts, garage }

/// The Posts | Garage tab switcher shown between the profile header and the
/// active section. Only one section is visible at a time.
class ProfileSectionTabs extends StatelessWidget {
  final ProfileSection active;
  final ValueChanged<ProfileSection> onChanged;

  const ProfileSectionTabs({
    super.key,
    required this.active,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.line),
          bottom: BorderSide(color: AppColors.line),
        ),
      ),
      child: Row(
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
        ],
      ),
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
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
