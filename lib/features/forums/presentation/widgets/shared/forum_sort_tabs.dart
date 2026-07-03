import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/forum_thread.dart';

/// The compact Hot / New / Active segmented control shown next to thread-list
/// headers.
class ForumSortTabs extends StatelessWidget {
  final ForumThreadSort active;
  final ValueChanged<ForumThreadSort> onChanged;

  const ForumSortTabs({super.key, required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.line2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: l10n.forumsSortHot,
            isActive: active == ForumThreadSort.hot,
            onTap: () => onChanged(ForumThreadSort.hot),
          ),
          _Segment(
            label: l10n.forumsSortNew,
            isActive: active == ForumThreadSort.newest,
            onTap: () => onChanged(ForumThreadSort.newest),
          ),
          _Segment(
            label: l10n.forumsSortActive,
            isActive: active == ForumThreadSort.active,
            onTap: () => onChanged(ForumThreadSort.active),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.ink : AppColors.mute,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
