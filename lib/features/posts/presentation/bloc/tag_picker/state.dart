import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/core/shared/entities/search_result.dart';
import 'package:car_social_media_app/features/garage/domain/entities/car_summary.dart';

enum TagLoadStatus { idle, loading, success, failure }

/// Drives the tags step: live people search results and the loaded garage of
/// the person whose car is being picked. The two concerns are independent —
/// people search feeds the typeahead, [ownerCars] feeds the car-picker sheet.
class TagPickerState extends Equatable {
  final TagLoadStatus peopleStatus;
  final List<SearchResultEntity> peopleResults;

  final TagLoadStatus carsStatus;
  final List<CarSummaryEntity> ownerCars;
  final String? ownerUsername;

  const TagPickerState({
    this.peopleStatus = TagLoadStatus.idle,
    this.peopleResults = const [],
    this.carsStatus = TagLoadStatus.idle,
    this.ownerCars = const [],
    this.ownerUsername,
  });

  TagPickerState copyWith({
    TagLoadStatus? peopleStatus,
    List<SearchResultEntity>? peopleResults,
    TagLoadStatus? carsStatus,
    List<CarSummaryEntity>? ownerCars,
    String? ownerUsername,
  }) {
    return TagPickerState(
      peopleStatus: peopleStatus ?? this.peopleStatus,
      peopleResults: peopleResults ?? this.peopleResults,
      carsStatus: carsStatus ?? this.carsStatus,
      ownerCars: ownerCars ?? this.ownerCars,
      ownerUsername: ownerUsername ?? this.ownerUsername,
    );
  }

  @override
  List<Object?> get props => [
        peopleStatus,
        peopleResults,
        carsStatus,
        ownerCars,
        ownerUsername,
      ];
}
