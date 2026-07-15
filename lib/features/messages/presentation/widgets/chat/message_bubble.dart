import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/message.dart';
import 'bubble_entrance.dart';

/// A single text bubble: white for the other user (left), ink for the
/// viewer (right). The corner toward the following message of the same
/// group is tightened for the stacked look.
class MessageBubble extends StatelessWidget {
  final MessageEntity message;

  /// Last bubble of its sender group — gets the small "tail" corner.
  final bool isGroupEnd;
  final bool animate;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isGroupEnd,
    required this.animate,
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

    return BubbleEntrance(
      animate: animate,
      fromRight: mine,
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            top: 3,
            bottom: 3,
            left: mine ? 60 : 16,
            right: mine ? 16 : 60,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            color: mine ? AppColors.ink : AppColors.surface,
            borderRadius: _radius,
          ),
          child: Text(
            message.text ?? '',
            style: TextStyle(
              color: mine ? Colors.white : AppColors.ink,
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}
