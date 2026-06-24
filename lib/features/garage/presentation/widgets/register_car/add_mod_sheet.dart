import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/services/car_image_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/car_modification.dart';
import '../../../domain/entities/reference_data.dart';
import '../../../domain/repositories/garage_repository.dart';
import '../../bloc/add_car/event.dart';
import 'mod_slot.dart';
import 'register_car_fields.dart';

const _monthsTitle = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Bottom sheet for composing or editing a single build-log item. Returns a
/// [ModSlot] on success ([NewModSlot] when adding, [ExistingModSlot] when
/// [initialMod] is supplied). The price is optional.
class AddModSheet extends StatefulWidget {
  final List<CarModCategoryEntity> categories;
  final CarImageService imageService;

  /// When non-null, the sheet opens in edit mode pre-filled with this mod.
  final CarModificationEntity? initialMod;

  const AddModSheet({
    super.key,
    required this.categories,
    required this.imageService,
    this.initialMod,
  });

  @override
  State<AddModSheet> createState() => _AddModSheetState();
}

class _AddModSheetState extends State<AddModSheet> {
  CarModCategoryEntity? _category;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  // Newly picked images (to upload).
  CompressedImage? _before;
  CompressedImage? _after;
  // Existing remote images kept from the original mod (edit mode only).
  // [_*Url] is for display; [_*Key] is the R2 key sent back on removal.
  String? _beforeUrl;
  String? _afterUrl;
  String? _beforeKey;
  String? _afterKey;
  // Existing media (by R2 key) the user removed or replaced — deleted on submit.
  final List<String> _removedKeys = [];
  DateTime? _date;

  bool get _isEdit => widget.initialMod != null;

  // Guards against a second image_picker request firing before the first
  // finishes — iOS throws PlatformException('multiple_request') otherwise.
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    final mod = widget.initialMod;
    if (mod == null) return;
    for (final c in widget.categories) {
      if (c.id == mod.categoryId) {
        _category = c;
        break;
      }
    }
    _titleCtrl.text = mod.title;
    _descCtrl.text = mod.description ?? '';
    if (mod.price != null) {
      _priceCtrl.text =
          mod.price!.toStringAsFixed(mod.price! % 1 == 0 ? 0 : 2);
    }
    if (mod.mileageAtInstall != null) {
      _mileageCtrl.text = mod.mileageAtInstall.toString();
    }
    _date = mod.installationDate;
    _beforeUrl = mod.beforeMedia.isEmpty ? null : mod.beforeMedia.first.url;
    _afterUrl = mod.afterMedia.isEmpty ? null : mod.afterMedia.first.url;
    _beforeKey = mod.beforeMedia.isEmpty ? null : mod.beforeMedia.first.key;
    _afterKey = mod.afterMedia.isEmpty ? null : mod.afterMedia.first.key;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _mileageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool isBefore}) async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      // Start compressing immediately so the bytes are ready by submit time.
      final image = CompressedImage.compress(file.path, widget.imageService);
      if (!mounted) return;
      setState(() {
        if (isBefore) {
          if (_beforeKey != null) _removedKeys.add(_beforeKey!);
          _beforeUrl = null;
          _beforeKey = null;
          _before = image;
        } else {
          if (_afterKey != null) _removedKeys.add(_afterKey!);
          _afterUrl = null;
          _afterKey = null;
          _after = image;
        }
      });
    } on PlatformException {
      // A pick was already in progress (e.g. a double tap) — safe to ignore.
    } finally {
      _isPicking = false;
    }
  }

  void _removeImage({required bool isBefore}) {
    setState(() {
      if (isBefore) {
        if (_before != null) {
          _before = null;
        } else if (_beforeKey != null) {
          _removedKeys.add(_beforeKey!);
          _beforeUrl = null;
          _beforeKey = null;
        }
      } else {
        if (_after != null) {
          _after = null;
        } else if (_afterKey != null) {
          _removedKeys.add(_afterKey!);
          _afterUrl = null;
          _afterKey = null;
        }
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _done() {
    final hasBefore = _before != null || _beforeUrl != null;
    final hasAfter = _after != null || _afterUrl != null;

    // When adding, both images are required. When editing an existing mod the
    // images are optional (the mod may have been created without them).
    final imagesOk = _isEdit || (hasBefore && hasAfter);
    if (_category == null ||
        _titleCtrl.text.trim().isEmpty ||
        _date == null ||
        !imagesOk) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit
              ? l10n.garageModValidationEdit
              : l10n.garageModValidationAdd),
        ),
      );
      return;
    }
    final price = _priceCtrl.text.trim().isNotEmpty
        ? double.tryParse(_priceCtrl.text.trim())
        : null;
    final mileage = _mileageCtrl.text.trim().isNotEmpty
        ? int.tryParse(_mileageCtrl.text.trim())
        : null;

    final request = ModRequestParams(
      categoryId: _category!.id,
      title: _titleCtrl.text.trim(),
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      installationDate: _date!,
      price: price,
      mileageAtInstall: mileage,
    );

    final ModSlot result = _isEdit
        ? ExistingModSlot(
            original: widget.initialMod!,
            request: request,
            newBefore: _before,
            newAfter: _after,
            beforeUrl: _beforeUrl,
            afterUrl: _afterUrl,
            removeMediaKeys: List.of(_removedKeys),
          )
        : NewModSlot(
            NewModInput(before: _before, after: _after, request: request),
          );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RegisterSectionHeader(
                            label: l10n.garageModSheetLabel,
                            title: _isEdit
                                ? l10n.garageModSheetTitleEdit
                                : l10n.garageModSheetTitleAdd,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 20, color: AppColors.ink),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    RegisterFieldLabel(l10n.garageFieldCategory),
                    const SizedBox(height: 8),
                    RegisterSelectorTile(
                      placeholder: l10n.garageHintCategory,
                      value: _category?.modName,
                      onTap: () => showRegisterPicker<CarModCategoryEntity>(
                        context: context,
                        title: l10n.garagePickerCategory,
                        items: widget.categories,
                        labelOf: (c) => c.modName,
                        onSelected: (c) => setState(() => _category = c),
                      ),
                    ),
                    const SizedBox(height: 16),
                    RegisterFieldLabel(l10n.garageFieldTitle),
                    const SizedBox(height: 8),
                    RegisterFormField(
                      controller: _titleCtrl,
                      hint: l10n.garageHintModTitle,
                    ),
                    const SizedBox(height: 16),
                    RegisterFieldLabel(l10n.garageFieldDescription,
                        optional: true),
                    const SizedBox(height: 8),
                    RegisterFormField(
                      controller: _descCtrl,
                      hint: l10n.garageHintModDescription,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    RegisterFieldLabel(l10n.garageFieldInstallationDate),
                    const SizedBox(height: 8),
                    RegisterSelectorTile(
                      placeholder: l10n.garageSelectDate,
                      value: _date != null ? _formatDate(_date!) : null,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RegisterFieldLabel(l10n.garageFieldPrice,
                                  optional: true),
                              const SizedBox(height: 8),
                              RegisterFormField(
                                controller: _priceCtrl,
                                hint: '0.00',
                                prefix: const Text(
                                  '€',
                                  style: TextStyle(
                                    color: AppColors.mute,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                keyboardType: const TextInputType
                                    .numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*')),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RegisterFieldLabel(l10n.garageFieldMileageShort,
                                  optional: true),
                              const SizedBox(height: 8),
                              RegisterFormField(
                                controller: _mileageCtrl,
                                hint: '45,000',
                                unit: 'KM',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    RegisterFieldLabel(l10n.garageLogModBeforeAfter),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ImageSlot(
                            label: l10n.garageModBefore,
                            filePath: _before?.path,
                            networkUrl: _beforeUrl,
                            onTap: () => _pick(isBefore: true),
                            onRemove: () => _removeImage(isBefore: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ImageSlot(
                            label: l10n.garageModAfter,
                            filePath: _after?.path,
                            networkUrl: _afterUrl,
                            onTap: () => _pick(isBefore: false),
                            onRemove: () => _removeImage(isBefore: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _done,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withAlpha(70),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isEdit ? Icons.check_rounded : Icons.add_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _isEdit
                                  ? l10n.garageModSaveChanges
                                  : l10n.garageModAddToBuildLog,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_monthsTitle[d.month - 1]} ${d.year}';
}

class _ImageSlot extends StatelessWidget {
  final String label;
  final String? filePath;
  final String? networkUrl;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _ImageSlot({
    required this.label,
    required this.filePath,
    this.networkUrl,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final ImageProvider? image = filePath != null
        ? FileImage(File(filePath!))
        : (networkUrl != null ? NetworkImage(networkUrl!) : null);
    final hasImage = image != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
          image: hasImage
              ? DecorationImage(image: image, fit: BoxFit.cover)
              : null,
        ),
        child: Stack(
          children: [
            if (!hasImage)
              const Center(
                child: Icon(Icons.add_photo_alternate_rounded,
                    color: AppColors.muteSoft, size: 26),
              ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasImage
                      ? Colors.black.withAlpha(120)
                      : AppColors.bg,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: hasImage ? Colors.white : AppColors.mute,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            if (hasImage)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(140),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
