import 'package:flutter/material.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';

/// The optional "share usage analytics" box on the sign-up page, under the
/// required Terms box and styled like it. Unticked by default — analytics is
/// opt-in — and the whole row is the tap target, not just the 24px box.
class AnalyticsConsentCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AnalyticsConsentCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MergeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: (checked) => onChanged(checked ?? false),
                activeColor: AppColors.accent,
                side: BorderSide(color: AppColors.line),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.authAnalyticsConsent,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mute,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
