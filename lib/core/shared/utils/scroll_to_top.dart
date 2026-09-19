import 'package:flutter/widgets.dart';

/// Brings [controller]'s scrollable back to the top, for a tab re-tap.
///
/// From far down it first jumps to one screen below the top and animates the
/// rest: animating the whole way would build every item in between.
Future<void> scrollToTop(ScrollController controller) async {
  if (!controller.hasClients) return;
  final position = controller.position;
  if (position.pixels <= position.minScrollExtent) return;
  final screen = position.viewportDimension;
  if (position.pixels > screen) controller.jumpTo(screen);
  await controller.animateTo(
    0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
  );
}
