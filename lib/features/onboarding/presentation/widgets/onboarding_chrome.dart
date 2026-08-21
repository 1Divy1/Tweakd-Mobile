import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/tweakd_wordmark.dart';
import '../../../../l10n/app_localizations.dart';

const onboardingStepCount = 4;

// ── Top bar ─────────────────────────────────────────────────────────────────

/// Onboarding top bar: the centered `Tweakd.` wordmark. There's no back
/// affordance here by design — once onboarding starts, forward is the only
/// direction (the bottom bar's BACK button still lets you fix an earlier
/// step, but there's no exit route back to signup).
class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Center(child: TweakdWordmark(height: 19)),
    );
  }
}

// ── Step progress ───────────────────────────────────────────────────────────

/// Slim fluid progress bar. Signup (email/password or social auth) already
/// counts as the first of five total steps, so the bar starts pre-filled at
/// 20% on the first onboarding screen and grows by one fifth on every forward
/// navigation.
class OnboardingStepProgress extends StatelessWidget {
  final int step;

  const OnboardingStepProgress({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final fraction = (step + 1) / (onboardingStepCount + 1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
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

// ── Bottom bar ────────────────────────────────────────────────────────────

/// Sticky bottom navigation. Shows BACK once past the first step and a primary
/// action that reads NEXT until the final step, where it becomes the submit
/// CTA and reflects the in-flight submission label.
class OnboardingBottomBar extends StatelessWidget {
  final int step;
  final bool isSubmitting;
  final String? submitLabel;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  /// Label for the primary action on the final step. Defaults to the localized
  /// "FINISH SETUP" when null.
  final String? lastLabel;

  const OnboardingBottomBar({
    super.key,
    required this.step,
    this.isSubmitting = false,
    this.submitLabel,
    this.onBack,
    this.onNext,
    this.lastLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLast = step == onboardingStepCount - 1;
    final showBack = onBack != null && !isSubmitting;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
      color: AppColors.bg,
      child: Row(
        children: [
          if (showBack) ...[
            Expanded(
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_back_rounded,
                          size: 18, color: AppColors.ink),
                      const SizedBox(width: 8),
                      Text(
                        l10n.onboardingBack,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: isSubmitting ? null : onNext,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: isSubmitting ? AppColors.muteSoft : AppColors.accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: isSubmitting
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              submitLabel ?? l10n.onboardingWorking,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLast
                                  ? (lastLabel ?? l10n.onboardingFinishSetup)
                                  : l10n.onboardingNext,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 18, color: Colors.white),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
