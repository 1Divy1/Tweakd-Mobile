import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

/// The green strip above the board that opens the completed-requests screen.
class CompletedRequestsBanner extends StatelessWidget {
  final VoidCallback onTap;

  const CompletedRequestsBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F3EC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.feedbackFeedCompletedLink,
                  style: const TextStyle(
                    color: Color(0xFF2E7D5B),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF2E7D5B),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
