import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Asks the organizer why they're turning a car away.
///
/// The reason is **mandatory**: `PATCH /{id}/cars/{car_id}` 400s on a rejection
/// without one, and the owner sees it verbatim on their declined strip. So the
/// confirm button stays inert until something is typed, rather than letting the
/// request go out and come back a 400.
///
/// Returns the reason, or null when dismissed — null means "didn't decline".
Future<String?> showDeclineEntryDialog(
  BuildContext context, {
  required String carName,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _DeclineEntryDialog(carName: carName),
  );
}

class _DeclineEntryDialog extends StatefulWidget {
  final String carName;

  const _DeclineEntryDialog({required this.carName});

  @override
  State<_DeclineEntryDialog> createState() => _DeclineEntryDialogState();
}

class _DeclineEntryDialogState extends State<_DeclineEntryDialog> {
  final _reason = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Rebuilds the confirm button as the field fills, so it enables the moment
    // there's something to send.
    _reason.addListener(_onChanged);
  }

  @override
  void dispose() {
    _reason
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reason = _reason.text.trim();

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
              l10n.mapEventsDeclineTitle,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.mapEventsDeclineBody(widget.carName),
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColors.ink2,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.mapEventsDeclineReasonLabel,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.mute,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reason,
              autofocus: true,
              maxLines: 3,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: 14, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: l10n.mapEventsDeclineReasonHint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.muteSoft,
                ),
                counterText: '',
                filled: true,
                fillColor: AppColors.bgSoft,
                contentPadding: const EdgeInsets.all(12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.accent),
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
                    onPressed: reason.isEmpty
                        ? null
                        : () => Navigator.of(context).pop(reason),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      disabledBackgroundColor: AppColors.line,
                      disabledForegroundColor: AppColors.muteSoft,
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
                    child: Text(l10n.mapEventsDecline),
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
