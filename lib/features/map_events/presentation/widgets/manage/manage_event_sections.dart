import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/presentation/widgets/car_image.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/map_event.dart';
import '../../../domain/entities/map_event_participant.dart';
import '../../../domain/entities/map_event_withdrawal_request.dart';
import '../../bloc/manage_event/bloc.dart';
import '../../bloc/manage_event/event.dart';
import '../../bloc/manage_event/state.dart';
import '../shared/map_event_car_card.dart';
import '../shared/map_event_chips.dart';
import '../shared/map_event_organizer_row.dart';
import 'decline_entry_dialog.dart';

/// The pending-entry queue: every car waiting on an organizer's yes or no.
class ManageEntriesSection extends StatelessWidget {
  final ManageMapEventState state;

  const ManageEntriesSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<ManageMapEventBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapEventSectionLabel(label: l10n.mapEventsManageEntries),
        const SizedBox(height: 10),
        if (state.pendingEntries.isEmpty)
          _EmptyCard(text: l10n.mapEventsNoPendingEntries)
        else
          for (final entry in state.pendingEntries) ...[
            MapEventCarCard(
              participant: entry,
              isBusy: state.busyIds.contains(entry.car.id),
              onAccept: () =>
                  bloc.add(ReviewEntry(carId: entry.car.id, accept: true)),
              // Declining needs a reason — the backend rejects the call without
              // one, and the owner is shown whatever is typed here.
              onDecline: () => _decline(context, bloc, entry),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Future<void> _decline(
    BuildContext context,
    ManageMapEventBloc bloc,
    MapEventParticipantEntity entry,
  ) async {
    final reason = await showDeclineEntryDialog(
      context,
      carName: '${entry.car.brand} ${entry.car.model}',
    );
    if (reason == null) return;
    bloc.add(ReviewEntry(carId: entry.car.id, accept: false, reason: reason));
  }
}

/// The withdrawal queue.
///
/// Grouped by owner, not by car, because that's how the backend models it: one
/// `POST /withdraw` flags all of a participant's accepted cars at once, and the
/// approve/reject endpoints are keyed by owner id.
class ManageWithdrawalsSection extends StatelessWidget {
  final ManageMapEventState state;

  const ManageWithdrawalsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapEventSectionLabel(label: l10n.mapEventsManageWithdrawals),
        const SizedBox(height: 10),
        if (state.withdrawals.isEmpty)
          _EmptyCard(text: l10n.mapEventsNoWithdrawals)
        else
          for (final request in state.withdrawals) ...[
            _WithdrawalCard(
              request: request,
              isBusy: state.busyIds.contains(request.ownerId),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _WithdrawalCard extends StatelessWidget {
  final MapEventWithdrawalRequestEntity request;
  final bool isBusy;

  const _WithdrawalCard({required this.request, required this.isBusy});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<ManageMapEventBloc>();
    final note = request.note;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '@${request.ownerUsername}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                l10n.mapEventsWithdrawalCarsCount(request.cars.length),
                style: const TextStyle(fontSize: 12, color: AppColors.mute),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final car in request.cars) ...[
            InkWell(
              onTap: () => context.push('/garage/cars/${car.id}', extra: false),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  CarImage(
                    imageUrl: car.coverImage?.url,
                    width: 58,
                    height: 42,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${car.brand} ${car.model}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 2),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.mapEventsWithdrawalNoteLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.mute,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.ink2,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isBusy
                      ? null
                      : () => bloc.add(
                            ReviewWithdrawal(
                              ownerId: request.ownerId,
                              approve: false,
                            ),
                          ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink2,
                    side: const BorderSide(color: AppColors.line),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  child: Text(l10n.mapEventsKeepThemIn),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: isBusy
                      ? null
                      : () => bloc.add(
                            ReviewWithdrawal(
                              ownerId: request.ownerId,
                              approve: true,
                            ),
                          ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  child: Text(l10n.mapEventsLetThemOut),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The organizer list, with removal. Adding happens in the edit form, which is
/// where the search sheet lives — and only the creator may do either.
class ManageOrganizersSection extends StatelessWidget {
  final ManageMapEventState state;
  final MapEventEntity event;

  const ManageOrganizersSection({
    super.key,
    required this.state,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<ManageMapEventBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapEventSectionLabel(label: l10n.mapEventsManageOrganizers),
        const SizedBox(height: 10),
        for (final organizer in event.organizers) ...[
          MapEventOrganizerRow(
            organizer: organizer,
            // The creator can't be removed, and only the creator may remove
            // anyone — the backend enforces both; this just doesn't offer it.
            onRemove: (event.viewer.isCreator && !organizer.isCreator)
                ? () => bloc.add(RemoveManagedOrganizer(organizer.id))
                : null,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Edit, cancel, finish, delete.
///
/// Edit is only offered while the event is still pending or rejected —
/// `PATCH` and `PUT /rules` are locked once the admins accept it, so an
/// always-visible button would just produce a 403.
class ManageLifecycleSection extends StatelessWidget {
  final ManageMapEventState state;
  final MapEventEntity event;

  const ManageLifecycleSection({
    super.key,
    required this.state,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<ManageMapEventBloc>();
    final isBusy = state.busyIds.contains('lifecycle');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapEventSectionLabel(label: l10n.mapEventsManageDanger),
        const SizedBox(height: 10),
        if (event.approvalStatus.isEditable)
          _ActionRow(
            icon: Icons.edit_outlined,
            label: l10n.mapEventsEditEvent,
            onTap: isBusy
                ? null
                : () async {
                    await context.push(
                      '/map-events/${event.id}/edit',
                      extra: event,
                    );
                    if (context.mounted) {
                      bloc.add(const RefreshMapEventManagement());
                    }
                  },
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              l10n.mapEventsEditLockedHint,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: AppColors.muteSoft,
              ),
            ),
          ),
        const SizedBox(height: 8),
        _ActionRow(
          icon: Icons.event_busy_outlined,
          label: l10n.mapEventsCancelEvent,
          onTap: isBusy
              ? null
              : () => _confirm(
                    context,
                    title: l10n.mapEventsConfirmCancelTitle,
                    body: l10n.mapEventsConfirmCancelBody,
                    confirmLabel: l10n.mapEventsConfirm,
                    onConfirm: () => bloc.add(
                      const RunEventLifecycleAction(
                        MapEventLifecycleAction.cancel,
                      ),
                    ),
                  ),
        ),
        const SizedBox(height: 8),
        _ActionRow(
          icon: Icons.flag_outlined,
          label: l10n.mapEventsFinishEvent,
          onTap: isBusy
              ? null
              : () => _confirm(
                    context,
                    title: l10n.mapEventsConfirmFinishTitle,
                    body: l10n.mapEventsConfirmFinishBody,
                    confirmLabel: l10n.mapEventsConfirm,
                    onConfirm: () => bloc.add(
                      const RunEventLifecycleAction(
                        MapEventLifecycleAction.finish,
                      ),
                    ),
                  ),
        ),
        // Deleting is creator-only. Anyone else gets a 403, so the row isn't
        // shown to them at all.
        if (event.viewer.isCreator) ...[
          const SizedBox(height: 8),
          _ActionRow(
            icon: Icons.delete_outline_rounded,
            label: l10n.mapEventsDeleteEvent,
            isDestructive: true,
            onTap: isBusy
                ? null
                : () => _confirm(
                      context,
                      title: l10n.mapEventsConfirmDeleteTitle,
                      body: l10n.mapEventsConfirmDeleteBody,
                      confirmLabel: l10n.mapEventsDelete,
                      isDestructive: true,
                      onConfirm: () => bloc.add(
                        const RunEventLifecycleAction(
                          MapEventLifecycleAction.delete,
                        ),
                      ),
                    ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            color: AppColors.ink2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppColors.mute),
            child: Text(l10n.mapEventsCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor:
                  isDestructive ? AppColors.accentHot : AppColors.accent,
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    if (confirmed ?? false) onConfirm();
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final tone = onTap == null
        ? AppColors.muteSoft
        : (isDestructive ? AppColors.accentHot : AppColors.ink);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: tone),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: tone,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.muteSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;

  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13.5, color: AppColors.mute),
      ),
    );
  }
}
