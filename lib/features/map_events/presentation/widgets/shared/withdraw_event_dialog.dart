import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// The withdrawal confirmation, with its optional note for the organizers.
///
/// Returns the note (possibly empty) when confirmed, or null when cancelled —
/// so a null result means "didn't withdraw", never "withdrew without a note".
///
/// The copy asks rather than announces: withdrawal is a **request** the
/// organizers review, not an immediate removal, and it can't be taken back
/// afterwards. Both facts are in the body text, because the difference matters
/// to whoever is about to tap the orange button.
Future<String?> showWithdrawEventDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _WithdrawEventDialog(),
  );
}

class _WithdrawEventDialog extends StatefulWidget {
  const _WithdrawEventDialog();

  @override
  State<_WithdrawEventDialog> createState() => _WithdrawEventDialogState();
}

class _WithdrawEventDialogState extends State<_WithdrawEventDialog> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.mapEventsWithdrawTitle,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.mapEventsWithdrawBody,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColors.ink2,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.mapEventsWithdrawNoteLabel,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: AppColors.mute,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              maxLines: 3,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: l10n.mapEventsWithdrawNoteHint,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.muteSoft,
                ),
                counterText: '',
                filled: true,
                fillColor: AppColors.bgSoft,
                contentPadding: const EdgeInsets.all(12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.bgSoft,
                      foregroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    child: Text(l10n.mapEventsCancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    // Empty string, not null: null is the dialog's "cancelled"
                    // signal, so an empty note has to be distinguishable.
                    onPressed: () =>
                        Navigator.of(context).pop(_note.text.trim()),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    child: Text(l10n.mapEventsWithdrawAction),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
