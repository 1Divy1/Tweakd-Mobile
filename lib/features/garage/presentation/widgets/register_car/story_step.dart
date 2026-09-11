import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/car_status_option.dart';
import 'register_car_fields.dart';

/// Step 5 — the car's role/status, picked from a wrap of selectable pills,
/// plus an optional free-text story for the build.
class StoryStep extends StatelessWidget {
  final List<CarStatusOptionEntity> statusOptions;
  final CarStatusOptionEntity? selectedStatus;
  final TextEditingController storyCtrl;
  final ValueChanged<CarStatusOptionEntity> onSelectStatus;

  const StoryStep({
    super.key,
    required this.statusOptions,
    required this.selectedStatus,
    required this.storyCtrl,
    required this.onSelectStatus,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterSectionHeader(title: l10n.garageRegisterStoryTitle),
        const SizedBox(height: 20),
        RegisterFieldLabel(l10n.garageFieldStatus),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final option in statusOptions)
              _StatusPill(
                label: option.type.toUpperCase(),
                selected: selectedStatus?.id == option.id,
                onTap: () => onSelectStatus(option),
              ),
          ],
        ),
        const SizedBox(height: 24),
        RegisterFieldLabel(l10n.garageFieldTheStory, optional: true),
        const SizedBox(height: 8),
        RegisterFormField(
          controller: storyCtrl,
          hint: l10n.garageHintStory,
          maxLines: 5,
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(selected ? 28 : 6),
              blurRadius: selected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.ink2,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
