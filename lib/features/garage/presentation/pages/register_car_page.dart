import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/car_image_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/car_status_option.dart';
import '../../domain/entities/reference_data.dart';
import '../../domain/repositories/garage_repository.dart';
import '../bloc/add_car/bloc.dart';
import '../bloc/add_car/event.dart';
import '../bloc/add_car/state.dart';
import '../widgets/register_car/add_mod_sheet.dart';
import '../widgets/register_car/drivetrain_step.dart';
import '../widgets/register_car/editable_image.dart';
import '../widgets/register_car/gallery_step.dart';
import '../widgets/register_car/identity_step.dart';
import '../widgets/register_car/mod_slot.dart';
import '../widgets/register_car/mods_step.dart';
import '../widgets/register_car/performance_step.dart';
import '../widgets/register_car/register_car_chrome.dart';
import '../widgets/register_car/register_car_fields.dart';
import '../widgets/register_car/story_step.dart';

/// Returns the first element matching [test], or null. Dependency-free
/// alternative to package:collection's firstWhereOrNull.
T? _firstWhereOrNull<T>(List<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}

class RegisterCarPage extends StatefulWidget {
  /// When non-null, the wizard opens in edit mode pre-populated with this car.
  final CarEntity? editCar;

  const RegisterCarPage({super.key, this.editCar});

  @override
  State<RegisterCarPage> createState() => _RegisterCarPageState();
}

class _RegisterCarPageState extends State<RegisterCarPage> {
  // Compression is started the moment an image is picked, so the bytes are
  // ready by the time the user reaches the submit step.
  final CarImageService _imageService = getIt<CarImageService>();

  int _step = 0;

  bool get _isEdit => widget.editCar != null;

  // Guards against a second image_picker request firing before the first
  // finishes — iOS throws PlatformException('multiple_request') otherwise.
  bool _isPicking = false;

  // Guards so the one-time seeding from [editCar] runs only once each.
  bool _seededSelections = false;
  bool _seededModel = false;

  // Step 1 — Identity
  CompressedImage? _cover;
  // Edit mode: the existing cover URL (shown until replaced) and the old URL to
  // delete from R2 once a new cover is picked.
  String? _existingCoverUrl;
  String? _removedCoverUrl;
  CarBrandEntity? _selectedBrand;
  CarModelEntity? _selectedModel;
  final _yearCtrl = TextEditingController();
  final _chassisCodeCtrl = TextEditingController();
  final _modelCodeCtrl = TextEditingController();

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
  final _mileageCtrl = TextEditingController();

  // Step 4 — Story
  CarStatusOptionEntity? _selectedStatus;
  final _storyCtrl = TextEditingController();

  // Step 5 — Gallery. A mix of existing remote photos and new local picks.
  final List<SlotImage> _gallery = [];
  // Edit mode: existing gallery URLs removed by the user (deleted from R2).
  final List<String> _removedGalleryUrls = [];

  // Step 6 — Modifications. New mods to create + existing mods being edited.
  final List<ModSlot> _mods = [];
  // Edit mode: existing mod ids removed by the user (deleted on submit).
  final List<String> _removedModIds = [];

  @override
  void initState() {
    super.initState();
    final car = widget.editCar;
    if (car == null) return;

    // Scalar fields don't depend on reference data — seed them immediately.
    _yearCtrl.text = car.year.toString();
    _chassisCodeCtrl.text = car.chassisCode ?? '';
    _modelCodeCtrl.text = car.modelCode ?? '';
    _hpCtrl.text = car.horsepower.toString();
    _torqueCtrl.text = car.torque.toString();
    _zeroToHundredCtrl.text =
        car.zeroToOneHundred != null ? car.zeroToOneHundred.toString() : '';
    _weightCtrl.text = car.weight.toString();
    _displacementCtrl.text = car.engineDisplacement.toString();
    _engineCodeCtrl.text = car.engineCode ?? '';
    _mileageCtrl.text = car.mileage != null ? car.mileage.toString() : '';
    _storyCtrl.text = car.story ?? '';

    _existingCoverUrl = car.coverImageUrl;
    _gallery.addAll(car.galleryUrls.map((u) => RemoteSlotImage(u)));
    _mods.addAll(car.modifications.map(
      (m) => ExistingModSlot(
        original: m,
        request: ModRequestParams(
          categoryId: m.categoryId,
          title: m.title,
          description: m.description,
          installationDate: m.installationDate,
          price: m.price,
          mileageAtInstall: m.mileageAtInstall,
        ),
        beforeUrl: m.beforeMedia.isEmpty ? null : m.beforeMedia.first.url,
        afterUrl: m.afterMedia.isEmpty ? null : m.afterMedia.first.url,
      ),
    ));
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    _chassisCodeCtrl.dispose();
    _modelCodeCtrl.dispose();
    _mileageCtrl.dispose();
    _storyCtrl.dispose();
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
        if (state is AddCarRefDataLoaded) _seedSelections(context, state);
        if (state is AddCarSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  _isEdit ? 'Changes saved!' : 'Machine registered!'),
            ),
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
                RegisterTopBar(
                  step: _step,
                  onClose: isSubmitting ? () {} : () => _confirmClose(context),
                ),
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
                  lastLabel: _isEdit ? 'SAVE' : 'ADD CAR',
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
          coverNetworkUrl: _existingCoverUrl,
          selectedBrand: _selectedBrand,
          selectedModel: _selectedModel,
          models: refData?.models ?? [],
          modelsLoading: refData?.modelsLoading ?? false,
          brands: refData?.brands ?? [],
          yearCtrl: _yearCtrl,
          chassisCodeCtrl: _chassisCodeCtrl,
          modelCodeCtrl: _modelCodeCtrl,
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
          mileageCtrl: _mileageCtrl,
          onSelectDrivetrain: (d) => setState(() => _selectedDrivetrain = d),
          onSelectColor: (c) => setState(() => _selectedColor = c),
          onSelectDistanceUnit: (u) => setState(() => _selectedDistanceUnit = u),
        ),
      3 => StoryStep(
          statusOptions: refData?.statusOptions ?? [],
          selectedStatus: _selectedStatus,
          storyCtrl: _storyCtrl,
          onSelectStatus: (s) => setState(() => _selectedStatus = s),
        ),
      4 => GalleryStep(
          images: _gallery,
          onAdd: _pickGalleryImages,
          onRemove: _removeGalleryImage,
        ),
      5 => ModsStep(
          mods: _mods,
          categories: refData?.modCategories ?? [],
          onAdd: () => _addModification(context, refData),
          onRemove: _removeMod,
          onEdit: _isEdit ? (i) => _editModification(context, refData, i) : null,
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Future<void> _pickCover() async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      if (!mounted) return;
      setState(() {
        // Replacing an existing cover: remember the old URL so its R2 object is
        // deleted on submit, and clear the network preview.
        if (_existingCoverUrl != null) {
          _removedCoverUrl = _existingCoverUrl;
          _existingCoverUrl = null;
        }
        _cover = CompressedImage.compress(file.path, _imageService);
      });
    } on PlatformException {
      // A pick was already in progress (e.g. a double tap) — safe to ignore.
    } finally {
      _isPicking = false;
    }
  }

  Future<void> _pickGalleryImages() async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final picker = ImagePicker();
      final files = await picker.pickMultiImage();
      if (files.isEmpty) return;
      if (!mounted) return;
      setState(() => _gallery.addAll(
            files.map(
              (f) => LocalSlotImage(
                  CompressedImage.compress(f.path, _imageService)),
            ),
          ));
    } on PlatformException {
      // A pick was already in progress (e.g. a double tap) — safe to ignore.
    } finally {
      _isPicking = false;
    }
  }

  void _removeGalleryImage(int i) {
    setState(() {
      final removed = _gallery.removeAt(i);
      // Existing photos must be deleted from R2 on submit.
      if (removed is RemoteSlotImage) _removedGalleryUrls.add(removed.url);
    });
  }

  void _removeMod(int i) {
    setState(() {
      final removed = _mods.removeAt(i);
      if (removed is ExistingModSlot) _removedModIds.add(removed.modId);
    });
  }

  Future<void> _addModification(
    BuildContext context,
    AddCarRefDataLoaded? refData,
  ) async {
    if (refData == null) return;
    final result = await showModalBottomSheet<ModSlot>(
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

  /// Opens the build-item sheet pre-filled to edit an existing mod, then
  /// replaces the slot with the updated [ExistingModSlot]. New (unsaved) mods
  /// are not editable in place — remove and re-add instead.
  Future<void> _editModification(
    BuildContext context,
    AddCarRefDataLoaded? refData,
    int index,
  ) async {
    if (refData == null) return;
    final slot = _mods[index];
    if (slot is! ExistingModSlot) return;

    final result = await showModalBottomSheet<ModSlot>(
      context: context,
      backgroundColor: AppColors.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddModSheet(
        categories: refData.modCategories,
        imageService: _imageService,
        initialMod: slot.original,
      ),
    );
    if (result != null) {
      setState(() => _mods[index] = result);
    }
  }

  Future<void> _confirmClose(BuildContext context) async {
    final navigator = Navigator.of(context);
    final discard = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Discard this build?',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "You haven't registered this machine yet. If you leave now, "
                'everything you entered will be lost.',
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _CloseDialogButton(
                      label: 'Keep editing',
                      onTap: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CloseDialogButton(
                      label: 'Discard',
                      isDestructive: true,
                      onTap: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (discard == true && navigator.canPop()) navigator.pop();
  }

  void _onNext(BuildContext context, AddCarRefDataLoaded refData) {
    if (_step < registerStepCount - 1) {
      if (!_validateStep(context)) return;
      setState(() => _step++);
      return;
    }
    if (_isEdit) {
      _submitEdit(context);
    } else {
      _submit(context);
    }
  }

  /// Matches the car's saved reference ids against the loaded reference lists
  /// to seed the selection chips/pickers. Runs once for the scalar selections,
  /// then again once the brand's models have loaded to seed the model.
  void _seedSelections(BuildContext context, AddCarRefDataLoaded refData) {
    final car = widget.editCar;
    if (car == null) return;

    if (!_seededSelections) {
      setState(() {
        _selectedBrand =
            _firstWhereOrNull(refData.brands, (b) => b.id == car.brandId);
        _selectedDrivetrain = _firstWhereOrNull(
            refData.drivetrains, (d) => d.id == car.drivetrainId);
        _selectedColor =
            _firstWhereOrNull(refData.colors, (c) => c.id == car.colorId);
        _selectedDistanceUnit = _firstWhereOrNull(
            refData.distanceUnits, (u) => u.id == car.mileageUnitId);
        _selectedFuelType = _firstWhereOrNull(
            refData.fuelTypeOptions, (f) => f.id == car.fuelTypeId);
        _selectedStatus = _firstWhereOrNull(
            refData.statusOptions, (s) => s.id == car.status.id);
      });
      _seededSelections = true;
      // Trigger loading the models for the saved brand so we can match it.
      context.read<AddCarBloc>().add(AddCarBrandSelected(car.brandId));
    }

    if (!_seededModel && refData.models.isNotEmpty) {
      final model =
          _firstWhereOrNull(refData.models, (m) => m.id == car.modelId);
      if (model != null) {
        setState(() => _selectedModel = model);
        _seededModel = true;
      }
    }
  }

  /// Builds the scalar-field payload shared by create and edit submits.
  CarRequestParams _buildCarParams() {
    return CarRequestParams(
      brandId: _selectedBrand!.id,
      modelId: _selectedModel!.id,
      drivetrainId: _selectedDrivetrain!.id,
      colorId: _selectedColor!.id,
      mileageUnitId: _selectedDistanceUnit!.id,
      mileage: _mileageCtrl.text.trim().isNotEmpty
          ? int.tryParse(_mileageCtrl.text.trim())
          : null,
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
      modelCode: _modelCodeCtrl.text.trim().isEmpty
          ? null
          : _modelCodeCtrl.text.trim(),
      engineCode: _engineCodeCtrl.text.trim().isEmpty
          ? null
          : _engineCodeCtrl.text.trim(),
      fuelTypeId: _selectedFuelType!.id,
      story: _storyCtrl.text.trim().isEmpty ? null : _storyCtrl.text.trim(),
      statusId: _selectedStatus!.id,
    );
  }

  void _submitEdit(BuildContext context) {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a status.')),
      );
      return;
    }

    context.read<AddCarBloc>().add(
          SubmitCarEdit(
            carId: widget.editCar!.id,
            car: _buildCarParams(),
            newCover: _cover,
            removedCoverUrl: _removedCoverUrl,
            gallery: List.of(_gallery),
            removedGalleryUrls: List.of(_removedGalleryUrls),
            mods: List.of(_mods),
            removedModIds: List.of(_removedModIds),
          ),
        );
  }

  bool _validateStep(BuildContext context) {
    String? error;
    switch (_step) {
      case 0:
        if (_cover == null && _existingCoverUrl == null) {
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
        } else if (_selectedFuelType == null) {
          error = 'Please select a fuel type.';
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

    final newMods = _mods.whereType<NewModSlot>().map((s) => s.input).toList();
    context.read<AddCarBloc>().add(
          SubmitNewCar(
            cover: _cover!,
            gallery: _gallery
                .whereType<LocalSlotImage>()
                .map((s) => s.image)
                .toList(),
            mods: newMods,
            car: _buildCarParams(),
          ),
        );
  }
}

/// Pill button used in the "discard build" confirmation dialog. Mirrors the
/// destructive/neutral styling used by the delete dialogs elsewhere.
class _CloseDialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _CloseDialogButton({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? Colors.red : AppColors.line,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDestructive ? Colors.white : AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
