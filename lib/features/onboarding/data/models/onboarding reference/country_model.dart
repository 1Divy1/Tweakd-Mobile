import '../../../domain/entities/onboarding reference/country_entity.dart';

class CountryModel {
  final String id;
  final String name;

  const CountryModel({required this.id, required this.name});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  CountryEntity toEntity() => CountryEntity(id: id, name: name);
}
