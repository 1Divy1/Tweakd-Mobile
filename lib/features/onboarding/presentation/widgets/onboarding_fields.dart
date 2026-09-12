import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Large title that opens every step of the onboarding wizard.
class OnboardingSectionHeader extends StatelessWidget {
  final String title;

  const OnboardingSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.ink,
        fontSize: 30,
        height: 1.05,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
    );
  }
}

/// Small uppercase field caption. An optional muted `OPTIONAL` suffix can be
/// appended inline.
class OnboardingFieldLabel extends StatelessWidget {
  final String text;
  final bool optional;

  const OnboardingFieldLabel(this.text, {super.key, this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          text,
          style: TextStyle(
            color: AppColors.ink2,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context)!.onboardingOptional,
            style: TextStyle(
              color: AppColors.muteSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}

/// Note card used at the foot of a step to explain a rule. [child] is rich
/// text so callers can emphasise inline fragments.
class OnboardingNoteCard extends StatelessWidget {
  final Widget child;

  const OnboardingNoteCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}
