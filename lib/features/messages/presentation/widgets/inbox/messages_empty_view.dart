import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Empty inbox: bubble icon, title, explainer copy and the NEW MESSAGE CTA.
class MessagesEmptyView extends StatelessWidget {
  final VoidCallback onNewMessage;

  const MessagesEmptyView({super.key, required this.onNewMessage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.ink,
                size: 36,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.messagesEmptyTitle,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.messagesEmptyBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.mute,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: onNewMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
              ),
              child: Text(
                l10n.messagesNewMessage,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
