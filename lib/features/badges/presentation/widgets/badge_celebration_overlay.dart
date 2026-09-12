import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_badge.dart';
import '../bloc/celebration/cubit.dart';
import '../bloc/celebration/state.dart';
import 'badge_art.dart';

/// Wraps the whole app (mounted in `MaterialApp.router`'s `builder`) and, when
/// [BadgeCelebrationCubit] has something queued, takes the screen over with a
/// full-bleed white Duolingo-style unlock celebration — an opaque surface that
/// fully hides whatever page was underneath. One badge at a time; tapping
/// *Continue* acknowledges it and advances the queue.
class BadgeCelebrationOverlay extends StatelessWidget {
  final Widget child;

  const BadgeCelebrationOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        BlocBuilder<BadgeCelebrationCubit, BadgeCelebrationState>(
          builder: (context, state) {
            final current = state.current;
            if (current == null) return const SizedBox.shrink();
            return Positioned.fill(
              child: _CelebrationView(
                // A fresh key per badge restarts the entrance animation as the
                // queue advances.
                key: ValueKey(current.badge.id),
                userBadge: current,
                onDismiss: () =>
                    context.read<BadgeCelebrationCubit>().dismissCurrent(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CelebrationView extends StatefulWidget {
  final UserBadgeEntity userBadge;
  final VoidCallback onDismiss;

  const _CelebrationView({
    super.key,
    required this.userBadge,
    required this.onDismiss,
  });

  @override
  State<_CelebrationView> createState() => _CelebrationViewState();
}

class _CelebrationViewState extends State<_CelebrationView>
    with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
    reverseDuration: const Duration(milliseconds: 220),
  );
  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  // Shoots up to the biggest pop, then a decaying bounce — each rebound
  // overshoots less than the last — before settling at rest (1.0). Three
  // rebounds, tuned to read clearly at this size.
  late final Animation<double> _badgeScale =
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem(
          tween: Tween(
            begin: 0.0,
            end: 1.28,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 22,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 1.28,
            end: 0.86,
          ).chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 16,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 0.86,
            end: 1.14,
          ).chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 14,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 1.14,
            end: 0.94,
          ).chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 12,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 0.94,
            end: 1.06,
          ).chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 10,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 1.06,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 10,
        ),
      ]).animate(_entry);
  late final Animation<double> _contentFade = CurvedAnimation(
    parent: _entry,
    curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
  );

  late final List<_Particle> _particles = _buildParticles(
    widget.userBadge.badge.id.hashCode,
  );

  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _entry.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      _confetti.forward();
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_closing) return;
    setState(() => _closing = true);
    try {
      await _entry.reverse();
    } catch (_) {
      // Controller disposed mid-reverse — nothing to do, the overlay is gone.
    }
    if (mounted) widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final badge = widget.userBadge.badge;
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final badgeSize = (shortestSide * 0.58).clamp(180.0, 300.0);

    return PopScope(
      // The celebration is modal: it dismisses only through Continue, so a
      // system back gesture must not tear the page underneath out from under
      // it.
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        // The takeover's ground is AppColors.surface, so the status bar icons
        // have to flip with it just like AppTheme's app bar does — dark icons
        // over the light-mode white surface, light icons over the dark-mode
        // near-black one.
        value: AppColors.isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Material(
          type: MaterialType.transparency,
          child: AnimatedBuilder(
            animation: Listenable.merge([_entry, _confetti]),
            builder: (context, _) {
              return Opacity(
                // Whole screen (white ground included) fades out over the
                // reverse; on the way in it is a hard cut, like a route push
                // with no transition — the elastic badge and confetti carry
                // the motion.
                opacity: _closing ? _entry.value.clamp(0.0, 1.0) : 1.0,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ColoredBox(color: AppColors.surface),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _ConfettiPainter(
                            t: _confetti.value,
                            particles: _particles,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: SafeArea(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.fromLTRB(
                                        24,
                                        24,
                                        24,
                                        12,
                                      ),
                                      child: _Reward(
                                        badgeSize: badgeSize,
                                        scale: _badgeScale.value,
                                        contentOpacity: _contentFade.value,
                                        headline: l10n.badgeCelebrationHeadline,
                                        title: badge.title,
                                        description: badge.description,
                                        art: BadgeArt(
                                          badge: badge,
                                          size: badgeSize,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    4,
                                    24,
                                    20,
                                  ),
                                  child: Opacity(
                                    opacity: _contentFade.value.clamp(0.0, 1.0),
                                    child: _ContinueButton(
                                      label: l10n.commonContinue,
                                      onPressed: _dismiss,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static List<_Particle> _buildParticles(int seed) {
    final rnd = math.Random(seed);
    // Saturated flecks only — anything pale washes out on the white ground.
    final palette = <Color>[
      AppColors.accent,
      AppColors.accentHot,
      Color(0xFFFFC93C),
      Color(0xFF3CCF91),
      Color(0xFF4DA3FF),
      Color(0xFF9B5DE5),
    ];
    return List.generate(44, (_) {
      return _Particle(
        // Upper hemisphere: fountains up and out, then gravity brings it down.
        angle: -math.pi * (0.05 + 0.9 * rnd.nextDouble()),
        speed: 0.45 + 0.55 * rnd.nextDouble(),
        size: 7 + 9 * rnd.nextDouble(),
        color: palette[rnd.nextInt(palette.length)],
        spin: 0.5 + 2.5 * rnd.nextDouble(),
        startPhase: 0.12 * rnd.nextDouble(),
        rect: rnd.nextBool(),
      );
    });
  }
}

class _Reward extends StatelessWidget {
  final double badgeSize;
  final double scale;
  final double contentOpacity;
  final String headline;
  final String title;
  final String? description;
  final Widget art;

  const _Reward({
    required this.badgeSize,
    required this.scale,
    required this.contentOpacity,
    required this.headline,
    required this.title,
    required this.description,
    required this.art,
  });

  @override
  Widget build(BuildContext context) {
    final desc = description?.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: contentOpacity,
          child: Text(
            headline.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(height: badgeSize * 0.18),
        Transform.scale(
          scale: scale.clamp(0.0, 1.4),
          child: SizedBox(width: badgeSize, height: badgeSize, child: art),
        ),
        SizedBox(height: badgeSize * 0.16),
        Opacity(
          opacity: contentOpacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              if (desc != null && desc.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mute,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ContinueButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        child: Text(label),
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double spin;
  final double startPhase;
  final bool rect;

  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.spin,
    required this.startPhase,
    required this.rect,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  final List<_Particle> particles;

  _ConfettiPainter({required this.t, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final origin = Offset(size.width * 0.5, size.height * 0.42);
    final reach = size.height * 0.9;

    for (final p in particles) {
      final local = ((t - p.startPhase) / (1 - p.startPhase)).clamp(0.0, 1.0);
      if (local <= 0) continue;

      final dist = p.speed * reach * local;
      final gravity = reach * local * local * 0.35;
      final pos =
          origin +
          Offset(math.cos(p.angle) * dist, math.sin(p.angle) * dist + gravity);
      final opacity = (1.0 - local).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * local * 2 * math.pi);
      if (p.rect) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.45,
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.t != t || !identical(old.particles, particles);
}
