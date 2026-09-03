import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// What the "+" in the own-profile top bar can start.
enum CreateAction { post, carEvent }

/// The chooser behind the "+" button. A chooser rather than a jump straight
/// into the composer: there are two things to create, and adding a third later
/// shouldn't move what the button does.
///
/// Resolves to the tapped [CreateAction], or `null` if dismissed.
Future<CreateAction?> showCreatePickerSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<CreateAction>(
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
          _OptionRow(
            icon: Icons.add_photo_alternate_outlined,
            label: l10n.profileCreatePost,
            subtitle: l10n.profileCreatePostHint,
            onTap: () => Navigator.of(sheetContext).pop(CreateAction.post),
          ),
          _OptionRow(
            icon: Icons.event_outlined,
            label: l10n.profileCreateEvent,
            subtitle: l10n.profileCreateEventHint,
            onTap: () => Navigator.of(sheetContext).pop(CreateAction.carEvent),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.bg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.ink, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.mute,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
