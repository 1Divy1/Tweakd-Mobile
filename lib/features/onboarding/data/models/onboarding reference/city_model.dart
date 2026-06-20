import '../../../domain/entities/onboarding reference/city_entity.dart';

class CityModel {
  final String id;
  final String name;
  final String region;
  final String countryId;

  const CityModel({
    required this.id,
    required this.name,
    required this.region,
    required this.countryId,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String? ?? '',
      countryId: json['country_id'] as String? ?? '',
    );
  }

  CityEntity toEntity() =>
      CityEntity(id: id, name: name, region: region, countryId: countryId);
}
