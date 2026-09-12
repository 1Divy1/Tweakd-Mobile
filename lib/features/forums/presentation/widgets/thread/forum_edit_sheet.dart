import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tweakd/core/shared/bloc/tag_picker/bloc.dart';
import 'package:tweakd/core/shared/entities/tag_selection.dart';
import 'package:tweakd/core/shared/widgets/tagging/tag_editor.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../shared/forum_section_label.dart';

/// What an edit sheet resolves to: the new body plus the replace-all tag sets
/// (always non-null — the sheet always shows the current tags, so whatever is
/// left in it is what the content should end up with).
class ForumEditResult {
  final String text;
  final List<String> taggedPeople;
  final List<String> taggedCars;

  const ForumEditResult({
    required this.text,
    required this.taggedPeople,
    required this.taggedCars,
  });
}

/// Bottom sheet with a text area and the tag editor, used to edit the OP body
/// or a reply. Resolves to the new content on save, null on cancel. Must be
/// called from a context that can read a [TagPickerBloc].
Future<ForumEditResult?> showForumEditSheet(
  BuildContext context, {
  required String title,
  required String initialText,
  required List<TaggedPerson> initialPeople,
  required List<TaggedCar> initialCars,
  bool allowEmpty = false,
}) {
  final tagBloc = context.read<TagPickerBloc>();
  return showModalBottomSheet<ForumEditResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => BlocProvider<TagPickerBloc>.value(
      value: tagBloc,
      child: _ForumEditSheet(
        title: title,
        initialText: initialText,
        initialPeople: initialPeople,
        initialCars: initialCars,
        allowEmpty: allowEmpty,
      ),
    ),
  );
}

class _ForumEditSheet extends StatefulWidget {
  final String title;
  final String initialText;
  final List<TaggedPerson> initialPeople;
  final List<TaggedCar> initialCars;
  final bool allowEmpty;

  const _ForumEditSheet({
    required this.title,
    required this.initialText,
    required this.initialPeople,
    required this.initialCars,
    required this.allowEmpty,
  });

  @override
  State<_ForumEditSheet> createState() => _ForumEditSheetState();
}

class _ForumEditSheetState extends State<_ForumEditSheet> {
  late final TextEditingController _controller;
  final _peopleSearchController = TextEditingController();
  late List<TaggedPerson> _people;
  late List<TaggedCar> _cars;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(() => setState(() {}));
    _people = [...widget.initialPeople];
    _cars = [...widget.initialCars];
  }

  @override
  void dispose() {
    _controller.dispose();
    _peopleSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canSave = widget.allowEmpty || _controller.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.title,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              minLines: 3,
              maxLines: 8,
              cursorColor: AppColors.accent,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 20),
          ForumSectionLabel(label: l10n.forumsTagsSectionLabel),
          const SizedBox(height: 10),
          Flexible(
            child: SingleChildScrollView(
              child: TagEditor(
                people: _people,
                cars: _cars,
                peopleSearchController: _peopleSearchController,
                showHeader: false,
                onAddPerson: (person) {
                  if (_people.length >= kTagSelectionLimit ||
                      _people.any((p) => p.id == person.id)) {
                    return;
                  }
                  setState(() => _people = [..._people, person]);
                },
                onRemovePerson: (id) => setState(() {
                  _people = [
                    for (final p in _people)
                      if (p.id != id) p,
                  ];
                  // Keep the owner-must-be-tagged rule satisfied.
                  _cars = tagCarsWithoutOwner(_cars, id);
                }),
                onAddCar: (car) {
                  if (_cars.length >= kTagSelectionLimit ||
                      _cars.any((c) => c.id == car.id)) {
                    return;
                  }
                  setState(() => _cars = [..._cars, car]);
                },
                onRemoveCar: (id) => setState(() {
                  _cars = [
                    for (final c in _cars)
                      if (c.id != id) c,
                  ];
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: BorderSide(color: AppColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.commonCancel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: canSave
                        ? () => Navigator.of(context).pop(
                            ForumEditResult(
                              text: _controller.text.trim(),
                              taggedPeople: [for (final p in _people) p.id],
                              taggedCars: [for (final c in _cars) c.id],
                            ),
                          )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      disabledBackgroundColor: AppColors.line,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: AppColors.muteSoft,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.forumsEditSave,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
