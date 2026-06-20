import 'dart:async';

import 'package:car_social_media_app/features/garage/domain/usecases/get_reference_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_car_categories.dart';
import '../../domain/usecases/get_cities.dart';
import '../../domain/usecases/get_community_roles.dart';
import '../../domain/usecases/get_countries.dart';
import '../../domain/usecases/submit_onboarding.dart';
import '../utils/onboarding_error_mapper.dart';
import 'event.dart';
import 'state.dart';

@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetCountriesUseCase getCountries;
  final GetCitiesUseCase getCities;
  final GetCommunityRolesUseCase getCommunityRoles;
  final GetCarCategoriesUseCase getCarCategories;
  final GetBrandsUseCase getBrands;
  final GetModelsByBrandUseCase getModelsByBrand;
  final SubmitOnboardingUseCase submitOnboarding;

  OnboardingBloc({
    required this.getCountries,
    required this.getCities,
    required this.getCommunityRoles,
    required this.getCarCategories,
    required this.getBrands,
    required this.getModelsByBrand,
    required this.submitOnboarding,
  }) : super(const OnboardingInitial()) {
    on<LoadOnboardingReferenceData>(_onLoadRefData);
    on<LoadCitiesForCountry>(_onLoadCities);
    on<LoadModelsForBrand>(_onLoadModels);
    on<SubmitOnboarding>(_onSubmit);
  }

  FutureOr<void> _onLoadRefData(
    LoadOnboardingReferenceData event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingRefLoading());

    final countriesResult = await getCountries(NoParams());
    final rolesResult = await getCommunityRoles(NoParams());
    final categoriesResult = await getCarCategories(NoParams());
    final brandsResult = await getBrands(NoParams());

    if (countriesResult.isLeft() ||
        rolesResult.isLeft() ||
        categoriesResult.isLeft() ||
        brandsResult.isLeft()) {
      emit(const OnboardingRefError(
          'Failed to load onboarding data. Please try again.'));
      return;
    }

    emit(
      OnboardingRefLoaded(
        countries: countriesResult.getOrElse(() => []),
        communityRoles: rolesResult.getOrElse(() => []),
        carCategories: categoriesResult.getOrElse(() => []),
        brands: brandsResult.getOrElse(() => []),
      ),
    );
  }

  FutureOr<void> _onLoadCities(
    LoadCitiesForCountry event,
    Emitter<OnboardingState> emit,
  ) async {
    final current = state;
    if (current is! OnboardingRefLoaded) return;
    // Already cached or in flight — nothing to do.
    if (current.citiesByCountry.containsKey(event.countryId)) return;
    if (current.loadingCitiesFor == event.countryId) return;

    emit(current.copyWith(loadingCitiesFor: event.countryId));

    final result = await getCities(GetCitiesParams(countryId: event.countryId));

    // Guard against the state having moved on (e.g. into submit) meanwhile.
    final latest = state;
    if (latest is! OnboardingRefLoaded) return;

    result.fold(
      (_) => emit(latest.copyWith(clearLoadingCities: true)),
      (cities) => emit(latest.copyWith(
        citiesByCountry: {...latest.citiesByCountry, event.countryId: cities},
        clearLoadingCities: true,
      )),
    );
  }

  FutureOr<void> _onLoadModels(
    LoadModelsForBrand event,
    Emitter<OnboardingState> emit,
  ) async {
    final current = state;
    if (current is! OnboardingRefLoaded) return;
    if (current.modelsByBrand.containsKey(event.brandId)) return;
    if (current.loadingModelsFor.contains(event.brandId)) return;

    emit(current.copyWith(
      loadingModelsFor: {...current.loadingModelsFor, event.brandId},
    ));

    final result = await getModelsByBrand(
      GetModelsByBrandParams(brandId: event.brandId),
    );

    final latest = state;
    if (latest is! OnboardingRefLoaded) return;

    final stillLoading = {...latest.loadingModelsFor}..remove(event.brandId);

    result.fold(
      (_) => emit(latest.copyWith(loadingModelsFor: stillLoading)),
      (models) => emit(latest.copyWith(
        modelsByBrand: {...latest.modelsByBrand, event.brandId: models},
        loadingModelsFor: stillLoading,
      )),
    );
  }

  FutureOr<void> _onSubmit(
    SubmitOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    final current = state;
    final refData = switch (current) {
      OnboardingRefLoaded() => current,
      OnboardingSubmitting(:final refData) => refData,
      OnboardingSubmitError(:final refData) => refData,
      _ => null,
    };
    if (refData == null) return;

    emit(OnboardingSubmitting(refData));

    final result = await submitOnboarding(event.params);

    result.fold(
      (failure) => emit(OnboardingSubmitError(
        refData: refData,
        message: OnboardingErrorMapper.getMessage(failure),
      )),
      (profile) => emit(OnboardingSubmitted(profile)),
    );
  }
}
