import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Walks the owner through deleting a car in two steps: first what goes with
/// it, then a last "this is permanent" check. Resolves `true` only when both
/// were confirmed.
Future<bool> confirmCarDeletion(
  BuildContext context, {
  required String carTitle,
}) async {
  final proceed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const DeleteCarWarningDialog(),
  );
  if (proceed != true || !context.mounted) return false;

  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => DeleteCarFinalDialog(carTitle: carTitle),
  );
  return confirmed == true;
}

/// Step one: lists everything that is deleted along with the car.
class DeleteCarWarningDialog extends StatelessWidget {
  const DeleteCarWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final losses = [
      (Icons.photo_library_outlined, l10n.garageDeleteLosesPhotos),
      (Icons.build_outlined, l10n.garageDeleteLosesBuildLog),
      (Icons.dynamic_feed_outlined, l10n.garageDeleteLosesPosts),
      (Icons.emoji_events_outlined, l10n.garageDeleteLosesEvents),
      (Icons.link_off, l10n.garageDeleteLosesShareLink),
      (Icons.sell_outlined, l10n.garageDeleteLosesTags),
    ];

    return _DeleteDialogShell(
      title: l10n.garageDeleteMachineTitle,
      body: [
        Text(
          l10n.garageDeleteMachineBody,
          style: TextStyle(
            color: AppColors.mute,
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        for (final (icon, label) in losses)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: AppColors.danger),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
      cancelLabel: l10n.garageDialogCancel,
      confirmLabel: l10n.garageDeleteContinue,
    );
  }
}

/// Step two: the last stop before an irreversible delete.
class DeleteCarFinalDialog extends StatelessWidget {
  final String carTitle;

  const DeleteCarFinalDialog({super.key, required this.carTitle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _DeleteDialogShell(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.warning_amber_rounded,
          color: AppColors.danger,
          size: 24,
        ),
      ),
      title: l10n.garageDeleteFinalTitle(carTitle),
      body: [
        Text(
          l10n.garageDeleteFinalBody,
          style: TextStyle(
            color: AppColors.mute,
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
      cancelLabel: l10n.garageDeleteFinalKeep,
      confirmLabel: l10n.garageDeleteFinalConfirm,
    );
  }
}

/// Shared frame for both steps. The content scrolls so a long list at a large
/// text scale never overflows a short screen; the buttons stay pinned below.
class _DeleteDialogShell extends StatelessWidget {
  final Widget? leading;
  final String title;
  final List<Widget> body;
  final String cancelLabel;
  final String confirmLabel;

  const _DeleteDialogShell({
    this.leading,
    required this.title,
    required this.body,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(height: 14),
                      ],
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...body,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DeleteDialogButton(
                      label: cancelLabel,
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DeleteDialogButton(
                      label: confirmLabel,
                      isDestructive: true,
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteDialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DeleteDialogButton({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Grows with the label instead of clipping it at large text scales.
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.danger : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? AppColors.danger : AppColors.line,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDestructive ? AppColors.onDanger : AppColors.ink,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
