import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/car_status_option.dart';
import 'register_car_fields.dart';

/// Step 4 — the car's role/status, picked from a wrap of selectable pills.
class StoryStep extends StatelessWidget {
  final List<CarStatusOptionEntity> statusOptions;
  final CarStatusOptionEntity? selectedStatus;
  final ValueChanged<CarStatusOptionEntity> onSelectStatus;

  const StoryStep({
    super.key,
    required this.statusOptions,
    required this.selectedStatus,
    required this.onSelectStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RegisterSectionHeader(
          label: '04 — STORY',
          title: "What's this machine's role?",
        ),
        const SizedBox(height: 20),
        const RegisterFieldLabel('STATUS'),
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
        const _StatusHint(),
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
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.line,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
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

class _StatusHint extends StatelessWidget {
  const _StatusHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Your status shapes how the build appears on the grid and who '
              "it's surfaced to. Pick the one that fits best.",
              style: TextStyle(
                color: AppColors.accentHot,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
