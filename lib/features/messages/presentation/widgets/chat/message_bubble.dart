import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/message.dart';
import 'bubble_entrance.dart';
import 'tagged_car_card.dart';

/// A single message bubble: white for the other user (left), ink for the
/// viewer (right). The corner toward the following message of the same
/// group is tightened for the stacked look. Soft-deleted messages render an
/// italic placeholder; long-pressing one of the viewer's own live bubbles
/// fires [onLongPress] (delete affordance).
///
/// A message can also carry shared cars ([MessageEntity.taggedCars]): those
/// render as tappable cards stacked above any text. A blank-text message with
/// no cars (a car share whose cars were all deleted from their garage) shows a
/// muted "shared cars" label so the bubble is never empty.
class MessageBubble extends StatelessWidget {
  final MessageEntity message;

  /// Last bubble of its sender group — gets the small "tail" corner.
  final bool isGroupEnd;
  final bool animate;
  final VoidCallback? onLongPress;
  final ValueChanged<DmTaggedCarEntity>? onCarTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isGroupEnd,
    required this.animate,
    this.onLongPress,
    this.onCarTap,
  });

  BorderRadius get _radius {
    const big = Radius.circular(22);
    const small = Radius.circular(6);
    if (message.isMine) {
      return BorderRadius.only(
        topLeft: big,
        topRight: big,
        bottomLeft: big,
        bottomRight: isGroupEnd ? small : big,
      );
    }
    return BorderRadius.only(
      topLeft: big,
      topRight: big,
      bottomLeft: isGroupEnd ? small : big,
      bottomRight: big,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    final deleted = message.isDeleted;
    final l10n = AppLocalizations.of(context)!;

    final hasCars = message.taggedCars.isNotEmpty;
    final hasText = (message.text ?? '').trim().isNotEmpty;
    // Blank text on a live message means a car share (backend never sends a
    // truly empty message). When its cars were later deleted from the garage,
    // fall back to a muted label so the bubble isn't empty.
    final isCarShare = !deleted && (hasCars || !hasText);

    return BubbleEntrance(
      animate: animate,
      fromRight: mine,
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: mine && !deleted ? onLongPress : null,
          child: Container(
            margin: EdgeInsets.only(
              top: 3,
              bottom: 3,
              left: mine ? 60 : 16,
              right: mine ? 16 : 60,
            ),
            padding: isCarShare
                ? const EdgeInsets.all(8)
                : const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              color: deleted
                  ? Colors.transparent
                  : mine
                      ? AppColors.ink
                      : AppColors.surface,
              borderRadius: _radius,
              border: deleted ? Border.all(color: AppColors.line) : null,
            ),
            child: _content(context, l10n, mine, deleted, hasCars, hasText),
          ),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    AppLocalizations l10n,
    bool mine,
    bool deleted,
    bool hasCars,
    bool hasText,
  ) {
    if (deleted) {
      return Text(
        l10n.messagesDeletedMessage,
        style: const TextStyle(
          color: AppColors.mute,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
          height: 1.35,
        ),
      );
    }

    final textStyle = TextStyle(
      color: mine ? Colors.white : AppColors.ink,
      fontSize: 15.5,
      fontWeight: FontWeight.w500,
      height: 1.35,
    );

    if (!hasCars && !hasText) {
      // Car share whose cars were all deleted from their garage.
      return Text(
        l10n.messagesSharedCars,
        style: TextStyle(
          color: mine ? Colors.white70 : AppColors.mute,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
          height: 1.35,
        ),
      );
    }

    if (!hasCars) {
      return Text(message.text!, style: textStyle);
    }

    return Column(
      crossAxisAlignment:
          mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < message.taggedCars.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          TaggedCarCard(
            car: message.taggedCars[i],
            onTap: onCarTap == null
                ? null
                : () => onCarTap!(message.taggedCars[i]),
          ),
        ],
        if (hasText)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
            child: Text(message.text!, style: textStyle),
          ),
      ],
    );
  }
}
