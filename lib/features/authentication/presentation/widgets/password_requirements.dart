import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../utils/password_policy.dart';

/// Live checklist under a password field: one line per rule, ticking green as
/// the user types. Showing the rules up front (rather than only on submit) is
/// what keeps people from bouncing off a rejected password.
class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final rule in PasswordRule.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _RuleRow(
              label: _labelFor(l10n, rule),
              met: PasswordPolicy.isRuleMet(rule, password),
            ),
          ),
      ],
    );
  }

  String _labelFor(AppLocalizations l10n, PasswordRule rule) =>
      switch (rule) {
        PasswordRule.minLength => l10n.authPasswordRuleLength(
          kPasswordMinLength,
        ),
        PasswordRule.lowercase => l10n.authPasswordRuleLowercase,
        PasswordRule.uppercase => l10n.authPasswordRuleUppercase,
        PasswordRule.digit => l10n.authPasswordRuleDigit,
        PasswordRule.symbol => l10n.authPasswordRuleSymbol,
      };
}

class _RuleRow extends StatelessWidget {
  final String label;
  final bool met;

  const _RuleRow({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 16,
          color: met ? AppColors.accent : AppColors.muteSoft,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
              color: met ? AppColors.ink2 : AppColors.mute,
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
