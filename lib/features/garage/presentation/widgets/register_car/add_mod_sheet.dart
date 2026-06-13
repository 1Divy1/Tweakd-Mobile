import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/services/car_image_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/reference_data.dart';
import '../../../domain/repositories/garage_repository.dart';
import '../../bloc/add_car/event.dart';
import 'register_car_fields.dart';

const _monthsTitle = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Bottom sheet for composing a single build-log item. Returns a [NewModInput]
/// on success. The price is optional and, when supplied, is always public
class AddModSheet extends StatefulWidget {
  final List<CarModCategoryEntity> categories;
  final CarImageService imageService;

  const AddModSheet({
    super.key,
    required this.categories,
    required this.imageService,
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
  CompressedImage? _before;
  CompressedImage? _after;
  DateTime? _date;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _mileageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool isBefore}) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    // Start compressing immediately so the bytes are ready by submit time.
    final image = CompressedImage.compress(file.path, widget.imageService);
    setState(() {
      if (isBefore) {
        _before = image;
      } else {
        _after = image;
      }
    });
  }

  void _removeImage({required bool isBefore}) {
    setState(() {
      if (isBefore) {
        _before = null;
      } else {
        _after = null;
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
    if (_category == null ||
        _titleCtrl.text.trim().isEmpty ||
        _before == null ||
        _after == null ||
        _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category, title, date and both images are required.'),
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

    Navigator.of(context).pop(
      NewModInput(
        before: _before,
        after: _after,
        request: ModRequestParams(
          categoryId: _category!.id,
          title: _titleCtrl.text.trim(),
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          installationDate: _date!,
          price: price,
          mileageAtInstall: mileage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        const Expanded(
                          child: RegisterSectionHeader(
                            label: '— MODIFICATION',
                            title: 'Add a build item',
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
                    const RegisterFieldLabel('CATEGORY'),
                    const SizedBox(height: 8),
                    RegisterSelectorTile(
                      placeholder: 'e.g. Engine',
                      value: _category?.modName,
                      onTap: () => showRegisterPicker<CarModCategoryEntity>(
                        context: context,
                        title: 'Select Category',
                        items: widget.categories,
                        labelOf: (c) => c.modName,
                        onSelected: (c) => setState(() => _category = c),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const RegisterFieldLabel('TITLE'),
                    const SizedBox(height: 8),
                    RegisterFormField(
                      controller: _titleCtrl,
                      hint: 'e.g. Stage 2 turbo',
                    ),
                    const SizedBox(height: 16),
                    const RegisterFieldLabel('DESCRIPTION', optional: true),
                    const SizedBox(height: 8),
                    RegisterFormField(
                      controller: _descCtrl,
                      hint: 'What changed, and what it gained…',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const RegisterFieldLabel('INSTALLATION DATE'),
                    const SizedBox(height: 8),
                    RegisterSelectorTile(
                      placeholder: 'Select date',
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
                              const RegisterFieldLabel('PRICE', optional: true),
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
                              const RegisterFieldLabel('MILEAGE',
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
                    const RegisterFieldLabel('BEFORE & AFTER'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ImageSlot(
                            label: 'BEFORE',
                            filePath: _before?.path,
                            onTap: () => _pick(isBefore: true),
                            onRemove: () => _removeImage(isBefore: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ImageSlot(
                            label: 'AFTER',
                            filePath: _after?.path,
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'ADD TO BUILD LOG',
                              style: TextStyle(
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
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _ImageSlot({
    required this.label,
    required this.filePath,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = filePath != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
          image: hasImage
              ? DecorationImage(
                  image: FileImage(File(filePath!)), fit: BoxFit.cover)
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
