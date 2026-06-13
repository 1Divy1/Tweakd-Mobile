import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Display names for each wizard step, in order. Index 0..5 map to the six
/// steps; the progress bar also uses "START" / "FINISH" book-ends.
const registerStepNames = <String>[
  'IDENTITY',
  'PERFORMANCE',
  'CONFIGURATION',
  'STORY',
  'GALLERY',
  'MODS',
];

const registerStepCount = 6;

// ── Top bar ─────────────────────────────────────────────────────────────────

/// Wizard top bar: a close affordance, the brand wordmark, and a stacked
/// `NN / 06` step counter.
class RegisterTopBar extends StatelessWidget {
  final int step;
  final VoidCallback onClose;

  const RegisterTopBar({super.key, required this.step, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final current = (step + 1).toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.close_rounded,
                  size: 20, color: AppColors.ink),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'KINETIC EDGE',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 42,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  current,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const Text(
                  '/06',
                  style: TextStyle(
                    color: AppColors.muteSoft,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step progress ─────────────────────────────────────────────────────────

/// The three-up progress rail showing the previous, current and next step.
/// The previous node collapses to a "START" marker before step 0, and the
/// next node becomes a "FINISH" marker after the final step.
class RegisterStepProgress extends StatelessWidget {
  final int step;

  const RegisterStepProgress({super.key, required this.step});

  static const double _railHeight = 58;

  @override
  Widget build(BuildContext context) {
    final isFirst = step == 0;
    final isLast = step == registerStepCount - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
      child: Column(
        children: [
          SizedBox(
            height: _railHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Connector line behind the nodes: accent up to the current
                // node, neutral after it.
                Row(
                  children: [
                    const Spacer(flex: 1),
                    Expanded(
                      flex: 2,
                      child: Container(height: 3, color: AppColors.accent),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(height: 3, color: AppColors.line),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: isFirst
                            ? const _StartNode()
                            : const _DoneNode(),
                      ),
                    ),
                    Expanded(
                      child: Center(child: _CurrentNode(step: step)),
                    ),
                    Expanded(
                      child: Center(
                        child: isLast
                            ? const _FinishNode()
                            : _UpcomingNode(step: step + 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _NodeLabel(
                  text: isFirst ? 'START' : registerStepNames[step - 1],
                  active: false,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _NodeLabel(text: registerStepNames[step], active: true),
                    const SizedBox(height: 2),
                    Text(
                      'STEP ${step + 1} / $registerStepCount',
                      style: const TextStyle(
                        color: AppColors.muteSoft,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _NodeLabel(
                  text: isLast ? 'FINISH' : registerStepNames[step + 1],
                  active: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NodeLabel extends StatelessWidget {
  final String text;
  final bool active;

  const _NodeLabel({required this.text, required this.active});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: active ? AppColors.ink : AppColors.muteSoft,
        fontSize: active ? 12 : 10,
        fontWeight: active ? FontWeight.w800 : FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _CurrentNode extends StatelessWidget {
  final int step;
  const _CurrentNode({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accentSoft, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withAlpha(60),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          (step + 1).toString().padLeft(2, '0'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DoneNode extends StatelessWidget {
  const _DoneNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withAlpha(45),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
    );
  }
}

class _UpcomingNode extends StatelessWidget {
  final int step;
  const _UpcomingNode({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.line),
      ),
      child: Center(
        child: Text(
          (step + 1).toString().padLeft(2, '0'),
          style: const TextStyle(
            color: AppColors.muteSoft,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StartNode extends StatelessWidget {
  const _StartNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.muteSoft, width: 2),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.muteSoft,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _FinishNode extends StatelessWidget {
  const _FinishNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.muteSoft, width: 2),
      ),
      child: const Icon(Icons.flag_rounded, color: AppColors.muteSoft, size: 18),
    );
  }
}

// ── Bottom bar ──────────────────────────────────────────────────────────────

/// Sticky bottom navigation. Shows BACK once past the first step and a primary
/// action that reads NEXT until the final step, where it becomes the submit
/// CTA and reflects the in-flight submission label.
class RegisterBottomBar extends StatelessWidget {
  final int step;
  final bool isSubmitting;
  final String? submitLabel;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  const RegisterBottomBar({
    super.key,
    required this.step,
    required this.isSubmitting,
    this.submitLabel,
    this.onBack,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = step == registerStepCount - 1;
    final showBack = onBack != null && !isSubmitting;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: const Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
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
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded,
                          size: 18, color: AppColors.ink),
                      SizedBox(width: 8),
                      Text(
                        'BACK',
                        style: TextStyle(
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
                  boxShadow: isSubmitting
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.accent.withAlpha(70),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
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
                              submitLabel ?? 'Working…',
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
                              isLast ? 'REGISTER MACHINE' : 'NEXT',
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
