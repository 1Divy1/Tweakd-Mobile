import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/domain/entities/car_summary.dart';
import 'package:tweakd/features/garage/presentation/widgets/car_image.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/contest.dart';
import '../../../domain/entities/contest_enums.dart';
import '../../utils/contest_formatting.dart';
import 'contest_category_icon.dart';

/// What the enter sheet hands back: which contests to ask into and which to
/// pull out of, for one car.
class ContestEntriesDiff {
  final String carId;
  final Set<String> enter;
  final Set<String> leave;

  const ContestEntriesDiff({
    required this.carId,
    required this.enter,
    required this.leave,
  });

  bool get isEmpty => enter.isEmpty && leave.isEmpty;
}

/// "Enter your car": the viewer's accepted event car (a chooser when they
/// have several), then every unfinished contest with a checkbox. Rows lock
/// once voting is open on a contest the car is already in; pending rows say
/// they're waiting; rejected rows quote the organizer.
Future<ContestEntriesDiff?> showEnterContestsSheet(
  BuildContext context, {
  required List<ContestEntity> contests,
  required List<CarSummaryEntity> myCars,
  required DateTime now,
}) {
  return showModalBottomSheet<ContestEntriesDiff>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _EnterSheet(contests: contests, myCars: myCars, now: now),
  );
}

class _EnterSheet extends StatefulWidget {
  final List<ContestEntity> contests;
  final List<CarSummaryEntity> myCars;
  final DateTime now;

  const _EnterSheet({
    required this.contests,
    required this.myCars,
    required this.now,
  });

  @override
  State<_EnterSheet> createState() => _EnterSheetState();
}

class _EnterSheetState extends State<_EnterSheet> {
  late String _carId;
  late Set<String> _selected;

  List<ContestEntity> get _eligible =>
      [for (final c in widget.contests) if (!c.isFinished) c];

  @override
  void initState() {
    super.initState();
    _carId = widget.myCars.first.id;
    _resetSelection();
  }

  void _resetSelection() {
    _selected = {
      for (final c in _eligible)
        if (c.viewer.entryFor(_carId)?.status.isLive ?? false) c.id,
    };
  }

  /// Locked: the car is accepted and voting is already on — no pulling out.
  bool _isLocked(ContestEntity c) =>
      c.isOpen && c.viewer.entryFor(_carId)?.status == ContestEntryStatus.accepted;

  void _toggle(ContestEntity c) {
    if (_isLocked(c)) return;
    setState(() {
      if (_selected.contains(c.id)) {
        _selected.remove(c.id);
      } else {
        _selected.add(c.id);
      }
    });
  }

  ContestEntriesDiff _diff() {
    final before = {
      for (final c in _eligible)
        if (c.viewer.entryFor(_carId)?.status.isLive ?? false) c.id,
    };
    return ContestEntriesDiff(
      carId: _carId,
      enter: _selected.difference(before),
      leave: before.difference(_selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final car = widget.myCars.firstWhere((c) => c.id == _carId);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.contestsEnterTitle,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.ink,
                    style: IconButton.styleFrom(backgroundColor: AppColors.bg),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                children: [
                  _CarRow(
                    car: car,
                    subtitle: l10n.contestsApprovedForMeet,
                    onTap: widget.myCars.length > 1 ? _pickCar : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.contestsEnterHint,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.mute,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final c in _eligible) ...[
                    _ContestRow(
                      contest: c,
                      now: widget.now,
                      selected: _selected.contains(c.id),
                      locked: _isLocked(c),
                      entry: c.viewer.entryFor(_carId),
                      onTap: () => _toggle(c),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_diff()),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    backgroundColor: AppColors.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Text(
                    l10n.contestsSaveEntries,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCar() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(18),
          children: [
            for (final c in widget.myCars) ...[
              _CarRow(
                car: c,
                subtitle: '@${c.ownerUsername ?? ''}',
                onTap: () => Navigator.of(context).pop(c.id),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
    if (picked != null && picked != _carId) {
      setState(() {
        _carId = picked;
        _resetSelection();
      });
    }
  }
}

class _CarRow extends StatelessWidget {
  final CarSummaryEntity car;
  final String subtitle;
  final VoidCallback? onTap;

  const _CarRow({required this.car, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          child: Row(
            children: [
              CarImage(
                imageUrl: car.coverImage?.url,
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      [if (car.year != null) '${car.year}', car.brand, car.model]
                          .join(' '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: AppColors.mute),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.unfold_more_rounded,
                  size: 18,
                  color: AppColors.muteSoft,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContestRow extends StatelessWidget {
  final ContestEntity contest;
  final DateTime now;
  final bool selected;
  final bool locked;
  final MyContestEntryEntity? entry;
  final VoidCallback onTap;

  const _ContestRow({
    required this.contest,
    required this.now,
    required this.selected,
    required this.locked,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = entry?.status;
    final subtitle = locked
        ? l10n.contestsEntryLocked
        : status == ContestEntryStatus.pending && selected
            ? l10n.contestsEntryPending
            : status == ContestEntryStatus.rejected && !selected
                ? l10n.contestsEntryRejected
                : contest.isOpen
                    ? l10n.contestsVotingAlreadyOpen
                    : ContestFormat.opensIn(l10n, contest.opensIn(now));
    final reason = status == ContestEntryStatus.rejected ? entry?.rejectionReason : null;

    return Material(
      color: selected ? AppColors.accentSoft.withValues(alpha: 0.45) : AppColors.bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: locked ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: selected ? Border.all(color: AppColors.accent, width: 1.5) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: ContestCategoryGlyph(
                      icon: contest.category.icon,
                      color: selected ? AppColors.accent : AppColors.mute,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          contest.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: AppColors.mute),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Opacity(
                    opacity: locked ? 0.5 : 1,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: selected ? AppColors.accent : AppColors.line,
                          width: 2,
                        ),
                        color: selected ? AppColors.accent : Colors.transparent,
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                          : null,
                    ),
                  ),
                ],
              ),
              if (reason != null && reason.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.contestsWhy,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mute,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.ink2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
