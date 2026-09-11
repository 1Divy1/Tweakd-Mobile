import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/contest.dart';
import '../../domain/entities/map_event.dart';
import '../bloc/create_contest/cubit.dart';
import '../bloc/create_contest/state.dart';
import '../utils/map_event_error_mapper.dart';
import '../utils/map_event_formatting.dart';
import '../widgets/contests/contest_category_icon.dart';
import '../widgets/contests/organizer_sheets.dart';
import '../widgets/shared/map_event_chips.dart';

/// New contest / edit contest: category tiles, name, judging note, when
/// voting opens and closes. Pops with the saved [ContestEntity].
class CreateContestPage extends StatefulWidget {
  final MapEventEntity event;
  final ContestEntity? editing;

  const CreateContestPage({super.key, required this.event, this.editing});

  @override
  State<CreateContestPage> createState() => _CreateContestPageState();
}

class _CreateContestPageState extends State<CreateContestPage> {
  late final TextEditingController _title;
  late final TextEditingController _criteria;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.editing?.title ?? '');
    _criteria = TextEditingController(text: widget.editing?.criteria ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _criteria.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final event = widget.event;

    return BlocConsumer<CreateContestCubit, CreateContestState>(
      listenWhen: (a, b) => a.status != b.status || a.title != b.title,
      listener: (context, state) {
        if (state.status == CreateContestStatus.success && state.result != null) {
          context.pop(state.result);
          return;
        }
        if (state.status == CreateContestStatus.failure && state.error != null ||
            state.status == CreateContestStatus.ready && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(mapEventErrorMessage(l10n, state.error!)),
            behavior: SnackBarBehavior.floating,
          ));
          context.read<CreateContestCubit>().clearError();
        }
        // A category pick can pre-fill the title.
        if (_title.text != state.title) {
          _title.value = TextEditingValue(
            text: state.title,
            selection: TextSelection.collapsed(offset: state.title.length),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateContestCubit>();
        final loading = state.status == CreateContestStatus.loading;
        final submitting = state.status == CreateContestStatus.submitting;
        final locked = state.isLockedOpen;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Column(
            children: [
              _Header(
                title: state.isEditing ? l10n.contestsEditTitle : l10n.contestsCreateTitle,
                subtitle: event.title,
              ),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 26),
                        children: [
                          if (locked) ...[
                            _Note(text: l10n.contestsLockedOpenNote),
                            const SizedBox(height: 16),
                          ],
                          MapEventSectionLabel(label: l10n.contestsCategory),
                          const SizedBox(height: 8),
                          _CategoryGrid(
                            state: state,
                            enabled: !locked,
                            onPick: cubit.pickCategory,
                          ),
                          const SizedBox(height: 20),
                          MapEventSectionLabel(label: l10n.contestsName),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _title,
                            enabled: !locked,
                            maxLength: 60,
                            onChanged: cubit.setTitle,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                            decoration: _field(
                              state.isCustomCategory
                                  ? l10n.contestsNameHintCustom
                                  : l10n.contestsNameHint,
                            ),
                          ),
                          const SizedBox(height: 14),
                          MapEventSectionLabel(label: l10n.contestsCriteria),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _criteria,
                            maxLength: 300,
                            minLines: 2,
                            maxLines: 4,
                            onChanged: cubit.setCriteria,
                            style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.ink),
                            decoration: _field(l10n.contestsCriteriaHint),
                          ),
                          const SizedBox(height: 14),
                          MapEventSectionLabel(label: l10n.contestsVotingOpens),
                          const SizedBox(height: 8),
                          _Choice(
                            selected: state.opensChoice == ContestOpensChoice.now,
                            enabled: !locked,
                            label: l10n.contestsOpensNow,
                            onTap: () => cubit.setOpensChoice(ContestOpensChoice.now),
                          ),
                          _Choice(
                            selected: state.opensChoice == ContestOpensChoice.atEventStart,
                            enabled: !locked,
                            label: l10n.contestsOpensAtStart,
                            sub: MapEventFormat.deadline(context, event.startsAt),
                            onTap: () => cubit.setOpensChoice(ContestOpensChoice.atEventStart),
                          ),
                          _Choice(
                            selected: state.opensChoice == ContestOpensChoice.custom,
                            enabled: !locked,
                            label: l10n.contestsSetATime,
                            sub: state.customOpensAt == null
                                ? null
                                : MapEventFormat.deadline(context, state.customOpensAt!),
                            onTap: () => _pickOpens(context, cubit, state),
                          ),
                          const SizedBox(height: 14),
                          MapEventSectionLabel(label: l10n.contestsVotingCloses),
                          const SizedBox(height: 8),
                          _Choice(
                            // The planned close stays editable even once voting
                            // is open — it's only a label.
                            selected: state.closesAt != null,
                            enabled: true,
                            label: l10n.contestsSetATime,
                            sub: state.closesAt == null
                                ? null
                                : MapEventFormat.deadline(context, state.closesAt!),
                            onTap: () => _pickCloses(context, cubit, state),
                          ),
                          const SizedBox(height: 8),
                          _Note(text: l10n.contestsFinishEarlyNote, icon: Icons.bolt_rounded),
                        ],
                      ),
              ),
              Container(
                color: AppColors.bg,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: state.canSubmit && !submitting ? () => cubit.submit(event) : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          disabledBackgroundColor: AppColors.line,
                          disabledForegroundColor: AppColors.muteSoft,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          textStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        child: submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(state.isEditing ? l10n.contestsSaveChanges : l10n.contestsPublish),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _field(String hint) => InputDecoration(
        hintText: hint,
        counterText: '',
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  Future<void> _pickOpens(
    BuildContext context,
    CreateContestCubit cubit,
    CreateContestState state,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final picked = await pickDateTime(
      context,
      initial: state.customOpensAt ?? widget.event.startsAt,
      first: now,
      last: now.add(const Duration(days: 60)),
      helpText: l10n.contestsVotingOpens,
    );
    if (picked != null) cubit.setOpensChoice(ContestOpensChoice.custom, at: picked);
  }

  Future<void> _pickCloses(
    BuildContext context,
    CreateContestCubit cubit,
    CreateContestState state,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final event = widget.event;
    final end = event.endsAt ?? event.startsAt.add(const Duration(hours: 24));
    final picked = await pickDateTime(
      context,
      initial: state.closesAt ?? end.subtract(const Duration(hours: 1)),
      first: now,
      last: end.add(const Duration(hours: 12)),
      helpText: l10n.contestsVotingCloses,
    );
    if (picked != null) cubit.setClosesAt(picked);
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.chevron_left_rounded),
                color: AppColors.ink,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.mute),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final CreateContestState state;
  final bool enabled;
  final ValueChanged<ContestCategoryEntity> onPick;

  const _CategoryGrid({required this.state, required this.enabled, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 48,
      ),
      itemCount: state.categories.length,
      itemBuilder: (context, i) {
        final category = state.categories[i];
        final on = state.categoryId == category.id;
        final label = category.isCustom
            ? l10n.contestsCategoryCustom
            : category.label.replaceFirst(RegExp(r'^Best '), '');
        return Material(
          color: on ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: enabled ? () => onPick(category) : null,
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
                        color: on ? Colors.white : AppColors.ink,
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
                border: selected ? Border.all(color: AppColors.ink, width: 1.5) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: selected ? AppColors.ink : AppColors.line, width: 2),
                      color: selected ? AppColors.ink : Colors.transparent,
                    ),
                    child: selected
                        ? const Center(
                            child: SizedBox(
                              width: 6,
                              height: 6,
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.ink),
                        ),
                        if (sub != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            sub!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.mute),
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

class _Note extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Note({required this.text, this.icon = Icons.info_outline_rounded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.mute),
          const SizedBox(width: 9),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 11.5, height: 1.45, color: AppColors.ink2)),
          ),
        ],
      ),
    );
  }
}
