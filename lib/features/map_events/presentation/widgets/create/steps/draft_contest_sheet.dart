import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/contest.dart';
import '../../../bloc/create_contest/state.dart';
import '../../../bloc/create_event/state.dart';
import '../../../utils/map_event_formatting.dart';
import '../../contests/contest_category_icon.dart';
import '../../shared/map_event_chips.dart';
import '../create_event_chrome.dart';
import '../create_event_fields.dart';

/// The add/edit form for a contest that doesn't exist on the server yet.
///
/// Deliberately a sheet over the wizard rather than a route: the wizard's step
/// is page-local state, and pushing a go_router route out of the middle of it
/// would put the flow's own back stack at odds with the browser-style one.
///
/// It mirrors [CreateContestPage] field for field, but writes to a
/// [PendingContest] instead of calling the API — an event that doesn't exist
/// yet has no id to hang a contest on.
Future<PendingContest?> showDraftContestSheet(
  BuildContext context, {
  required List<ContestCategoryEntity> categories,
  required DateTime? eventStartsAt,
  required DateTime? eventEndsAt,
  PendingContest? editing,
}) {
  return showModalBottomSheet<PendingContest>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (_) => _DraftContestSheet(
      categories: categories,
      eventStartsAt: eventStartsAt,
      eventEndsAt: eventEndsAt,
      editing: editing,
    ),
  );
}

class _DraftContestSheet extends StatefulWidget {
  final List<ContestCategoryEntity> categories;
  final DateTime? eventStartsAt;
  final DateTime? eventEndsAt;
  final PendingContest? editing;

  const _DraftContestSheet({
    required this.categories,
    required this.eventStartsAt,
    required this.eventEndsAt,
    this.editing,
  });

  @override
  State<_DraftContestSheet> createState() => _DraftContestSheetState();
}

class _DraftContestSheetState extends State<_DraftContestSheet> {
  late final TextEditingController _title;
  late final TextEditingController _criteria;

  String? _categoryId;
  ContestOpensChoice _opens = ContestOpensChoice.atEventStart;
  DateTime? _customOpensAt;

  /// The planned close attendees see. Nothing acts on it — the organizer opens
  /// and closes voting by hand once the event is approved.
  DateTime? _closesAt;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    _title = TextEditingController(text: editing?.title ?? '');
    _criteria = TextEditingController(text: editing?.criteria ?? '');
    _categoryId = editing?.categoryId;
    if (editing != null) {
      _opens = editing.opensChoice;
      _customOpensAt = editing.customOpensAt;
      _closesAt = editing.closesAt;
    }
    // Seed a sensible default (an hour before the meet ends) so the form is
    // valid without a tap; the organizer moves it from the picker.
    _closesAt ??= _defaultCloses();
  }

  DateTime? _defaultCloses() {
    final end = widget.eventEndsAt ??
        widget.eventStartsAt?.add(const Duration(hours: 24));
    return end?.subtract(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _title.dispose();
    _criteria.dispose();
    super.dispose();
  }

  ContestCategoryEntity? get _category {
    for (final category in widget.categories) {
      if (category.id == _categoryId) return category;
    }
    return null;
  }

  /// Same rule as `CreateContestState.canSubmit`, so a draft can never be
  /// weaker than what the API would accept.
  bool get _canSave =>
      _categoryId != null &&
      _title.text.trim().length >= 3 &&
      (_opens != ContestOpensChoice.custom || _customOpensAt != null) &&
      _closesAt != null;

  /// Picking a predefined category pre-fills the title with its label unless
  /// the organizer already typed something of their own.
  void _pickCategory(ContestCategoryEntity category) {
    final previous = _category;
    final titleWasDefault = _title.text.isEmpty ||
        (previous != null && _title.text == previous.label);

    setState(() {
      _categoryId = category.id;
      if (titleWasDefault) {
        _title.text = category.isCustom ? '' : category.label;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final hasStart = widget.eventStartsAt != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  children: [
                    MapEventSectionLabel(
                      label: l10n.mapEventsContestCategoryLabel,
                    ),
                    const SizedBox(height: 10),
                    _CategoryGrid(
                      categories: widget.categories,
                      selectedId: _categoryId,
                      onPick: _pickCategory,
                    ),
                    const SizedBox(height: 20),
                    EventTextField(
                      label: l10n.mapEventsContestTitleLabel,
                      hint: l10n.mapEventsContestTitleHint,
                      controller: _title,
                      maxLength: 60,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 18),
                    EventTextField(
                      label: l10n.mapEventsContestCriteriaLabel,
                      labelSuffix: l10n.mapEventsOptional,
                      hint: l10n.mapEventsContestCriteriaHint,
                      controller: _criteria,
                      maxLines: 3,
                      maxLength: 300,
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 22),
                    MapEventSectionLabel(
                      label: l10n.mapEventsContestOpensLabel,
                    ),
                    const SizedBox(height: 10),
                    _Choice(
                      selected: _opens == ContestOpensChoice.atEventStart,
                      enabled: hasStart,
                      label: l10n.mapEventsContestOpensAtStart,
                      sub: hasStart
                          ? MapEventFormat.deadline(
                              context,
                              widget.eventStartsAt!,
                            )
                          : null,
                      onTap: () => setState(
                        () => _opens = ContestOpensChoice.atEventStart,
                      ),
                    ),
                    _Choice(
                      selected: _opens == ContestOpensChoice.now,
                      enabled: true,
                      label: l10n.mapEventsContestOpensNow,
                      onTap: () =>
                          setState(() => _opens = ContestOpensChoice.now),
                    ),
                    _Choice(
                      selected: _opens == ContestOpensChoice.custom,
                      enabled: true,
                      label: l10n.mapEventsContestCustomTime,
                      sub: _customOpensAt == null
                          ? null
                          : MapEventFormat.deadline(context, _customOpensAt!),
                      onTap: () => _pickCustom(isOpening: true),
                    ),
                    const SizedBox(height: 18),
                    MapEventSectionLabel(
                      label: l10n.mapEventsContestClosesLabel,
                    ),
                    const SizedBox(height: 10),
                    _Choice(
                      selected: _closesAt != null,
                      enabled: true,
                      label: l10n.mapEventsContestCustomTime,
                      sub: _closesAt == null
                          ? null
                          : MapEventFormat.deadline(context, _closesAt!),
                      onTap: () => _pickCustom(isOpening: false),
                    ),
                    const SizedBox(height: 4),
                    EventHint(l10n.mapEventsContestClosesManualNote),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _canSave ? _save : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      disabledBackgroundColor: AppColors.line2,
                      disabledForegroundColor: AppColors.muteSoft,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kCreateEventRadius),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    child: Text(l10n.mapEventsContestSave),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustom({required bool isOpening}) async {
    final now = DateTime.now();
    final seed = (isOpening ? _customOpensAt : _closesAt) ??
        widget.eventStartsAt ??
        now;
    final floor = now.isBefore(seed) ? now : seed;

    final date = await showDatePicker(
      context: context,
      initialDate: seed.isBefore(floor) ? floor : seed,
      firstDate: DateTime(floor.year, floor.month, floor.day),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(seed),
    );
    if (time == null || !mounted) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isOpening) {
        _customOpensAt = picked;
        _opens = ContestOpensChoice.custom;
      } else {
        _closesAt = picked;
      }
    });
  }

  void _save() {
    final category = _category!;
    final editing = widget.editing;

    Navigator.of(context).pop(
      PendingContest(
        // Reusing the id on an edit is what makes UpdateDraftContest able to
        // find the row it replaces.
        localId: editing?.localId ??
            'draft-${DateTime.now().microsecondsSinceEpoch}',
        categoryId: category.id,
        categoryLabel: category.label,
        title: _title.text.trim(),
        criteria: _criteria.text.trim(),
        opensChoice: _opens,
        customOpensAt: _customOpensAt,
        closesAt: _closesAt,
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<ContestCategoryEntity> categories;
  final String? selectedId;
  final ValueChanged<ContestCategoryEntity> onPick;

  const _CategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        // Tiles hold text, so their height follows the text scale rather than
        // clipping the label at larger settings.
        mainAxisExtent: MediaQuery.textScalerOf(context).scale(48).clamp(48, 84),
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final category = categories[i];
        final on = selectedId == category.id;
        final label = category.isCustom
            ? l10n.contestsCategoryCustom
            : category.label.replaceFirst(RegExp(r'^Best '), '');

        return Material(
          color: on ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => onPick(category),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  ContestCategoryGlyph(
                    icon: category.icon,
                    color: on ? AppColors.accent : AppColors.mute,
                    size: 16,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        height: 1.2,
                        color: on ? AppColors.inkPanel : AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Choice extends StatelessWidget {
  final bool selected;
  final bool enabled;
  final String label;
  final String? sub;
  final VoidCallback onTap;

  const _Choice({
    required this.selected,
    required this.enabled,
    required this.label,
    this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: selected
                    ? Border.all(color: AppColors.ink, width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.ink : AppColors.line,
                        width: 2,
                      ),
                      color: selected ? AppColors.ink : Colors.transparent,
                    ),
                    child: selected
                        ? Center(
                            child: SizedBox(
                              width: 6,
                              height: 6,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.inkPanel,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        if (sub != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            sub!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mute,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
