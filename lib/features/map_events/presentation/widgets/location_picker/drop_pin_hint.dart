import 'package:tweakd/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The instructional animation shown after the camera lands on a chosen
/// candidate and before the user has dropped their pin: a pin falling onto the
/// centre of the screen, over a pulsing target ring.
///
/// It is a **hint, not a marker** — it marks no coordinate and disappears the
/// moment a real pin exists. Its whole job is to answer "why is nothing
/// selected yet?", because the app deliberately refuses to accept the
/// candidate's own coordinate: the event's position has to be one the user
/// placed. See `MAP_EVENTS_NOTES.md` §1.7.
///
/// Sits under an [IgnorePointer] so the tap it's asking for reaches the map.
class DropPinHint extends StatefulWidget {
  const DropPinHint({super.key});

  @override
  State<DropPinHint> createState() => _DropPinHintState();
}

class _DropPinHintState extends State<DropPinHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  /// The pin's fall. Ends at 0.55 of the cycle so the pin rests on the target
  /// for the remainder — a continuously moving pin reads as decoration, while
  /// one that lands and pauses reads as an instruction.
  late final Animation<double> _fall = Tween<double>(
    begin: -26,
    end: 0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.55, curve: Curves.bounceOut),
    ),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.25, curve: Curves.easeOut),
  );

  /// The ring pulses out as the pin lands, like an impact.
  late final Animation<double> _ring = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 0.9, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: (1 - _ring.value).clamp(0.0, 1.0) * 0.55,
                    child: Container(
                      width: 26 + 54 * _ring.value,
                      height: 26 + 54 * _ring.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // The exact pixel the user is being asked to hit, and the
                  // point the candidate's coordinate was centred on.
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                    ),
                  ),

                  // Offset up by its own height so the pin's tip, not its
                  // middle, rests on the target dot.
                  Transform.translate(
                    offset: Offset(0, _fall.value - 21),
                    child: Opacity(
                      opacity: _fade.value,
                      child: Icon(
                        Icons.location_on,
                        size: 40,
                        color: AppColors.accent,
                        shadows: [
                          Shadow(
                            color: Color(0x59000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
