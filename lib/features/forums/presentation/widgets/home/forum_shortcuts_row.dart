import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/forum_shortcut.dart';
import '../shared/forum_section_label.dart';

/// The horizontal "YOUR SHORTCUTS" row. Edit mode turns the cards
/// reorderable (drag) and deletable (x).
class ForumShortcutsRow extends StatelessWidget {
  final List<ForumShortcutEntity> shortcuts;
  final bool isEditing;
  final VoidCallback onToggleEditing;
  final ValueChanged<ForumShortcutEntity> onOpen;
  final ValueChanged<ForumShortcutEntity> onRemove;
  final void Function(int oldIndex, int newIndex) onMove;

  const ForumShortcutsRow({
    super.key,
    required this.shortcuts,
    required this.isEditing,
    required this.onToggleEditing,
    required this.onOpen,
    required this.onRemove,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ForumSectionLabel(label: l10n.forumsYourShortcuts),
              const Spacer(),
              GestureDetector(
                onTap: onToggleEditing,
                child: Text(
                  isEditing ? l10n.forumsDoneEditing : l10n.forumsEditShortcuts,
                  style: TextStyle(
                    color: isEditing ? AppColors.accent : AppColors.mute,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 92,
          child: isEditing
              ? ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  buildDefaultDragHandles: false,
                  itemCount: shortcuts.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;
                    onMove(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final shortcut = shortcuts[index];
                    return ReorderableDragStartListener(
                      key: ValueKey(shortcut.id),
                      index: index,
                      child: _ShortcutCard(
                        shortcut: shortcut,
                        isEditing: true,
                        onTap: () {},
                        onRemove: () => onRemove(shortcut),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: shortcuts.length,
                  itemBuilder: (context, index) {
                    final shortcut = shortcuts[index];
                    return _ShortcutCard(
                      shortcut: shortcut,
                      isEditing: false,
                      onTap: () => onOpen(shortcut),
                      onRemove: null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final ForumShortcutEntity shortcut;
  final bool isEditing;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _ShortcutCard({
    required this.shortcut,
    required this.isEditing,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final filterParts = [
      shortcut.brand?.name,
      shortcut.model?.model,
      shortcut.topic?.name,
    ].whereType<String>().join(' · ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.drag_indicator,
                  size: 16,
                  color: isEditing ? AppColors.ink2 : AppColors.muteSoft,
                ),
                const Spacer(),
                if (isEditing && onRemove != null)
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.bgSoft,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 13,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              shortcut.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    filterParts,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.mute,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
