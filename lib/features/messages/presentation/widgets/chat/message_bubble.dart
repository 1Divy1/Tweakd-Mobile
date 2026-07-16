import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/message.dart';
import 'bubble_entrance.dart';

/// A single text bubble: white for the other user (left), ink for the
/// viewer (right). The corner toward the following message of the same
/// group is tightened for the stacked look. Soft-deleted messages render an
/// italic placeholder; long-pressing one of the viewer's own live bubbles
/// fires [onLongPress] (delete affordance).
class MessageBubble extends StatelessWidget {
  final MessageEntity message;

  /// Last bubble of its sender group — gets the small "tail" corner.
  final bool isGroupEnd;
  final bool animate;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isGroupEnd,
    required this.animate,
    this.onLongPress,
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              color: deleted
                  ? Colors.transparent
                  : mine
                      ? AppColors.ink
                      : AppColors.surface,
              borderRadius: _radius,
              border: deleted ? Border.all(color: AppColors.line) : null,
            ),
            child: Text(
              deleted ? l10n.messagesDeletedMessage : (message.text ?? ''),
              style: deleted
                  ? const TextStyle(
                      color: AppColors.mute,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    )
                  : TextStyle(
                      color: mine ? Colors.white : AppColors.ink,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
