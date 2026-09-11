import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/presentation/widgets/car_image.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/contest.dart';
import '../../utils/contest_formatting.dart';
import '../../utils/map_event_formatting.dart';

/// "Finish now?" — who wins if the organizer stops here, and how close it is.
/// Returns true to finish.
Future<bool> showFinishContestSheet(
  BuildContext context, {
  required ContestEntity contest,
  required DateTime now,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _FinishSheet(contest: contest, now: now),
  );
  return result ?? false;
}

class _FinishSheet extends StatelessWidget {
  final ContestEntity contest;
  final DateTime now;

  const _FinishSheet({required this.contest, required this.now});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = contest.entries;
    final lead = entries.isEmpty ? null : entries.first;
    final hasVotes = (lead?.votesCount ?? 0) > 0;
    final gap = lead == null
        ? 0
        : lead.votesCount - (entries.length > 1 ? entries[1].votesCount : 0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetTitle(title: l10n.contestsFinishTitle(contest.title)),
            const SizedBox(height: 12),
            Text(
              !hasVotes
                  ? l10n.contestsFinishBodyNoVotes
                  : contest.hasPlannedTimeLeft(now)
                      ? l10n.contestsFinishBody(
                          ContestFormat.timeLeft(l10n, contest.timeLeft(now)),
                        )
                      : l10n.contestsFinishBodyPastPlan,
              style: const TextStyle(fontSize: 13, height: 1.55, color: AppColors.ink2),
            ),
            if (lead != null && hasVotes) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.contestsWinsIfFinishNow,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.mute,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CarImage(
                          imageUrl: lead.car.coverImage?.url,
                          width: 46,
                          height: 46,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${lead.car.brand} ${lead.car.model}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  if (lead.car.ownerUsername != null) '@${lead.car.ownerUsername}',
                                  l10n.contestsVotesOf(lead.votesCount, contest.votesCount),
                                ].join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.mute),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: gap <= 3
                            ? AppColors.accentSoft.withValues(alpha: 0.5)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            gap <= 3 ? Icons.bolt_rounded : Icons.check_rounded,
                            size: 14,
                            color: gap <= 3 ? AppColors.accent : AppColors.mute,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              gap <= 3 ? l10n.contestsCloseRace(gap) : l10n.contestsClearLead(gap),
                              style: const TextStyle(
                                fontSize: 11.5,
                                height: 1.4,
                                color: AppColors.ink2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: l10n.contestsKeepOpen,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 13,
                  child: _SheetButton(
                    label: l10n.contestsFinishPublish,
                    accent: true,
                    onTap: () => Navigator.of(context).pop(true),
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

/// "Extend voting": a date-time picker bounded to the future. Returns the new
/// *planned* closing time, or null — voting itself runs until the organizer
/// finishes the contest.
Future<DateTime?> showExtendContestSheet(
  BuildContext context, {
  required ContestEntity contest,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final now = DateTime.now();
  final initial = contest.closesAt.isAfter(now)
      ? contest.closesAt.add(const Duration(minutes: 30))
      : now.add(const Duration(minutes: 30));
  final picked = await pickDateTime(
    context,
    initial: initial,
    first: now,
    last: now.add(const Duration(days: 7)),
    helpText: l10n.contestsExtendTitle,
  );
  if (picked == null || !context.mounted) return null;
  if (!picked.isAfter(now.add(const Duration(minutes: 4)))) return null;
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetTitle(title: l10n.contestsExtendTitle),
            const SizedBox(height: 10),
            Text(
              l10n.contestsExtendBody,
              style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.ink2),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.contestsExtendClosesAt(MapEventFormat.deadline(sheetContext, picked)),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _SheetButton(
              label: l10n.contestsExtendConfirm,
              accent: true,
              onTap: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed == true ? picked : null;
}

/// "Decline this car?" with a required reason. Returns the reason, or null.
Future<String?> showDeclineContestEntryDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.contestsDeclineEntryTitle,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 300,
          maxLines: 3,
          minLines: 2,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: l10n.contestsDeclineEntryHint,
            filled: true,
            fillColor: AppColors.bg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.contestsKeepOpen),
          ),
          FilledButton(
            onPressed: controller.text.trim().isEmpty
                ? null
                : () => Navigator.of(dialogContext).pop(controller.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
            child: Text(l10n.contestsDecline),
          ),
        ],
      ),
    ),
  ).whenComplete(controller.dispose);
}

/// "Delete this contest?" Returns true to delete.
Future<bool> showDeleteContestDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        l10n.contestsDeleteTitle,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink),
      ),
      content: Text(
        l10n.contestsDeleteBody,
        style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.ink2),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.contestsKeepOpen),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.accentHot),
          child: Text(l10n.contestsDelete),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Date then time, with the app's pickers. Null if either is dismissed.
Future<DateTime?> pickDateTime(
  BuildContext context, {
  required DateTime initial,
  required DateTime first,
  required DateTime last,
  String? helpText,
}) async {
  final date = await showDatePicker(
    context: context,
    initialDate: initial.isBefore(first) ? first : initial,
    firstDate: DateTime(first.year, first.month, first.day),
    lastDate: last,
    helpText: helpText,
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
    helpText: helpText,
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

class _SheetTitle extends StatelessWidget {
  final String title;

  const _SheetTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, size: 18),
          color: AppColors.ink,
          style: IconButton.styleFrom(backgroundColor: AppColors.bg),
        ),
      ],
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final bool accent;
  final VoidCallback onTap;

  const _SheetButton({required this.label, this.accent = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: accent ? AppColors.accent : AppColors.bg,
          foregroundColor: accent ? Colors.white : AppColors.ink,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.7),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
