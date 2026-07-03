import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/forum_filter.dart';
import '../shared/forum_chips.dart';
import '../shared/forum_section_label.dart';

/// Bottom sheet that names and saves the hub's filter as a shortcut.
/// Resolves to `(name, notify)` on save, null on cancel.
Future<(String, bool)?> showSaveShortcutSheet(
  BuildContext context, {
  required ForumFilter filter,
  bool notifyDefault = false,
}) {
  return showModalBottomSheet<(String, bool)>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) =>
        _SaveShortcutSheet(filter: filter, notifyDefault: notifyDefault),
  );
}

class _SaveShortcutSheet extends StatefulWidget {
  final ForumFilter filter;
  final bool notifyDefault;

  const _SaveShortcutSheet({required this.filter, required this.notifyDefault});

  @override
  State<_SaveShortcutSheet> createState() => _SaveShortcutSheetState();
}

class _SaveShortcutSheetState extends State<_SaveShortcutSheet> {
  late final TextEditingController _nameController;
  late bool _notify;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.filter.defaultShortcutName);
    _nameController.addListener(() => setState(() {}));
    _notify = widget.notifyDefault;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filter = widget.filter;
    final canSave = _nameController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.forumsSaveShortcut,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.forumsSaveShortcutSubtitle,
            style: const TextStyle(
              color: AppColors.mute,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (filter.brand != null)
                ForumTagChip(label: filter.brand!.name, showDot: true),
              if (filter.model != null)
                ForumTagChip(label: filter.model!.model, showDot: true),
              if (filter.topic != null)
                ForumTagChip(label: filter.topic!.name),
            ],
          ),
          const SizedBox(height: 18),
          ForumSectionLabel(label: l10n.forumsShortcutNameLabel),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.bgSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: TextField(
              controller: _nameController,
              maxLength: 100,
              cursorColor: AppColors.accent,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.line2, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.forumsNotifyMe,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.forumsNotifyMeSubtitle,
                      style: const TextStyle(
                        color: AppColors.mute,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _notify,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.accent,
                onChanged: (v) => setState(() => _notify = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: const BorderSide(color: AppColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.commonCancel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: canSave
                        ? () => Navigator.of(context)
                            .pop((_nameController.text.trim(), _notify))
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      disabledBackgroundColor: AppColors.line,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: AppColors.muteSoft,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.forumsSaveShortcut,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
