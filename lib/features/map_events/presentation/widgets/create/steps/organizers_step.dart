import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/create_event/bloc.dart';
import '../../../bloc/create_event/event.dart';
import '../../../bloc/create_event/state.dart';
import '../../shared/map_event_organizer_row.dart';
import '../create_event_chrome.dart';
import '../create_event_fields.dart';
import '../organizer_search_sheet.dart';

/// Step 2 — co-organizers.
///
/// The search itself is unchanged: [showOrganizerSearchSheet] still hits
/// `GET /map-events/organizers/search`, which returns individuals and
/// businesses merged. All that moved is the framing — the section is now a
/// screen of its own.
class OrganizersStep extends StatelessWidget {
  final CreateMapEventState state;

  const OrganizersStep({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<CreateMapEventBloc>();

    // In edit mode the event's own organizer list is authoritative; in create
    // mode there's nothing on the server yet, so only the queue.
    final existing = state.editEvent?.organizers ?? const [];
    final isEmpty = existing.isEmpty && state.pendingOrganizers.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CreateEventStepHeader(
                title: l10n.mapEventsStepOrganizersTitle,
                subtitle: l10n.mapEventsStepOrganizersSubtitle,
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: CreateEventOptionalChip(label: l10n.mapEventsOptional),
        ),
        const SizedBox(height: 16),
        for (final organizer in existing) ...[
          MapEventOrganizerRow(
            organizer: organizer,
            isSelf: organizer.isCreator,
            onRemove: organizer.isCreator
                ? null
                : () => bloc.add(RemoveEventOrganizer(organizer.id)),
          ),
          const SizedBox(height: 8),
        ],
        for (final pending in state.pendingOrganizers) ...[
          _PendingOrganizerRow(
            pending: pending,
            onRemove: () => bloc.add(
              RemoveEventOrganizer(pending.candidate.referenceId),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (isEmpty) ...[
          EventHint(l10n.mapEventsStepOrganizersEmpty),
          const SizedBox(height: 12),
        ],
        EventDashedButton(
          label: l10n.mapEventsAddOrganizer,
          icon: Icons.person_add_alt_rounded,
          onTap: () async {
            final candidate = await showOrganizerSearchSheet(context);
            if (candidate != null) bloc.add(AddEventOrganizer(candidate));
          },
        ),
      ],
    );
  }
}

class _PendingOrganizerRow extends StatelessWidget {
  final PendingOrganizer pending;
  final VoidCallback onRemove;

  const _PendingOrganizerRow({required this.pending, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final candidate = pending.candidate;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(kCreateEventRadius),
      ),
      child: Row(
        children: [
          Icon(
            candidate.isBusiness
                ? Icons.storefront_rounded
                : Icons.person_rounded,
            size: 19,
            color: AppColors.accent,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              candidate.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.mute,
            tooltip: l10n.mapEventsRemoveOrganizer,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
