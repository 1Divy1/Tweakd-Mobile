import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class FollowTabSwitcher extends StatelessWidget {
  final bool showFollowers;
  final int followersCount;
  final int followingCount;
  final ValueChanged<bool> onTabChanged;

  const FollowTabSwitcher({
    super.key,
    required this.showFollowers,
    required this.followersCount,
    required this.followingCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FollowTab(
              label: 'FOLLOWERS',
              count: followersCount,
              isActive: showFollowers,
              onTap: () => onTabChanged(true),
            ),
          ),
          Expanded(
            child: _FollowTab(
              label: 'FOLLOWING',
              count: followingCount,
              isActive: !showFollowers,
              onTap: () => onTabChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _FollowTab({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.mute,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(width: 8),
            _CountChip(count: count, isActive: isActive),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final int count;
  final bool isActive;

  const _CountChip({required this.count, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF222222) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isActive ? null : Border.all(color: AppColors.line),
      ),
      child: Text(
        _formatCount(count),
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.mute,
          fontSize: 11,
          fontWeight: FontWeight.w700,
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
