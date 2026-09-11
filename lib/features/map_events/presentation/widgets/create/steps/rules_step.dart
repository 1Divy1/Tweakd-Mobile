import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/create_event/bloc.dart';
import '../../../bloc/create_event/event.dart';
import '../../../bloc/create_event/state.dart';
import '../../shared/map_event_chips.dart';
import '../create_event_chrome.dart';
import '../create_event_fields.dart';

/// Step 4 — house rules, capacity, and whether entries are vetted.
class RulesStep extends StatelessWidget {
  final CreateMapEventState state;
  final TextEditingController capacityController;

  /// One controller per rule row, kept aligned with the bloc's list by index.
  final List<TextEditingController> ruleControllers;

  const RulesStep({
    super.key,
    required this.state,
    required this.capacityController,
    required this.ruleControllers,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateEventStepHeader(
          title: l10n.mapEventsStepRulesTitle,
          subtitle: l10n.mapEventsStepRulesSubtitle,
        ),
        _RulesSection(state: state, controllers: ruleControllers),
        const SizedBox(height: 26),
        EventTextField(
          label: l10n.mapEventsFieldCapacity,
          hint: l10n.mapEventsCapacityHint,
          controller: capacityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 5,
          onChanged: (v) => context
              .read<CreateMapEventBloc>()
              .add(ChangeEventCapacity(int.tryParse(v))),
        ),
        const SizedBox(height: 22),
        EventToggleCard(
          title: l10n.mapEventsApprovalToggleTitle,
          body: l10n.mapEventsApprovalToggleBody,
          value: state.requiresApproval,
          onChanged: (v) =>
              context.read<CreateMapEventBloc>().add(ToggleEventApproval(v)),
        ),
      ],
    );
  }
}

class _RulesSection extends StatelessWidget {
  final CreateMapEventState state;
  final List<TextEditingController> controllers;

  const _RulesSection({required this.state, required this.controllers});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<CreateMapEventBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: MapEventSectionLabel(label: l10n.mapEventsFieldRules),
            ),
            const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < state.rules.length; i++)
          if (i < controllers.length)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controllers[i],
                      onChanged: (v) => bloc.add(ChangeEventRule(i, v)),
                      maxLength: CreateMapEventBloc.maxRuleLength,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppColors.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.mapEventsRuleHint,
                        hintStyle: const TextStyle(
                          fontSize: 14.5,
                          color: AppColors.muteSoft,
                        ),
                        counterText: '',
                        prefixIcon: SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.mute,
                              ),
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(kCreateEventRadius),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(kCreateEventRadius),
                          borderSide: const BorderSide(color: AppColors.accent),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => bloc.add(RemoveEventRule(i)),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.mute,
                    tooltip: l10n.mapEventsRemoveRule,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
        if (state.rules.length < CreateMapEventBloc.maxRules)
          EventDashedButton(
            label: l10n.mapEventsAddRule,
            icon: Icons.add_rounded,
            onTap: () => bloc.add(const AddEventRule()),
          ),
      ],
    );
  }
}
