import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
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
    final countrySelected = selectedCountry != null;
    final regionSelected = selectedRegion != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingSectionHeader(
          label: '05 — LOCATION',
          title: 'Where’s home base?',
          subtitle: 'Used for local meets, events and marketplace finds — '
              'never shown publicly on your profile.',
        ),
        const SizedBox(height: 20),
        const OnboardingFieldLabel('COUNTRY'),
        const SizedBox(height: 8),
        OnboardingSelectorTile(
          placeholder: 'Select your country',
          value: selectedCountry?.name,
          onTap: () => showOnboardingPicker<CountryEntity>(
            context: context,
            title: 'Select country',
            items: countries,
            labelOf: (c) => c.name,
            onSelected: onSelectCountry,
            searchable: true,
          ),
        ),
        const SizedBox(height: 16),
        const OnboardingFieldLabel('REGION'),
        const SizedBox(height: 8),
        OnboardingSelectorTile(
          placeholder: countrySelected ? 'Select your region' : 'Pick a country first',
          value: selectedRegion,
          loading: citiesLoading,
          enabled: countrySelected && _regions.isNotEmpty,
          onTap: () => showOnboardingPicker<String>(
            context: context,
            title: 'Select region',
            items: _regions,
            labelOf: (r) => r,
            onSelected: onSelectRegion,
            searchable: true,
          ),
        ),
        const SizedBox(height: 16),
        const OnboardingFieldLabel('CITY'),
        const SizedBox(height: 8),
        OnboardingSelectorTile(
          placeholder: regionSelected ? 'Select your city' : 'Pick a region first',
          value: selectedCity?.name,
          enabled: regionSelected && _citiesInRegion.isNotEmpty,
          onTap: () => showOnboardingPicker<CityEntity>(
            context: context,
            title: 'Select city',
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
                const Text(
                  'DISCOVERY RADIUS',
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const TextSpan(
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
            child: const Icon(Icons.my_location_rounded,
                color: AppColors.accent, size: 22),
          ),
        ],
      ),
    );
  }
}
