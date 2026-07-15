import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import 'bubble_entrance.dart';

/// The "partner is typing" bubble: three dots bouncing in a staggered wave.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BubbleEntrance(
      animate: true,
      fromRight: false,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(top: 3, bottom: 3, left: 16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 5),
                    _Dot(progress: _controller.value, index: i),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final double progress;
  final int index;

  const _Dot({required this.progress, required this.index});

  @override
  Widget build(BuildContext context) {
    // Each dot runs the same sine wave, phase-shifted by its index; only the
    // first 60% of the cycle bounces so the wave pauses between loops.
    final phase = (progress - index * 0.15) % 1.0;
    final t = (phase / 0.6).clamp(0.0, 1.0);
    final bounce = math.sin(t * math.pi);

    return Transform.translate(
      offset: Offset(0, -4 * bounce),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Color.lerp(
            AppColors.muteSoft,
            AppColors.mute,
            bounce,
          ),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
