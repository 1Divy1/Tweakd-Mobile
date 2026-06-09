import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';

class ProfileStatsRow extends StatelessWidget {
  final int followers;
  final int following;

  // TODO: Refactor this in the future to pass this data on the bloc state not through the router
  final String username;

  const ProfileStatsRow({
    super.key,
    required this.username,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'FOLLOWERS',
              username: username,
              followersCount: followers,
              followingCount: following,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'FOLLOWING',
              username: username,
              followersCount: followers,
              followingCount: following,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String username;
  final int followersCount;
  final int followingCount;

  const _StatCard({
    required this.label,
    required this.username,
    required this.followersCount,
    required this.followingCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => label == 'FOLLOWERS'
          ? context.push(
              '/followers',
              extra: {
                'username': username,
                'followersCount': followersCount,
                'followingCount': followingCount,
              },
            )
          : context.push(
              '/following',
              extra: {
                'username': username,
                'followersCount': followersCount,
                'followingCount': followingCount,
              },
            ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _formatCount(followersCount),
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.mute,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
