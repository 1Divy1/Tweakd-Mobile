import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../shared/message_pill_button.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          MessagePillButton(icon: Icons.chevron_left_rounded, onTap: onBack),
          Expanded(
            child: Text(
              l10n.messagesTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
          ),
          MessagePillButton(icon: Icons.edit_outlined, onTap: onCompose),
        ],
      ),
    );
  }
}
