import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/shared/layout/app_layout.dart';

/// Inbox header: back button, letterspaced "MESSAGES" title and the compose
/// (new message) button.
class MessagesTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onCompose;

  const MessagesTopBar({
    super.key,
    required this.onBack,
    required this.onCompose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(16, 12, 16, 8) + AppLayout.inset(context),
      child: Row(
        children: [
          AppPillButton(icon: Icons.chevron_left_rounded, onTap: onBack),
          Expanded(
            child: Text(
              l10n.messagesTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          AppPillButton(icon: Icons.edit_outlined, onTap: onCompose),
        ],
      ),
    );
  }
}
