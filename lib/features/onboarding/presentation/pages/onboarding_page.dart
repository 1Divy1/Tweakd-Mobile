import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/push_permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/dream_car_draft.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/entities/onboarding reference/city_entity.dart';
import '../../domain/entities/onboarding reference/country_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/state.dart';
import '../bloc/username_availability/bloc.dart';
import '../bloc/username_availability/state.dart';
import '../utils/username_validator.dart';
import '../widgets/onboarding_chrome.dart';
import '../widgets/steps/garage_step.dart';
import '../widgets/steps/identity_step.dart';
import '../widgets/steps/location_step.dart';
import '../widgets/steps/notifications_step.dart';
import '../widgets/steps/role_step.dart';
import '../widgets/steps/taste_step.dart';

/// One-time onboarding wizard. Every step's answers are held locally and sent
/// in one shot on the final step (mirrors the register-car flow) — nothing is
/// persisted until the user finishes.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with WidgetsBindingObserver {
  int _step = 0;

  // Step 1 — Identity
  final _usernameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  // Step 2 — Garage (dream cars). Start with one empty row.
  final List<DreamCarRow> _dreamCars = [DreamCarRow()];

  // Step 3 — Role
  final Set<String> _roleIds = {};

  // Step 4 — Taste
  final Set<String> _categoryIds = {};

  // Step 5 — Location
  CountryEntity? _country;
  String? _region;
  CityEntity? _city;
  int _radiusKm = 40;

  // Step 6 — Notifications
  NotificationPreferences _notifications = NotificationPreferences.defaults();

  // OS-level push permission, reflected by the banner on the Notifications step.
  final _pushPermissions = getIt<PushPermissionService>();
  PushPermission _pushPermission = PushPermission.canRequest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPushPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  /// The user may flip the permission in system settings while we're
  /// backgrounded (e.g. after tapping "OPEN SETTINGS"); re-read it on resume so
  /// the banner stays truthful.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPushPermission();
  }

  Future<void> _refreshPushPermission() async {
    final status = await _pushPermissions.current();
    if (mounted) setState(() => _pushPermission = status);
  }

  Future<void> _enablePush() async {
    final status = await _pushPermissions.request();
    if (mounted) setState(() => _pushPermission = status);
  }

  void _openPushSettings() => _pushPermissions.openSettings();

  OnboardingBloc get _bloc => context.read<OnboardingBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingSubmitted) {
          context.go('/profile');
        } else if (state is OnboardingSubmitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final refData = _refDataOf(state);
        final isSubmitting = state is OnboardingSubmitting;
        // Step 0 (Identity) needs no reference data; later steps do.
        final canProceed =
            !isSubmitting && (_step == 0 || refData != null);

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                OnboardingTopBar(
                  onBack: isSubmitting ? null : () => _onTopBack(context),
                ),
                OnboardingStepProgress(step: _step),
                Expanded(child: _body(context, state, refData)),
                OnboardingBottomBar(
                  step: _step,
                  isSubmitting: isSubmitting,
                  submitLabel: isSubmitting ? 'Finishing setup…' : null,
                  onBack: _step > 0 && !isSubmitting
                      ? () => setState(() => _step--)
                      : null,
                  onNext: canProceed ? () => _onNext(context, refData) : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    OnboardingState state,
    OnboardingRefLoaded? refData,
  ) {
    // Identity never depends on reference data.
    if (_step != 0) {
      if (state is OnboardingRefLoading) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        );
      }
      if (state is OnboardingRefError) {
        return _RefErrorView(
          message: state.message,
          onRetry: () => _bloc.add(const LoadOnboardingReferenceData()),
        );
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: _stepContent(refData),
    );
  }

  Widget _stepContent(OnboardingRefLoaded? refData) {
    switch (_step) {
      case 0:
        return IdentityStep(usernameCtrl: _usernameCtrl, bioCtrl: _bioCtrl);
      case 1:
        return GarageStep(
          rows: _dreamCars,
          brands: refData?.brands ?? const [],
          modelsByBrand: refData?.modelsByBrand ?? const {},
          loadingModelsFor: refData?.loadingModelsFor ?? const {},
          onAddRow: () => setState(() => _dreamCars.add(DreamCarRow())),
          onRemoveRow: (i) => setState(() => _dreamCars.removeAt(i)),
          onSelectBrand: _onSelectBrand,
          onToggleModel: _onToggleModel,
        );
      case 2:
        return RoleStep(
          roles: refData?.communityRoles ?? const [],
          selectedIds: _roleIds,
          onToggle: (id) => setState(() => _toggle(_roleIds, id)),
        );
      case 3:
        return TasteStep(
          categories: refData?.carCategories ?? const [],
          selectedIds: _categoryIds,
          onToggle: (id) => setState(() => _toggle(_categoryIds, id)),
        );
      case 4:
        final cities = _country == null
            ? const <CityEntity>[]
            : (refData?.citiesByCountry[_country!.id] ?? const []);
        return LocationStep(
          countries: refData?.countries ?? const [],
          selectedCountry: _country,
          cities: cities,
          citiesLoading:
              _country != null && refData?.loadingCitiesFor == _country!.id,
          selectedRegion: _region,
          selectedCity: _city,
          radiusKm: _radiusKm,
          onSelectCountry: _onSelectCountry,
          onSelectRegion: (region) => setState(() {
            _region = region;
            _city = null;
          }),
          onSelectCity: (city) => setState(() => _city = city),
          onRadiusChanged: (km) => setState(() => _radiusKm = km),
        );
      case 5:
        return NotificationsStep(
          prefs: _notifications,
          radiusKm: _radiusKm,
          onChanged: (prefs) => setState(() => _notifications = prefs),
          pushPermission: _pushPermission,
          onEnablePush: _enablePush,
          onOpenPushSettings: _openPushSettings,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 2 handlers ─────────────────────────────────────────────────────

  void _onSelectBrand(int index, CarBrandEntity brand) {
    setState(() {
      _dreamCars[index].brand = brand;
      _dreamCars[index].models = [];
    });
    _bloc.add(LoadModelsForBrand(brand.id));
  }

  void _onToggleModel(int index, CarModelEntity model) {
    setState(() {
      final models = _dreamCars[index].models;
      final existing = models.indexWhere((m) => m.id == model.id);
      if (existing >= 0) {
        models.removeAt(existing);
      } else {
        models.add(model);
      }
    });
  }

  // ── Step 5 handlers ─────────────────────────────────────────────────────

  void _onSelectCountry(CountryEntity country) {
    setState(() {
      _country = country;
      _region = null;
      _city = null;
    });
    _bloc.add(LoadCitiesForCountry(country.id));
  }

  void _toggle(Set<String> set, String id) {
    if (!set.remove(id)) set.add(id);
  }

  // ── Navigation & submit ───────────────────────────────────────────────

  void _onTopBack(BuildContext context) {
    if (_step > 0) {
      setState(() => _step--);
      return;
    }
    if (context.canPop()) context.pop();
  }

  void _onNext(BuildContext context, OnboardingRefLoaded? refData) {
    if (!_validateStep(context)) return;

    if (_step < onboardingStepCount - 1) {
      setState(() => _step++);
      return;
    }
    _submit(context);
  }

  bool _validateStep(BuildContext context) {
    String? error;
    switch (_step) {
      case 0:
        error = validateOnboardingUsername(_usernameCtrl.text.trim());
        if (error == null &&
            context.read<UsernameAvailabilityBloc>().state is UsernameTaken) {
          error = 'That handle is already taken. Try another one.';
        }
      case 1:
        break; // dream cars are optional
      case 2:
        if (_roleIds.isEmpty) error = 'Pick at least one role.';
      case 3:
        if (_categoryIds.length < kMinTasteCategories) {
          error = 'Pick at least $kMinTasteCategories category to continue.';
        }
      case 4:
        if (_city == null) error = 'Select your city to continue.';
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return false;
    }
    return true;
  }

  void _submit(BuildContext context) {
    // Re-check the required answers in case the user navigated back and
    // cleared one. Jump to the offending step rather than failing the call.
    final usernameError = validateOnboardingUsername(_usernameCtrl.text.trim());
    if (usernameError != null) {
      _jumpTo(context, 0, usernameError);
      return;
    }
    if (context.read<UsernameAvailabilityBloc>().state is UsernameTaken) {
      _jumpTo(context, 0, 'That handle is already taken. Try another one.');
      return;
    }
    if (_roleIds.isEmpty) {
      _jumpTo(context, 2, 'Pick at least one role.');
      return;
    }
    if (_categoryIds.length < kMinTasteCategories) {
      _jumpTo(context, 3, 'Pick at least $kMinTasteCategories category.');
      return;
    }
    if (_city == null) {
      _jumpTo(context, 4, 'Select your city.');
      return;
    }

    final bio = _bioCtrl.text.trim();
    _bloc.add(
      SubmitOnboarding(
        OnboardingSubmissionParams(
          username: _usernameCtrl.text.trim(),
          bio: bio.isEmpty ? null : bio,
          cityId: _city!.id,
          discoveryRadiusKm: _radiusKm,
          categoryIds: _categoryIds.toList(),
          roleIds: _roleIds.toList(),
          notifications: _notifications,
          dreamCars: _buildDreamCars(),
        ),
      ),
    );
  }

  /// Expands the dream-car rows into the flat list the backend expects: one
  /// entry per selected model, or a single brand-only entry when a row has a
  /// brand but no models. Rows without a brand are skipped.
  List<DreamCarEntity> _buildDreamCars() {
    final result = <DreamCarEntity>[];
    for (final row in _dreamCars) {
      final brand = row.brand;
      if (brand == null) continue;
      if (row.models.isEmpty) {
        result.add(DreamCarEntity(brandId: brand.id));
      } else {
        for (final model in row.models) {
          result.add(DreamCarEntity(brandId: brand.id, modelId: model.id));
        }
      }
    }
    return result;
  }

  void _jumpTo(BuildContext context, int step, String message) {
    setState(() => _step = step);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  OnboardingRefLoaded? _refDataOf(OnboardingState state) => switch (state) {
        OnboardingRefLoaded() => state,
        OnboardingSubmitting(:final refData) => refData,
        OnboardingSubmitError(:final refData) => refData,
        _ => null,
      };
}

class _RefErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RefErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppColors.muteSoft, size: 40),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mute, fontSize: 15),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
