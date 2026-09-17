import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/car_status_option.dart';
import '../../domain/entities/reference_data.dart';
import '../../domain/repositories/garage_repository.dart';
import '../bloc/add_car/bloc.dart';
import '../bloc/add_car/event.dart';
import '../bloc/add_car/state.dart';
import '../utils/garage_error_mapper.dart';
import '../widgets/register_car/editable_image.dart';
import '../widgets/register_car/gallery_step.dart';
import '../widgets/register_car/mod_slot.dart';
import '../widgets/register_car/mods_step.dart';
import '../widgets/register_car/register_car_chrome.dart';
import '../widgets/register_car/register_car_fields.dart';
import '../widgets/register_car/reorderable_photo_tile.dart';
import '../widgets/register_car/register_discard_dialog.dart';
import '../widgets/register_car/specs_step.dart';
import '../widgets/register_car/story_step.dart';
import 'build_log_entry_page.dart';
import '../../../../core/shared/layout/app_layout.dart';

/// Wizard step indices. Every technical figure lives on one tabbed specs
/// step; the build log follows it — it's the part owners care most about —
/// and all of the imagery is collected last, on the gallery step.
class _Step {
  static const specs = 0;
  static const buildLog = 1;
  static const story = 2;
  static const gallery = 3;
}

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
  final ImageService _imageService = getIt<ImageService>();

  int _step = _Step.specs;

  /// Which tab of the specs step is showing. Owned here rather than by
  /// [SpecsStep] so a failed validation can pull the user to the tab holding
  /// the missing field, and so the tab survives stepping away and back.
  SpecsTab _specsTab = SpecsTab.basics;

  /// Every step shares one scroll view, so moving between steps — or between
  /// specs tabs — has to put the user back at the top of the new content.
  final ScrollController _scrollCtrl = ScrollController();

  bool get _isEdit => widget.editCar != null;

  /// What the form held once it was ready (after an edit's seeding), so
  /// leaving only asks when something would actually be lost. Null until then.
  List<Object?>? _baseline;

  List<Object?> get _snapshot => [
        _selectedBrand?.id,
        _selectedModel?.id,
        _selectedFuelType?.id,
        _selectedDrivetrain?.id,
        _selectedColor?.id,
        _selectedDistanceUnit?.id,
        _selectedStatus?.id,
        for (final c in [
          _yearCtrl,
          _chassisCodeCtrl,
          _modelCodeCtrl,
          _hpCtrl,
          _torqueCtrl,
          _zeroToHundredCtrl,
          _weightCtrl,
          _displacementCtrl,
          _engineCodeCtrl,
          _mileageCtrl,
          _storyCtrl,
        ])
          c.text.trim(),
        _cover,
        _removedCover,
        '|', ..._gallery,
        '|', ..._removedGalleryKeys,
        '|', ..._mods,
        '|', ..._removedModIds,
      ];

  // Guards against a second image_picker request firing before the first
  // finishes — iOS throws PlatformException('multiple_request') otherwise.
  bool _isPicking = false;

  // Guards so the one-time seeding from [editCar] runs only once each.
  bool _seededSelections = false;
  bool _seededModel = false;

  // Identity
  CarBrandEntity? _selectedBrand;
  CarModelEntity? _selectedModel;
  final _yearCtrl = TextEditingController();
  final _chassisCodeCtrl = TextEditingController();
  final _modelCodeCtrl = TextEditingController();

  // Performance
  final _hpCtrl = TextEditingController();
  final _torqueCtrl = TextEditingController();
  final _zeroToHundredCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _displacementCtrl = TextEditingController();
  final _engineCodeCtrl = TextEditingController();
  CarFuelTypeOptionEntity? _selectedFuelType;

  // Configuration
  CarDrivetrainEntity? _selectedDrivetrain;
  CarColorEntity? _selectedColor;
  CarDistanceUnitEntity? _selectedDistanceUnit;
  final _mileageCtrl = TextEditingController();

  // Story
  CarStatusOptionEntity? _selectedStatus;
  final _storyCtrl = TextEditingController();

  // Gallery — the cover plus a mix of existing remote photos and new picks.
  CompressedImage? _cover;
  // Edit mode: the existing cover URL (shown until replaced) and whether an
  // existing cover should be deleted from R2 once a new cover is picked.
  String? _existingCoverUrl;
  bool _removedCover = false;
  final List<SlotImage> _gallery = [];
  // Edit mode: existing gallery R2 keys removed by the user (deleted from R2).
  final List<String> _removedGalleryKeys = [];

  // Build log — new mods to create + existing mods being edited.
  final List<ModSlot> _mods = [];
  // Edit mode: existing mod ids removed by the user (deleted on submit).
  final List<String> _removedModIds = [];

  @override
  void initState() {
    super.initState();
    final car = widget.editCar;
    if (car == null) {
      _baseline = _snapshot;
      return;
    }

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

    _existingCoverUrl = car.coverImage?.url;
    _gallery.addAll(car.gallery.map((g) => RemoteSlotImage(g.url, g.key)));
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
        keptBefore: m.beforeMedia,
        keptAfter: m.afterMedia,
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
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<AddCarBloc, AddCarState>(
      listener: (context, state) {
        if (state is AddCarRefDataLoaded) _seedSelections(context, state);
        if (state is AddCarSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  _isEdit ? l10n.garageChangesSaved : l10n.garageCarRegistered),
            ),
          );
          context.pop();
        }
        if (state is AddCarError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(garageErrorMessage(l10n, state.code))),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is AddCarSubmitting;
        final submitLabel = state is AddCarSubmitting
            ? addCarPhaseLabel(l10n, state.phase)
            : null;
        final refData = switch (state) {
          AddCarRefDataLoaded() => state,
          AddCarSubmitting(:final refData) => refData,
          AddCarError(:final refData) => refData,
          _ => null,
        };

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop || isSubmitting) return;
            // System back walks back through the steps before it leaves.
            if (_step > 0) {
              _goToStep(_step - 1);
            } else {
              _close();
            }
          },
          child: Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                RegisterStepProgress(step: _step, onBack: _close),
                if (state is AddCarRefDataLoading)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  )
                else if (state is AddCarRefDataError)
                  Expanded(
                    child: RegisterRefDataError(
                      message: garageErrorMessage(l10n, state.code),
                      onRetry: () => context
                          .read<AddCarBloc>()
                          .add(const LoadAddCarReferenceData()),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32) +
          AppLayout.inset(context, maxWidth: AppLayout.formWidth),
                      child: _stepContent(context, refData),
                    ),
                  ),
                RegisterBottomBar(
                  step: _step,
                  isSubmitting: isSubmitting,
                  submitLabel: submitLabel,
                  lastLabel: _isEdit
                      ? l10n.garageRegisterSave
                      : l10n.garageRegisterAddCar,
                  onBack: _step > 0 ? () => _goToStep(_step - 1) : null,
                  onNext:
                      refData != null ? () => _onNext(context, refData) : null,
                ),
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  Widget _stepContent(BuildContext context, AddCarRefDataLoaded? refData) {
    return switch (_step) {
      _Step.specs => SpecsStep(
          tab: _specsTab,
          onTabChanged: _showSpecsTab,
          selectedBrand: _selectedBrand,
          selectedModel: _selectedModel,
          models: refData?.models ?? [],
          modelsLoading: refData?.modelsLoading ?? false,
          brands: refData?.brands ?? [],
          yearCtrl: _yearCtrl,
          chassisCodeCtrl: _chassisCodeCtrl,
          modelCodeCtrl: _modelCodeCtrl,
          onSelectBrand: (brand) {
            setState(() {
              _selectedBrand = brand;
              _selectedModel = null;
            });
            context.read<AddCarBloc>().add(AddCarBrandSelected(brand.id));
          },
          onSelectModel: (m) => setState(() => _selectedModel = m),
          hpCtrl: _hpCtrl,
          torqueCtrl: _torqueCtrl,
          zeroToHundredCtrl: _zeroToHundredCtrl,
          weightCtrl: _weightCtrl,
          displacementCtrl: _displacementCtrl,
          engineCodeCtrl: _engineCodeCtrl,
          fuelTypeOptions: refData?.fuelTypeOptions ?? [],
          selectedFuelType: _selectedFuelType,
          onSelectFuelType: (f) => setState(() => _selectedFuelType = f),
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
      _Step.buildLog => ModsStep(
          mods: _mods,
          categories: refData?.modCategories ?? [],
          onAdd: () => _addModification(context, refData),
          onRemove: _removeMod,
          onEdit: _isEdit ? (i) => _editModification(context, refData, i) : null,
        ),
      _Step.story => StoryStep(
          statusOptions: refData?.statusOptions ?? [],
          selectedStatus: _selectedStatus,
          storyCtrl: _storyCtrl,
          onSelectStatus: (s) => setState(() => _selectedStatus = s),
        ),
      _Step.gallery => GalleryStep(
          images: _gallery,
          coverFilePath: _cover?.path,
          coverNetworkUrl: _existingCoverUrl,
          onPickCover: _pickCover,
          onAdd: _pickGalleryImages,
          onRemove: _removeGalleryImage,
          onReorder: _reorderGalleryImage,
        ),
      _ => const SizedBox.shrink(),
    };
  }

  /// Leaves the wizard, asking first when something entered would be lost.
  Future<void> _close() async {
    if (context.read<AddCarBloc>().state is AddCarSubmitting) return;
    final navigator = Navigator.of(context);
    final baseline = _baseline;
    if (baseline == null || listEquals(baseline, _snapshot)) {
      navigator.pop();
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final discard = await showRegisterDiscardDialog(
      context,
      title: _isEdit
          ? l10n.garageEditCarDiscardTitle
          : l10n.garageRegisterDiscardTitle,
      body: _isEdit
          ? l10n.garageEditCarDiscardBody
          : l10n.garageRegisterDiscardBody,
    );
    if (discard == true) navigator.pop();
  }

  /// Moves to [step] and returns the shared scroll view to the top, so the
  /// new step opens at its title rather than wherever the last one was left.
  void _goToStep(int step) {
    setState(() => _step = step);
    _scrollToTop();
  }

  void _showSpecsTab(SpecsTab tab) {
    if (tab == _specsTab) return;
    setState(() => _specsTab = tab);
    _scrollToTop();
  }

  void _scrollToTop() {
    if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(0);
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
        // Replacing an existing cover: flag it for deletion from R2 on submit
        // (the backend deletes by car id), and clear the network preview.
        if (_existingCoverUrl != null) {
          _removedCover = true;
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
    // The grid hides its add tile at the cap, but a multi-pick could still
    // blow past it in one go, so the picker is capped too.
    final remaining = maxGalleryPhotos - _gallery.length;
    if (remaining <= 0) return;

    _isPicking = true;
    try {
      final picker = ImagePicker();
      final files = await picker.pickMultiImage(limit: remaining);
      if (files.isEmpty) return;
      if (!mounted) return;
      setState(() => _gallery.addAll(
            // pickMultiImage's limit isn't honoured on every platform.
            files.take(remaining).map(
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
      // Existing photos must be deleted from R2 on submit (by their R2 key).
      if (removed is RemoteSlotImage) _removedGalleryKeys.add(removed.key);
    });
  }

  /// Drag-to-reorder from the gallery grid. This list's order is what gets
  /// written by `saveGalleryKeys`, and `car_gallery` has a `position` column
  /// the backend sorts on, so the order the user lands on is the order that
  /// comes back.
  void _reorderGalleryImage(int oldIndex, int newIndex) {
    setState(() => reorderInPlace(_gallery, oldIndex, newIndex));
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
    final result = await showBuildLogEntry(
      context,
      categories: refData.modCategories,
      imageService: _imageService,
    );
    if (result != null) {
      setState(() => _mods.add(result));
    }
  }

  /// Opens the build-log editor pre-filled to edit an existing mod, then
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

    final result = await showBuildLogEntry(
      context,
      categories: refData.modCategories,
      imageService: _imageService,
      initialMod: slot.original,
    );
    if (result != null) {
      setState(() => _mods[index] = result);
    }
  }

  void _onNext(BuildContext context, AddCarRefDataLoaded refData) {
    if (_step < registerStepCount - 1) {
      if (!_validateStep(context)) return;
      _goToStep(_step + 1);
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
      _baseline = _snapshot;
      // Trigger loading the models for the saved brand so we can match it.
      context.read<AddCarBloc>().add(AddCarBrandSelected(car.brandId));
    }

    if (!_seededModel && refData.models.isNotEmpty) {
      final model =
          _firstWhereOrNull(refData.models, (m) => m.id == car.modelId);
      if (model != null) {
        setState(() => _selectedModel = model);
        _seededModel = true;
        _baseline = _snapshot;
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
    if (!_validateSubmit(context)) return;

    context.read<AddCarBloc>().add(
          SubmitCarEdit(
            carId: widget.editCar!.id,
            car: _buildCarParams(),
            newCover: _cover,
            removedCover: _removedCover,
            gallery: List.of(_gallery),
            removedGalleryKeys: List.of(_removedGalleryKeys),
            mods: List.of(_mods),
            removedModIds: List.of(_removedModIds),
          ),
        );
  }

  /// The first missing required value across the specs tabs, paired with the
  /// tab it lives on. Ordered basics → power → config, so the user is walked
  /// through the gaps left to right.
  (SpecsTab, String)? _specsProblem(AppLocalizations l10n) {
    if (_selectedBrand == null) {
      return (SpecsTab.basics, l10n.garageValMake);
    } else if (_selectedModel == null) {
      return (SpecsTab.basics, l10n.garageValModel);
    } else if (_yearCtrl.text.trim().isEmpty) {
      return (SpecsTab.basics, l10n.garageValYear);
    } else if (_hpCtrl.text.trim().isEmpty) {
      return (SpecsTab.power, l10n.garageValHorsepower);
    } else if (_torqueCtrl.text.trim().isEmpty) {
      return (SpecsTab.power, l10n.garageValTorque);
    } else if (_weightCtrl.text.trim().isEmpty) {
      return (SpecsTab.power, l10n.garageValWeight);
    } else if (_displacementCtrl.text.trim().isEmpty) {
      return (SpecsTab.power, l10n.garageValDisplacement);
    } else if (_selectedFuelType == null) {
      return (SpecsTab.power, l10n.garageValFuelType);
    } else if (_selectedDrivetrain == null) {
      return (SpecsTab.config, l10n.garageValDrivetrain);
    } else if (_selectedColor == null) {
      return (SpecsTab.config, l10n.garageValColor);
    } else if (_selectedDistanceUnit == null) {
      return (SpecsTab.config, l10n.garageValMileageUnit);
    }
    return null;
  }

  bool _validateStep(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String? error;
    switch (_step) {
      case _Step.specs:
        final problem = _specsProblem(l10n);
        if (problem != null) {
          // A message about a field on a tab the user can't see would be a
          // dead end, so open that tab before complaining about it.
          _showSpecsTab(problem.$1);
          error = problem.$2;
        }
      case _Step.story:
        if (_selectedStatus == null) {
          error = l10n.garageValStatus;
        }
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return false;
    }
    return true;
  }

  /// Final gate before submitting. The cover now lives on the last step, so it
  /// is checked here rather than on the way out of an earlier one.
  bool _validateSubmit(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String? error;
    if (_cover == null && _existingCoverUrl == null) {
      error = l10n.garageValCoverPhoto;
    } else if (_selectedStatus == null) {
      error = l10n.garageValStatus;
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return false;
    }
    return true;
  }

  void _submit(BuildContext context) {
    if (!_validateSubmit(context)) return;

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
