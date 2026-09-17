import 'package:flutter/material.dart';

import '../../../../core/services/image_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/car_modification.dart';
import '../../domain/entities/reference_data.dart';
import '../widgets/register_car/build_log_entry_form.dart';
import '../widgets/register_car/mod_slot.dart';
import '../widgets/register_car/register_car_chrome.dart';
import '../widgets/register_car/register_car_fields.dart';
import '../widgets/register_car/register_discard_dialog.dart';
import '../../../../core/shared/layout/app_layout.dart';

/// Opens the full-screen build-log editor and resolves to the composed
/// [ModSlot], or null if the user backed out.
///
/// A full screen rather than a sheet: the form is long, it owns the keyboard,
/// and half-dismissing it by accident used to throw the entry away.
Future<ModSlot?> showBuildLogEntry(
  BuildContext context, {
  required List<CarModCategoryEntity> categories,
  required ImageService imageService,
  CarModificationEntity? initialMod,
}) {
  return Navigator.of(context).push<ModSlot>(
    MaterialPageRoute(
      builder: (_) => BuildLogEntryPage(
        categories: categories,
        imageService: imageService,
        initialMod: initialMod,
      ),
    ),
  );
}

/// Full-screen editor for a single build-log item inside the add-car wizard.
/// Pops with a [ModSlot] ([NewModSlot] when adding, [ExistingModSlot] when
/// [initialMod] is supplied); nothing is saved here — the wizard submits the
/// whole car at the end.
class BuildLogEntryPage extends StatefulWidget {
  final List<CarModCategoryEntity> categories;
  final ImageService imageService;

  /// When non-null, the page opens in edit mode pre-filled with this mod.
  final CarModificationEntity? initialMod;

  const BuildLogEntryPage({
    super.key,
    required this.categories,
    required this.imageService,
    this.initialMod,
  });

  @override
  State<BuildLogEntryPage> createState() => _BuildLogEntryPageState();
}

class _BuildLogEntryPageState extends State<BuildLogEntryPage> {
  final _form = GlobalKey<BuildLogEntryFormState>();

  bool get _isEdit => widget.initialMod != null;

  Future<void> _close() async {
    final navigator = Navigator.of(context);
    if (!(_form.currentState?.isDirty ?? false)) {
      navigator.pop();
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final discard = await showRegisterDiscardDialog(
      context,
      title: l10n.garageBuildLogDiscardTitle,
      body: l10n.garageBuildLogDiscardBody,
    );
    if (discard == true) navigator.pop();
  }

  void _done() {
    final result = _form.currentState?.compose();
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.garageModValidation),
        ),
      );
      return;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              // No title bar — this is a screen, not a sheet. Just the way out.
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 6) +
          AppLayout.inset(context, maxWidth: AppLayout.formWidth),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RegisterCloseButton(onTap: _close),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24) +
          AppLayout.inset(context, maxWidth: AppLayout.formWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RegisterSectionHeader(
                        title: _isEdit
                            ? l10n.garageModSheetTitleEdit
                            : l10n.garageModSheetTitleAdd,
                      ),
                      const SizedBox(height: 20),
                      BuildLogEntryForm(
                        key: _form,
                        categories: widget.categories,
                        imageService: widget.imageService,
                        initialMod: widget.initialMod,
                      ),
                    ],
                  ),
                ),
              ),
              _SubmitBar(isEdit: _isEdit, onTap: _done),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  final bool isEdit;
  final VoidCallback onTap;

  const _SubmitBar({required this.isEdit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26) +
          AppLayout.inset(context, maxWidth: AppLayout.formWidth),
      color: AppColors.bg,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(kRegisterRadius),
          ),
          child: RegisterFitted(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isEdit ? Icons.check_rounded : Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isEdit
                      ? l10n.garageModSaveChanges
                      : l10n.garageModAddToBuildLog,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
