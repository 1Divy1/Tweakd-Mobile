import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'register_car_fields.dart';

const registerStepCount = 4;

// ── Step progress ─────────────────────────────────────────────────────────

/// Slim fluid progress bar, mirroring the onboarding wizard. Fills by one
/// [registerStepCount]th per forward navigation, animating between steps.
///
/// This is the whole top of the wizard: there is deliberately no close button.
/// Once you start adding a car the only thing on screen is how far you've got,
/// so the flow reads as something to finish rather than something to abandon.
/// Leaving is still possible — the edge-swipe back gesture pops the route —
/// it just isn't advertised.
class RegisterStepProgress extends StatelessWidget {
  final int step;

  const RegisterStepProgress({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final fraction = (step + 1) / registerStepCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
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

// ── Bottom bar ──────────────────────────────────────────────────────────────

/// Sticky bottom navigation. Shows BACK once past the first step and a primary
/// action that reads NEXT until the final step, where it becomes the submit
/// CTA and reflects the in-flight submission label. The bar sits flush on the
/// page background — no divider, no lift, no glow.
class RegisterBottomBar extends StatelessWidget {
  final int step;
  final bool isSubmitting;
  final String? submitLabel;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  /// Label for the primary action on the final step (e.g. 'ADD CAR' / 'SAVE').
  /// Defaults to the localized "ADD CAR" when null.
  final String? lastLabel;

  const RegisterBottomBar({
    super.key,
    required this.step,
    required this.isSubmitting,
    this.submitLabel,
    this.onBack,
    this.onNext,
    this.lastLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLast = step == registerStepCount - 1;
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
                    borderRadius: BorderRadius.circular(kRegisterRadius),
                  ),
                  child: RegisterFitted(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: AppColors.ink,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.garageRegisterBack,
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
                  borderRadius: BorderRadius.circular(kRegisterRadius),
                ),
                child: Center(
                  child: RegisterFitted(
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
                                submitLabel ?? l10n.garageRegisterWorking,
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
                                    ? (lastLabel ?? l10n.garageRegisterAddCar)
                                    : l10n.garageRegisterNext,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
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
