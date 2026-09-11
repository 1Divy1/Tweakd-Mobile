import 'package:tweakd/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// One corner radius across every boxy control in the wizard, matching the
/// add-car flow's `kRegisterRadius`.
const double kCreateEventRadius = 16;

/// Widest the wizard's content ever gets. Without it the steps sprawl into
/// unreadable line lengths on a tablet.
const double kCreateEventMaxWidth = 560;

// ── Top bar ─────────────────────────────────────────────────────────────────

/// The X, and the slim progress bar under it.
///
/// Unlike the add-car wizard this one keeps a close button: the event form is
/// reachable from the map's FAB, so it is genuinely a thing you drop into and
/// may want straight back out of — and its draft survives leaving, which makes
/// leaving cheap rather than destructive.
class CreateEventTopBar extends StatelessWidget {
  final int step;
  final int stepCount;
  final VoidCallback onClose;

  const CreateEventTopBar({
    super.key,
    required this.step,
    required this.stepCount,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onClose,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(
                    Icons.close_rounded,
                    size: 19,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
        CreateEventProgress(step: step, stepCount: stepCount),
      ],
    );
  }
}

/// Slim fluid progress bar, mirroring onboarding and the add-car wizard.
class CreateEventProgress extends StatelessWidget {
  final int step;
  final int stepCount;

  const CreateEventProgress({
    super.key,
    required this.step,
    required this.stepCount,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = stepCount == 0 ? 0.0 : (step + 1) / stepCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Container(
          height: 6,
          color: AppColors.line,
          child: LayoutBuilder(
            builder: (context, constraints) => Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * fraction,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step heading ────────────────────────────────────────────────────────────

/// Each step opens with its name and a line saying what it wants. With the
/// form split across screens this is the only thing telling the organizer
/// where they are.
class CreateEventStepHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const CreateEventStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 25,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            height: 1.45,
            color: AppColors.ink2,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// A step's optional badge — used by ORGANIZERS and CONTESTS, both of which
/// can be walked straight past.
class CreateEventOptionalChip extends StatelessWidget {
  final String label;

  const CreateEventOptionalChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.line2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.mute,
        ),
      ),
    );
  }
}

// ── Bottom bar ──────────────────────────────────────────────────────────────

/// BACK / NEXT, flush on the page background — no divider, no lift, no glow.
///
/// [blocker] is what the step is still missing. It is shown above the buttons
/// rather than disabling NEXT: a greyed-out button that won't say why is the
/// single most common way a form flow dead-ends.
class CreateEventBottomBar extends StatelessWidget {
  final bool canGoBack;
  final bool isLastStep;
  final bool isSubmitting;
  final String nextLabel;
  final String backLabel;
  final String? blocker;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  const CreateEventBottomBar({
    super.key,
    required this.canGoBack,
    required this.isLastStep,
    required this.isSubmitting,
    required this.nextLabel,
    required this.backLabel,
    this.blocker,
    this.onBack,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    // Buttons hold text, so their height has to follow the text scale rather
    // than sit at a fixed 56.
    final scale = MediaQuery.textScalerOf(context);
    final height = scale.scale(56).clamp(56.0, 92.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      color: AppColors.bg,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kCreateEventMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (blocker != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 15,
                        color: AppColors.accentHot,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          blocker!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: AppColors.accentHot,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Row(
                children: [
                  if (canGoBack && !isSubmitting) ...[
                    Expanded(
                      child: _BarButton(
                        height: height,
                        background: AppColors.surface,
                        foreground: AppColors.ink,
                        label: backLabel,
                        icon: Icons.arrow_back_rounded,
                        iconLeading: true,
                        onTap: onBack,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: _BarButton(
                      height: height,
                      background:
                          isSubmitting ? AppColors.muteSoft : AppColors.accent,
                      foreground: Colors.white,
                      label: nextLabel,
                      icon: isLastStep ? null : Icons.arrow_forward_rounded,
                      isBusy: isSubmitting,
                      onTap: isSubmitting ? null : onNext,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final double height;
  final Color background;
  final Color foreground;
  final String label;
  final IconData? icon;
  final bool iconLeading;
  final bool isBusy;
  final VoidCallback? onTap;

  const _BarButton({
    required this.height,
    required this.background,
    required this.foreground,
    required this.label,
    this.icon,
    this.iconLeading = false,
    this.isBusy = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: 1,
      style: TextStyle(
        color: foreground,
        fontWeight: FontWeight.w800,
        fontSize: 14,
        letterSpacing: 1,
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(kCreateEventRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          // Scales the label down rather than letting a long translation at a
          // large text scale overflow the button.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isBusy) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else if (icon != null && iconLeading) ...[
                  Icon(icon, size: 18, color: foreground),
                  const SizedBox(width: 8),
                ],
                text,
                if (!isBusy && icon != null && !iconLeading) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 18, color: foreground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
