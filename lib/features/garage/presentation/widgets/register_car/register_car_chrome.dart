import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'register_car_fields.dart';
import '../../../../../core/shared/layout/app_layout.dart';

const registerStepCount = 4;

// ── Step progress ─────────────────────────────────────────────────────────

/// Slim fluid progress bar, mirroring the onboarding wizard. Fills by one
/// [registerStepCount]th per forward navigation, animating between steps.
///
/// Pass [onBack] to lead the bar with a back button (the add-car wizard); the
/// add-modification flow has its own close button above it instead.
class RegisterStepProgress extends StatelessWidget {
  final int step;

  /// Leaves the flow. Stepping back within it is the bottom bar's job.
  final VoidCallback? onBack;

  /// How many steps the bar is divided into. The add-car wizard's own count by
  /// default; the add-modification flow passes its shorter one.
  final int stepCount;

  const RegisterStepProgress({
    super.key,
    required this.step,
    this.stepCount = registerStepCount,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (step + 1) / stepCount;
    final bar = ClipRRect(
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
      );

    final back = onBack;
    return Padding(
      padding: EdgeInsets.fromLTRB(back == null ? 20 : 12, back == null ? 18 : 8, 20, 12) +
          AppLayout.inset(context, maxWidth: AppLayout.formWidth),
      child: back == null
          ? bar
          : Row(
              children: [
                Semantics(
                  button: true,
                  label: MaterialLocalizations.of(context).backButtonTooltip,
                  child: AppPillButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: back,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: bar),
              ],
            ),
    );
  }
}

// ── Close ───────────────────────────────────────────────────────────────────

/// The square "×" the build-log editor and the add-modification flow open
/// with. The add-car wizard leads with a back button instead.
class RegisterCloseButton extends StatelessWidget {
  final VoidCallback? onTap;

  const RegisterCloseButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: MaterialLocalizations.of(context).closeButtonLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(kRegisterRadius),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 20,
            color: AppColors.ink,
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

  /// How many steps the flow has, so the bar knows when it is on the last one.
  final int stepCount;

  const RegisterBottomBar({
    super.key,
    required this.step,
    required this.isSubmitting,
    this.submitLabel,
    this.onBack,
    this.onNext,
    this.lastLabel,
    this.stepCount = registerStepCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLast = step == stepCount - 1;
    final showBack = onBack != null && !isSubmitting;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26) +
          AppLayout.inset(context, maxWidth: AppLayout.formWidth),
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
                        Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: AppColors.ink,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.garageRegisterBack,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
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
