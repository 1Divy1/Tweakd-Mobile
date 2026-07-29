import 'package:flutter/material.dart';

/// One-shot entrance for a freshly arrived bubble: fade + slide-up + a
/// slight scale pop, anchored to the bubble's own side. Bubbles from the
/// initial history load pass [animate] false and render still.
class BubbleEntrance extends StatefulWidget {
  final bool animate;
  final bool fromRight;
  final Widget child;

  const BubbleEntrance({
    super.key,
    required this.animate,
    required this.fromRight,
    required this.child,
  });

  @override
  State<BubbleEntrance> createState() => _BubbleEntranceState();
}

class _BubbleEntranceState extends State<BubbleEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: widget.animate ? 0 : 1,
  );
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.6, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.35),
          end: Offset.zero,
        ).animate(_fade),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(_curve),
          alignment: widget.fromRight
              ? Alignment.bottomRight
              : Alignment.bottomLeft,
          child: widget.child,
        ),
      ),
    );
  }
}
