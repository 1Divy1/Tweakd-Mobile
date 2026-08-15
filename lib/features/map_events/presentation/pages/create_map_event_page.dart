import 'dart:io';

import 'package:car_social_media_app/core/di/injection.dart';
import 'package:car_social_media_app/core/services/image_service.dart';
import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/map_event.dart';
import '../bloc/create_event/bloc.dart';
import '../bloc/create_event/event.dart';
import '../bloc/create_event/state.dart';
import '../utils/map_event_error_mapper.dart';
import '../utils/map_event_formatting.dart';
import '../widgets/create/create_event_fields.dart';
import '../widgets/create/organizer_search_sheet.dart';
import '../widgets/shared/map_event_chips.dart';
import '../widgets/shared/map_event_organizer_row.dart';
import 'pick_event_location_page.dart';

/// The "NEW EVENT" full-screen form — one long scroll with a pinned CTA — and
/// the same form in edit mode.
///
/// The text controllers live here rather than in the bloc: a `TextEditingController`
/// is presentation state (cursor, selection, IME composition), and rebuilding
/// one from bloc state on every keystroke fights the keyboard.
class CreateMapEventPage extends StatefulWidget {
  /// Set when editing an existing event. Editing is only permitted while the
  /// event is pending or rejected — the router only ever offers it then.
  final MapEventEntity? editEvent;

  const CreateMapEventPage({super.key, this.editEvent});

  @override
  State<CreateMapEventPage> createState() => _CreateMapEventPageState();
}

class _CreateMapEventPageState extends State<CreateMapEventPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _locationName = TextEditingController();
  final _capacity = TextEditingController();

  /// One controller per rule row, kept aligned with the bloc's list by index.
  final List<TextEditingController> _rules = [];

  final _imageService = getIt<ImageService>();

  /// Guards the one-time seeding of the controllers from the loaded event: the
  /// listener fires on every state change, and re-seeding would fight typing.
  bool _seeded = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _locationName.dispose();
    _capacity.dispose();
    for (final controller in _rules) {
      controller.dispose();
    }
    super.dispose();
  }

  void _seed(CreateMapEventState state) {
    if (_seeded || !state.isEditing) return;
    _seeded = true;
    _title.text = state.title;
    _description.text = state.description;
    _locationName.text = state.locationName;
    _capacity.text = state.capacity?.toString() ?? '';
    _syncRuleControllers(state.rules.length);
    for (var i = 0; i < state.rules.length; i++) {
      _rules[i].text = state.rules[i];
    }
  }

  void _syncRuleControllers(int count) {
    while (_rules.length < count) {
      _rules.add(TextEditingController());
    }
    while (_rules.length > count) {
      _rules.removeLast().dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<CreateMapEventBloc, CreateMapEventState>(
        listener: (context, state) {
          _seed(state);
          _syncRuleControllers(state.rules.length);

          final error = state.error;
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(mapEventErrorMessage(l10n, error)),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context
                .read<CreateMapEventBloc>()
                .add(const ClearCreateEventError());
          }
        },
        builder: (context, state) {
          if (state.status == CreateEventStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == CreateEventStatus.failure) {
            return _LoadFailed(state: state);
          }
          if (state.status == CreateEventStatus.success) {
            return _SubmittedView(state: state);
          }

          return SafeArea(
            child: Column(
              children: [
                _Header(isEditing: state.isEditing),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      MapEventSectionLabel(
                        label: l10n.mapEventsFieldCover,
                        trailing: l10n.mapEventsRequired,
                      ),
                      const SizedBox(height: 10),
                      _CoverPicker(
                        state: state,
                        onPick: () => _pickCover(context),
                      ),
                      const SizedBox(height: 22),
                      EventTextField(
                        label: l10n.mapEventsFieldTitle,
                        hint: l10n.mapEventsFieldTitleHint,
                        controller: _title,
                        maxLength: 120,
                        onChanged: (v) => context
                            .read<CreateMapEventBloc>()
                            .add(ChangeEventTitle(v)),
                      ),
                      const SizedBox(height: 20),
                      _CategoryPicker(state: state),
                      const SizedBox(height: 20),
                      EventTextField(
                        label: l10n.mapEventsFieldDescription,
                        hint: l10n.mapEventsFieldDescriptionHint,
                        controller: _description,
                        maxLines: 4,
                        maxLength: 2000,
                        onChanged: (v) => context
                            .read<CreateMapEventBloc>()
                            .add(ChangeEventDescription(v)),
                      ),
                      const SizedBox(height: 20),
                      _LocationSection(
                        state: state,
                        controller: _locationName,
                      ),
                      const SizedBox(height: 20),
                      _DateTimeSection(state: state),
                      const SizedBox(height: 20),
                      EventTextField(
                        label: l10n.mapEventsFieldCapacity,
                        labelSuffix: l10n.mapEventsOptional,
                        hint: l10n.mapEventsCapacityHint,
                        controller: _capacity,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 5,
                        onChanged: (v) => context
                            .read<CreateMapEventBloc>()
                            .add(ChangeEventCapacity(int.tryParse(v))),
                      ),
                      // A capacity can be raised but never cleared through
                      // PATCH, so editing says so rather than letting the user
                      // discover it.
                      if (state.isEditing) ...[
                        const SizedBox(height: 6),
                        _Hint(text: l10n.mapEventsCapacityLockedHint),
                      ],
                      const SizedBox(height: 16),
                      _ApprovalSection(state: state),
                      const SizedBox(height: 20),
                      _RulesSection(state: state, controllers: _rules),
                      const SizedBox(height: 20),
                      _OrganizersSection(state: state),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                _SubmitBar(state: state),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickCover(BuildContext context) async {
    final bloc = context.read<CreateMapEventBloc>();
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    // Compression starts immediately and runs while the rest of the form is
    // filled in, so submitting doesn't wait on it.
    bloc.add(ChangeEventCover(CompressedImage.compress(file.path, _imageService)));
  }
}

class _Header extends StatelessWidget {
  final bool isEditing;

  const _Header({required this.isEditing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          Material(
            color: AppColors.surface,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => context.pop(),
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 38,
                height: 38,
                child: Icon(Icons.close_rounded, size: 19, color: AppColors.ink),
              ),
            ),
          ),
          Expanded(
            child: Text(
              isEditing ? l10n.mapEventsEditTitle : l10n.mapEventsCreateTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.ink,
              ),
            ),
          ),
          // Balances the close button so the title sits truly centred.
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class _CoverPicker extends StatelessWidget {
  final CreateMapEventState state;
  final VoidCallback onPick;

  const _CoverPicker({required this.state, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final picked = state.cover;
    final existing = state.editEvent?.coverImageUrl;

    if (picked == null && (existing == null || existing.isEmpty)) {
      return EventDashedButton(
        label: l10n.mapEventsCoverAdd,
        icon: Icons.photo_camera_outlined,
        height: 132,
        onTap: onPick,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_camera_outlined,
              size: 24,
              color: AppColors.mute,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.mapEventsCoverAdd,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: AppColors.mute,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.mapEventsCoverHint,
              style: const TextStyle(fontSize: 11, color: AppColors.muteSoft),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          SizedBox(
            height: 156,
            width: double.infinity,
            child: picked != null
                ? Image.file(File(picked.path), fit: BoxFit.cover)
                : Image.network(existing!, fit: BoxFit.cover),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Material(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onPick,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    l10n.mapEventsCoverChange,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
            _CategoryChip(label: l10n.mapEventsCategoryCarShow, isLocked: true),
            _CategoryChip(label: l10n.mapEventsCategoryCruise, isLocked: true),
          ],
        ),
        const SizedBox(height: 8),
        _Hint(text: l10n.mapEventsCategoriesSoonNote),
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
        : (isActive ? Colors.white : AppColors.ink);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(14),
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: foreground,
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

class _LocationSection extends StatelessWidget {
  final CreateMapEventState state;
  final TextEditingController controller;

  const _LocationSection({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final position = state.position;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventTextField(
          label: l10n.mapEventsFieldLocation,
          hint: l10n.mapEventsFieldVenueHint,
          controller: controller,
          maxLength: 160,
          onChanged: (v) => context
              .read<CreateMapEventBloc>()
              .add(ChangeEventLocationName(v)),
        ),
        const SizedBox(height: 10),
        EventDashedButton(
          label: position == null
              ? l10n.mapEventsSetLocationOnMap
              : l10n.mapEventsLocationSet,
          icon: position == null
              ? Icons.place_outlined
              : Icons.check_circle_outline_rounded,
          onTap: () async {
            final bloc = context.read<CreateMapEventBloc>();
            final picked = await showPickEventLocation(
              context,
              initial: state.position,
            );
            if (picked == null) return;

            bloc.add(ChangeEventPosition(picked.position));

            // The address the user typed in the picker fills the venue field
            // only when they haven't written their own label — "Port Hercule
            // — Level 2" is more useful than a street address, so a name
            // already there is never overwritten.
            if (controller.text.trim().isEmpty &&
                picked.addressLabel.isNotEmpty) {
              controller.text = picked.addressLabel;
              bloc.add(ChangeEventLocationName(picked.addressLabel));
            }
          },
        ),
      ],
    );
  }
}

class _DateTimeSection extends StatelessWidget {
  final CreateMapEventState state;

  const _DateTimeSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<CreateMapEventBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapEventSectionLabel(label: l10n.mapEventsFieldDateTime),
        const SizedBox(height: 8),
        _DateTimeRow(
          label: l10n.mapEventsStartsLabel,
          value: state.startsAt,
          onChanged: (value) => bloc.add(ChangeEventStart(value)),
        ),
        const SizedBox(height: 8),
        _DateTimeRow(
          label: l10n.mapEventsEndsLabel,
          value: state.endsAt,
          // The end can only be picked once there's a start to anchor it to,
          // and it can't land before that start.
          minimum: state.startsAt,
          enabled: state.startsAt != null,
          onChanged: (value) => bloc.add(ChangeEventEnd(value)),
          onClear: state.endsAt == null
              ? null
              : () => bloc.add(const ChangeEventEnd(null)),
        ),
        const SizedBox(height: 6),
        _Hint(text: l10n.mapEventsEndBlankHint),
      ],
    );
  }
}

/// A date field and a time field side by side, as the design lays them out.
/// The two edit one [DateTime]; picking a date on a null value defaults the
/// time to the top of the next hour rather than midnight.
class _DateTimeRow extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateTime? minimum;
  final bool enabled;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback? onClear;

  const _DateTimeRow({
    required this.label,
    required this.value,
    this.minimum,
    this.enabled = true,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final current = value;

    return Row(
      children: [
        Expanded(
          child: EventPickerField(
            value: current == null
                ? label
                : MapEventFormat.dayAndMonth(context, current),
            icon: Icons.calendar_today_rounded,
            isPlaceholder: current == null,
            onTap: enabled ? () => _pickDate(context) : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: EventPickerField(
            value: current == null ? '—' : MapEventFormat.time(context, current),
            icon: Icons.schedule_rounded,
            isPlaceholder: current == null,
            onTap: (enabled && current != null)
                ? () => _pickTime(context, current)
                : null,
          ),
        ),
        if (onClear != null) ...[
          const SizedBox(width: 4),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.mute,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final floor = minimum ?? now;
    final initial = value ?? _nextHour(floor);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(floor) ? floor : initial,
      firstDate: DateTime(floor.year, floor.month, floor.day),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked == null) return;

    final time = value ?? _nextHour(floor);
    onChanged(
      DateTime(picked.year, picked.month, picked.day, time.hour, time.minute),
    );
  }

  Future<void> _pickTime(BuildContext context, DateTime current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) return;
    onChanged(
      DateTime(
        current.year,
        current.month,
        current.day,
        picked.hour,
        picked.minute,
      ),
    );
  }

  static DateTime _nextHour(DateTime from) =>
      DateTime(from.year, from.month, from.day, from.hour).add(
        const Duration(hours: 1),
      );
}

class _ApprovalSection extends StatelessWidget {
  final CreateMapEventState state;

  const _ApprovalSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<CreateMapEventBloc>();

    return EventToggleCard(
      title: l10n.mapEventsApprovalToggleTitle,
      body: l10n.mapEventsApprovalToggleBody,
      value: state.requiresApproval,
      onChanged: (v) => bloc.add(ToggleEventApproval(v)),
      // The design labels the deadline OPTIONAL; the API requires it for car
      // meets, and the API wins — so the label says REQUIRED and the CTA
      // refuses to submit without it.
      nested: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          MapEventSectionLabel(
            label: l10n.mapEventsFieldDeadline,
            trailing: state.requiresDeadline
                ? l10n.mapEventsRequired
                : l10n.mapEventsOptional,
          ),
          const SizedBox(height: 8),
          _DateTimeRow(
            label: l10n.mapEventsFieldDeadline,
            value: state.registrationDeadline,
            onChanged: (value) => bloc.add(ChangeEventDeadline(value)),
            onClear: state.registrationDeadline == null || state.requiresDeadline
                ? null
                : () => bloc.add(const ChangeEventDeadline(null)),
          ),
        ],
      ),
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
        MapEventSectionLabel(
          label: l10n.mapEventsFieldRules,
          trailing: l10n.mapEventsOptional,
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < state.rules.length; i++) ...[
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
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
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
        ],
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

class _OrganizersSection extends StatelessWidget {
  final CreateMapEventState state;

  const _OrganizersSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<CreateMapEventBloc>();
    final existing = state.editEvent?.organizers ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapEventSectionLabel(label: l10n.mapEventsFieldOrganizers),
        const SizedBox(height: 6),
        _Hint(text: l10n.mapEventsOrganizersHint),
        const SizedBox(height: 10),
        // In edit mode the event's own organizer list is authoritative; in
        // create mode there's nothing on the server yet, so only the queue.
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
        borderRadius: BorderRadius.circular(14),
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
              style: const TextStyle(
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

/// The pinned CTA. Its label names what's missing rather than just going grey,
/// so a form that won't submit explains itself.
class _SubmitBar extends StatelessWidget {
  final CreateMapEventState state;

  const _SubmitBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = state.isComplete && !state.isSubmitting;

    final label = state.isSubmitting
        ? l10n.mapEventsSubmitting
        : state.isComplete
            ? (state.isEditing ? l10n.mapEventsSaveCta : l10n.mapEventsCreateCta)
            : state.isMissingDeadlineOnly
                ? l10n.mapEventsCreateCtaDeadline
                : state.isMissingCoverOnly
                    ? l10n.mapEventsCreateCtaCover
                    : l10n.mapEventsCreateCtaIncomplete;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.validationMessage != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _validationText(l10n, state.validationMessage!),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.accentHot,
                ),
              ),
            ),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: enabled
                  ? () => context
                      .read<CreateMapEventBloc>()
                      .add(const SubmitMapEvent())
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                disabledBackgroundColor: AppColors.line2,
                disabledForegroundColor: AppColors.muteSoft,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.muteSoft,
                      ),
                    )
                  : Text(label),
            ),
          ),
        ],
      ),
    );
  }

  static String _validationText(AppLocalizations l10n, String key) =>
      switch (key) {
        CreateEventValidation.endBeforeStart =>
          l10n.mapEventsValidationEndBeforeStart,
        CreateEventValidation.deadlineAfterStart =>
          l10n.mapEventsValidationDeadlineAfterStart,
        CreateEventValidation.capacityTooSmall =>
          l10n.mapEventsValidationCapacity,
        _ => l10n.mapEventsErrorInvalidInput,
      };
}

/// The post-submit confirmation. Every new event goes to the admin team, so
/// this is the honest end of the flow — not a jump to a page that isn't on the
/// map yet.
class _SubmittedView extends StatelessWidget {
  final CreateMapEventState state;

  const _SubmittedView({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 28,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.mapEventsPendingReviewTitle,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.mapEventsPendingReviewBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.45,
                color: AppColors.ink2,
              ),
            ),
            if (state.coverUploadFailed) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.image_not_supported_outlined,
                      size: 17,
                      color: AppColors.mute,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.mapEventsCoverUploadFailed,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: AppColors.ink2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
                child: Text(l10n.mapEventsDone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  final CreateMapEventState state;

  const _LoadFailed({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = state.error ?? const MapEventError(MapEventErrorCode.generic);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: AppColors.muteSoft,
              ),
              const SizedBox(height: 14),
              Text(
                mapEventErrorMessage(l10n, error),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14.5, color: AppColors.ink2),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => context
                    .read<CreateMapEventBloc>()
                    .add(LoadCreateEventRefs(editEvent: state.editEvent)),
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                child: Text(l10n.mapEventsRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;

  const _Hint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        height: 1.35,
        color: AppColors.muteSoft,
      ),
    );
  }
}
