import 'package:equatable/equatable.dart';

/// A city option. [region] is used client-side to group cities under a
/// Region picker; only [id] is sent to the backend.
class CityEntity extends Equatable {
  final String id;
  final String name;
  final String region;
  final String countryId;

  const CityEntity({
    required this.id,
    required this.name,
    required this.region,
    required this.countryId,
  });

  @override
  List<Object?> get props => [id, name, region, countryId];
}