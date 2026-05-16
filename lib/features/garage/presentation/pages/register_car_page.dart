import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/car_status_option.dart';
import '../../domain/entities/reference_data.dart';
import '../../domain/repositories/garage_repository.dart';
import '../bloc/add_car/bloc.dart';
import '../bloc/add_car/event.dart';
import '../bloc/add_car/state.dart';

class RegisterCarPage extends StatefulWidget {
  const RegisterCarPage({super.key});

  @override
  State<RegisterCarPage> createState() => _RegisterCarPageState();
}

class _RegisterCarPageState extends State<RegisterCarPage> {
  static const _stepCount = 6;

  int _step = 0;

  // Step 1 — Identity
  String? _coverFilePath;
  CarBrandEntity? _selectedBrand;
  CarModelEntity? _selectedModel;
  final _yearCtrl = TextEditingController();
  final _chassisCodeCtrl = TextEditingController();

  // Step 2 — Performance
  final _hpCtrl = TextEditingController();
  final _torqueCtrl = TextEditingController();
  final _zeroToHundredCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _displacementCtrl = TextEditingController();

  // Step 3 — Drivetrain
  CarDrivetrainEntity? _selectedDrivetrain;
  CarColorEntity? _selectedColor;
  CarDistanceUnitEntity? _selectedDistanceUnit;
  final _engineCodeCtrl = TextEditingController();

  // Step 4 — Story
  CarStatusOptionEntity? _selectedStatus;

  // Step 5 — Gallery
  final List<String> _galleryFilePaths = [];

  // Step 6 — Modifications
  final List<NewModInput> _mods = [];

  @override
  void dispose() {
    _yearCtrl.dispose();
    _chassisCodeCtrl.dispose();
    _hpCtrl.dispose();
    _torqueCtrl.dispose();
    _zeroToHundredCtrl.dispose();
    _weightCtrl.dispose();
    _displacementCtrl.dispose();
    _engineCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCarBloc, AddCarState>(
      listener: (context, state) {
        if (state is AddCarSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Machine registered!')),
          );
          context.pop();
        }
        if (state is AddCarError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is AddCarSubmitting;
        final submitLabel =
            state is AddCarSubmitting ? state.statusLabel : null;
        final refData = switch (state) {
          AddCarRefDataLoaded() => state,
          AddCarSubmitting(:final refData) => refData,
          AddCarError(:final refData) => refData,
          _ => null,
        };

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(onClose: () => context.pop()),
                _StepIndicator(current: _step),
                if (state is AddCarRefDataLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  )
                else if (state is AddCarRefDataError)
                  Expanded(
                    child: _RefDataError(
                      message: state.message,
                      onRetry: () => context
                          .read<AddCarBloc>()
                          .add(const LoadAddCarReferenceData()),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      child: _stepContent(context, refData),
                    ),
                  ),
                _BottomBar(
                  step: _step,
                  stepCount: _stepCount,
                  isSubmitting: isSubmitting,
                  submitLabel: submitLabel,
                  onBack: _step > 0 ? () => setState(() => _step--) : null,
                  onNext: refData != null ? () => _onNext(context, refData) : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stepContent(BuildContext context, AddCarRefDataLoaded? refData) {
    return switch (_step) {
      0 => _IdentityStep(
          coverFilePath: _coverFilePath,
          selectedBrand: _selectedBrand,
          selectedModel: _selectedModel,
          models: refData?.models ?? [],
          modelsLoading: refData?.modelsLoading ?? false,
          brands: refData?.brands ?? [],
          yearCtrl: _yearCtrl,
          chassisCodeCtrl: _chassisCodeCtrl,
          onPickCover: () => _pickCover(),
          onSelectBrand: (brand) {
            setState(() {
              _selectedBrand = brand;
              _selectedModel = null;
            });
            context.read<AddCarBloc>().add(AddCarBrandSelected(brand.id));
          },
          onSelectModel: (m) => setState(() => _selectedModel = m),
        ),
      1 => _PerformanceStep(
          hpCtrl: _hpCtrl,
          torqueCtrl: _torqueCtrl,
          zeroToHundredCtrl: _zeroToHundredCtrl,
          weightCtrl: _weightCtrl,
          displacementCtrl: _displacementCtrl,
        ),
      2 => _DrivetrainStep(
          drivetrains: refData?.drivetrains ?? [],
          colors: refData?.colors ?? [],
          distanceUnits: refData?.distanceUnits ?? [],
          selectedDrivetrain: _selectedDrivetrain,
          selectedColor: _selectedColor,
          selectedDistanceUnit: _selectedDistanceUnit,
          engineCodeCtrl: _engineCodeCtrl,
          onSelectDrivetrain: (d) => setState(() => _selectedDrivetrain = d),
          onSelectColor: (c) => setState(() => _selectedColor = c),
          onSelectDistanceUnit: (u) => setState(() => _selectedDistanceUnit = u),
        ),
      3 => _StoryStep(
          statusOptions: refData?.statusOptions ?? [],
          selectedStatus: _selectedStatus,
          onSelectStatus: (s) => setState(() => _selectedStatus = s),
        ),
      4 => _GalleryStep(
          filePaths: _galleryFilePaths,
          onAdd: _pickGalleryImages,
          onRemove: (i) => setState(() => _galleryFilePaths.removeAt(i)),
        ),
      5 => _ModificationsStep(
          mods: _mods,
          onAdd: () => _addModification(context, refData),
          onRemove: (i) => setState(() => _mods.removeAt(i)),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _coverFilePath = file.path);
  }

  Future<void> _pickGalleryImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;
    setState(() => _galleryFilePaths.addAll(files.map((f) => f.path)));
  }

  Future<void> _addModification(
    BuildContext context,
    AddCarRefDataLoaded? refData,
  ) async {
    if (refData == null) return;
    final result = await showModalBottomSheet<NewModInput>(
      context: context,
      backgroundColor: AppColors.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _AddModSheet(categories: refData.modCategories),
    );
    if (result != null) {
      setState(() => _mods.add(result));
    }
  }

  void _onNext(BuildContext context, AddCarRefDataLoaded refData) {
    if (_step < _stepCount - 1) {
      if (!_validateStep(context)) return;
      setState(() => _step++);
      return;
    }
    _submit(context);
  }

  bool _validateStep(BuildContext context) {
    String? error;
    switch (_step) {
      case 0:
        if (_coverFilePath == null) {
          error = 'Please pick a cover photo.';
        } else if (_selectedBrand == null) {
          error = 'Please select a brand.';
        } else if (_selectedModel == null) {
          error = 'Please select a model.';
        } else if (_yearCtrl.text.trim().isEmpty) {
          error = 'Please enter the year.';
        }
      case 1:
        if (_hpCtrl.text.trim().isEmpty) {
          error = 'Please enter horsepower.';
        } else if (_torqueCtrl.text.trim().isEmpty) {
          error = 'Please enter torque.';
        } else if (_weightCtrl.text.trim().isEmpty) {
          error = 'Please enter weight.';
        } else if (_displacementCtrl.text.trim().isEmpty) {
          error = 'Please enter displacement.';
        }
      case 2:
        if (_selectedDrivetrain == null) {
          error = 'Please select a drivetrain.';
        } else if (_selectedColor == null) {
          error = 'Please select a color.';
        } else if (_selectedDistanceUnit == null) {
          error = 'Please select a mileage unit.';
        }
      case 3:
        if (_selectedStatus == null) {
          error = 'Please select a status.';
        }
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return false;
    }
    return true;
  }

  void _submit(BuildContext context) {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a status.')),
      );
      return;
    }

    context.read<AddCarBloc>().add(
          SubmitNewCar(
            coverFilePath: _coverFilePath!,
            galleryFilePaths: List.of(_galleryFilePaths),
            mods: List.of(_mods),
            car: CarRequestParams(
              brandId: _selectedBrand!.id,
              modelId: _selectedModel!.id,
              drivetrainId: _selectedDrivetrain!.id,
              colorId: _selectedColor!.id,
              mileageUnitId: _selectedDistanceUnit!.id,
              year: int.parse(_yearCtrl.text.trim()),
              horsepower: int.parse(_hpCtrl.text.trim()),
              torque: int.parse(_torqueCtrl.text.trim()),
              weight: int.parse(_weightCtrl.text.trim()),
              engineDisplacement: double.parse(_displacementCtrl.text.trim()),
              zeroToOneHundred: _zeroToHundredCtrl.text.trim().isNotEmpty
                  ? double.tryParse(_zeroToHundredCtrl.text.trim())
                  : null,
              chassisCode: _chassisCodeCtrl.text.trim().isEmpty
                  ? null
                  : _chassisCodeCtrl.text.trim(),
              engineCode: _engineCodeCtrl.text.trim().isEmpty
                  ? null
                  : _engineCodeCtrl.text.trim(),
              statusId: _selectedStatus!.id,
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
          const Expanded(
            child: Center(
              child: Text(
                'KINETIC EDGE',
                style: TextStyle(
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

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  static const _labels = [
    'IDENTITY',
    'PERFORMANCE',
    'DRIVETRAIN',
    'STORY',
    'GALLERY',
    'MODS',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final active = i == current;
          final done = i < current;
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.ink
                        : (done ? AppColors.ink2 : Colors.transparent),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color:
                          active || done ? AppColors.ink : AppColors.muteSoft,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: active || done
                            ? Colors.white
                            : AppColors.muteSoft,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _labels[i],
                  style: TextStyle(
                    color: active ? AppColors.ink : AppColors.muteSoft,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Bottom navigation bar ─────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int step;
  final int stepCount;
  final bool isSubmitting;
  final String? submitLabel;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  const _BottomBar({
    required this.step,
    required this.stepCount,
    required this.isSubmitting,
    this.submitLabel,
    this.onBack,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = step == stepCount - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          if (onBack != null && !isSubmitting)
            Expanded(
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Center(
                    child: Text(
                      'BACK',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (onBack != null && !isSubmitting) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: isSubmitting ? null : onNext,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isSubmitting ? AppColors.muteSoft : AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isSubmitting
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              submitLabel ?? 'Working…',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          isLast ? 'REGISTER MACHINE' : 'NEXT',
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
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Identity ──────────────────────────────────────────────────────────

class _IdentityStep extends StatelessWidget {
  final String? coverFilePath;
  final CarBrandEntity? selectedBrand;
  final CarModelEntity? selectedModel;
  final List<CarBrandEntity> brands;
  final List<CarModelEntity> models;
  final bool modelsLoading;
  final TextEditingController yearCtrl;
  final TextEditingController chassisCodeCtrl;
  final VoidCallback onPickCover;
  final ValueChanged<CarBrandEntity> onSelectBrand;
  final ValueChanged<CarModelEntity> onSelectModel;

  const _IdentityStep({
    required this.coverFilePath,
    required this.selectedBrand,
    required this.selectedModel,
    required this.brands,
    required this.models,
    required this.modelsLoading,
    required this.yearCtrl,
    required this.chassisCodeCtrl,
    required this.onPickCover,
    required this.onSelectBrand,
    required this.onSelectModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: '01 — IDENTITY', title: 'Visual & basics'),
        const SizedBox(height: 16),
        _FieldLabel('PRIMARY ASSET'),
        const SizedBox(height: 8),
        _CoverPicker(filePath: coverFilePath, onTap: onPickCover),
        const SizedBox(height: 16),
        _FieldLabel('MAKE'),
        const SizedBox(height: 8),
        _SelectorTile(
          placeholder: 'e.g. Porsche',
          value: selectedBrand?.name,
          onTap: () => _showBrandPicker(context),
        ),
        const SizedBox(height: 12),
        _FieldLabel('MODEL'),
        const SizedBox(height: 8),
        _SelectorTile(
          placeholder:
              selectedBrand == null ? 'Select a brand first' : 'e.g. 911 GT3 RS',
          value: selectedModel?.model,
          loading: modelsLoading,
          onTap: selectedBrand == null || modelsLoading
              ? null
              : () => _showModelPicker(context),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('YEAR'),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: yearCtrl,
                    hint: '2024',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
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
                  _FieldLabel('CHASSIS CODE'),
                  const SizedBox(height: 8),
                  _FormField(controller: chassisCodeCtrl, hint: 'e.g. G82'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showBrandPicker(BuildContext context) {
    _showPickerSheet<CarBrandEntity>(
      context: context,
      title: 'Select Brand',
      items: brands,
      labelOf: (b) => b.name,
      onSelected: onSelectBrand,
    );
  }

  void _showModelPicker(BuildContext context) {
    _showPickerSheet<CarModelEntity>(
      context: context,
      title: 'Select Model',
      items: models,
      labelOf: (m) => m.model,
      onSelected: onSelectModel,
    );
  }
}

// ── Step 2: Performance ───────────────────────────────────────────────────────

class _PerformanceStep extends StatelessWidget {
  final TextEditingController hpCtrl;
  final TextEditingController torqueCtrl;
  final TextEditingController zeroToHundredCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController displacementCtrl;

  const _PerformanceStep({
    required this.hpCtrl,
    required this.torqueCtrl,
    required this.zeroToHundredCtrl,
    required this.weightCtrl,
    required this.displacementCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: '02 — PERFORMANCE', title: 'Power & weight'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _LabeledField(
                  label: 'POWER (HP)', ctrl: hpCtrl, hint: '503', isNumber: true),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LabeledField(
                  label: 'TORQUE (NM)',
                  ctrl: torqueCtrl,
                  hint: '650',
                  isNumber: true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LabeledField(
                label: '0–100 (SEC)',
                ctrl: zeroToHundredCtrl,
                hint: '3.9',
                isDecimal: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LabeledField(
                  label: 'WEIGHT (KG)',
                  ctrl: weightCtrl,
                  hint: '1650',
                  isNumber: true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'DISPLACEMENT (L)',
          ctrl: displacementCtrl,
          hint: '3.0',
          isDecimal: true,
        ),
      ],
    );
  }
}

// ── Step 3: Drivetrain ────────────────────────────────────────────────────────

class _DrivetrainStep extends StatelessWidget {
  final List<CarDrivetrainEntity> drivetrains;
  final List<CarColorEntity> colors;
  final List<CarDistanceUnitEntity> distanceUnits;
  final CarDrivetrainEntity? selectedDrivetrain;
  final CarColorEntity? selectedColor;
  final CarDistanceUnitEntity? selectedDistanceUnit;
  final TextEditingController engineCodeCtrl;
  final ValueChanged<CarDrivetrainEntity> onSelectDrivetrain;
  final ValueChanged<CarColorEntity> onSelectColor;
  final ValueChanged<CarDistanceUnitEntity> onSelectDistanceUnit;

  const _DrivetrainStep({
    required this.drivetrains,
    required this.colors,
    required this.distanceUnits,
    required this.selectedDrivetrain,
    required this.selectedColor,
    required this.selectedDistanceUnit,
    required this.engineCodeCtrl,
    required this.onSelectDrivetrain,
    required this.onSelectColor,
    required this.onSelectDistanceUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: '03 — DRIVETRAIN', title: 'Configuration'),
        const SizedBox(height: 16),
        _FieldLabel('DRIVETRAIN'),
        const SizedBox(height: 8),
        _SelectorTile(
          placeholder: 'e.g. Rear-Wheel Drive',
          value: selectedDrivetrain?.name,
          onTap: () => _showPickerSheet<CarDrivetrainEntity>(
            context: context,
            title: 'Select Drivetrain',
            items: drivetrains,
            labelOf: (d) => d.name,
            onSelected: onSelectDrivetrain,
          ),
        ),
        const SizedBox(height: 12),
        _FieldLabel('COLOR'),
        const SizedBox(height: 8),
        _SelectorTile(
          placeholder: 'e.g. Inka Orange',
          value: selectedColor?.name,
          onTap: () => _showPickerSheet<CarColorEntity>(
            context: context,
            title: 'Select Color',
            items: colors,
            labelOf: (c) => c.name,
            onSelected: onSelectColor,
          ),
        ),
        const SizedBox(height: 12),
        _FieldLabel('MILEAGE UNIT'),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final unit in distanceUnits)
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelectDistanceUnit(unit),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: distanceUnits.last == unit ? 0 : 8,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selectedDistanceUnit?.id == unit.id
                          ? AppColors.ink
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedDistanceUnit?.id == unit.id
                            ? AppColors.ink
                            : AppColors.line,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        unit.name.toUpperCase(),
                        style: TextStyle(
                          color: selectedDistanceUnit?.id == unit.id
                              ? Colors.white
                              : AppColors.ink2,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'ENGINE CODE',
          ctrl: engineCodeCtrl,
          hint: 'e.g. S58',
        ),
      ],
    );
  }
}

// ── Step 4: Story ─────────────────────────────────────────────────────────────

class _StoryStep extends StatelessWidget {
  final List<CarStatusOptionEntity> statusOptions;
  final CarStatusOptionEntity? selectedStatus;
  final ValueChanged<CarStatusOptionEntity> onSelectStatus;

  const _StoryStep({
    required this.statusOptions,
    required this.selectedStatus,
    required this.onSelectStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: '04 — STORY', title: "What's this machine's role?"),
        const SizedBox(height: 16),
        _FieldLabel('STATUS'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final option in statusOptions)
              GestureDetector(
                onTap: () => onSelectStatus(option),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedStatus?.id == option.id
                        ? AppColors.ink
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selectedStatus?.id == option.id
                          ? AppColors.ink
                          : AppColors.line,
                    ),
                  ),
                  child: Text(
                    option.type.toUpperCase(),
                    style: TextStyle(
                      color: selectedStatus?.id == option.id
                          ? Colors.white
                          : AppColors.ink2,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Step 5: Gallery ───────────────────────────────────────────────────────────

class _GalleryStep extends StatelessWidget {
  final List<String> filePaths;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _GalleryStep({
    required this.filePaths,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: '05 — GALLERY', title: 'Show it off (optional)'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filePaths.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, i) {
            if (i == filePaths.length) {
              return GestureDetector(
                onTap: onAdd,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Icon(Icons.add_a_photo_outlined,
                      color: AppColors.mute),
                ),
              );
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(filePaths[i]), fit: BoxFit.cover),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => onRemove(i),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ── Step 6: Modifications ─────────────────────────────────────────────────────

class _ModificationsStep extends StatelessWidget {
  final List<NewModInput> mods;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _ModificationsStep({
    required this.mods,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
            label: '06 — MODS', title: 'Build log (optional)'),
        const SizedBox(height: 16),
        for (var i = 0; i < mods.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    mods[i].request.title,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onRemove(i),
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.mute, size: 20),
                ),
              ],
            ),
          ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: const Center(
              child: Text(
                '+ ADD MODIFICATION',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Add-modification bottom sheet ──────────────────────────────────────────────

class _AddModSheet extends StatefulWidget {
  final List<CarModCategoryEntity> categories;

  const _AddModSheet({required this.categories});

  @override
  State<_AddModSheet> createState() => _AddModSheetState();
}

class _AddModSheetState extends State<_AddModSheet> {
  CarModCategoryEntity? _category;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  String? _beforeFilePath;
  String? _afterFilePath;
  DateTime? _date;
  bool _isPricePublic = false;

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
    setState(() {
      if (isBefore) {
        _beforeFilePath = file.path;
      } else {
        _afterFilePath = file.path;
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
        _beforeFilePath == null ||
        _afterFilePath == null ||
        _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Category, title, date and both images required.')),
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
        beforeFilePath: _beforeFilePath!,
        afterFilePath: _afterFilePath!,
        request: ModRequestParams(
          categoryId: _category!.id,
          title: _titleCtrl.text.trim(),
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          installationDate: _date!,
          price: price,
          isPricePublic: price != null && _isPricePublic,
          mileageAtInstall: mileage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SectionHeader(
                  label: '— MODIFICATION', title: 'Add a build item'),
              const SizedBox(height: 16),
              _FieldLabel('CATEGORY'),
              const SizedBox(height: 8),
              _SelectorTile(
                placeholder: 'e.g. Engine',
                value: _category?.modName,
                onTap: () => _showPickerSheet<CarModCategoryEntity>(
                  context: context,
                  title: 'Select Category',
                  items: widget.categories,
                  labelOf: (c) => c.modName,
                  onSelected: (c) => setState(() => _category = c),
                ),
              ),
              const SizedBox(height: 12),
              _FieldLabel('TITLE'),
              const SizedBox(height: 8),
              _FormField(controller: _titleCtrl, hint: 'e.g. Stage 2 turbo'),
              const SizedBox(height: 12),
              _FieldLabel('DESCRIPTION (OPTIONAL)'),
              const SizedBox(height: 8),
              _FormField(controller: _descCtrl, hint: 'Notes…', maxLines: 3),
              const SizedBox(height: 12),
              _FieldLabel('BEFORE & AFTER'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _SheetImageSlot(
                      label: 'BEFORE',
                      filePath: _beforeFilePath,
                      onTap: () => _pick(isBefore: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetImageSlot(
                      label: 'AFTER',
                      filePath: _afterFilePath,
                      onTap: () => _pick(isBefore: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _FieldLabel('INSTALLATION DATE'),
              const SizedBox(height: 8),
              _SelectorTile(
                placeholder: 'Select date',
                value: _date != null
                    ? '${_date!.day}/${_date!.month}/${_date!.year}'
                    : null,
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              _FieldLabel('PRICE (OPTIONAL)'),
              const SizedBox(height: 8),
              _FormField(
                controller: _priceCtrl,
                hint: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => setState(() => _isPricePublic = !_isPricePublic),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _isPricePublic
                            ? AppColors.accent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _isPricePublic
                              ? AppColors.accent
                              : AppColors.line,
                        ),
                      ),
                      child: _isPricePublic
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    const Text('Make price visible to others',
                        style: TextStyle(
                            color: AppColors.ink2,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _FieldLabel('MILEAGE AT INSTALL (OPTIONAL)'),
              const SizedBox(height: 8),
              _FormField(
                controller: _mileageCtrl,
                hint: 'e.g. 45000',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _done,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'ADD',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetImageSlot extends StatelessWidget {
  final String label;
  final String? filePath;
  final VoidCallback onTap;

  const _SheetImageSlot({
    required this.label,
    required this.filePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
          image: filePath != null
              ? DecorationImage(
                  image: FileImage(File(filePath!)), fit: BoxFit.cover)
              : null,
        ),
        child: filePath == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.mute, size: 24),
                    const SizedBox(height: 4),
                    Text(label,
                        style: const TextStyle(
                            color: AppColors.mute,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              )
            : null,
      ),
    );
  }
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

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
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
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
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

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final bool isNumber;
  final bool isDecimal;

  const _LabeledField({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.isNumber = false,
    this.isDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 8),
        _FormField(
          controller: ctrl,
          hint: hint,
          keyboardType: isDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : isNumber
                  ? TextInputType.number
                  : null,
          inputFormatters: isNumber
              ? [FilteringTextInputFormatter.digitsOnly]
              : isDecimal
                  ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
                  : null,
        ),
      ],
    );
  }
}

class _SelectorTile extends StatelessWidget {
  final String placeholder;
  final String? value;
  final bool loading;
  final VoidCallback? onTap;

  const _SelectorTile({
    required this.placeholder,
    this.value,
    this.loading = false,
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
              child: loading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.mute,
                      ),
                    )
                  : Text(
                      value ?? placeholder,
                      style: TextStyle(
                        color:
                            value != null ? AppColors.ink : AppColors.muteSoft,
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

class _CoverPicker extends StatelessWidget {
  final String? filePath;
  final VoidCallback onTap;

  const _CoverPicker({required this.filePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
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
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_outlined,
                          color: AppColors.accent, size: 26),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Pick Studio Shot',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap to pick from gallery',
                      style: TextStyle(color: AppColors.mute, fontSize: 12),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}

class _RefDataError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RefDataError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.mute)),
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
                child: const Text('Retry',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Generic picker bottom sheet ───────────────────────────────────────────────

void _showPickerSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  required ValueChanged<T> onSelected,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.6,
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
              title,
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
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                color: AppColors.line,
              ),
              itemBuilder: (ctx, i) => ListTile(
                title: Text(
                  labelOf(items[i]),
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onSelected(items[i]);
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
