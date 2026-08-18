import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';

enum AppBottomNavTab { feed, map, forums, feedback, search, profile }

class AppBottomNav extends StatelessWidget {
  final AppBottomNavTab activeTab;

  const AppBottomNav({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              isActive: activeTab == AppBottomNavTab.feed,
              onTap: () {
                if (activeTab != AppBottomNavTab.feed) context.go('/feed');
              },
            ),
            _NavItem(
              icon: Icons.map_rounded,
              isActive: activeTab == AppBottomNavTab.map,
              onTap: () {
                // Map takes fullscreen, so it's pushed into the existing navigation stack
                if (activeTab != AppBottomNavTab.map) context.push('/map');
              },
            ),
            _NavItem(
              icon: Icons.forum_rounded,
              isActive: activeTab == AppBottomNavTab.forums,
              onTap: () {
                if (activeTab != AppBottomNavTab.forums) {
                  context.go('/forums');
                }
              },
            ),
            _NavItem(
              icon: Icons.campaign_outlined,
              isActive: activeTab == AppBottomNavTab.feedback,
              onTap: () {
                if (activeTab != AppBottomNavTab.feedback) {
                  context.go('/feedback-feed');
                }
              },
            ),
            _NavItem(
              icon: Icons.search,
              isActive: activeTab == AppBottomNavTab.search,
              onTap: () {
                if (activeTab != AppBottomNavTab.search) context.go('/search');
              },
            ),
            _NavItem(
              icon: Icons.person_outline,
              isActive: activeTab == AppBottomNavTab.profile,
              onTap: () {
                if (activeTab != AppBottomNavTab.profile)
                  context.go('/profile');
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
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.ink : AppColors.muteSoft;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        // Tight horizontal padding so six tabs still fit on a small phone.
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Container(
              width: 18,
              height: 3,
              decoration: BoxDecoration(
                color: isActive ? AppColors.ink : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
