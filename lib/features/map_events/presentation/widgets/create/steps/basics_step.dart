import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/create_event/bloc.dart';
import '../../../bloc/create_event/event.dart';
import '../../../bloc/create_event/state.dart';
import '../../shared/map_event_chips.dart';
import '../create_event_chrome.dart';
import '../create_event_fields.dart';

/// Step 1 — title, description, category.
class BasicsStep extends StatelessWidget {
  final CreateMapEventState state;
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const BasicsStep({
    super.key,
    required this.state,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<CreateMapEventBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateEventStepHeader(
          title: l10n.mapEventsStepBasicsTitle,
          subtitle: l10n.mapEventsStepBasicsSubtitle,
        ),
        EventTextField(
          label: l10n.mapEventsFieldTitle,
          hint: l10n.mapEventsFieldTitleHint,
          controller: titleController,
          maxLength: 120,
          onChanged: (v) => bloc.add(ChangeEventTitle(v)),
        ),
        const SizedBox(height: 20),
        EventTextField(
          label: l10n.mapEventsFieldDescription,
          hint: l10n.mapEventsFieldDescriptionHint,
          controller: descriptionController,
          maxLines: 5,
          maxLength: 2000,
          onChanged: (v) => bloc.add(ChangeEventDescription(v)),
        ),
        const SizedBox(height: 24),
        _CategoryPicker(state: state),
      ],
    );
  }
}

/// Categories: the enabled ones from the backend, followed by the locked
/// `SOON` chips.
///
/// Those three are **hardcoded** (owner-confirmed): `/categories` only returns
/// what can actually be created, so the coming-soon ones have nowhere else to
/// come from.
class _CategoryPicker extends StatelessWidget {
  final CreateMapEventState state;

  const _CategoryPicker({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapEventSectionLabel(label: l10n.mapEventsFieldCategory),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in state.categories)
              _CategoryChip(
                label: category.label,
                isActive: state.categoryId == category.id,
                onTap: state.isEditing
                    // The category can't be changed after creation: it decides
                    // which extra fields the event carries, and PATCH has no
                    // category_id.
                    ? null
                    : () => context
                        .read<CreateMapEventBloc>()
                        .add(ChangeEventCategory(category.id)),
              ),
            _CategoryChip(label: l10n.mapEventsCategoryTrackDay, isLocked: true),
            _CategoryChip(
              label: l10n.mapEventsCategoryCarsAndCoffee,
              isLocked: true,
            ),
            _CategoryChip(label: l10n.mapEventsCategoryCruise, isLocked: true),
          ],
        ),
        const SizedBox(height: 10),
        EventHint(l10n.mapEventsCategoriesSoonNote),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isLocked;
  final VoidCallback? onTap;

  const _CategoryChip({
    required this.label,
    this.isActive = false,
    this.isLocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = isLocked
        ? AppColors.line2
        : (isActive ? AppColors.ink : AppColors.surface);
    final foreground = isLocked
        ? AppColors.muteSoft
        : (isActive ? AppColors.inkPanel : AppColors.ink);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(kCreateEventRadius),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(kCreateEventRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLocked
                    ? Icons.lock_outline_rounded
                    : (isActive ? Icons.check_rounded : Icons.circle_outlined),
                size: 14,
                color: foreground,
              ),
              const SizedBox(width: 7),
              // Constrained so a long category label at a large text scale
              // wraps inside the chip instead of overflowing the row.
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ),
              if (isLocked) ...[
                const SizedBox(width: 7),
                const MapEventSoonChip(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
