import 'package:tweakd/features/garage/domain/entities/reference_data.dart';
import 'package:tweakd/features/profile/domain/entities/profile.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/onboarding reference/city_entity.dart';
import '../../domain/entities/onboarding reference/country_entity.dart';
import '../utils/onboarding_error_mapper.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingRefLoading extends OnboardingState {
  const OnboardingRefLoading();
}

class OnboardingRefError extends OnboardingState {
  final OnboardingErrorCode code;
  const OnboardingRefError(this.code);

  @override
  List<Object?> get props => [code];
}

/// All reference data needed by the wizard. Countries and brands load once
/// up front; cities (per country) and models (per brand) are fetched lazily
/// and cached as the user drills in.
class OnboardingRefLoaded extends OnboardingState {
  final List<CountryEntity> countries;
  final List<CarBrandEntity> brands;

  final Map<String, List<CityEntity>> citiesByCountry;
  final Map<String, List<CarModelEntity>> modelsByBrand;

  /// Country id whose cities are currently being fetched, if any.
  final String? loadingCitiesFor;

  /// Brand ids whose models are currently being fetched.
  final Set<String> loadingModelsFor;

  /// Display name the sign-up provider supplied, used to prefill the name
  /// field once. Null when the provider gave none (email/password sign-up, or
  /// a returning Apple account), in which case the user types it.
  final String? suggestedFullName;

  const OnboardingRefLoaded({
    required this.countries,
    required this.brands,
    this.suggestedFullName,
    this.citiesByCountry = const {},
    this.modelsByBrand = const {},
    this.loadingCitiesFor,
    this.loadingModelsFor = const {},
  });

  OnboardingRefLoaded copyWith({
    Map<String, List<CityEntity>>? citiesByCountry,
    Map<String, List<CarModelEntity>>? modelsByBrand,
    String? loadingCitiesFor,
    bool clearLoadingCities = false,
    Set<String>? loadingModelsFor,
  }) {
    return OnboardingRefLoaded(
      countries: countries,
      brands: brands,
      suggestedFullName: suggestedFullName,
      citiesByCountry: citiesByCountry ?? this.citiesByCountry,
      modelsByBrand: modelsByBrand ?? this.modelsByBrand,
      loadingCitiesFor:
          clearLoadingCities ? null : (loadingCitiesFor ?? this.loadingCitiesFor),
      loadingModelsFor: loadingModelsFor ?? this.loadingModelsFor,
    );
  }

  @override
  List<Object?> get props => [
        countries,
        brands,
        suggestedFullName,
        citiesByCountry,
        modelsByBrand,
        loadingCitiesFor,
        loadingModelsFor,
      ];
}

/// Submit in flight. Carries the reference data so the wizard keeps rendering.
class OnboardingSubmitting extends OnboardingState {
  final OnboardingRefLoaded refData;
  const OnboardingSubmitting(this.refData);

  @override
  List<Object?> get props => [refData];
}

class OnboardingSubmitted extends OnboardingState {
  final ProfileEntity profile;
  const OnboardingSubmitted(this.profile);

  @override
  List<Object?> get props => [profile];
}

class OnboardingSubmitError extends OnboardingState {
  final OnboardingRefLoaded refData;
  final OnboardingErrorCode code;
  const OnboardingSubmitError({required this.refData, required this.code});

  @override
  List<Object?> get props => [refData, code];
}
