import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/forum_shortcut.dart';
import '../../utils/forum_format.dart';
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
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 46,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        constraints: const BoxConstraints(minWidth: 108, maxWidth: 168),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        // One row, vertically centred: the handle and the badge sit either
        // side of the name instead of stacking above it.
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.drag_indicator,
              size: 16,
              color: isEditing ? AppColors.ink2 : AppColors.muteSoft,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  shortcut.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (!isEditing && shortcut.unreadCount > 0)
              _UnreadBadge(count: shortcut.unreadCount)
            else if (isEditing && onRemove != null)
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
                  child: Icon(
                    Icons.close,
                    size: 13,
                    color: AppColors.ink,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The unread-thread count pill on a shortcut card (new threads matching the
/// filter that the viewer hasn't opened yet).
class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: Text(
        forumCompactCount(count),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
