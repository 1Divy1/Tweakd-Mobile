import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/onboarding reference/city_entity.dart';
import '../../../domain/entities/onboarding reference/country_entity.dart';
import '../onboarding_fields.dart';
import '../onboarding_pickers.dart';

const int kMinDiscoveryRadiusKm = 1;
const int kMaxDiscoveryRadiusKm = 100;

/// Step 5 — home base. Country and Region only narrow the City selection;
/// just the city id is submitted. Regions are derived from the loaded cities.
class LocationStep extends StatelessWidget {
  final List<CountryEntity> countries;
  final CountryEntity? selectedCountry;
  final List<CityEntity> cities;
  final bool citiesLoading;
  final String? selectedRegion;
  final CityEntity? selectedCity;
  final int radiusKm;
  final ValueChanged<CountryEntity> onSelectCountry;
  final ValueChanged<String> onSelectRegion;
  final ValueChanged<CityEntity> onSelectCity;
  final ValueChanged<int> onRadiusChanged;

  const LocationStep({
    super.key,
    required this.countries,
    required this.selectedCountry,
    required this.cities,
    required this.citiesLoading,
    required this.selectedRegion,
    required this.selectedCity,
    required this.radiusKm,
    required this.onSelectCountry,
    required this.onSelectRegion,
    required this.onSelectCity,
    required this.onRadiusChanged,
  });

  List<String> get _regions {
    final seen = <String>{};
    for (final city in cities) {
      if (city.region.isNotEmpty) seen.add(city.region);
    }
    final list = seen.toList()..sort();
    return list;
  }

  List<CityEntity> get _citiesInRegion => selectedRegion == null
      ? const []
      : cities.where((c) => c.region == selectedRegion).toList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final countrySelected = selectedCountry != null;
    final regionSelected = selectedRegion != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionHeader(
          title: l10n.onboardingLocationTitle,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Center(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  OnboardingFieldLabel(l10n.onboardingFieldCountry),
                  const SizedBox(height: 8),
                  OnboardingSelectorTile(
                    placeholder: l10n.onboardingSelectCountryPlaceholder,
                    value: selectedCountry?.name,
                    onTap: () => showOnboardingPicker<CountryEntity>(
                      context: context,
                      title: l10n.onboardingPickerCountry,
                      items: countries,
                      labelOf: (c) => c.name,
                      onSelected: onSelectCountry,
                      searchable: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OnboardingFieldLabel(l10n.onboardingFieldRegion),
                  const SizedBox(height: 8),
                  OnboardingSelectorTile(
                    placeholder: countrySelected
                        ? l10n.onboardingSelectRegionPlaceholder
                        : l10n.onboardingPickCountryFirst,
                    value: selectedRegion,
                    loading: citiesLoading,
                    enabled: countrySelected && _regions.isNotEmpty,
                    onTap: () => showOnboardingPicker<String>(
                      context: context,
                      title: l10n.onboardingPickerRegion,
                      items: _regions,
                      labelOf: (r) => r,
                      onSelected: onSelectRegion,
                      searchable: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OnboardingFieldLabel(l10n.onboardingFieldCity),
                  const SizedBox(height: 8),
                  OnboardingSelectorTile(
                    placeholder: regionSelected
                        ? l10n.onboardingSelectCityPlaceholder
                        : l10n.onboardingPickRegionFirst,
                    value: selectedCity?.name,
                    enabled: regionSelected && _citiesInRegion.isNotEmpty,
                    onTap: () => showOnboardingPicker<CityEntity>(
                      context: context,
                      title: l10n.onboardingPickerCity,
                      items: _citiesInRegion,
                      labelOf: (c) => c.name,
                      onSelected: onSelectCity,
                      searchable: true,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _RadiusCard(radiusKm: radiusKm),
                  const SizedBox(height: 6),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.accent,
                      inactiveTrackColor: AppColors.line,
                      thumbColor: AppColors.accent,
                      overlayColor: AppColors.accent.withAlpha(40),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: radiusKm.toDouble(),
                      min: kMinDiscoveryRadiusKm.toDouble(),
                      max: kMaxDiscoveryRadiusKm.toDouble(),
                      onChanged: (v) => onRadiusChanged(v.round()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RadiusCard extends StatelessWidget {
  final int radiusKm;
  const _RadiusCard({required this.radiusKm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.onboardingDiscoveryRadius,
                  style: TextStyle(
                    color: AppColors.muteSoft,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$radiusKm',
                        style: TextStyle(
                          color: AppColors.inkPanel,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: ' KM',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.my_location_rounded,
                color: AppColors.accent, size: 22),
          ),
        ],
      ),
    );
  }
}
