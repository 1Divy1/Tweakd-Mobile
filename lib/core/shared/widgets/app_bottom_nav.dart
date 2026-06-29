import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:car_social_media_app/l10n/app_localizations.dart';

import '../../theme/app_colors.dart';

enum AppBottomNavTab { feed, map, createPost, search, profile }

class AppBottomNav extends StatelessWidget {
  final AppBottomNavTab activeTab;

  const AppBottomNav({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            
            // TODO: add custom icons for the bottom nav

            _NavItem(
              icon: Icons.grid_view_rounded,
              label: l10n.navFeed,
              isActive: activeTab == AppBottomNavTab.feed,
              onTap: () {
                if (activeTab != AppBottomNavTab.feed) context.go('/feed');
              },
            ),
            _NavItem(
              icon: Icons.map_outlined,
              label: l10n.navMap,
              isActive: activeTab == AppBottomNavTab.map,
              onTap: () {
                // Map route to be implemented later.
              },
            ),
            // Center create action. Pushed (not go) over the active tab so the
            // user can leave the wizard and land back where they started.
            _CreateNavItem(
              label: l10n.navCreate,
              onTap: () => context.push('/posts/create'),
            ),
            _NavItem(
              icon: Icons.search,
              label: l10n.navSearch,
              isActive: activeTab == AppBottomNavTab.search,
              onTap: () {
                if (activeTab != AppBottomNavTab.search) context.go('/search');
              },
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: l10n.navProfile,
              isActive: activeTab == AppBottomNavTab.profile,
              onTap: () {
                if (activeTab != AppBottomNavTab.profile) context.go('/profile');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The prominent center "create post" action. Unlike the other tabs it is never
/// a persistent destination, so it has no active state — it pushes the wizard.
class _CreateNavItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CreateNavItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withAlpha(70),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 10,
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.accent : AppColors.muteSoft;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
