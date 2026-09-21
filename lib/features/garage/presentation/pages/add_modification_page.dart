import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/car_summary.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/log_mod/bloc.dart';
import '../bloc/log_mod/event.dart';
import '../bloc/log_mod/state.dart';
import '../bloc/state.dart';
import '../utils/garage_error_mapper.dart';
import '../widgets/add_mod/add_mod_car_step.dart';
import '../widgets/register_car/build_log_entry_form.dart';
import '../widgets/register_car/mod_slot.dart';
import '../widgets/register_car/register_car_chrome.dart';
import '../widgets/register_car/register_car_fields.dart';
import '../widgets/register_car/register_discard_dialog.dart';
import '../widgets/register_car/register_toggle_tile.dart';

enum _AddModStep { car, details }

/// Logs a new modification against one of the viewer's cars, in the add-car
/// wizard's visual language and with its build-log form.
///
/// Opened two ways:
/// - from the create sheet, with no [carId] — the page loads the garage
///   (a [GarageBloc] is provided) and asks which car, unless there is only
///   one; with none it points at adding a car first;
/// - from a car's own page, with its [carId] — straight to the form.
///
/// Pops with `true` once the modification is saved.
class AddModificationPage extends StatefulWidget {
  final String? carId;

  const AddModificationPage({super.key, this.carId});

  @override
  State<AddModificationPage> createState() => _AddModificationPageState();
}

class _AddModificationPageState extends State<AddModificationPage> {
  final _form = GlobalKey<BuildLogEntryFormState>();
  final ImageService _imageService = getIt<ImageService>();

  String? _pickedCarId;
  int _stepIndex = 0;

  /// Whether the entry also goes to the feed. **On by default** — a build log
  /// nobody sees is worth less to everyone than one that becomes something to
  /// scroll, and the toggle is right there for anyone who would rather not.
  bool _shareToFeed = true;

  /// Whether [_shareToFeed] is still the default. Analytics only.
  bool _shareUntouched = true;

  /// Which car the entry is for: the one the page was opened for, the only one
  /// in the garage, or the one picked on the car step.
  String? _carIdFor(List<CarSummaryEntity>? cars) {
    if (widget.carId != null) return widget.carId;
    if (cars != null && cars.length == 1) return cars.single.id;
    return _pickedCarId;
  }

  /// The car step only earns its place when there is a choice to make.
  List<_AddModStep> _stepsFor(List<CarSummaryEntity>? cars) =>
      widget.carId == null && cars != null && cars.length > 1
          ? const [_AddModStep.car, _AddModStep.details]
          : const [_AddModStep.details];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final garage =
        widget.carId == null ? context.watch<GarageBloc>().state : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // System back walks back through the steps before it leaves.
        if (_stepIndex > 0) {
          setState(() => _stepIndex--);
        } else {
          _close();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: BlocConsumer<LogModBloc, LogModState>(
            listener: (context, state) {
              if (state is LogModSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.shareFailed
                        ? l10n.modShareFailed
                        : l10n.garageLogModLogged),
                  ),
                );
                Navigator.of(context).pop(true);
              }
              if (state is LogModError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(garageErrorMessage(l10n, state.code))),
                );
              }
            },
            builder: (context, modState) {
              final blocking = _blockingView(context, l10n, modState, garage);
              if (blocking != null) {
                return Column(
                  children: [
                    _topBar(),
                    Expanded(child: blocking),
                  ],
                );
              }

              final cars =
                  garage is GarageLoaded ? garage.garage.cars : null;
              return _wizard(context, l10n, modState, cars);
            },
          ),
        ),
      ),
    );
  }

  /// Whatever stands between the user and the form: loading, a failed load, or
  /// an empty garage. Null once the wizard can be shown.
  Widget? _blockingView(
    BuildContext context,
    AppLocalizations l10n,
    LogModState modState,
    GarageState? garage,
  ) {
    if (modState is LogModCategoriesError) {
      return RegisterRefDataError(
        message: garageErrorMessage(l10n, modState.code),
        onRetry: () =>
            context.read<LogModBloc>().add(const LoadModCategories()),
      );
    }
    if (garage is GarageError) {
      return RegisterRefDataError(
        message: garageErrorMessage(l10n, garage.code),
        onRetry: () => context.read<GarageBloc>().add(const LoadMyGarage()),
      );
    }
    if (garage is GarageLoaded && garage.garage.cars.isEmpty) {
      return AddModNoCarsView(onAddCar: _addCar);
    }
    final loading = modState is LogModInitial ||
        modState is LogModCategoriesLoading ||
        (garage != null && garage is! GarageLoaded);
    if (loading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    return null;
  }

  Widget _wizard(
    BuildContext context,
    AppLocalizations l10n,
    LogModState modState,
    List<CarSummaryEntity>? cars,
  ) {
    final steps = _stepsFor(cars);
    final index = _stepIndex.clamp(0, steps.length - 1);
    final carId = _carIdFor(cars);
    final isSubmitting = modState is LogModSubmitting;
    final categories = switch (modState) {
      LogModCategoriesLoaded(:final categories) => categories,
      LogModSubmitting(:final categories) => categories,
      LogModError(:final categories) => categories,
      _ => const <Never>[],
    };

    return Column(
      children: [
        _topBar(step: index, stepCount: steps.length),
        Expanded(
          // Both steps stay mounted, so stepping back to change the car keeps
          // everything already typed into the form.
          child: IndexedStack(
            index: index,
            sizing: StackFit.expand,
            children: [
              for (final step in steps)
                _scrollable(switch (step) {
                  _AddModStep.car => AddModCarStep(
                      cars: cars ?? const [],
                      selectedCarId: carId,
                      onSelect: (id) => setState(() => _pickedCarId = id),
                    ),
                  _AddModStep.details => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RegisterSectionHeader(
                          title: l10n.garageModSheetTitleAdd,
                        ),
                        const SizedBox(height: 20),
                        BuildLogEntryForm(
                          key: _form,
                          categories: categories,
                          imageService: _imageService,
                        ),
                        const SizedBox(height: 20),
                        RegisterToggleTile(
                          icon: Icons.auto_awesome_outlined,
                          title: l10n.modShareToFeedTitle,
                          badge: l10n.modShareToFeedBadge,
                          description: l10n.modShareToFeedBody,
                          value: _shareToFeed,
                          onChanged: (v) => setState(() {
                            _shareToFeed = v;
                            _shareUntouched = false;
                          }),
                        ),
                      ],
                    ),
                }),
            ],
          ),
        ),
        RegisterBottomBar(
          step: index,
          stepCount: steps.length,
          isSubmitting: isSubmitting,
          lastLabel: l10n.garageModAddToBuildLog,
          onBack: index > 0 ? () => setState(() => _stepIndex = index - 1) : null,
          onNext: () => _next(context, l10n, steps, index, carId),
        ),
      ],
    );
  }

  /// The X, with the progress bar under it once there is more than one step.
  Widget _topBar({int step = 0, int stepCount = 1}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: RegisterCloseButton(onTap: _close),
          ),
        ),
        if (stepCount > 1)
          RegisterStepProgress(step: step, stepCount: stepCount)
        else
          const SizedBox(height: 10),
      ],
    );
  }

  Widget _scrollable(Widget child) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: child,
        ),
      ),
    );
  }

  void _next(
    BuildContext context,
    AppLocalizations l10n,
    List<_AddModStep> steps,
    int index,
    String? carId,
  ) {
    FocusScope.of(context).unfocus();

    if (carId == null) {
      _snack(context, l10n.garageAddModPickCar);
      if (index != 0) setState(() => _stepIndex = 0);
      return;
    }
    if (steps[index] == _AddModStep.car) {
      setState(() => _stepIndex = index + 1);
      return;
    }

    final slot = _form.currentState?.compose();
    if (slot is! NewModSlot) {
      _snack(context, l10n.garageModValidation);
      return;
    }
    context.read<LogModBloc>().add(SubmitModification(
          carId: carId,
          input: slot.input,
          shareToFeed: _shareToFeed,
          shareIsDefault: _shareUntouched,
        ));
  }

  /// Adding a car happens on top of this flow; coming back reloads the garage
  /// so the new car can be picked straight away.
  Future<void> _addCar() async {
    await context.push('/garage/cars/add');
    if (mounted) context.read<GarageBloc>().add(const LoadMyGarage());
  }

  /// Leaving asks first only when the form holds something to lose.
  Future<void> _close() async {
    if (context.read<LogModBloc>().state is LogModSubmitting) return;
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

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
