import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Actions offered by a tagged item's "⋯" menu. Only untagging exists today.
enum TagMenuAction { remove }

/// Opens the tagged item options sheet. Resolves to the tapped action, or null
/// when dismissed. Only shown on your own tags feed — you can only untag
/// yourself.
Future<TagMenuAction?> showTagItemMenu(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<TagMenuAction>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => Navigator.of(sheetContext).pop(TagMenuAction.remove),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.person_remove_outlined,
                    color: AppColors.accentHot,
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    l10n.tagsRemove,
                    style: TextStyle(
                      color: AppColors.accentHot,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Confirmation for an untag. The copy spells out that this is a hard delete
/// for everyone (and takes the viewer's tagged cars with it), because the
/// action can't be undone from the app — only the author can re-tag.
Future<bool> confirmRemoveTag(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) => Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tagsRemoveTitle,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.tagsRemoveBody,
              style: TextStyle(
                color: AppColors.mute,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: l10n.commonCancel,
                    onTap: () => Navigator.of(dialogContext).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: l10n.tagsRemoveConfirm,
                    isDestructive: true,
                    onTap: () => Navigator.of(dialogContext).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed ?? false;
}

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DialogButton({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.danger : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDestructive ? AppColors.danger : AppColors.line),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDestructive ? AppColors.onDanger : AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
