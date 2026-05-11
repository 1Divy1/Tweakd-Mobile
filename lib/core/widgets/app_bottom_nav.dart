import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

enum AppBottomNavTab { feed, map, search, contests, profile }

class AppBottomNav extends StatelessWidget {
  final AppBottomNavTab activeTab;

  const AppBottomNav({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
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
            _NavItem(
              icon: Icons.grid_view_rounded,
              label: 'FEED',
              isActive: activeTab == AppBottomNavTab.feed,
              onTap: () {
                if (activeTab != AppBottomNavTab.feed) context.go('/feed');
              },
            ),
            _NavItem(
              icon: Icons.map_outlined,
              label: 'MAP',
              isActive: activeTab == AppBottomNavTab.map,
              onTap: () {
                // Map route to be implemented later.
              },
            ),
            _NavItem(
              icon: Icons.search,
              label: 'SEARCH',
              isActive: activeTab == AppBottomNavTab.search,
              onTap: () {
                if (activeTab != AppBottomNavTab.search) context.go('/search');
              },
            ),
            _NavItem(
              icon: Icons.emoji_events_outlined,
              label: 'CONTESTS',
              isActive: activeTab == AppBottomNavTab.contests,
              onTap: () {
                // Contests route to be implemented later.
              },
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'PROFILE',
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
