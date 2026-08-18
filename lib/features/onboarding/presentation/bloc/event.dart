import 'package:equatable/equatable.dart';

import '../../domain/repositories/onboarding_repository.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the up-front reference data (countries and car brands).
class LoadOnboardingReferenceData extends OnboardingEvent {
  const LoadOnboardingReferenceData();
}

/// Fetches (and caches) the cities for [countryId] so the Region/City pickers
/// can be populated.
class LoadCitiesForCountry extends OnboardingEvent {
  final String countryId;
  const LoadCitiesForCountry(this.countryId);

  @override
  List<Object?> get props => [countryId];
}

/// Fetches (and caches) the models for [brandId] for a dream-car row.
class LoadModelsForBrand extends OnboardingEvent {
  final String brandId;
  const LoadModelsForBrand(this.brandId);

  @override
  List<Object?> get props => [brandId];
}

/// Commits the collected onboarding answers.
class SubmitOnboarding extends OnboardingEvent {
  final OnboardingSubmissionParams params;
  const SubmitOnboarding(this.params);

  @override
  List<Object?> get props => [params];
}
