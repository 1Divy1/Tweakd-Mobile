import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Forums home header: browse button, "Forums" title, and the new-thread
/// button.
class ForumsTopBar extends StatelessWidget {
  final VoidCallback onBrowse;
  final VoidCallback onSaved;
  final VoidCallback onNewThread;

  const ForumsTopBar({
    super.key,
    required this.onBrowse,
    required this.onSaved,
    required this.onNewThread,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          AppPillButton(icon: Icons.explore_outlined, onTap: onBrowse),
          Expanded(
            child: Text(
              l10n.forumsTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          AppPillButton(
            icon: Icons.bookmark_border_rounded,
            onTap: onSaved,
          ),
          const SizedBox(width: 8),
          AppPillButton(icon: Icons.add_rounded, onTap: onNewThread),
        ],
      ),
    );
  }
}
