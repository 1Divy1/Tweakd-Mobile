import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/services/image_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/car_modification.dart';
import '../../../domain/entities/reference_data.dart';
import '../../../domain/repositories/garage_repository.dart';
import '../../bloc/add_car/event.dart';
import 'mod_slot.dart';
import 'register_car_fields.dart';
import 'register_toggle_tile.dart';
import 'reorderable_photo_tile.dart';

const _monthsTitle = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// One image in a before/after phase — either freshly picked (to upload) or an
/// existing one carried over from the saved mod.
sealed class _PhaseImage {
  const _PhaseImage();
}

class _NewPhaseImage extends _PhaseImage {
  final CompressedImage image;
  const _NewPhaseImage(this.image);
}

class _KeptPhaseImage extends _PhaseImage {
  final ModificationMediaEntity media;
  const _KeptPhaseImage(this.media);
}

/// The fields of a single build-log item: category, title, description, date,
/// price, mileage and the before/after photos. Price, mileage, description and
/// the photos are optional.
///
/// Shared by the add-car wizard's build-log editor ([BuildLogEntryPage]) and
/// the standalone add-modification flow, so both look and validate the same.
/// The host owns the chrome and asks for the result through a
/// `GlobalKey<BuildLogEntryFormState>`: [BuildLogEntryFormState.isDirty] to
/// decide whether closing needs a warning, and
/// [BuildLogEntryFormState.compose] for the finished entry.
class BuildLogEntryForm extends StatefulWidget {
  final List<CarModCategoryEntity> categories;
  final ImageService imageService;

  /// When non-null, the form opens pre-filled with this mod (edit mode).
  final CarModificationEntity? initialMod;

  const BuildLogEntryForm({
    super.key,
    required this.categories,
    required this.imageService,
    this.initialMod,
  });

  @override
  State<BuildLogEntryForm> createState() => BuildLogEntryFormState();
}

class BuildLogEntryFormState extends State<BuildLogEntryForm> {
  CarModCategoryEntity? _category;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  DateTime? _date;

  /// Whether other users may see the price. Off by default: a price is recorded
  /// for the owner's own expense tracking unless they choose to publish it.
  bool _isPricePublic = false;

  final List<_PhaseImage> _before = [];
  final List<_PhaseImage> _after = [];

  /// Existing media (by R2 key) the user removed — deleted on submit.
  final List<String> _removedKeys = [];

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
      _priceCtrl.text = mod.price!.toStringAsFixed(mod.price! % 1 == 0 ? 0 : 2);
    }
    _isPricePublic = mod.isPricePublic;
    if (mod.mileageAtInstall != null) {
      _mileageCtrl.text = mod.mileageAtInstall.toString();
    }
    _date = mod.installationDate;
    _before.addAll(mod.beforeMedia.map(_KeptPhaseImage.new));
    _after.addAll(mod.afterMedia.map(_KeptPhaseImage.new));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The price-visibility toggle appears only once a price is typed, so this
    // field -- unlike the others -- has to rebuild the form as it changes.
    _priceCtrl.removeListener(_onPriceChanged);
    _priceCtrl.addListener(_onPriceChanged);
  }

  void _onPriceChanged() {
    final hasPrice = _priceCtrl.text.trim().isNotEmpty;
    if (hasPrice != _hadPrice) {
      _hadPrice = hasPrice;
      if (mounted) setState(() {});
    }
  }

  bool _hadPrice = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.removeListener(_onPriceChanged);
    _priceCtrl.dispose();
    _mileageCtrl.dispose();
    super.dispose();
  }

  /// Whether the user has entered anything worth warning about before closing.
  /// In edit mode the form starts pre-filled, so only actual edits count.
  bool get isDirty {
    if (_isEdit) {
      final mod = widget.initialMod!;
      return _category?.id != mod.categoryId ||
          _titleCtrl.text.trim() != mod.title ||
          _descCtrl.text.trim() != (mod.description ?? '') ||
          _date != mod.installationDate ||
          _isPricePublic != mod.isPricePublic ||
          _removedKeys.isNotEmpty ||
          _before.any((i) => i is _NewPhaseImage) ||
          _after.any((i) => i is _NewPhaseImage);
    }
    return _category != null ||
        _titleCtrl.text.trim().isNotEmpty ||
        _descCtrl.text.trim().isNotEmpty ||
        _priceCtrl.text.trim().isNotEmpty ||
        _mileageCtrl.text.trim().isNotEmpty ||
        _date != null ||
        _before.isNotEmpty ||
        _after.isNotEmpty;
  }

  /// Photos are optional in both modes — only the identifying fields are not.
  bool get isComplete =>
      _category != null && _titleCtrl.text.trim().isNotEmpty && _date != null;

  /// The finished entry — a [NewModSlot] when adding, an [ExistingModSlot]
  /// when editing — or null while a required field is still empty.
  ModSlot? compose() {
    if (!isComplete) return null;

    final price = _priceCtrl.text.trim().isNotEmpty
        ? double.tryParse(_priceCtrl.text.trim())
        : null;
    final mileage = _mileageCtrl.text.trim().isNotEmpty
        ? int.tryParse(_mileageCtrl.text.trim())
        : null;

    final request = ModRequestParams(
      categoryId: _category!.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      installationDate: _date!,
      price: price,
      // A price that was cleared cannot stay published -- the backend and the
      // database both refuse that pair.
      isPricePublic: price != null && _isPricePublic,
      mileageAtInstall: mileage,
    );

    if (_isEdit) {
      return ExistingModSlot(
        original: widget.initialMod!,
        request: request,
        newBefore: _newImages(_before),
        newAfter: _newImages(_after),
        keptBefore: _keptMedia(_before),
        keptAfter: _keptMedia(_after),
        removeMediaKeys: List.of(_removedKeys),
      );
    }
    return NewModSlot(
      NewModInput(
        request: request,
        before: _newImages(_before),
        after: _newImages(_after),
      ),
    );
  }

  static List<CompressedImage> _newImages(List<_PhaseImage> slots) => [
    for (final slot in slots)
      if (slot is _NewPhaseImage) slot.image,
  ];

  static List<ModificationMediaEntity> _keptMedia(List<_PhaseImage> slots) => [
    for (final slot in slots)
      if (slot is _KeptPhaseImage) slot.media,
  ];

  Future<void> _pick({required bool isBefore}) async {
    if (_isPicking) return;
    final slots = isBefore ? _before : _after;
    final remaining = maxModImagesPerPhase - slots.length;
    if (remaining <= 0) return;

    _isPicking = true;
    try {
      final picker = ImagePicker();
      final files = await picker.pickMultiImage(limit: remaining);
      if (files.isEmpty) return;
      // Start compressing immediately so the bytes are ready by submit time.
      // pickMultiImage's limit isn't honoured on every platform, so cap here.
      final picked = files
          .take(remaining)
          .map(
            (f) => _NewPhaseImage(
              CompressedImage.compress(f.path, widget.imageService),
            ),
          )
          .toList();
      if (!mounted) return;
      setState(() => slots.addAll(picked));
    } on PlatformException {
      // A pick was already in progress (e.g. a double tap) — safe to ignore.
    } finally {
      _isPicking = false;
    }
  }

  void _reorderImage({
    required bool isBefore,
    required int oldIndex,
    required int newIndex,
  }) {
    setState(
        () => reorderInPlace(isBefore ? _before : _after, oldIndex, newIndex));
  }

  void _removeImage({required bool isBefore, required int index}) {
    setState(() {
      final slots = isBefore ? _before : _after;
      final removed = slots.removeAt(index);
      // Existing media must be deleted from R2 on submit (by its key).
      if (removed is _KeptPhaseImage) _removedKeys.add(removed.media.key);
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

  String _formatDate(DateTime d) =>
      '${d.day} ${_monthsTitle[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        RegisterFieldLabel(l10n.garageFieldDescription, optional: true),
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
                  RegisterFieldLabel(l10n.garageFieldPrice, optional: true),
                  const SizedBox(height: 8),
                  RegisterFormField(
                    controller: _priceCtrl,
                    hint: '0.00',
                    prefix: Text(
                      '€',
                      style: TextStyle(
                        color: AppColors.mute,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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
                  RegisterFieldLabel(
                    l10n.garageFieldMileageShort,
                    optional: true,
                  ),
                  const SizedBox(height: 8),
                  RegisterFormField(
                    controller: _mileageCtrl,
                    hint: '45,000',
                    unit: 'KM',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
            ),
          ],
        ),
        // Nothing to decide until there is a price to publish.
        if (_priceCtrl.text.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          RegisterToggleTile(
            icon: Icons.sell_outlined,
            title: l10n.garageModPricePublicTitle,
            description: l10n.garageModPricePublicBody,
            value: _isPricePublic,
            onChanged: (v) => setState(() => _isPricePublic = v),
          ),
        ],
        const SizedBox(height: 20),
        // Before/after photos are optional, and deliberately not labelled as
        // such — they read as an invitation, not a field the user has to
        // dismiss.
        _PhaseRow(
          label: l10n.garageModBefore,
          images: _before,
          onAdd: () => _pick(isBefore: true),
          onRemove: (i) => _removeImage(isBefore: true, index: i),
          onReorder: (from, to) =>
              _reorderImage(isBefore: true, oldIndex: from, newIndex: to),
        ),
        const SizedBox(height: 16),
        _PhaseRow(
          label: l10n.garageModAfter,
          images: _after,
          onAdd: () => _pick(isBefore: false),
          onRemove: (i) => _removeImage(isBefore: false, index: i),
          onReorder: (from, to) =>
              _reorderImage(isBefore: false, oldIndex: from, newIndex: to),
        ),
      ],
    );
  }
}

/// One before/after phase: its caption and up to [maxModImagesPerPhase]
/// thumbnails followed by an add tile while there is room left.
class _PhaseRow extends StatelessWidget {
  final String label;
  final List<_PhaseImage> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _PhaseRow({
    required this.label,
    required this.images,
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    // Always lay out exactly [maxModImagesPerPhase] cells so a tile keeps the
    // same width whether the phase holds one photo or three: the thumbnails,
    // then the add tile while there is room, then invisible spacers.
    final cells = <Widget>[
      for (var i = 0; i < images.length; i++)
        ReorderablePhotoTile(
          index: i,
          enabled: images.length > 1,
          onReorder: onReorder,
          feedback: SizedBox(
            width: 96,
            height: 96,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kRegisterRadius),
              child: _phaseImageWidget(images[i]),
            ),
          ),
          child: _PhaseThumb(image: images[i], onRemove: () => onRemove(i)),
        ),
      if (images.length < maxModImagesPerPhase) _PhaseAddTile(onTap: onAdd),
    ];
    while (cells.length < maxModImagesPerPhase) {
      cells.add(const SizedBox(height: 96));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterFieldLabel(label),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < cells.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: cells[i]),
            ],
          ],
        ),
      ],
    );
  }
}

Widget _phaseImageWidget(_PhaseImage image) => switch (image) {
      _NewPhaseImage(:final image) =>
        Image.file(File(image.path), fit: BoxFit.cover),
      _KeptPhaseImage(:final media) =>
        Image.network(media.url, fit: BoxFit.cover),
    };

class _PhaseThumb extends StatelessWidget {
  final _PhaseImage image;
  final VoidCallback onRemove;

  const _PhaseThumb({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(kRegisterRadius),
            child: _phaseImageWidget(image),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(140),
                  borderRadius: BorderRadius.circular(kRegisterRadius),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseAddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _PhaseAddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: RegisterAddSurface(
        onTap: onTap,
        child: Center(
          child: Icon(
            Icons.add_photo_alternate_rounded,
            color: AppColors.muteSoft,
            size: 26,
          ),
        ),
      ),
    );
  }
}
