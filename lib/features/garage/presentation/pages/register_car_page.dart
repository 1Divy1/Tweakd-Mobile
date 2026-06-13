import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/car_image_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/car_status_option.dart';
import '../../domain/entities/reference_data.dart';
import '../../domain/repositories/garage_repository.dart';
import '../bloc/add_car/bloc.dart';
import '../bloc/add_car/event.dart';
import '../bloc/add_car/state.dart';
import '../widgets/register_car/add_mod_sheet.dart';
import '../widgets/register_car/drivetrain_step.dart';
import '../widgets/register_car/gallery_step.dart';
import '../widgets/register_car/identity_step.dart';
import '../widgets/register_car/mods_step.dart';
import '../widgets/register_car/performance_step.dart';
import '../widgets/register_car/register_car_chrome.dart';
import '../widgets/register_car/register_car_fields.dart';
import '../widgets/register_car/story_step.dart';

class RegisterCarPage extends StatefulWidget {
  const RegisterCarPage({super.key});

  @override
  State<RegisterCarPage> createState() => _RegisterCarPageState();
}

class _RegisterCarPageState extends State<RegisterCarPage> {
  // Compression is started the moment an image is picked, so the bytes are
  // ready by the time the user reaches the submit step.
  final CarImageService _imageService = getIt<CarImageService>();

  int _step = 0;

  // Step 1 — Identity
  CompressedImage? _cover;
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
  final _engineCodeCtrl = TextEditingController();
  CarFuelTypeOptionEntity? _selectedFuelType;

  // Step 3 — Configuration
  CarDrivetrainEntity? _selectedDrivetrain;
  CarColorEntity? _selectedColor;
  CarDistanceUnitEntity? _selectedDistanceUnit;

  // Step 4 — Story
  CarStatusOptionEntity? _selectedStatus;

  // Step 5 — Gallery
  final List<CompressedImage> _gallery = [];

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
                RegisterTopBar(step: _step, onClose: () => context.pop()),
                RegisterStepProgress(step: _step),
                if (state is AddCarRefDataLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  )
                else if (state is AddCarRefDataError)
                  Expanded(
                    child: RegisterRefDataError(
                      message: state.message,
                      onRetry: () => context
                          .read<AddCarBloc>()
                          .add(const LoadAddCarReferenceData()),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      child: _stepContent(context, refData),
                    ),
                  ),
                RegisterBottomBar(
                  step: _step,
                  isSubmitting: isSubmitting,
                  submitLabel: submitLabel,
                  onBack: _step > 0 ? () => setState(() => _step--) : null,
                  onNext:
                      refData != null ? () => _onNext(context, refData) : null,
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
      0 => IdentityStep(
          coverFilePath: _cover?.path,
          selectedBrand: _selectedBrand,
          selectedModel: _selectedModel,
          models: refData?.models ?? [],
          modelsLoading: refData?.modelsLoading ?? false,
          brands: refData?.brands ?? [],
          yearCtrl: _yearCtrl,
          chassisCodeCtrl: _chassisCodeCtrl,
          onPickCover: _pickCover,
          onSelectBrand: (brand) {
            setState(() {
              _selectedBrand = brand;
              _selectedModel = null;
            });
            context.read<AddCarBloc>().add(AddCarBrandSelected(brand.id));
          },
          onSelectModel: (m) => setState(() => _selectedModel = m),
        ),
      1 => PerformanceStep(
          hpCtrl: _hpCtrl,
          torqueCtrl: _torqueCtrl,
          zeroToHundredCtrl: _zeroToHundredCtrl,
          weightCtrl: _weightCtrl,
          displacementCtrl: _displacementCtrl,
          engineCodeCtrl: _engineCodeCtrl,
          fuelTypeOptions: refData?.fuelTypeOptions ?? [],
          selectedFuelType: _selectedFuelType,
          onSelectFuelType: (f) => setState(() => _selectedFuelType = f),
        ),
      2 => DrivetrainStep(
          drivetrains: refData?.drivetrains ?? [],
          colors: refData?.colors ?? [],
          distanceUnits: refData?.distanceUnits ?? [],
          selectedDrivetrain: _selectedDrivetrain,
          selectedColor: _selectedColor,
          selectedDistanceUnit: _selectedDistanceUnit,
          onSelectDrivetrain: (d) => setState(() => _selectedDrivetrain = d),
          onSelectColor: (c) => setState(() => _selectedColor = c),
          onSelectDistanceUnit: (u) => setState(() => _selectedDistanceUnit = u),
        ),
      3 => StoryStep(
          statusOptions: refData?.statusOptions ?? [],
          selectedStatus: _selectedStatus,
          onSelectStatus: (s) => setState(() => _selectedStatus = s),
        ),
      4 => GalleryStep(
          filePaths: _gallery.map((e) => e.path).toList(),
          onAdd: _pickGalleryImages,
          onRemove: (i) => setState(() => _gallery.removeAt(i)),
        ),
      5 => ModsStep(
          mods: _mods,
          categories: refData?.modCategories ?? [],
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
    setState(
        () => _cover = CompressedImage.compress(file.path, _imageService));
  }

  Future<void> _pickGalleryImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;
    setState(() => _gallery.addAll(
          files.map((f) => CompressedImage.compress(f.path, _imageService)),
        ));
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddModSheet(
        categories: refData.modCategories,
        imageService: _imageService,
      ),
    );
    if (result != null) {
      setState(() => _mods.add(result));
    }
  }

  void _onNext(BuildContext context, AddCarRefDataLoaded refData) {
    if (_step < registerStepCount - 1) {
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
        if (_cover == null) {
          error = 'Please pick a cover photo.';
        } else if (_selectedBrand == null) {
          error = 'Please select a make.';
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
            cover: _cover!,
            gallery: List.of(_gallery),
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
              fuelTypeId: _selectedFuelType?.id,
              statusId: _selectedStatus!.id,
            ),
          ),
        );
  }
}
