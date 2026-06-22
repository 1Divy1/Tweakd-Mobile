import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/car_image_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/reference_data.dart';
import '../../domain/repositories/garage_repository.dart';
import '../bloc/log_mod/bloc.dart';
import '../bloc/log_mod/event.dart';
import '../bloc/log_mod/state.dart';
import '../utils/garage_error_mapper.dart';

class LogModificationPage extends StatefulWidget {
  final String carId;

  const LogModificationPage({super.key, required this.carId});

  @override
  State<LogModificationPage> createState() => _LogModificationPageState();
}

class _LogModificationPageState extends State<LogModificationPage> {
  // Compression starts the moment an image is picked, so the bytes are ready
  // by the time the user submits.
  final CarImageService _imageService = getIt<CarImageService>();

  CarModCategoryEntity? _selectedCategory;
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();

  CompressedImage? _before;
  CompressedImage? _after;

  DateTime? _installationDate;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _mileageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogModBloc, LogModState>(
      listener: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        if (state is LogModSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.garageLogModLogged)),
          );
          context.pop();
        }
        if (state is LogModError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(garageErrorMessage(l10n, state.code))),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is LogModSubmitting;
        final categories = switch (state) {
          LogModCategoriesLoaded(:final categories) => categories,
          LogModSubmitting(:final categories) => categories,
          LogModError(:final categories) => categories,
          _ => <CarModCategoryEntity>[],
        };

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(onClose: () => context.pop()),
                if (state is LogModCategoriesLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  )
                else if (state is LogModCategoriesError)
                  Expanded(
                    child: _CategoriesError(
                      message: garageErrorMessage(
                        AppLocalizations.of(context)!,
                        state.code,
                      ),
                      onRetry: () => context
                          .read<LogModBloc>()
                          .add(const LoadModCategories()),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      child: _FormContent(
                        categories: categories,
                        selectedCategory: _selectedCategory,
                        titleCtrl: _titleCtrl,
                        descriptionCtrl: _descriptionCtrl,
                        priceCtrl: _priceCtrl,
                        mileageCtrl: _mileageCtrl,
                        beforeFilePath: _before?.path,
                        afterFilePath: _after?.path,
                        installationDate: _installationDate,
                        onSelectCategory: (c) =>
                            setState(() => _selectedCategory = c),
                        onPickBefore: () => _pickImage(isBefore: true),
                        onPickAfter: () => _pickImage(isBefore: false),
                        onPickDate: () => _pickDate(context),
                      ),
                    ),
                  ),
                _SubmitBar(
                  isSubmitting: isSubmitting,
                  enabled: state is LogModCategoriesLoaded ||
                      state is LogModError,
                  onSubmit: () => _submit(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage({required bool isBefore}) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    // Start compressing immediately so the bytes are ready by submit time.
    final image = CompressedImage.compress(file.path, _imageService);
    setState(() {
      if (isBefore) {
        _before = image;
      } else {
        _after = image;
      }
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _installationDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.surface,
            onSurface: AppColors.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _installationDate = picked);
    }
  }

  void _submit(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String? error;
    if (_selectedCategory == null) {
      error = l10n.garageLogModValCategory;
    } else if (_titleCtrl.text.trim().isEmpty) {
      error = l10n.garageLogModValTitle;
    } else if (_before == null) {
      error = l10n.garageLogModValBefore;
    } else if (_after == null) {
      error = l10n.garageLogModValAfter;
    } else if (_installationDate == null) {
      error = l10n.garageLogModValDate;
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final price = _priceCtrl.text.trim().isNotEmpty
        ? double.tryParse(_priceCtrl.text.trim())
        : null;
    final mileage = _mileageCtrl.text.trim().isNotEmpty
        ? int.tryParse(_mileageCtrl.text.trim())
        : null;

    context.read<LogModBloc>().add(
          SubmitModification(
            carId: widget.carId,
            before: _before,
            after: _after,
            params: ModRequestParams(
              categoryId: _selectedCategory!.id,
              title: _titleCtrl.text.trim(),
              description: _descriptionCtrl.text.trim().isEmpty
                  ? null
                  : _descriptionCtrl.text.trim(),
              installationDate: _installationDate!,
              price: price,
              mileageAtInstall: mileage,
            ),
          ),
        );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onClose;
  const _TopBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(Icons.close, size: 18, color: AppColors.ink),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.garageLogModTitle,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// ── Submit bar ────────────────────────────────────────────────────────────────

class _SubmitBar extends StatelessWidget {
  final bool isSubmitting;
  final bool enabled;
  final VoidCallback onSubmit;

  const _SubmitBar({
    required this.isSubmitting,
    required this.enabled,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: GestureDetector(
        onTap: (isSubmitting || !enabled) ? null : onSubmit,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: (isSubmitting || !enabled)
                ? AppColors.muteSoft
                : AppColors.accent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    AppLocalizations.of(context)!.garageLogModSubmit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Form content ──────────────────────────────────────────────────────────────

class _FormContent extends StatelessWidget {
  final List<CarModCategoryEntity> categories;
  final CarModCategoryEntity? selectedCategory;
  final TextEditingController titleCtrl;
  final TextEditingController descriptionCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController mileageCtrl;
  final String? beforeFilePath;
  final String? afterFilePath;
  final DateTime? installationDate;
  final ValueChanged<CarModCategoryEntity> onSelectCategory;
  final VoidCallback onPickBefore;
  final VoidCallback onPickAfter;
  final VoidCallback onPickDate;

  const _FormContent({
    required this.categories,
    required this.selectedCategory,
    required this.titleCtrl,
    required this.descriptionCtrl,
    required this.priceCtrl,
    required this.mileageCtrl,
    required this.beforeFilePath,
    required this.afterFilePath,
    required this.installationDate,
    required this.onSelectCategory,
    required this.onPickBefore,
    required this.onPickAfter,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          label: l10n.garageLogModSectionLabel,
          title: l10n.garageLogModSectionTitle,
        ),
        const SizedBox(height: 20),

        // Category
        _FieldLabel(l10n.garageFieldCategory),
        const SizedBox(height: 8),
        _SelectorTile(
          placeholder: l10n.garageLogModCategoryHint,
          value: selectedCategory?.modName,
          onTap: () => _showCategoryPicker(context),
        ),
        const SizedBox(height: 14),

        // Title
        _FieldLabel(l10n.garageFieldTitle),
        const SizedBox(height: 8),
        _InputField(
          controller: titleCtrl,
          hint: l10n.garageLogModTitleHint,
          maxLines: 1,
        ),
        const SizedBox(height: 14),

        // Description
        _FieldLabel(l10n.garageLogModDescLabel),
        const SizedBox(height: 8),
        _InputField(
          controller: descriptionCtrl,
          hint: l10n.garageLogModDescHint,
          maxLines: 4,
        ),
        const SizedBox(height: 20),

        // Before / After images
        _FieldLabel(l10n.garageLogModBeforeAfter),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ImageSlot(
                label: l10n.garageModBefore,
                filePath: beforeFilePath,
                onTap: onPickBefore,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ImageSlot(
                label: l10n.garageModAfter,
                filePath: afterFilePath,
                onTap: onPickAfter,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Installation date
        _FieldLabel(l10n.garageLogModInstallDate),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    installationDate != null
                        ? _formatDate(installationDate!)
                        : l10n.garageSelectDate,
                    style: TextStyle(
                      color: installationDate != null
                          ? AppColors.ink
                          : AppColors.muteSoft,
                      fontSize: 14,
                      fontWeight: installationDate != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.mute, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Price (optional)
        _FieldLabel(l10n.garageLogModPriceLabel),
        const SizedBox(height: 8),
        _InputField(
          controller: priceCtrl,
          hint: '0.00',
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
        ),
        const SizedBox(height: 20),

        // Mileage at install (optional)
        _FieldLabel(l10n.garageLogModMileageLabel),
        const SizedBox(height: 8),
        _InputField(
          controller: mileageCtrl,
          hint: l10n.garageLogModMileageHint,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                AppLocalizations.of(context)!.garagePickerCategory,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.line),
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                itemCount: categories.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.line),
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(
                    categories[i].modName,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onSelectCategory(categories[i]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final String title;

  const _SectionHeader({required this.label, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.muteSoft, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _SelectorTile extends StatelessWidget {
  final String placeholder;
  final String? value;
  final VoidCallback? onTap;

  const _SelectorTile({
    required this.placeholder,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? placeholder,
                style: TextStyle(
                  color: value != null ? AppColors.ink : AppColors.muteSoft,
                  fontSize: 14,
                  fontWeight:
                      value != null ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            const Icon(Icons.expand_more, color: AppColors.mute, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ImageSlot extends StatelessWidget {
  final String label;
  final String? filePath;
  final VoidCallback onTap;

  const _ImageSlot({
    required this.label,
    required this.filePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
          image: filePath != null
              ? DecorationImage(
                  image: FileImage(File(filePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: filePath == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.mute,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.mute,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              )
            : Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _CategoriesError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CategoriesError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mute),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context)!.commonRetry,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
