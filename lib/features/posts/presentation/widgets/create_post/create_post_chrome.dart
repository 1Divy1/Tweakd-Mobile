import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import 'create_post_fields.dart';

/// Photos → caption → tags → visibility → review.
const postStepCount = 5;

// ── Top bar ─────────────────────────────────────────────────────────────────

/// The X, and the slim progress bar under it — the same top as the
/// create-event wizard, which is also opened from the create sheet.
class PostTopBar extends StatelessWidget {
  final int step;
  final VoidCallback? onClose;

  const PostTopBar({super.key, required this.step, required this.onClose});

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
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(
                    Icons.close_rounded,
                    size: 19,
                    color: onClose == null ? AppColors.muteSoft : AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
        PostStepProgress(step: step),
      ],
    );
  }
}

/// Slim fluid progress bar, mirroring onboarding and the other wizards. Fills
/// by one [postStepCount]th per step, animating between them.
class PostStepProgress extends StatelessWidget {
  final int step;

  const PostStepProgress({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final fraction = (step + 1) / postStepCount;

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
                decoration: BoxDecoration(
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

// ── Bottom bar ──────────────────────────────────────────────────────────────

/// BACK / NEXT, flush on the page background — no divider, no lift, no glow.
///
/// [blocker] is what the step is still missing. It is shown above the buttons
/// rather than greying NEXT out, so the user is never left guessing why the
/// flow won't move.
class PostBottomBar extends StatelessWidget {
  final bool canGoBack;
  final bool isLastStep;
  final bool isSubmitting;
  final String nextLabel;
  final String backLabel;
  final String? blocker;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  const PostBottomBar({
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
          constraints: const BoxConstraints(maxWidth: kPostMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (blocker != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 15,
                        color: AppColors.accentHot,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          blocker!,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: AppColors.accentHot,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(kPostRadius),
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
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
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
