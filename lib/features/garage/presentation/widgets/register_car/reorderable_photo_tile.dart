import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import 'register_car_fields.dart';

/// Makes a photo tile draggable onto its siblings to change their order.
///
/// Flutter's built-in `ReorderableListView` is list-only, so the wizard's photo
/// collections — a 3-column gallery grid and the before/after rows — do their
/// own drag and drop: press and hold a tile, drop it on another, and the two
/// positions are reordered. The tile under the finger glows accent so the drop
/// target is never ambiguous.
///
/// [index] is the tile's position in its own collection; [onReorder] is called
/// with the dragged index and the index it was dropped on.
class ReorderablePhotoTile extends StatelessWidget {
  final int index;

  /// Set false when there is nothing to reorder (a lone photo), so the tile
  /// doesn't absorb long presses for no reason.
  final bool enabled;

  final Widget child;

  /// What follows the finger. Sized by the caller.
  final Widget feedback;

  final void Function(int oldIndex, int newIndex) onReorder;

  const ReorderablePhotoTile({
    super.key,
    required this.index,
    required this.enabled,
    required this.child,
    required this.feedback,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) => onReorder(details.data, index),
      builder: (context, candidate, _) {
        final target = AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRegisterRadius),
            boxShadow: candidate.isEmpty
                ? null
                : [
                    BoxShadow(
                      color: AppColors.accent.withAlpha(90),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
          ),
          child: child,
        );

        if (!enabled) return target;

        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(opacity: 0.9, child: feedback),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: target),
          child: target,
        );
      },
    );
  }
}

/// Moves the item at [oldIndex] to [newIndex] in [items], in place.
///
/// Shared so the gallery and the before/after rows can't drift apart on the
/// off-by-one that reordering always invites.
void reorderInPlace<T>(List<T> items, int oldIndex, int newIndex) {
  if (oldIndex == newIndex) return;
  if (oldIndex < 0 || oldIndex >= items.length) return;
  final moved = items.removeAt(oldIndex);
  items.insert(newIndex.clamp(0, items.length), moved);
}
